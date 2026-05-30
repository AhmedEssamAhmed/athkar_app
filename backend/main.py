"""
Noor Athkar – FastAPI Backend

Serves as a proxy for external APIs used by the Flutter client.
API keys are read from a `.env` file and never exposed to the client.

Endpoints:
  GET  /                          → Health check
  GET  /api/mosques/nearby        → Overpass API proxy (nearby mosques)

Run locally:
  cd backend
  pip install -r requirements.txt
  cp .env.example .env      # then fill in your keys
  uvicorn main:app --reload --port 8000
"""

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
# TODO: Restrict to specific origins before production deployment,
# e.g. allow_origins=["https://noorathkar.com", "https://www.noorathkar.com"]
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Shared HTTP client (reused across requests for connection pooling)
http_client = httpx.AsyncClient(timeout=30.0)


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
    urls = [
        "https://overpass-api.de/api/interpreter",
        "https://overpass.kumi.systems/api/interpreter",
        "https://lz4.overpass-api.de/api/interpreter"
    ]
    query = f"""[out:json][timeout:25];(node["amenity"="place_of_worship"]["religion"="muslim"](around:{radius},{lat},{lng});way["amenity"="place_of_worship"]["religion"="muslim"](around:{radius},{lat},{lng});relation["amenity"="place_of_worship"]["religion"="muslim"](around:{radius},{lat},{lng}););out center;"""
    
    headers = {
        "User-Agent": "NoorAthkarApp/1.0 (contact@noorathkar.com)",
        "Accept": "application/json"
    }
    
    data = None
    for url in urls:
        try:
            resp = await http_client.post(url, data={"data": query}, headers=headers)
            if resp.status_code == 200:
                data = resp.json()
                break
        except httpx.RequestError:
            continue
            
    if not data:
        raise HTTPException(status_code=502, detail="Overpass API error: All endpoints timed out")
    
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
# Shutdown
# ══════════════════════════════════════════════════════════════════

@app.on_event("shutdown")
async def shutdown():
    await http_client.aclose()
