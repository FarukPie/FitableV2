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
        
        browser = None
        try:
            async with async_playwright() as p:
                # STEALTH: Advanced Browser Launch Configuration
                browser = await p.chromium.launch(
                    headless=True, # Must be True for Render/Production
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
                    "fabric_composition": None,
                    "product_url": url,
                }

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
                    # Fallback: Try to glean info from URL if blocked
                    product_url_clean = url.split('?')[0]
                    inferred_name = product_url_clean.split('/')[-1].replace('-', ' ').title()
                    
                    data["product_name"] = inferred_name
                    data["brand"] = brand
                    # Wait, if we return here, finally block inside 'try' logic?
                    # Since we are inside the 'try' now, we need to ensure close happens.
                    # We can't return easily from inside async with without closing.
                    # Actually async_playwright context manager handles 'p', but browser needs closing?
                    # Yes.
                    
                    data["error"] = "Access Denied (Partial Data)"
                    return data

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
                elif brand == "Trendyol":
                    self._scrape_trendyol_specific(soup, data)
                    
                # 4. Generic Fallback (Last Resort)
                self._scrape_generic_fallback(soup, data)

                # 5. Extract Fabric (Post-processing check)
                if not data.get("fabric_composition"):
                    self._extract_fabric_composition(soup, data)
                
                print(f"Final Data: {data}")
                
                # SANITIZATION: Ensure no field is a list/dict, enabling safe JSON consumption
                for k, v in data.items():
                    if isinstance(v, list):
                        # If list, join or take first
                        data[k] = " ".join([str(x) for x in v]) if v else ""
                    elif isinstance(v, dict):
                         # If dict (unlikely for current schema but safety first), stringify
                         data[k] = str(v)
                    elif v is None:
                        data[k] = ""
                    else:
                        # Ensure string
                        data[k] = str(v)

                return data

        except Exception as e:
            print(f"Error scraping {url}: {e}")
            return {
                "brand": brand,
                "error": str(e),
                "product_url": url,
                 # Return bare minimum to avoid crashes downstream if possible
                "product_name": "Scraping Failed",
                "description": "", 
                "price": ""
            }
        finally:
            if browser:
                await browser.close()

    def _extract_image_url(self, img_entry, data):
        if isinstance(img_entry, str):
            data["image_url"] = img_entry
        elif isinstance(img_entry, dict):
            # Try common fields for ImageObject
            if "url" in img_entry:
                data["image_url"] = img_entry["url"]
            elif "contentUrl" in img_entry:
                data["image_url"] = img_entry["contentUrl"]
    
    def _extract_from_json_ld(self, json_data: Dict, data: Dict):
        # ... logic same as before, simplified for brevity in this thought trace ...
        # I will include the full logic in the tool call
        schema_type = json_data.get("@type")
        if schema_type == "Product":
            if not data["product_name"] and "name" in json_data:
                data["product_name"] = self._clean_text(json_data["name"])
            if not data["image_url"] and "image" in json_data:
                img = json_data["image"]
                if isinstance(img, list):
                     if img:
                         self._extract_image_url(img[0], data)
                else:
                    self._extract_image_url(img, data)
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

    def _scrape_trendyol_specific(self, soup, data):
        # Trendyol specific selectors
        if not data["product_name"]:
             # Often in h1.pr-new-br or .product-name
             for sel in ["h1.pr-new-br span", "h1.pr-new-br", ".product-name", "h1"]:
                 tag = soup.select_one(sel)
                 if tag:
                     data["product_name"] = self._clean_text(tag.get_text())
                     break
        
        if not data["price"]:
            # Often .prc-dsc, .prc-slg
             for sel in [".prc-dsc", ".prc-slg", ".product-price-container .price", ".pr-bx-w .prc-box-sll"]:
                 tag = soup.select_one(sel)
                 if tag:
                     data["price"] = self._clean_text(tag.get_text())
                     break
        
        if not data["image_url"]:
             # Often .base-product-image img
             tag = soup.select_one(".base-product-image img")
             if tag:
                 data["image_url"] = tag.get("src")

        # Extract Fit Advice (Orange Box)
        # Search for text "Kullanıcıların çoğu"
        # Since class names are dynamic/obfuscated, text search is safer.
        import re
        advice_tag = soup.find(string=re.compile("Kullanıcıların çoğu", re.IGNORECASE))
        if advice_tag:
            # Usually strict text in a span or p
            # "Kullanıcıların çoğu kendi bedenini almanızı öneriyor"
            data["fit_advice"] = self._clean_text(advice_tag.parent.get_text())

    def _scrape_generic_fallback(self, soup, data):
        if not data["product_name"]:
            tag = soup.find("title")
            if tag: data["product_name"] = self._clean_text(tag.get_text())

    def _extract_fabric_composition(self, soup, data):
        """
        Tries to find material info using Regex and Keywords.
        """
        # Common Turkey sites uses 'Materyal', 'İçerik', 'Kompozisyon', or 'Material'
        # We look for text nodes containing '%' patterns.
        
        candidates = []
        
        # 1. Search text nodes with '%' directly
        # Regex: Digit%... or %Digit...
        import re
        fabric_pattern = re.compile(r"(\d+\s?%\s?[A-Za-zığüşöçİĞÜŞÖÇ]+|%s?\d+\s?[A-Za-zığüşöçİĞÜŞÖÇ]+)", re.IGNORECASE)
        
        # Limit search to likely areas (body text, sidebars, lists)
        # Searching whole body might be slow but robust
        # Let's search specific keywords first
        
        keywords = ["Materyal", "Material", "Kompozisyon", "İçerik", "Composition", "Kumaş"]
        
        # Helper to scan text
        def scan_text(text):
            if not text: return
            matches = fabric_pattern.findall(text)
            if matches:
                # Join matches: "95% Pamuk", "5% Elastan" -> "95% Pamuk 5% Elastan"
                candidates.append(" ".join(matches))

        # Try to find specific sections
        for kw in keywords:
            # Find elements containing keyword
            elements = soup.find_all(string=re.compile(kw, re.IGNORECASE))
            for el in elements:
                # Check parent or next sibling for the actual value
                parent = el.parent
                if parent:
                    # Check parent's full text
                    scan_text(parent.get_text())
                    # Check next sibling
                    nxt = parent.find_next_sibling()
                    if nxt:
                        scan_text(nxt.get_text())
        
        # If no keywords found, try searching the description we already extracted
        if not candidates and data.get("description"):
            scan_text(data["description"])
            
        # If still nothing, brute force p and li tags (last resort, maybe risky)
        if not candidates:
            # Try finding any text with "Cotton", "Pamuk", "Elastan", "Polyester"
            material_terms = ["Pamuk", "Cotton", "Elastan", "Elastane", "Polyester", "Viskon", "Viscose", "Keten", "Linen"]
            for term in material_terms:
                 found = soup.find(string=re.compile(term, re.IGNORECASE))
                 if found:
                     scan_text(found.parent.get_text())
                     if candidates: break
                     
        if candidates:
            # Pick longest formatting or first unique
            # Simplest: Just take the longest string found that looks like a composition
            best_match = max(candidates, key=len)
            data["fabric_composition"] = self._clean_text(best_match)
