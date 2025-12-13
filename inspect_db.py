import os
from dotenv import load_dotenv
from supabase import create_client, Client

load_dotenv()

url: str = os.environ.get("SUPABASE_URL")
key: str = os.environ.get("SUPABASE_SERVICE_KEY") or os.environ.get("SUPABASE_KEY")
supabase: Client = create_client(url, key)

if __name__ == "__main__":
    try:
        print("--- Inspecting 'recommendation_history' ---")
        # Fetch one row to see columns and ID type
        response = supabase.table("recommendation_history").select("*").limit(1).execute()
        if response.data:
            sample = response.data[0]
            print(f"Columns: {list(sample.keys())}")
            print(f"Sample Row: {sample}")
            print(f"ID Type: {type(sample['id'])}")
        else:
            print("Table is empty or no access.")
            
    except Exception as e:
        print(f"Error: {e}")
