"""
Noor Athkar – FastAPI Backend (Local Development)

This server acts as a secure proxy for external APIs and a data
service for the Flutter client. API keys are read from a `.env`
file and never exposed to the client.

Endpoints:
  GET  /                          → Health check
  GET  /api/mosques/nearby        → Google Places proxy (nearby mosques)
  GET  /api/location/geocode      → Reverse-geocode (lat/lng → city/country)
  GET  /api/quran/juz/{number}    → Quran data for a single Juz

Run locally:
  cd backend
  pip install -r requirements.txt
  cp .env.example .env      # then fill in your keys
  uvicorn main:app --reload --port 8000
"""

import os
from typing import Optional

import httpx
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

# ── Load environment variables ────────────────────────────────────
load_dotenv()

# ── FastAPI app ───────────────────────────────────────────────────
app = FastAPI(
    title="Noor Athkar API",
    version="1.0.0",
    description="Secure proxy for Google Maps, Quran data, and more.",
)

# Allow the Flutter web app to call this server during development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Restrict in production
    allow_methods=["*"],
    allow_headers=["*"],
)

# Shared HTTP client (reused across requests for connection pooling)
http_client = httpx.AsyncClient(timeout=15.0)


# ══════════════════════════════════════════════════════════════════
# Health check
# ══════════════════════════════════════════════════════════════════

@app.get("/")
async def health_check():
    return {
        "status": "ok",
        "service": "Noor Athkar API",
        "version": "1.0.0",
    }


# ══════════════════════════════════════════════════════════════════
# 1.  Nearby Mosques  (Google Places API proxy)
# ══════════════════════════════════════════════════════════════════

class MosqueResult(BaseModel):
    name: str
    address: str
    lat: float
    lng: float
    rating: Optional[float] = None
    distance_label: Optional[str] = None


@app.get("/api/mosques/nearby", response_model=list[MosqueResult])
async def nearby_mosques(
    lat: float = Query(..., description="User latitude"),
    lng: float = Query(..., description="User longitude"),
    radius: int = Query(3000, description="Search radius in metres"),
):
    """Return mosques near the user via OpenStreetMap Overpass API."""
    url = "https://overpass-api.de/api/interpreter"
    query = f"""[out:json][timeout:15];(node["amenity"="place_of_worship"]["religion"="muslim"](around:{radius},{lat},{lng});way["amenity"="place_of_worship"]["religion"="muslim"](around:{radius},{lat},{lng});relation["amenity"="place_of_worship"]["religion"="muslim"](around:{radius},{lat},{lng}););out center;"""
    
    headers = {
        "User-Agent": "NoorAthkarApp/1.0 (contact@noorathkar.com)",
        "Accept": "application/json"
    }
    
    resp = await http_client.post(url, data={"data": query}, headers=headers)
    
    if resp.status_code != 200:
        raise HTTPException(status_code=502, detail=f"Overpass API error: {resp.status_code}")
    
    data = resp.json()
    elements = data.get("elements", [])
    
    results: list[MosqueResult] = []
    for place in elements:
        tags = place.get("tags", {})
        name = tags.get("name") or tags.get("name:ar") or tags.get("name:en") or "Mosque / مسجد"
        
        lat_val = place.get("lat") or place.get("center", {}).get("lat")
        lng_val = place.get("lon") or place.get("center", {}).get("lon")
        
        street = tags.get("addr:street", "")
        city = tags.get("addr:city", "")
        if street and city:
            address = f"{street}, {city}"
        elif street:
            address = street
        elif city:
            address = city
        else:
            address = ""
            
        if lat_val and lng_val:
            results.append(
                MosqueResult(
                    name=name,
                    address=address,
                    lat=lat_val,
                    lng=lng_val,
                    rating=None,
                )
            )
            
    return results


# ══════════════════════════════════════════════════════════════════
# 2.  Reverse Geocode  (lat/lng → City, Country)
# ══════════════════════════════════════════════════════════════════

class GeoResult(BaseModel):
    city: str
    country: str
    formatted: str


@app.get("/api/location/geocode", response_model=GeoResult)
async def reverse_geocode(
    lat: float = Query(...),
    lng: float = Query(...),
):
    """Convert coordinates to a human-readable city + country using Nominatim."""
    url = "https://nominatim.openstreetmap.org/reverse"
    params = {
        "lat": lat,
        "lon": lng,
        "format": "json",
        "addressdetails": 1,
    }
    headers = {
        "User-Agent": "NoorAthkarApp/1.0 (contact@noorathkar.com)"
    }

    resp = await http_client.get(url, params=params, headers=headers)
    
    if resp.status_code != 200:
        raise HTTPException(status_code=502, detail=f"Nominatim API error: {resp.status_code}")
        
    data = resp.json()
    address = data.get("address", {})
    
    city = address.get("city") or address.get("town") or address.get("village") or address.get("suburb") or ""
    country = address.get("country", "")
    formatted = data.get("display_name", "")

    if not city and not country:
        raise HTTPException(status_code=404, detail="Location not found")

    return GeoResult(
        city=city,
        country=country,
        formatted=formatted or f"{city}, {country}",
    )


# ══════════════════════════════════════════════════════════════════
# 3.  Quran Data  (proxy to Alquran.cloud)
# ══════════════════════════════════════════════════════════════════

class Ayah(BaseModel):
    number: int
    number_in_surah: int
    surah_number: int
    surah_name_ar: str
    surah_name_en: str
    text_ar: str
    page: int
    juz: int


@app.get("/api/quran/juz/{juz_number}", response_model=list[Ayah])
async def get_juz(juz_number: int):
    """Fetch all Ayahs for a given Juz (1-30) from Alquran.cloud."""
    if juz_number < 1 or juz_number > 30:
        raise HTTPException(status_code=400, detail="Juz must be 1–30")

    url = f"https://api.alquran.cloud/v1/juz/{juz_number}/ar.alafasy"
    resp = await http_client.get(url)
    data = resp.json()

    if data.get("code") != 200:
        raise HTTPException(status_code=502, detail="Quran API error")

    ayahs: list[Ayah] = []
    for a in data["data"]["ayahs"]:
        ayahs.append(
            Ayah(
                number=a["number"],
                number_in_surah=a["numberInSurah"],
                surah_number=a["surah"]["number"],
                surah_name_ar=a["surah"]["name"],
                surah_name_en=a["surah"]["englishName"],
                text_ar=a["text"],
                page=a["page"],
                juz=a["juz"],
            )
        )

    return ayahs


# ══════════════════════════════════════════════════════════════════
# Shutdown
# ══════════════════════════════════════════════════════════════════

@app.on_event("shutdown")
async def shutdown():
    await http_client.aclose()
