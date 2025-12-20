import re
import json
import asyncio
import random
from typing import Dict, Optional
from playwright.async_api import async_playwright
from bs4 import BeautifulSoup

class ProductScraper:
    # Concurrency Control: Limit to 1 concurrent browser to prevent OOM
    _semaphore = asyncio.Semaphore(1)
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
                capitalized = parts[0].capitalize()
                # Normalization for Pull&Bear
                if "pullandbear" in capitalized.lower():
                    return "Pullandbear"
                return capitalized
            return "Unknown"
        except:
            return "Unknown"

    @staticmethod
    def _clean_text(text: Optional[str]) -> str:
        if not text:
            return ""
        return text.strip().replace('\n', ' ').replace('\r', '')

    @staticmethod
    def _resolve_short_link(url: str) -> str:
        """Resolves short links (like ty.gl) to their final destination."""
        try:
            import urllib.request
            req = urllib.request.Request(
                url, 
                headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'}
            )
            with urllib.request.urlopen(req, timeout=10) as response:
                return response.geturl()
        except Exception as e:
            print(f"Short link resolution failed for {url}: {e}")
            return url

    async def scrape_product(self, url: str) -> Dict[str, str]:
        # Wrapper to enforce concurrency limit
        async with self._semaphore:
            # Pre-resolve short links (ty.gl)
            if "ty.gl" in url:
                try:
                    resolved_url = await asyncio.to_thread(self._resolve_short_link, url)
                    if resolved_url:
                        url = resolved_url
                except Exception:
                    pass
            
            return await self._scrape_product_impl(url)

    async def _scrape_product_impl(self, url: str) -> Dict[str, str]:
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
                        "--disable-dev-shm-usage", # CRITICAL for Docker integration
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

                # RESOURCE OPTIMIZATION: Block unnecessary resources
                # Relaxed: Allowing images to prevent layout issues/bot detection
                await page.route("**/*", lambda route: route.abort() 
                    if route.request.resource_type in ["stylesheet", "font", "media"] 
                    else route.continue_()
                )

                # STEALTH: Optimized for speed - Minimal delay
                await asyncio.sleep(random.uniform(0.1, 0.3))
                
                # Reduced timeout to 30s to fail faster and release resources
                try:
                    await page.goto(url, wait_until="domcontentloaded", timeout=30000)
                    # CAPTURE FINAL URL (Crucial for short links like ty.gl)
                    data["product_url"] = page.url 
                except Exception as e:
                    print(f"Navigation Timeout/Error: {e}")
                    # Try to capture URL even if timeout occurred (might have redirected)
                    try: 
                        if page.url != "about:blank":
                            data["product_url"] = page.url
                    except: pass
                    # Continue to try scraping whatever loaded
                    pass
                
                # STEALTH: Simulate human behavior (micro-movements and delays)
                try:
                    await page.mouse.move(random.randint(100, 500), random.randint(100, 500))
                except: pass
                await asyncio.sleep(random.uniform(0.5, 0.8)) # Minimal wait for load
                
                content = await page.content()
                
                # ANTI-BOT DETECTION
                if "Access Denied" in content or "Access to this page has been denied" in content:
                    print("Anti-Bot Detected: Access Denied")
                    # Fallback: Try to glean info from URL if blocked
                    # Use resolved URL if available
                    final_url = data.get("product_url", url)
                    product_url_clean = final_url.split('?')[0]
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
                elif brand == "Pullandbear":
                    self._scrape_pullandbear_specific(soup, data)
                    
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
                
                # FINAL CLEANUP: Product Name
                # User wants to remove .html, .htm, and potential SKU codes from the name
                if data["product_name"]:
                    from urllib.parse import unquote
                    name = unquote(data["product_name"]) # Decode URL encoding (e.g., %C4%B1 -> ı)
                    
                    # 1. Remove .html / .htm extension
                    name = re.sub(r'\.html?$', '', name, flags=re.IGNORECASE)
                    
                    # 2. General cleanup of common URL separators/noise if we fell back to URL
                    name = name.replace("-", " ").replace("_", " ")
                    
                    # 3. Remove trailing SKU-like patterns (e.g. P06019390, 8484/123, L07550518)
                    # Expanded Regex: 
                    # - Space + [A-Z0-9]+ (at least 5 chars) at end
                    # - Space + Digit-Digit pattern (REF codes)
                    name = re.sub(r'\s+[A-Z0-9]{5,}$', '', name)
                    name = re.sub(r'\s+\d+/\d+/?$', '', name) # Reference codes like 8484/123
                    
                    # 4. Remove purely numeric trailing words (often prices or IDs stuck to name)
                    name = re.sub(r'\s+\d+$', '', name)

                    # 5. Remove "Fiyatı, Yorumları" and similar suffixes (Trendyol/Search optimization)
                    # Core pattern: Fiyatı, Yorumları, Fiyatı ve Yorumları, etc.
                    # Handle comma, dash, space separators.
                    cleaning_pattern = r'\s+(?:Fiyatı|Yorumları|Özellikleri|Kullananlar)(?:[,\s\-]*(?:Fiyatı|Yorumları|Özellikleri|Kullananlar))*\s*$'
                    name = re.sub(cleaning_pattern, '', name, flags=re.IGNORECASE)

                    # 5. Capitalize nicely
                    name = name.strip()
                    # Fix artifacts like repeated spaces
                    name = re.sub(r'\s+', ' ', name)
                    
                    data["product_name"] = name.title() # Ensure nice casing

                return data

        except Exception as e:
            print(f"Error scraping {url}: {e}")
            
            # Fallback: Extract from URL
            try:
                # Try to retrieve resolved URL if data exists
                final_url = url
                if 'data' in locals() and isinstance(data, dict):
                     final_url = data.get("product_url", url)
                
                product_url_clean = final_url.split('?')[0]
                inferred_name = product_url_clean.split('/')[-1].replace('-', ' ').title()
                # Remove common extensions/ids
                inferred_name = re.sub(r'\.html?$', '', inferred_name, flags=re.IGNORECASE)
                inferred_name = re.sub(r'\s+[A-Z0-9]{5,}$', '', inferred_name) # Remove SKUs
            except:
                inferred_name = "Ürün (Detaylar Alınamadı)"

            return {
                "brand": brand,
                "error": str(e),
                "product_url": url,
                 # Improved Fallback Name
                "product_name": inferred_name,
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
        
        # Zara Image Extraction
        if not data["image_url"]:
             # Zara often uses picture tags or lazy loaded images in a list
             # 1. Main Media Image
             for sel in [".media-image__image", "img.media-image__image", ".product-detail-view__main-image", "ul.product-detail-images__list img"]:
                 tag = soup.select_one(sel)
                 if tag and tag.get("src"):
                     data["image_url"] = tag.get("src")
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
             # Added: .gallery-container img, .product-slide img for better coverage
             for sel in [".base-product-image img", ".gallery-container img", ".product-slide img", ".gallery-modal-content img"]:
                 tag = soup.select_one(sel)
                 if tag:
                     src = tag.get("src")
                     if src:
                        data["image_url"] = src
                        break

    def _scrape_pullandbear_specific(self, soup, data):
        # Pull & Bear Specific Selectors
        if not data["product_name"]:
             for sel in ["h1.product-name", ".product-detail-info__name", "h1", ".pdp-title"]:
                 tag = soup.select_one(sel)
                 if tag:
                     data["product_name"] = self._clean_text(tag.get_text())
                     break
        
        if not data["price"]:
             for sel in [".price-current", ".product-detail-info__price", ".price__amount", ".current-price"]:
                 tag = soup.select_one(sel)
                 if tag:
                     data["price"] = self._clean_text(tag.get_text())
                     break
        
        if not data["image_url"]:
             # P&B usually has grid images
             # .product-image img, .slider-image img
             for sel in [".product-image img", ".carousel-item img", "img.c-product-card__image", ".product-detail-images img"]:
                 tag = soup.select_one(sel)
                 if tag:
                      src = tag.get("src")
                      if src:
                         data["image_url"] = src
                         break

        # Extract Fit Advice (Orange Box)
        # Search for text "Kullanıcıların çoğu"
        # Since class names are dynamic/obfuscated, text search is safer.
        import re
        advice_tag = soup.find(string=re.compile("Kullanıcıların çoğu", re.IGNORECASE))
        if advice_tag:
            # Usually strict text in a span or p
            # "Kullanıcıların çoğu kendi bedenini almanızı öneriyor"
            text = advice_tag.parent.get_text()
            data["fit_advice"] = self._clean_text(text)
        
        # Fallback: Check for the JSON config if text search failed or returned raw JS
        if not data.get("fit_advice") or "window[" in data.get("fit_advice", ""):
            # Search for the script containing the config
            script_pattern = re.compile(r'window\["__envoy_slicing-attributes__PROPS"\]\s*=\s*({.*?});', re.DOTALL)
            script = soup.find("script", string=script_pattern)
            if script:
                 match = script_pattern.search(script.string)
                 if match:
                     try:
                         json_str = match.group(1)
                         config = json.loads(json_str)
                         translations = config.get("translations", {})
                         # "size-expectation.fit-option.too-small"
                         # "size-expectation.fit-option.too-large"
                         # "size-expectation.fit-option.fit-as-expected"
                         
                         # We need to find WHICH one applies to this product? 
                         # Actually the translations dictionary just defines the text. 
                         # It doesn't tell us the *value* for this product.
                         # The value for this product might be in 'initialState' or similar. 
                         
                         # Wait, the previous extraction found "Kullanıcıların çoğu..." text inside the JSON *values* of the translations key.
                         # This means I found the *dictionary of all possible messages*, not the specific message for this product.
                         # Unless the text is printed on screen, I need to find the *active* attribute.
                         
                         # Re-evaluating: The text "Kullanıcıların çoğu..." is visible on the screen for users.
                         # If I found it in the script, it's because soup found the *text node* inside the script tag?
                         # BeautifulSoup usually doesn't return script content as text unless explicitly asked or if it's malformed.
                         # Actually `soup.find(string=...)` searches properly.
                         
                         # If I can't find the rendered element, it means it's Client-Side Rendered (CSR) and not in the initial HTML.
                         # Playwright waits for network idle, but maybe not long enough for the component to mount?
                         
                         # For now, let's reset fit_advice if it looks like code.
                         data["fit_advice"] = ""
                     except:
                         pass
            
            # If we captured raw code in data['fit_advice'], clear it
            if "window[" in data.get("fit_advice", ""):
                 data["fit_advice"] = ""
            if "window[" in data.get("fit_advice", ""):
                 data["fit_advice"] = ""

    def _scrape_generic_fallback(self, soup, data):
        if not data["product_name"]:
            tag = soup.find("title")
            if tag: data["product_name"] = self._clean_text(tag.get_text())
        
        # Last Resort: Find ANY substantial image
        if not data["image_url"]:
            self._find_best_fallback_image(soup, data)

    def _find_best_fallback_image(self, soup, data):
        """
        Scans all <img> tags, scores them based on likely product attributes 
        (size, position, classes), and returns the best candidate.
        """
        images = soup.find_all("img")
        best_img = ""
        max_score = 0
        
        for img in images:
            src = img.get("src")
            if not src or src.startswith("data:") or "icon" in src or "logo" in src:
                continue
            
            score = 0
            
            # Helper to check attributes
            width = img.get("width", "0")
            height = img.get("height", "0")
            try:
                w = int(width.replace("px","")) if width and width.isdigit() else 0
                h = int(height.replace("px","")) if height and height.isdigit() else 0
            except:
                w, h = 0, 0
                
            # Filter tiny images
            if 0 < w < 100 or 0 < h < 100:
                continue

            # Heuristics
            if "product" in str(img.get("class", "")).lower(): score += 5
            if "gallery" in str(img.get("class", "")).lower(): score += 3
            if "main" in str(img.get("class", "")).lower(): score += 3
            if "detail" in str(img.get("class", "")).lower(): score += 2
            
            # Prefer JPG/WEBP over PNG (logos are often PNG)
            if ".jpg" in src or ".jpeg" in src or ".webp" in src: score += 1
            
            # Avoid common non-product terms
            if "avatar" in src or "user" in src or "banner" in src: score -= 10
            
            if score > max_score:
                max_score = score
                best_img = src
        
        if best_img:
            data["image_url"] = best_img
            print(f"Fallback Image Found (Score {max_score}): {best_img}")

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
