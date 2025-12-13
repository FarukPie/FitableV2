import os
import sys
from dotenv import load_dotenv
from supabase import create_client, Client

# Usage: python scripts/seed_zara_official.py
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
    res = supabase.table("brands").insert({"name": name, "website_url": "zara.com"}).execute()
    return res.data[0]['id']

def seed_zara_official():
    brand_id = get_or_create_brand("Zara")
    
    data = []

    # --- WOMEN TOPS (Detailed Measures) ---
    # XXS, 32, Chest 80, Waist 58, Hips 86
    data.append({"cat": "top", "label": "XXS (32)", "gender": "female", "min_chest": 80, "max_chest": 82, "min_waist": 58, "max_waist": 62, "min_hips": 86, "max_hips": 90})
    data.append({"cat": "top", "label": "XS (34)", "gender": "female", "min_chest": 82, "max_chest": 86, "min_waist": 62, "max_waist": 66, "min_hips": 90, "max_hips": 94})
    data.append({"cat": "top", "label": "S (36)", "gender": "female", "min_chest": 86, "max_chest": 90, "min_waist": 66, "max_waist": 70, "min_hips": 94, "max_hips": 98})
    data.append({"cat": "top", "label": "M (38)", "gender": "female", "min_chest": 90, "max_chest": 96, "min_waist": 70, "max_waist": 76, "min_hips": 98, "max_hips": 104})
    data.append({"cat": "top", "label": "L (40-42)", "gender": "female", "min_chest": 96, "max_chest": 102, "min_waist": 76, "max_waist": 82, "min_hips": 104, "max_hips": 110})
    data.append({"cat": "top", "label": "XL (44)", "gender": "female", "min_chest": 102, "max_chest": 108, "min_waist": 82, "max_waist": 88, "min_hips": 110, "max_hips": 116})
    data.append({"cat": "top", "label": "XXL (46)", "gender": "female", "min_chest": 108, "max_chest": 114, "min_waist": 88, "max_waist": 94, "min_hips": 116, "max_hips": 122})

    # --- WOMEN BOTTOMS (Derived from provided mapping and Top/Body measurements) ---
    # 34=XS, 36=S, 38=M, 40=L. The prompt gives mapping, I will use the body measurements for these sizes.
    # XS(34): W62 H90
    data.append({"cat": "bottom", "label": "XS (34)", "gender": "female", "min_waist": 62, "max_waist": 66, "min_hips": 90, "max_hips": 94})
    data.append({"cat": "bottom", "label": "S (36)", "gender": "female", "min_waist": 66, "max_waist": 70, "min_hips": 94, "max_hips": 98})
    data.append({"cat": "bottom", "label": "M (38)", "gender": "female", "min_waist": 70, "max_waist": 76, "min_hips": 98, "max_hips": 104})
    data.append({"cat": "bottom", "label": "L (40)", "gender": "female", "min_waist": 76, "max_waist": 82, "min_hips": 104, "max_hips": 110})
    # Adding larger sizes based on pattern to be safe? The prompt only listed up to 40=L. 
    # But table above has XL(44) and XXL(46). I will include them for completeness if that's okay.
    data.append({"cat": "bottom", "label": "XL (44)", "gender": "female", "min_waist": 82, "max_waist": 88, "min_hips": 110, "max_hips": 116})


    # --- MEN TOPS ---
    # S: 91-96 | M: 97-102 | L: 103-108 | XL: 109-114 | XXL: 115-120
    data.append({"cat": "top", "label": "S", "gender": "male", "min_chest": 91, "max_chest": 96})
    data.append({"cat": "top", "label": "M", "gender": "male", "min_chest": 97, "max_chest": 102})
    data.append({"cat": "top", "label": "L", "gender": "male", "min_chest": 103, "max_chest": 108})
    data.append({"cat": "top", "label": "XL", "gender": "male", "min_chest": 109, "max_chest": 114})
    data.append({"cat": "top", "label": "XXL", "gender": "male", "min_chest": 115, "max_chest": 120})

    # --- MEN BOTTOMS ---
    # S(38/30): 76-79
    data.append({"cat": "bottom", "label": "S (30\")", "gender": "male", "min_waist": 76, "max_waist": 79})
    data.append({"cat": "bottom", "label": "M (31-32\")", "gender": "male", "min_waist": 80, "max_waist": 84})
    data.append({"cat": "bottom", "label": "L (33-34\")", "gender": "male", "min_waist": 85, "max_waist": 89})
    data.append({"cat": "bottom", "label": "XL (36\")", "gender": "male", "min_waist": 90, "max_waist": 95})
    data.append({"cat": "bottom", "label": "XXL (38\")", "gender": "male", "min_waist": 96, "max_waist": 100})

    # --- KIDS (Sampling a few for DB - Height Based primarily) ---
    # Since our engine heavily relies on Height/Weight, we can use Height as constraint?
    # Actually, standard logic uses Chest/Waist. Kids data has Chest/Waist.
    # 9-10Y: 140cm, Chest 70.
    data.append({"cat": "top", "label": "9-10 Years (140cm)", "gender": "kid", "min_chest": 68, "max_chest": 72, "min_waist": 60, "max_waist": 64}) # Range approx
    data.append({"cat": "top", "label": "11-12 Years (152cm)", "gender": "kid", "min_chest": 76, "max_chest": 80, "min_waist": 64, "max_waist": 68})
    data.append({"cat": "top", "label": "13-14 Years (164cm)", "gender": "kid", "min_chest": 82, "max_chest": 86, "min_waist": 67, "max_waist": 71})

    processed = 0
    print("\nStarting Official Zara Seeding...")
    
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
            
    print(f"\nOfficial Zara data seeded successfully! Processed {processed}/{len(data)} items.")

if __name__ == "__main__":
    seed_zara_official()
