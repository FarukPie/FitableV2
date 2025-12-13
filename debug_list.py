
import os
from dotenv import load_dotenv
from supabase import create_client, Client

load_dotenv()

url: str = os.environ.get("SUPABASE_URL")
# Use service key to see everything
key: str = os.environ.get("SUPABASE_SERVICE_KEY") 

supabase: Client = create_client(url, key)

# User ID from the logs
user_id = "340ec1de-84b3-4cd4-a2ba-4f72e82a4e19"

if __name__ == "__main__":
    try:
        print(f"--- Listing History for User {user_id} ---")
        response = supabase.table("recommendation_history").select("*").eq("user_id", user_id).execute()
        
        print(f"Found {len(response.data)} items.")
        for item in response.data:
            print(f"ID: {item['id']} | Product: {item.get('product_name', 'N/A')}")

    except Exception as e:
        print(f"Error: {e}")
