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

if __name__ == "__main__":
    # Example Usage:
    # 1. Define Brand Name
    brand_name = "PullBear" 
    
    # 2. Get/Create Brand
    brand_id = add_brand(brand_name)
    
    if brand_id:
        # 3. Define Data (Change this for your needs)
        # Example: Men's T-Shirts
        my_sizes = [
            {"size_label": "S", "min_chest": 90, "max_chest": 95},
            {"size_label": "M", "min_chest": 96, "max_chest": 101},
            {"size_label": "L", "min_chest": 102, "max_chest": 107},
            {"size_label": "XL", "min_chest": 108, "max_chest": 112},
        ]
        
        add_size_chart(brand_id, "top", my_sizes)
        # Uncomment to add bottoms:
        # add_size_chart(brand_id, "bottom", [...])
        
        print("Done!")
