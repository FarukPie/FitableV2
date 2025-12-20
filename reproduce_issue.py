
import asyncio
from app.services.scraper import ProductScraper
import sys

# Windows Proactor Event Loop Fix
if sys.platform == 'win32':
    asyncio.set_event_loop_policy(asyncio.WindowsProactorEventLoopPolicy())

async def test_scrape():
    scraper = ProductScraper()
    url = "https://voidtr.com/void-premium-oversize-basic-t-shirt?Beden=S&Renk=Siyah"
    print(f"Testing URL: {url}")
    try:
        data = await scraper.scrape_product(url)
        print("Scrape Result:", data)
    except Exception as e:
        print(f"Scrape Failed: {e}")

if __name__ == "__main__":
    asyncio.run(test_scrape())
