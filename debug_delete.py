
import os
from dotenv import load_dotenv
from supabase import create_client, Client

load_dotenv()

url: str = os.environ.get("SUPABASE_URL")
# Force use of Service Key to match backend config intention
key: str = os.environ.get("SUPABASE_SERVICE_KEY") 

print(f"URL: {url}")
print(f"Key (First 10 chars): {key[:10] if key else 'None'}")

if not key:
    print("CRITICAL: SUPABASE_SERVICE_KEY is missing!")
    exit(1)

supabase: Client = create_client(url, key)

# Test ID from the user logs that failed
# INFO: DELETE /history/3ba78748-0762-48b1-8ed0-5f0a1542b878
test_id = "3ba78748-0762-48b1-8ed0-5f0a1542b878"

if __name__ == "__main__":
    try:
        print(f"--- Attempting to delete {test_id} with SERVICE KEY ---")
        
        # Check if it exists first
        check = supabase.table("recommendation_history").select("*").eq("id", test_id).execute()
        print(f"Pre-check found: {len(check.data)} rows")
        if check.data:
            print(f"Row data: {check.data[0]}")

        # Delete
        response = supabase.table("recommendation_history").delete().eq("id", test_id).execute()
        print(f"Delete Response Data: {response.data}")
        
    except Exception as e:
        print(f"Error: {e}")
