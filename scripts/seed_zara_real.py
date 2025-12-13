import os
import sys
from dotenv import load_dotenv
from supabase import create_client, Client

# Add parent directory to path to find .env if needed, but usually python scripts/seed... works from root
# We assume running from root: python scripts/seed_zara_real.py
load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
# Use Service Key to ensure we can write to DB without RLS if applies, or standard Key
SUPABASE_KEY = os.getenv("SUPABASE_SERVICE_KEY") or os.getenv("SUPABASE_KEY")

if not SUPABASE_URL or not SUPABASE_KEY:
    print("Error: SUPABASE_URL or SUPABASE_KEY not found in .env")
    sys.exit(1)

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

def get_or_create_brand(name: str) -> int:
    print(f"Checking Brand: {name}")
    res = supabase.table("brands").select("id").ilike("name", name).execute()
    if res.data:
        bid = res.data[0]['id']
        print(f" -> Found Brand '{name}' (ID: {bid})")
        return bid
    
    print(f" -> Creating Brand '{name}'")
    res = supabase.table("brands").insert({"name": name}).execute()
    return res.data[0]['id']

def seed_zara():
    brand_id = get_or_create_brand("Zara")
    
    # DATA PAYLOAD
    data = [
        # MEN - TOPS
        {"cat": "top", "label": "S", "min_chest": 91, "max_chest": 96, "gender": "male"},
        {"cat": "top", "label": "M", "min_chest": 96, "max_chest": 101, "gender": "male"},
        {"cat": "top", "label": "L", "min_chest": 101, "max_chest": 106, "gender": "male"},
        {"cat": "top", "label": "XL", "min_chest": 106, "max_chest": 111, "gender": "male"},
        {"cat": "top", "label": "XXL", "min_chest": 111, "max_chest": 116, "gender": "male"},
        
        # MEN - BOTTOMS
        {"cat": "bottom", "label": "EU 38 (US 30)", "min_waist": 76, "max_waist": 79, "min_hips": 95, "max_hips": 99, "gender": "male"},
        {"cat": "bottom", "label": "EU 40 (US 31)", "min_waist": 80, "max_waist": 84, "min_hips": 100, "max_hips": 104, "gender": "male"},
        {"cat": "bottom", "label": "EU 42 (US 32)", "min_waist": 85, "max_waist": 89, "min_hips": 105, "max_hips": 109, "gender": "male"},
        {"cat": "bottom", "label": "EU 44 (US 34)", "min_waist": 90, "max_waist": 95, "min_hips": 110, "max_hips": 114, "gender": "male"},
        {"cat": "bottom", "label": "EU 46 (US 36)", "min_waist": 96, "max_waist": 100, "min_hips": 115, "max_hips": 119, "gender": "male"},

        # WOMEN - TOPS
        {"cat": "top", "label": "XS", "min_chest": 82, "max_chest": 85, "gender": "female"},
        {"cat": "top", "label": "S", "min_chest": 86, "max_chest": 89, "gender": "female"},
        {"cat": "top", "label": "M", "min_chest": 90, "max_chest": 93, "gender": "female"},
        {"cat": "top", "label": "L", "min_chest": 94, "max_chest": 97, "gender": "female"},
        {"cat": "top", "label": "XL", "min_chest": 98, "max_chest": 102, "gender": "female"},
    ]
    
    processed = 0
    
    print("\nStarting Seeding Process...")
    for item in data:
        # Base Row
        row = {
            "brand_id": brand_id,
            "category": item["cat"],
            "size_label": item["label"],
            # Include gender if your schema supports it, otherwise generic top/bottom
            # Usually size_catalogs might not have gender column? Recommendation logic checks 'men'/'women' in product Desc.
            # But the constraint might need uniqueness.
            # Let's check keys.
            "min_chest": item.get("min_chest"),
            "max_chest": item.get("max_chest"),
            "min_waist": item.get("min_waist"),
            "max_waist": item.get("max_waist"),
            "min_hips": item.get("min_hips"),
            "max_hips": item.get("max_hips"),
        }
        
        # Calculate Shoulder for Tops
        if item["cat"] == "top" and item.get("min_chest"):
            # Formula: Shoulder = Chest / 0.85
            row["min_shoulder"] = round(item["min_chest"] / 0.85, 2)
            row["max_shoulder"] = round(item["max_chest"] / 0.85, 2)
            
        # Clean None
        row = {k: v for k, v in row.items() if v is not None}
        
        try:
            # Manual Upsert Simulation (since DB might lack unique constraint on columns)
            # 1. Check if exists
            existing = supabase.table("size_catalogs").select("id").eq("brand_id", brand_id).eq("category", item["cat"]).eq("size_label", item["label"]).execute()
            
            if existing.data:
                # Update
                rec_id = existing.data[0]['id']
                supabase.table("size_catalogs").update(row).eq("id", rec_id).execute()
                print(f" -> Updated {item['label']} ({item['cat']}) (ID: {rec_id})")
            else:
                # Insert
                supabase.table("size_catalogs").insert(row).execute()
                print(f" -> Inserted {item['label']} ({item['cat']})")
            
            processed += 1
            
        except Exception as e:
            print(f"Error processing {item['label']}: {e}")
            
    print(f"\nSeeding Complete. Processed {processed}/{len(data)} items.")

if __name__ == "__main__":
    seed_zara()
