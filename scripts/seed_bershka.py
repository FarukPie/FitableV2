import os
import sys
from dotenv import load_dotenv
from supabase import create_client, Client

# Usage: python scripts/seed_bershka.py
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
    res = supabase.table("brands").insert({"name": name, "website_url": "bershka.com"}).execute()
    return res.data[0]['id']

def seed_bershka():
    brand_id = get_or_create_brand("Bershka")
    
    # DATA PAYLOAD
    data = [
        # MEN - TOPS
        {"cat": "top", "label": "XS", "min_chest": 82, "max_chest": 86, "gender": "male"},
        {"cat": "top", "label": "S", "min_chest": 86, "max_chest": 91, "gender": "male"},
        {"cat": "top", "label": "M", "min_chest": 91, "max_chest": 96, "gender": "male"},
        {"cat": "top", "label": "L", "min_chest": 96, "max_chest": 101, "gender": "male"},
        {"cat": "top", "label": "XL", "min_chest": 101, "max_chest": 106, "gender": "male"},
        {"cat": "top", "label": "XXL", "min_chest": 106, "max_chest": 111, "gender": "male"},
        
        # MEN - BOTTOMS
        {"cat": "bottom", "label": "EU 36 (US 28)", "min_waist": 74, "max_waist": 77, "min_hips": 93, "max_hips": 96, "gender": "male"},
        {"cat": "bottom", "label": "EU 38 (US 30)", "min_waist": 78, "max_waist": 81, "min_hips": 97, "max_hips": 100, "gender": "male"},
        {"cat": "bottom", "label": "EU 40 (US 31)", "min_waist": 82, "max_waist": 85, "min_hips": 101, "max_hips": 104, "gender": "male"},
        {"cat": "bottom", "label": "EU 42 (US 32)", "min_waist": 86, "max_waist": 89, "min_hips": 105, "max_hips": 108, "gender": "male"},
        {"cat": "bottom", "label": "EU 44 (US 34)", "min_waist": 90, "max_waist": 93, "min_hips": 109, "max_hips": 112, "gender": "male"},
        {"cat": "bottom", "label": "EU 46 (US 36)", "min_waist": 94, "max_waist": 97, "min_hips": 113, "max_hips": 116, "gender": "male"},

        # WOMEN - TOPS
        {"cat": "top", "label": "XS", "min_chest": 78, "max_chest": 82, "gender": "female"},
        {"cat": "top", "label": "S", "min_chest": 82, "max_chest": 86, "gender": "female"},
        {"cat": "top", "label": "M", "min_chest": 86, "max_chest": 90, "gender": "female"},
        {"cat": "top", "label": "L", "min_chest": 90, "max_chest": 96, "gender": "female"},
        {"cat": "top", "label": "XL", "min_chest": 96, "max_chest": 102, "gender": "female"},

        # WOMEN - BOTTOMS
        {"cat": "bottom", "label": "EU 32", "min_waist": 58, "max_waist": 60, "min_hips": 86, "max_hips": 88, "gender": "female"},
        {"cat": "bottom", "label": "EU 34", "min_waist": 60, "max_waist": 63, "min_hips": 88, "max_hips": 91, "gender": "female"},
        {"cat": "bottom", "label": "EU 36", "min_waist": 63, "max_waist": 66, "min_hips": 91, "max_hips": 94, "gender": "female"},
        {"cat": "bottom", "label": "EU 38", "min_waist": 66, "max_waist": 70, "min_hips": 94, "max_hips": 98, "gender": "female"},
        {"cat": "bottom", "label": "EU 40", "min_waist": 70, "max_waist": 74, "min_hips": 98, "max_hips": 102, "gender": "female"},
        {"cat": "bottom", "label": "EU 42", "min_waist": 74, "max_waist": 78, "min_hips": 102, "max_hips": 106, "gender": "female"},
    ]
    
    processed = 0
    print("\nStarting Bershka Seeding...")
    
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
            # Match by brand, cat, label AND GENDER
            existing = supabase.table("size_catalogs").select("id")\
                .eq("brand_id", brand_id)\
                .eq("category", item["cat"])\
                .eq("size_label", item["label"])\
                .eq("gender", item["gender"])\
                .execute()
            
            if existing.data:
                rec_id = existing.data[0]['id']
                supabase.table("size_catalogs").update(row).eq("id", rec_id).execute()
                print(f" -> Updated {item['label']} ({item['gender']} {item['cat']}) (ID: {rec_id})")
            else:
                supabase.table("size_catalogs").insert(row).execute()
                print(f" -> Inserted {item['label']} ({item['gender']} {item['cat']})")
                
            processed += 1
            
        except Exception as e:
            print(f"Error processing {item['label']}: {e}")
            
    print(f"\nBershka data seeded successfully! Processed {processed}/{len(data)} items.")

if __name__ == "__main__":
    seed_bershka()
