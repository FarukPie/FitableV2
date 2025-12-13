import os
import asyncio
from dotenv import load_dotenv
from supabase import create_client, Client

load_dotenv()

url: str = os.environ.get("SUPABASE_URL")
key: str = os.environ.get("SUPABASE_SERVICE_KEY") or os.environ.get("SUPABASE_KEY")
supabase: Client = create_client(url, key)

if __name__ == "__main__":
    try:
        user_id = "340ec1de-84b3-4cd4-a2ba-4f72e82a4e19"
        print(f"Checking rows for user: {user_id}")
        response = supabase.table("user_measurements").select("*").eq("user_id", user_id).execute()
        print(f"Found {len(response.data)} rows.")
        for row in response.data:
            print(row)
    except Exception as e:
        print(f"Error: {e}")
