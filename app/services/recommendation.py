from typing import Dict, List, Optional, Any
from supabase import Client

class SizeRecommender:
    def __init__(self, supabase_client: Client):
        self.supabase = supabase_client

    def _normalize_brand(self, brand_name: str) -> Optional[int]:
        """
        Tries to find the brand_id in the DB by performing a case-insensitive search.
        """
        # Normalize: "zara.com" -> "zara"
        clean_name = brand_name.lower().replace(".com", "").strip()
        
        # Simple ilike query
        try:
            response = self.supabase.table("brands").select("id").ilike("name", f"%{clean_name}%").limit(1).execute()
            if response.data:
                return response.data[0]["id"]
        except Exception as e:
            print(f"Error normalizing brand {brand_name}: {e}")
        return None

    def _get_user_measurements(self, user_id: str) -> Optional[Dict[str, float]]:
        """
        Fetches user measurements from DB.
        """
        try:
            # Try to fetch specific user
            response = self.supabase.table("user_measurements").select("*").eq("user_id", user_id).limit(1).execute()
            if response.data:
                return response.data[0]
            
            # --- DEBUG: Schema Inspector ---
            # If we didn't find the user, let's see what IS in the table to debug column names/IDs
            print(f"DEBUG: Lookup failed for user_id='{user_id}'. Checking table structure...")
            debug_resp = self.supabase.table("user_measurements").select("*").limit(5).execute()
            if debug_resp.data:
                sample = debug_resp.data[0]
                print(f"DEBUG: Table 'user_measurements' Columns: {list(sample.keys())}")
                print(f"DEBUG: First 5 rows IDs: {[r.get('user_id', 'No user_id col') for r in debug_resp.data]}")
            else:
                print("DEBUG: Table 'user_measurements' appears to be EMPTY.")
            # -------------------------------
                
        except Exception as e:
            print(f"Error fetching user measurements for {user_id}: {e}")
            # If user_id column doesn't exist, we might catch it here
            if "Column not found" in str(e) or "does not exist" in str(e):
                 print("DEBUG: CRITICAL - check if column 'user_id' exists in 'user_measurements'.")
        
        return None

    def _get_size_chart(self, brand_id: int, category: str) -> List[Dict[str, Any]]:
        """
        Fetches size catalog for the brand and category.
        """
        try:
            # Category normalization if needed (e.g., "shirt" -> "top")
            # For now assuming simple "top", "bottom" or exact match from DB
            # We might need a mapper here. Let's try "top" and "bottom" generic.
            
            # Simple heuristic mapping based on product category if passed, 
            # but for now we look for generic "top" or "bottom" catalogs.
            
            response = self.supabase.table("size_catalogs").select("*") \
                .eq("brand_id", brand_id) \
                .eq("category", category) \
                .execute()
            return response.data
        except Exception as e:
            print(f"Error fetching size chart: {e}")
            return []

    def _infer_category(self, product_data: Dict) -> str:
        """
        Infers 'top' or 'bottom' based on product name/desc.
        """
        text = (product_data.get("product_name", "") + " " + product_data.get("description", "")).lower()
        
        tops = ["shirt", "t-shirt", "top", "blouse", "sweater", "jacket", "coat", "hoodie", "kazak", "gömlek", "tişört"]
        bottoms = ["pant", "jeans", "trousers", "skirt", "short", "legging", "pantolon", "etek", "şort"]
        
        for kw in bottoms:
            if kw in text:
                return "bottom"
        return "top" # Default to top

    def get_recommendation(self, user_id: str, product_data: Dict) -> Dict[str, Any]:
        print(f"--- Getting Recommendation for User: {user_id} ---")
        user_measurements = self._get_user_measurements(user_id)
        if not user_measurements:
            print(f"DEBUG: User measurements not found for ID {user_id}")
            return {"error": "User measurements not found"}
        print(f"DEBUG: Fetched User Measurements: {user_measurements}")

        brand_name = product_data.get("brand", "Unknown")
        print(f"DEBUG: Product Brand: {brand_name}")
        
        brand_id = self._normalize_brand(brand_name)
        if not brand_id:
            print(f"DEBUG: Brand '{brand_name}' not found in DB.")
            return {"error": f"Brand '{brand_name}' not found in database size charts."}
        print(f"DEBUG: Found Brand ID: {brand_id}")

        category = self._infer_category(product_data)
        print(f"DEBUG: Inferred Category: {category}")
        
        size_chart = self._get_size_chart(brand_id, category)
        if not size_chart:
            print(f"DEBUG: No size chart found for Brand ID {brand_id} and Category {category}")
            return {"error": f"No size chart found for {brand_name} - {category}"}
        print(f"DEBUG: Fetched Size Chart with {len(size_chart)} entries.")

        best_match = None
        highest_score = 0.0
        fit_message = ""
        warnings = []

        check_chest = category == "top"
        check_waist_hips = category == "bottom"

        u_chest = user_measurements.get("chest")
        u_waist = user_measurements.get("waist")
        u_hips = user_measurements.get("hips")
        
        print(f"DEBUG: Matching against measurements - Chest: {u_chest}, Waist: {u_waist}, Hips: {u_hips}")

        for size in size_chart:
            score = 0
            matches = 0
            
            # Debugging individual size checking
            current_size_label = size.get("size_label", "Unknown")
            
            if check_chest and u_chest and size.get("min_chest") is not None:
                min_c = size["min_chest"]
                max_c = size["max_chest"]
                if min_c <= u_chest <= max_c:
                    score += 1.0 
                elif u_chest < min_c and (min_c - u_chest) < 2: 
                    score += 0.5
                elif u_chest > max_c and (u_chest - max_c) < 2: 
                    score += 0.5
                matches += 1

            if check_waist_hips:
                if u_waist and size.get("min_waist") is not None:
                    min_w = size["min_waist"]
                    max_w = size["max_waist"]
                    if min_w <= u_waist <= max_w:
                        score += 1.0
                    elif abs(u_waist - min_w) < 2 or abs(u_waist - max_w) < 2:
                         score += 0.5
                    matches += 1
                
                if u_hips and size.get("min_hips") is not None:
                    min_h = size["min_hips"]
                    max_h = size["max_hips"]
                    if min_h <= u_hips <= max_h:
                        score += 1.0
                    matches += 1
            
            if matches > 0:
                final_score = score / matches
            else:
                final_score = 0
            
            print(f"DEBUG: Size {current_size_label} Score: {final_score}")

            if final_score > highest_score:
                highest_score = final_score
                best_match = size

        if not best_match:
            print("DEBUG: No suitable match found (Highest Score: 0)")
            return {
                "recommended_size": "Unknown",
                "confidence_score": 0.0,
                "fit_message": "Could not find a matching size based on your measurements.",
                "warning": ""
            }

        print(f"DEBUG: Best Match: {best_match['size_label']} (Score: {highest_score})")

        # Analyze Fit Keywords
        desc = product_data.get("description", "").lower()
        if "oversize" in desc:
            warnings.append("This item is Oversized. You might fit in a smaller size.")
        if "slim fit" in desc:
            warnings.append("This is Slim Fit. Consider sizing up if you prefer loose fit.")

        return {
            "recommended_size": best_match["size_label"],
            "confidence_score": round(highest_score, 2),
            "fit_message": f"Based on your measurements, {best_match['size_label']} is the best fit.",
            "warning": " ".join(warnings)
        }
