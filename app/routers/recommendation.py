from typing import Dict, Any
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel, HttpUrl

from app.core.config import supabase
from app.services.scraper import ProductScraper
from app.services.recommendation import SizeRecommender

router = APIRouter(
    prefix="/recommendation",
    tags=["Recommendation"]
)

class RecommendationRequest(BaseModel):
    user_id: str
    url: str 
    
    class Config:
        json_schema_extra = {
            "example": {
                "user_id": "123e4567-e89b-12d3-a456-426614174000",
                "url": "https://www.zara.com/tr/tr/ornek-urun-linki.html"
            }
        }

@router.post("/recommend")
async def get_recommendation(request: RecommendationRequest) -> Dict[str, Any]:
    # 1. Scrape Product Data
    scraper = ProductScraper()
    url_str = str(request.url)
    product_data = await scraper.scrape_product(url_str)
    
    if product_data.get("error"):
         # We might still proceed if partial data is there, or fail.
         # For now, if no brand detected, recommendation might fail.
         pass

    # 2. Get Recommendation
    recommender = SizeRecommender(supabase)
    recommendation = recommender.get_recommendation(request.user_id, product_data)
    
    # 3. Save to History (Removed: Now manual)
    # logic moved to POST /history/add


    # 4. Combine Response
    return {
        "product": product_data,
        "recommendation": recommendation
    }
