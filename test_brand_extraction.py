from app.services.scraper import ProductScraper

def test_brand_extraction():
    test_urls = [
        ("https://www.zara.com/tr/tr/shirt-p123.html", "Zara"),
        ("https://www2.hm.com/tr_tr/productpage.12345.html", "Hm"),
        ("https://shop.mango.com/tr/kadin/gomlek_c123", "Mango"),
        ("https://www.bershka.com/tr/kadin-c123.html", "Bershka"),
        ("https://pullandbear.com/tr/kadin/giyim-n123", "Pullandbear"),
    ]
    
    print("Testing Brand Extraction Logic:")
    all_passed = True
    for url, expected in test_urls:
        brand = ProductScraper._detect_brand(url)
        print(f"URL: {url}")
        print(f"  Expected: {expected}, Got: {brand}")
        if brand != expected:
            print("  [FAIL]")
            all_passed = False
        else:
            print("  [PASS]")
            
    if all_passed:
        print("\nAll brand extraction tests PASSED.")
    else:
        print("\nSome tests FAILED.")

if __name__ == "__main__":
    test_brand_extraction()
