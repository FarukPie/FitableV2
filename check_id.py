
import os
from dotenv import load_dotenv
from supabase import create_client, Client

load_dotenv()

url: str = os.environ.get("SUPABASE_URL")
key: str = os.environ.get("SUPABASE_SERVICE_KEY") 

supabase: Client = create_client(url, key)

target_id = "34a5fa2d-f2cc-4bd2-9f40-38d9abd0f67d"

if __name__ == "__main__":
    print(f"--- Checking for ID: {target_id} ---")
    response = supabase.table("recommendation_history").select("*").eq("id", target_id).execute()
    
    if response.data:
        print(f"FOUND: {response.data[0]}")
    else:
        print("NOT FOUND in DB.")
