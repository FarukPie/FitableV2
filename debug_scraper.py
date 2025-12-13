import asyncio
import json
from app.services.scraper import ProductScraper

async def run_debug():
    url = "https://www.zara.com/tr/tr/basic-pamuklu-t-shirt-p00858800.html"
    print(f"DEBUG: Starting scrape for {url}")
    
    scraper = ProductScraper()
    result = await scraper.scrape_product(url)
    
    print("\n--- DEBUG RESULT ---")
    print(json.dumps(result, indent=2, ensure_ascii=False))
    
    with open("debug_output.json", "w", encoding="utf-8") as f:
        json.dump(result, f, indent=2, ensure_ascii=False)

if __name__ == "__main__":
    asyncio.run(run_debug())
