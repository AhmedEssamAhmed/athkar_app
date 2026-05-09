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
GOOGLE_MAPS_API_KEY = os.getenv("GOOGLE_MAPS_API_KEY", "")

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
    """Return mosques near the user via Google Places Nearby Search."""
    if not GOOGLE_MAPS_API_KEY:
        raise HTTPException(
            status_code=503,
            detail="GOOGLE_MAPS_API_KEY is not configured on the server.",
        )

    url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
    params = {
        "location": f"{lat},{lng}",
        "radius": radius,
        "type": "mosque",
        "key": GOOGLE_MAPS_API_KEY,
    }

    resp = await http_client.get(url, params=params)
    data = resp.json()

    if data.get("status") not in ("OK", "ZERO_RESULTS"):
        raise HTTPException(status_code=502, detail=data.get("status"))

    results: list[MosqueResult] = []
    for place in data.get("results", []):
        loc = place["geometry"]["location"]
        results.append(
            MosqueResult(
                name=place.get("name", ""),
                address=place.get("vicinity", ""),
                lat=loc["lat"],
                lng=loc["lng"],
                rating=place.get("rating"),
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
    """Convert coordinates to a human-readable city + country."""
    if not GOOGLE_MAPS_API_KEY:
        raise HTTPException(
            status_code=503,
            detail="GOOGLE_MAPS_API_KEY is not configured on the server.",
        )

    url = "https://maps.googleapis.com/maps/api/geocode/json"
    params = {
        "latlng": f"{lat},{lng}",
        "result_type": "locality|country",
        "key": GOOGLE_MAPS_API_KEY,
    }

    resp = await http_client.get(url, params=params)
    data = resp.json()

    city = ""
    country = ""
    formatted = ""

    for result in data.get("results", []):
        for comp in result.get("address_components", []):
            types = comp.get("types", [])
            if "locality" in types:
                city = comp["long_name"]
            if "country" in types:
                country = comp["long_name"]
        if not formatted:
            formatted = result.get("formatted_address", "")

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
