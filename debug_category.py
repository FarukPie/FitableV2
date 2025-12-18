from app.services.recommendation import SizeRecommender
from unittest.mock import MagicMock

def test_category():
    mock_client = MagicMock()
    recommender = SizeRecommender(mock_client)

    test_cases = [
        {"product_name": "Erkek Gri Kazak", "description": "Yün karışımlı"},
        {"product_name": "Triko Üst", "description": "Rahat kesim"},
        {"product_name": "Basic T-Shirt", "description": ""},
        {"product_name": "Mavi Jean Pantolon", "description": ""},
        {"product_name": "Something Unknown", "description": "No keywords here"},
        {"product_name": "Kazak", "description": ""} # Minimal case
    ]

    print("--- Testing Category Inference ---")
    for data in test_cases:
        cat = recommender._infer_category(data)
        print(f"Input: {data['product_name']} -> Category: {cat}")

if __name__ == "__main__":
    test_category()
