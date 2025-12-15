import os
from dotenv import load_dotenv
from supabase import create_client

# Load environment variables
load_dotenv()
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_SERVICE_KEY") or os.getenv("SUPABASE_KEY")

if not SUPABASE_URL or not SUPABASE_KEY:
    print("Error: SUPABASE_URL or SUPABASE_KEY not found in .env")
    exit(1)

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

def add_brand(name):
    print(f"Adding Brand: {name}")
    try:
        # Check if exists
        res = supabase.table("brands").select("*").ilike("name", name).execute()
        if res.data:
            print(f"Brand '{name}' already exists with ID: {res.data[0]['id']}")
            return res.data[0]['id']
        
        # Insert
        res = supabase.table("brands").insert({"name": name}).execute()
        new_id = res.data[0]['id']
        print(f"Created Brand '{name}' with ID: {new_id}")
        return new_id
    except Exception as e:
        print(f"Error adding brand: {e}")
        return None

def add_size_chart(brand_id, category, sizes):
    """
    sizes: List of dicts e.g.
    [
      {"size_label": "S", "min_chest": 80, "max_chest": 88},
      {"size_label": "M", "min_chest": 89, "max_chest": 96}
    ]
    """
    print(f"Adding {len(sizes)} sizes for Brand ID {brand_id} ({category})...")
    for size in sizes:
        row = {
            "brand_id": brand_id,
            "category": category, # 'top' or 'bottom'
            "size_label": size.get("size_label"),
            "min_chest": size.get("min_chest"),
            "max_chest": size.get("max_chest"),
            "min_waist": size.get("min_waist"),
            "max_waist": size.get("max_waist"),
            "min_hips": size.get("min_hips"),
            "max_hips": size.get("max_hips"),
            "min_height": size.get("min_height"),
            "max_height": size.get("max_height"),
        }
        # Remove None values
        row = {k: v for k, v in row.items() if v is not None}
        
        try:
            supabase.table("size_catalogs").insert(row).execute()
            print(f"  - Added {size['size_label']}")
        except Exception as e:
            print(f"  - Failed to add {size.get('size_label')}: {e}")

# Universal Standard Size Chart to standardize Zara
UNIVERSAL_SIZE_CHART = [
    # Tops
    {"category": "top", "size_label": "S", "min_chest": 88, "max_chest": 96, "min_waist": 73, "max_waist": 81},
    {"category": "top", "size_label": "M", "min_chest": 96, "max_chest": 104, "min_waist": 81, "max_waist": 89},
    {"category": "top", "size_label": "L", "min_chest": 104, "max_chest": 112, "min_waist": 89, "max_waist": 97},
    {"category": "top", "size_label": "XL", "min_chest": 112, "max_chest": 124, "min_waist": 97, "max_waist": 109},
    {"category": "top", "size_label": "XXL", "min_chest": 124, "max_chest": 136, "min_waist": 109, "max_waist": 121},
    # Bottoms
    {"category": "bottom", "size_label": "S", "min_waist": 73, "max_waist": 81, "min_hips": 88, "max_hips": 96},
    {"category": "bottom", "size_label": "M", "min_waist": 81, "max_waist": 89, "min_hips": 96, "max_hips": 104},
    {"category": "bottom", "size_label": "L", "min_waist": 89, "max_waist": 97, "min_hips": 104, "max_hips": 112},
    {"category": "bottom", "size_label": "XL", "min_waist": 97, "max_waist": 109, "min_hips": 112, "max_hips": 120},
    {"category": "bottom", "size_label": "XXL", "min_waist": 109, "max_waist": 121, "min_hips": 120, "max_hips": 128},
]

def reset_brand_to_universal(brand_name):
    print(f"--- Resetting {brand_name} to Universal Standards ---")
    brand_id = add_brand(brand_name)
    if not brand_id: return

    # 1. DELETE existing charts for this brand to avoid conflicts/duplicates
    print(f"Clearing old data for {brand_name} (ID: {brand_id})...")
    try:
        supabase.table("size_catalogs").delete().eq("brand_id", brand_id).execute()
    except Exception as e:
        print(f"Error clearing data: {e}")

    # 2. INSERT Universal Data
    # Filter for Tops and Bottoms
    tops = [s for s in UNIVERSAL_SIZE_CHART if s["category"] == "top"]
    bottoms = [s for s in UNIVERSAL_SIZE_CHART if s["category"] == "bottom"]

    add_size_chart(brand_id, "top", tops)
    add_size_chart(brand_id, "bottom", bottoms)
    print(f"Successfully reset {brand_name} to Universal Standards.")

if __name__ == "__main__":
    # Run this to fix Zara (and potentially others)
    reset_brand_to_universal("Zara")
