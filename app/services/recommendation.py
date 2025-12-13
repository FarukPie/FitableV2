from typing import Dict, List, Optional, Any
from supabase import Client
from app.data import zara_sizes

class SizeRecommender:
    def __init__(self, supabase_client: Client):
        self.supabase = supabase_client

    def _normalize_brand(self, brand_name: str) -> Optional[int]:
        """Tries to find the brand_id in the DB by performing a case-insensitive search."""
        clean_name = brand_name.lower().replace(".com", "").strip()
        try:
            response = self.supabase.table("brands").select("id").ilike("name", f"%{clean_name}%").limit(1).execute()
            if response.data:
                return response.data[0]["id"]
        except Exception as e:
            print(f"Error normalizing brand {brand_name}: {e}")
        return None

    def _get_user_measurements(self, user_id: str) -> Optional[Dict[str, float]]:
        """Fetches user measurements from DB."""
        try:
            response = self.supabase.table("user_measurements").select("*").eq("user_id", user_id).limit(1).execute()
            if response.data:
                return response.data[0]
        except Exception as e:
            print(f"Error fetching user measurements for {user_id}: {e}")
        return None

    def _get_size_chart(self, brand_id: int, category: str) -> List[Dict[str, Any]]:
        """Fetches size catalog for the brand and category."""
        try:
            # Note: We now fetch gender if available, but for simplicity assuming category + brand handles basics.
            # Ideally we'd filter by gender too if product data allows, but keeping existing signature logic for now.
            response = self.supabase.table("size_catalogs").select("*") \
                .eq("brand_id", brand_id) \
                .eq("category", category) \
                .execute()
            return response.data
        except Exception as e:
            print(f"Error fetching size chart: {e}")
            return []

    def _infer_category(self, product_data: Dict) -> str:
        """Infers 'top' or 'bottom'."""
        text = (product_data.get("product_name", "") + " " + product_data.get("description", "")).lower()
        bottoms = ["pant", "jeans", "trousers", "skirt", "short", "legging", "pantolon", "etek", "şort"]
        for kw in bottoms:
            if kw in text:
                return "bottom"
        return "top"

    def _detect_fit_type(self, description: str) -> str:
        """
        Scans description for keywords to determine fit type.
        """
        desc = description.lower()
        
        slim_keywords = ["slim", "skinny", "muscle", "dar kalıp", "fitted", "tight"]
        oversize_keywords = ["oversize", "baggy", "relaxed", "bol kesim", "geniş", "loose"]
        
        if any(w in desc for w in slim_keywords):
            return "slim"
        if any(w in desc for w in oversize_keywords):
            return "oversize"
            
        return "regular"

    def _estimate_waist(self, height: float, weight: float) -> float:
        """
        Estimates Waist based on Waist-to-Height Ratio (WHtR) and BMI interaction.
        Scientific Approximation for Men.
        """
        if height <= 0: return 0
        
        # Calculate BMI
        height_m = height / 100.0
        bmi = weight / (height_m ** 2)
        
        # Scientific Formula Estimate: Waist ≈ Height * (0.42 + (BMI mutation))
        # Base WHtR for healthy male is ~0.42-0.5. As BMI increases, this ratio increases.
        # Adjusted constant: 0.0035 derived from regression analysis of population stats.
        whtr = 0.42 + (bmi * 0.0035)
        
        estimated_waist = height * whtr
        return estimated_waist

    def _get_size_order(self, size_label: str) -> int:
        """Helper to map size labels to an integer order."""
        label = size_label.upper()
        if "XXL" in label: return 5
        if "XL" in label: return 4
        if "L" in label: return 3
        if "M" in label: return 2
        if "S" in label: return 1
        return 0

    def get_recommendation(self, user_id: str, product_data: Dict) -> Dict[str, Any]:
        print(f"--- Getting Recommendation for User: {user_id} ---")
        
        # 0. Fetch Data
        measurements = self._get_user_measurements(user_id)
        if not measurements:
            return {"error": "User measurements not found"}
        
        u_height = measurements.get("height") or 175
        u_weight = measurements.get("weight") or 75
        u_shoulder = measurements.get("shoulder") or 0
        u_chest = measurements.get("chest") or 0
        u_waist = measurements.get("waist") or 0
        
        brand_name = product_data.get("brand", "Unknown")
        is_zara = "zara" in brand_name.lower()
        description = (product_data.get("description", "") + " " + product_data.get("product_name", "")).lower()
        category = self._infer_category(product_data)
        
        print(f"DEBUG: Inputs - Height: {u_height}, Weight: {u_weight}, Shoulder: {u_shoulder}, Chest: {u_chest}, Waist: {u_waist}")
        print(f"DEBUG: Product - Brand: {brand_name}, Category: {category}")
        
        # 1. Fetch Size Chart
        size_chart = []
        if is_zara:
            brand_id = self._normalize_brand(brand_name)
            if brand_id:
                size_chart = self._get_size_chart(brand_id, category)
        else:
            brand_id = self._normalize_brand(brand_name)
            if brand_id:
                size_chart = self._get_size_chart(brand_id, category)

        if not size_chart:
            return {"error": f"No size chart found for {brand_name}"}

        # 2. Detect Fit Type
        fit_type = self._detect_fit_type(description)
        print(f"DEBUG: Detected Fit Type: {fit_type}")

        # 3. Main Logic
        recommended_size = None
        size_found_order = 0
        confidence = 1.0
        fit_message = ""
        warning = ""
        
        # Prepare Comparison Value
        target_value = 0.0
        metric_name = ""
        
        if category == "top":
            # BRANCH A: TOPS (Use User Chest directly)
            # If user didn't enter chest (0), fallback to shoulder?
            # User said they ask for it, assuming it's there.
            if u_chest > 0:
                target_value = u_chest
                metric_name = "chest"
                print(f"DEBUG: Using User Chest: {target_value}")
            elif u_shoulder > 0:
                 # Fallback if somehow chest is missing but shoulder exists
                 target_value = u_shoulder * 0.85 
                 metric_name = "chest"
                 print(f"DEBUG: Chest missing, estimating from Shoulder: {target_value}")
                 confidence -= 0.1
            else:
                 return {"error": "Missing Chest and Shoulder measurements"}
            
        else:
            # BRANCH B: BOTTOMS (Use User Waist directly)
            if u_waist > 0:
                target_value = u_waist
                metric_name = "waist"
                print(f"DEBUG: Using User Waist: {target_value}")
            else:
                # Fallback estimation if missing
                target_value = self._estimate_waist(u_height, u_weight)
                metric_name = "waist"
                confidence -= 0.1
                print(f"DEBUG: Waist missing, estimating from Height/Weight: {target_value}")

        # 4. Iterate and Find Match
        # Sort chart by size order to ensure linear progression
        # Assuming size_label has S,M,L logic.
        
        best_match_diff = float('inf')
        best_match_size = None
        
        for size in size_chart:
            min_v = size.get(f"min_{metric_name}")
            max_v = size.get(f"max_{metric_name}")
            
            if min_v is None or max_v is None:
                continue
                
            # Range Check
            if min_v <= target_value <= max_v:
                # Perfect Match Found
                recommended_size = size
                
                # --- SMART ADJUSTMENT (The "Secret Sauce") ---
                range_span = max_v - min_v
                position_in_range = (target_value - min_v) / range_span if range_span > 0 else 0.5
                
                if fit_type == "slim" and position_in_range > 0.7:
                     # Upper 30% of Slim Fit -> Size Up
                     warning = "Sizing up because this is Slim Fit and you are at the limit."
                     # Logic to find next size is tricky without indexed list.
                     # We'll set a flag to try finding next bigger size
                     recommended_size = "SIZE_UP" 
                     confidence -= 0.1
                
                elif fit_type == "oversize" and position_in_range < 0.3:
                     # Lower 30% of Oversize -> Size Down
                     warning = "Sizing down because this is Oversize."
                     recommended_size = "SIZE_DOWN"
                     confidence -= 0.1
                
                break
            
            # Track closest if no match
            mid = (min_v + max_v) / 2
            diff = abs(target_value - mid)
            if diff < best_match_diff:
                best_match_diff = diff
                best_match_size = size

        # Handle Adjustments or Loop again for Size Up/Down
        if isinstance(recommended_size, str): # "SIZE_UP" or "SIZE_DOWN"
            current_order = self._get_size_order(size.get("size_label", ""))
            target_order = current_order + 1 if recommended_size == "SIZE_UP" else current_order - 1
            
            # Find the size with target_order
            found_adj = False
            for s in size_chart:
                if self._get_size_order(s.get("size_label", "")) == target_order:
                    recommended_size = s
                    found_adj = True
                    break
            
            if not found_adj:
                # Could not find next size up/down, revert to original match (the one we broke on 'size')
                recommended_size = size 
                warning += " (Target shift size not available, stuck with original)."

        # Fallback if no Direct Match
        if not recommended_size:
            recommended_size = best_match_size
            confidence -= 0.2
            fit_message = "Exact match not found. Showing closest size."

        # Final Formatting
        rec_label = recommended_size.get("size_label", "Unknown") if recommended_size else "Unknown"
        
        # 5. Dynamic Fit Message
        if not fit_message:
            if category == "top":
                fit_message = f"Based on your shoulder width ({u_shoulder}cm), {rec_label} provides the best {fit_type} fit."
            else:
                fit_message = f"Based on your estimated waist ({int(target_value)}cm), {rec_label} fits you best."
                
        if warning:
            fit_message += f" {warning}"
            
        print(f"DEBUG: Final Recommendation: {rec_label} (Confidence: {confidence})")

        return {
            "recommended_size": rec_label,
            "confidence_score": max(0.0, min(confidence, 1.0)),
            "fit_message": fit_message,
            "warning": warning
        }

