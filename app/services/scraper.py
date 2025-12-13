import re
import json
import asyncio
import random
from typing import Dict, Optional
from playwright.async_api import async_playwright
from bs4 import BeautifulSoup

class ProductScraper:
    @staticmethod
    def _detect_brand(url: str) -> str:
        try:
            from urllib.parse import urlparse
            parsed = urlparse(url)
            domain = parsed.netloc
            parts = domain.split('.')
            
            # Common subdomains to ignore
            ignore_parts = {'www', 'www2', 'shop', 'store', 'm', 'tr', 'com', 'org', 'net'}
            
            # Find the first part that is NOT in the ignore list and is NOT a TLD (short heuristic)
            # Actually, the brand is usually the first "main" word. 
            # Let's try to remove known prefixes.
            while parts and parts[0] in {'www', 'www2', 'shop', 'store', 'm'}:
                parts.pop(0)
            
            if parts:
                return parts[0].capitalize()
            return "Unknown"
        except:
            return "Unknown"

    @staticmethod
    def _clean_text(text: Optional[str]) -> str:
        if not text:
            return ""
        return text.strip().replace('\n', ' ').replace('\r', '')

    async def scrape_product(self, url: str) -> Dict[str, str]:
        brand = self._detect_brand(url)
        print(f"--- Scraping URL: {url} (Brand: {brand}) ---")
        
        async with async_playwright() as p:
            # STEALTH: Advanced Browser Launch Configuration
            browser = await p.chromium.launch(
                headless=False, # Must be False to bypass anti-bot
                args=[
                    "--disable-blink-features=AutomationControlled",
                    "--no-sandbox",
                    "--disable-setuid-sandbox",
                    "--disable-infobars",
                    "--window-position=-2400,-2400", # Hide window off-screen
                    "--ignore-certificate-errors",
                    "--ignore-ssl-errors",
                    "--disable-accelerated-2d-canvas",
                    "--disable-gpu",
                ]
            )
            
            # STEALTH: Real User-Agent and Viewport
            context = await browser.new_context(
                user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
                locale="tr-TR,tr;q=0.9,en-US;q=0.8,en;q=0.7", # Localized
                viewport={"width": 1920, "height": 1080},
                device_scale_factor=1,
                has_touch=False,
                is_mobile=False,
                bypass_csp=True
            )
            
            # STEALTH: Manual Injection of Evasion Scripts (Replacing playwright-stealth)
            await context.add_init_script("""
                // Override navigator.webdriver
                Object.defineProperty(navigator, 'webdriver', {
                    get: () => undefined
                });

                // Mock navigator.plugins and mimeTypes (Generic Chrome)
                Object.defineProperty(navigator, 'plugins', {
                    get: () => [1, 2, 3, 4, 5],
                });
                Object.defineProperty(navigator, 'languages', {
                    get: () => ['en-US', 'en'],
                });

                // Mock window.chrome
                window.chrome = {
                    runtime: {}
                };

                // Pass WebGL checks
                const getParameter = WebGLRenderingContext.prototype.getParameter;
                WebGLRenderingContext.prototype.getParameter = function(parameter) {
                    if (parameter === 37445) {
                        return 'Intel Open Source Technology Center';
                    }
                    if (parameter === 37446) {
                        return 'Mesa DRI Intel(R) Ivybridge Mobile ';
                    }
                    return getParameter(parameter);
                };
                
                // Permission Fix
                const originalQuery = window.navigator.permissions.query;
                window.navigator.permissions.query = (parameters) => (
                    parameters.name === 'notifications' ?
                        Promise.resolve({ state: Notification.permission }) :
                        originalQuery(parameters)
                );
            """)
            
            page = await context.new_page()

            data = {
                "brand": brand,
                "product_name": "",
                "price": "",
                "image_url": "",
                "description": "",
                "product_url": url,
            }

            try:
                # STEALTH: Random navigation delay
                await asyncio.sleep(random.uniform(1.0, 3.0))
                
                await page.goto(url, wait_until="domcontentloaded", timeout=60000)
                
                # STEALTH: Simulate human behavior (micro-movements and delays)
                await page.mouse.move(random.randint(100, 500), random.randint(100, 500))
                await asyncio.sleep(random.uniform(2.0, 5.0)) # Wait for React/Anti-bot to settle
                
                content = await page.content()
                
                # ANTI-BOT DETECTION
                if "Access Denied" in content or "Access to this page has been denied" in content:
                    print("Anti-Bot Detected: Access Denied")
                    # Fallback to simple extraction if blocked, sometimes content is still there?
                    # No, usually it's just a block page. 
                    # We will raise error to let user know.
                    raise Exception("Anti-Bot Detected: Access Denied (Try restarting backend or waiting)")

                # Wait for key elements to ensure render
                try:
                    await page.wait_for_selector("h1", timeout=5000)
                except:
                    print("Timeout waiting for h1, proceeding with DOM content.")

                soup = BeautifulSoup(content, 'html.parser')
                print(f"Page Title: {soup.title.string if soup.title else 'No Title'}")

                # 1. JSON-LD
                json_ld_tags = soup.find_all("script", type="application/ld+json")
                print(f"Found {len(json_ld_tags)} JSON-LD tags")
                for tag in json_ld_tags:
                    try:
                        structured_data = json.loads(tag.string)
                        if isinstance(structured_data, list):
                            for item in structured_data:
                                self._extract_from_json_ld(item, data)
                        else:
                            self._extract_from_json_ld(structured_data, data)
                    except json.JSONDecodeError:
                        continue
                
                print(f"After JSON-LD: {data}")

                # 2. Meta Tags Fallback
                self._extract_meta(soup, data)
                
                # 3. Specific Selectors
                if brand == "Zara":
                    self._scrape_zara_specific(soup, data)
                    
                # 4. Generic Fallback (Last Resort)
                self._scrape_generic_fallback(soup, data)

                print(f"Final Data: {data}")
                return data

            except Exception as e:
                print(f"Error scraping {url}: {e}")
                data["error"] = str(e)
                # If bot detected, we might return partial data or empty
                return data
            finally:
                await browser.close()

    def _extract_from_json_ld(self, json_data: Dict, data: Dict):
        # ... logic same as before, simplified for brevity in this thought trace ...
        # I will include the full logic in the tool call
        schema_type = json_data.get("@type")
        if schema_type == "Product":
            if not data["product_name"] and "name" in json_data:
                data["product_name"] = self._clean_text(json_data["name"])
            if not data["image_url"] and "image" in json_data:
                img = json_data["image"]
                data["image_url"] = img[0] if isinstance(img, list) else img
            if not data["description"] and "description" in json_data:
                data["description"] = self._clean_text(json_data["description"])
            if not data["price"] and "offers" in json_data:
                offers = json_data["offers"]
                price_val = None
                currency = "TL"
                if isinstance(offers, list):
                    price_val = offers[0].get("price")
                    currency = offers[0].get("priceCurrency", "TL")
                elif isinstance(offers, dict):
                    price_val = offers.get("price")
                    currency = offers.get("priceCurrency", "TL")
                if price_val:
                    data["price"] = f"{price_val} {currency}"

    def _extract_meta(self, soup, data):
        if not data["product_name"]:
            tag = soup.find("meta", property="og:title")
            if tag: data["product_name"] = self._clean_text(tag.get("content"))
        if not data["image_url"]:
            tag = soup.find("meta", property="og:image")
            if tag: data["image_url"] = tag.get("content")
        if not data["description"]:
            tag = soup.find("meta", property="og:description")
            if tag: data["description"] = self._clean_text(tag.get("content"))

    def _scrape_zara_specific(self, soup, data):
        # Zara CSS classes often change. Trying multiple variations.
        if not data["product_name"]:
            # Try new Zara selectors
            for sel in ["h1.product-detail-info__header-name", ".product-detail-info__name", "h1"]:
                tag = soup.select_one(sel)
                if tag: 
                    data["product_name"] = self._clean_text(tag.get_text())
                    break
        
        if not data["price"]:
            for sel in [".price-current__amount", ".money-amount__main", ".price__amount", ".product-detail-info__price-amount"]:
                tag = soup.select_one(sel)
                if tag:
                    data["price"] = self._clean_text(tag.get_text())
                    break

    def _scrape_generic_fallback(self, soup, data):
        if not data["product_name"]:
            tag = soup.find("title")
            if tag: data["product_name"] = self._clean_text(tag.get_text())
