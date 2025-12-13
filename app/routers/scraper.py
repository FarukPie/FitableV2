from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, HttpUrl
from app.services.scraper import ProductScraper

router = APIRouter(
    prefix="/scraper",
    tags=["Scraper"]
)

class ScrapeRequest(BaseModel):
    url: str
    
    class Config:
        json_schema_extra = {
            "example": {
                "url": "https://www.zara.com/tr/tr/ornek-urun-linki.html"
            }
        }

@router.post("/scrape")
async def scrape_product(request: ScrapeRequest):
    scraper = ProductScraper()
    # Convert HttpUrl to string
    url_str = str(request.url)
    
    data = await scraper.scrape_product(url_str)
    
    if "error" in data:
        # Depending on requirements, we might want to return 400 or just the data with error
        # Here we'll return the data but log the error internally? 
        # Or better, let the client know something went wrong if critical fields are missing.
        # For now, return what we got.
        pass
        
    return data
