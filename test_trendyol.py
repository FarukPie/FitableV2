import asyncio
from app.services.scraper import ProductScraper

async def main():
    scraper = ProductScraper()
    # Example Trendyol URL (Generic example, or I can search for a real one if needed, but the user provided one in the prompt logs)
    # The log showed: https://www.trendyol.com/madmext/siyah-polo-yaka-fermuarli-orme-kazak-7242-p-848172886?boutiqueId=61&merchantId=105292
    url = "https://www.trendyol.com/madmext/siyah-polo-yaka-fermuarli-orme-kazak-7242-p-848172886" 
    
    print(f"Testing Scraper with URL: {url}")
    data = await scraper.scrape_product(url)
    
    print("\n--- Scraped Data ---")
    for k, v in data.items():
        print(f"{k} ({type(v).__name__}): {v}")

if __name__ == "__main__":
    asyncio.run(main())
