import os
import sys
from dotenv import load_dotenv
from supabase import create_client, Client

# Usage: python scripts/seed_pullandbear.py
load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
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
    # Basic insert, website_url optional
    res = supabase.table("brands").insert({"name": name, "website_url": "pullandbear.com"}).execute()
    return res.data[0]['id']

def seed_pullandbear():
    brand_id = get_or_create_brand("Pull & Bear")
    
    # DATA PAYLOAD
    data = [
        # MEN - TOPS
        {"cat": "top", "label": "XS", "min_chest": 82, "max_chest": 87, "gender": "male"},
        {"cat": "top", "label": "S", "min_chest": 88, "max_chest": 93, "gender": "male"},
        {"cat": "top", "label": "M", "min_chest": 94, "max_chest": 99, "gender": "male"},
        {"cat": "top", "label": "L", "min_chest": 100, "max_chest": 105, "gender": "male"},
        {"cat": "top", "label": "XL", "min_chest": 106, "max_chest": 111, "gender": "male"},
        {"cat": "top", "label": "XXL", "min_chest": 112, "max_chest": 117, "gender": "male"},
        
        # MEN - BOTTOMS
        {"cat": "bottom", "label": "EU 36 (USA 28)", "min_waist": 75, "max_waist": 79, "min_hips": 90, "max_hips": 94, "gender": "male"},
        {"cat": "bottom", "label": "EU 38 (USA 30)", "min_waist": 80, "max_waist": 84, "min_hips": 95, "max_hips": 99, "gender": "male"},
        {"cat": "bottom", "label": "EU 40 (USA 31)", "min_waist": 85, "max_waist": 89, "min_hips": 100, "max_hips": 104, "gender": "male"},
        {"cat": "bottom", "label": "EU 42 (USA 32)", "min_waist": 90, "max_waist": 94, "min_hips": 105, "max_hips": 109, "gender": "male"},
        {"cat": "bottom", "label": "EU 44 (USA 34)", "min_waist": 95, "max_waist": 99, "min_hips": 110, "max_hips": 114, "gender": "male"},
        {"cat": "bottom", "label": "EU 46 (USA 36)", "min_waist": 100, "max_waist": 104, "min_hips": 115, "max_hips": 119, "gender": "male"},

        # WOMEN - TOPS
        {"cat": "top", "label": "XS", "min_chest": 80, "max_chest": 82, "gender": "female"},
        {"cat": "top", "label": "S", "min_chest": 84, "max_chest": 86, "gender": "female"},
        {"cat": "top", "label": "M", "min_chest": 88, "max_chest": 90, "gender": "female"},
        {"cat": "top", "label": "L", "min_chest": 92, "max_chest": 96, "gender": "female"},
        {"cat": "top", "label": "XL", "min_chest": 98, "max_chest": 102, "gender": "female"},

        # WOMEN - BOTTOMS
        {"cat": "bottom", "label": "EU 32", "min_waist": 58, "max_waist": 60, "min_hips": 86, "max_hips": 88, "gender": "female"},
        {"cat": "bottom", "label": "EU 34", "min_waist": 62, "max_waist": 64, "min_hips": 90, "max_hips": 92, "gender": "female"},
        {"cat": "bottom", "label": "EU 36", "min_waist": 66, "max_waist": 68, "min_hips": 94, "max_hips": 96, "gender": "female"},
        {"cat": "bottom", "label": "EU 38", "min_waist": 70, "max_waist": 72, "min_hips": 98, "max_hips": 100, "gender": "female"},
        {"cat": "bottom", "label": "EU 40", "min_waist": 74, "max_waist": 76, "min_hips": 102, "max_hips": 104, "gender": "female"},
    ]
    
    processed = 0
    print("\nStarting Pull & Bear Seeding...")
    
    for item in data:
        row = {
            "brand_id": brand_id,
            "category": item["cat"],
            "size_label": item["label"],
            "gender": item["gender"],
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
            
        # Clean None values
        row = {k: v for k, v in row.items() if v is not None}
        
        try:
            # Manual Upsert (Select -> Update/Insert)
            existing = supabase.table("size_catalogs").select("id")\
                .eq("brand_id", brand_id)\
                .eq("category", item["cat"])\
                .eq("size_label", item["label"])\
                .execute()
            
            if existing.data:
                rec_id = existing.data[0]['id']
                supabase.table("size_catalogs").update(row).eq("id", rec_id).execute()
                print(f" -> Updated {item['label']} ({item['cat']}) (ID: {rec_id})")
            else:
                supabase.table("size_catalogs").insert(row).execute()
                print(f" -> Inserted {item['label']} ({item['cat']})")
                
            processed += 1
            
        except Exception as e:
            print(f"Error processing {item['label']}: {e}")
            
    print(f"\nPull & Bear data seeded successfully! Processed {processed}/{len(data)} items.")

if __name__ == "__main__":
    seed_pullandbear()
