
from app.services.recommendation import SizeRecommender
import sys

# Mocking the Supabase client and inner methods to avoid DB calls
class MockRecommender(SizeRecommender):
    def __init__(self):
        # Bypass parent init that sets supabase client
        self.supabase = None

    def _get_user_measurements(self, user_id: str):
        if user_id == "woman_perfect_s":
            return {"chest": 86, "waist": 66, "hips": 94} # Fits Zara S (84-88) perfectly
        if user_id == "woman_between":
            return {"chest": 83, "waist": 63, "hips": 91} # Fits XS (81-84)
        if user_id == "man_l":
            return {"chest": 105, "waist": 88} # Fits L (103-108)
        if user_id == "kid_100cm":
            return {"height": 100} # Fits 3-4 Years (98-104)
        if user_id == "kid_130cm":
            return {"height": 130} # Fits 9-10 Years (128-140)
        return {}

recommender = MockRecommender()

def test(user_id, product, expected_size):
    print(f"\nTesting User: {user_id} with Product: {product.get('product_name')}")
    result = recommender.get_recommendation(user_id, product)
    rec = result.get("recommended_size")
    print(f"Result: {rec} (Confidence: {result.get('confidence_score')})")
    if expected_size and expected_size in rec:
         print("PASS")
    else:
         print(f"FAIL - Expected {expected_size}")

# Case 1: Woman S
test("woman_perfect_s", {"brand": "Zara", "product_name": "Basic Shirt", "gender": "Women"}, "S")

# Case 2: Woman XS (Between sizes logic)
test("woman_between", {"brand": "Zara", "product_name": "Dress", "gender": "Women"}, "XS")

# Case 3: Man L Top
test("man_l", {"brand": "Zara", "product_name": "Denim Jacket", "gender": "Men"}, "L")

# Case 4: Kid 3-4 Years
test("kid_100cm", {"brand": "Zara", "product_name": "Cotton T-Shirt", "gender": "Kids"}, "3-4")

# Case 5: Kid 9-10 Years
test("kid_130cm", {"brand": "Zara", "product_name": "Parka", "gender": "Boy"}, "9-10")

# Case 6: Man Bottom
test("man_l", {"brand": "zara", "product_name": "Jeans", "description": "Classic fit", "gender": "Men"}, "L")

