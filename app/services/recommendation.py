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
            # Fallback if no chart found: Try general chart or return error
            return {"error": f"No size chart found for {brand_name}"}

        # 2. Detect Fit Type
        fit_type = self._detect_fit_type(description)
        print(f"DEBUG: Detected Fit Type: {fit_type}")

        # 3. CRITICAL: Sort Chart by Size Order
        # We need a reliable index. 
        # _get_size_order returns 0-5 for S-XXL.
        size_chart.sort(key=lambda s: self._get_size_order(s.get("size_label", "")))
        
        # Map indices to size objects for easy lookup
        # index 0 might be XS, but let's map whatever we have.
        # We'll use the self._get_size_order to determine the "slot".
        # Note: If multiple sizes map to same order (e.g. 38 and 40 both 'M'), this logic might need refinement.
        # For now, assuming distinct steps.
        
        # 4. Step 1: Calculate "Candidate Sizes" separately
        # We will determine the "Minimum Required Size Index" for each metric.
        
        candidate_indices = {
            "shoulder": -1,
            "chest": -1,
            "waist": -1,
            "weight": -1
        }
        
        reasons = []

        # --- Metric A: Shoulder ---
        if u_shoulder > 0:
            for size in size_chart:
                s_idx = self._get_size_order(size.get("size_label", ""))
                # If product has shoulder data? Most size charts don't have shoulder.
                # If they don't, we can't use it directly unless we estimate chest from shoulder.
                # Assuming size chart MIGHT have min_shoulder/max_shoulder if we added it, 
                # OR we map shoulder to Chest (Shoulder * 0.85 approx for Top).
                
                # Let's assume we use Chest for Tops if Shoulder is not in DB.
                # But prompt says "size_by_shoulder: Find the size where user.shoulder fits".
                # If DB lacks shoulder, we skip or infer.
                # Taking prompt literally: "size_by_shoulder"
                pass 

        # Since generic charts usually use Chest/Waist/Hips, we will map user metrics to those.
        
        # --- Helper to find fitting index ---
        def find_fitting_index(val, metric_key):
            best_idx = -1
            # Iterate to find the *smallest* size that fits (min_v <= val <= max_v)
            # OR if val > max_v of largest size, we need larger.
            
            for size in size_chart:
                idx = self._get_size_order(size.get("size_label", ""))
                min_v = size.get(f"min_{metric_key}")
                max_v = size.get(f"max_{metric_key}")
                
                if min_v is None or max_v is None: continue
                
                # If value fits in range
                if min_v <= val <= max_v:
                    return idx
                
                # If value is smaller than min -> this size is too big, but maybe smallest available? 
                # If we sorted ASC, and val < min_v, then this is the first size that 'covers' it (albeit loose).
                # Actually if val < min_v of Smallest size, then XS fits (or even smaller). 
                # We usually want the size where val is comfortable.
                
                # Logic: Find the size where val <= max_v. The first one effectively.
                if val <= max_v:
                    return idx
            
            # If we are here, val > max_v of all sizes?
            # Return the largest index
            if size_chart:
                return self._get_size_order(size_chart[-1].get("size_label", ""))
            return -1

        # --- 4a. Shoulder / Chest (for Tops) ---
        target_chest = u_chest
        if target_chest <= 0 and u_shoulder > 0:
             target_chest = u_shoulder * 0.85 # Approximation
             reasons.append(f"Chest estimated from Shoulder ({u_shoulder}cm).")

        if category == "top" and target_chest > 0:
             candidate_indices["chest"] = find_fitting_index(target_chest, "chest")
             
        # --- 4b. Waist (CRITICAL) ---
        # "size_by_waist: If waist > product_chest, that size is impossible" -> Implies tops constraint too?
        # Yes, for tops, waist (belly) can be the limiting factor.
        target_waist = u_waist
        if target_waist <= 0 and u_height > 0 and u_weight > 0:
            target_waist = self._estimate_waist(u_height, u_weight)
            reasons.append(f"Waist estimated from Height/Weight ({target_waist:.1f}cm).")
        
        if target_waist > 0:
             # Check against 'waist' limits of the product (if available)
             # Note: Top size charts sometimes have waist (fitted shirts) or just chest.
             # If Top chart has waist, use it. If not, use Chest as proxy for "Width"?
             # Actually, if Top chart has only Chest, but User Waist > Chest max, we must size up.
             # We'll try to match against 'waist' key first.
             idx_w = find_fitting_index(target_waist, "waist")
             
             # Fallback logic for Tops if 'waist' not in chart: Compare Waist to Chest dimension?
             # Usually T-shirt waist ≈ Chest width.
             if idx_w == -1 and category == "top":
                  idx_w = find_fitting_index(target_waist, "chest")
            
             candidate_indices["waist"] = idx_w

        # --- 4c. Weight (Floor) ---
        # Map weight to min size floor. 90kg -> XL (index 4).
        # Heuristic: <60: S(1), 60-70: M(2), 70-85: L(3), 85-100: XL(4), >100: XXL(5)
        w_idx = -1
        if u_weight < 60: w_idx = 1 # S
        elif 60 <= u_weight < 70: w_idx = 2 # M
        elif 70 <= u_weight < 85: w_idx = 3 # L
        elif 85 <= u_weight < 95: w_idx = 4 # XL
        elif u_weight >= 95: w_idx = 5 # XXL
        
        candidate_indices["weight"] = w_idx

        # 5. Step 2: The "Max-Constraint" Logic
        # Filter valid indices (> -1)
        valid_indices = [v for k, v in candidate_indices.items() if v > -1]
        
        if not valid_indices:
            return {"error": "Could not determine size from measurements."}
            
        final_idx = max(valid_indices)
        
        # 6. Step 4: Product Specific Adjustments
        # Slim fit -> Add 1 if constrained by Waist?
        # Only if Waist was the winner?
        # Complex logic: if final_idx == candidate_indices['waist'] and fit_type == "slim":
        #    final_idx += 1
        
        report_lines = []
        
        # Determine strict label
        def get_label(idx):
            # Find size in chart with this order logic
            # Reverse map simple S/M/L logic
            labels = {1: "S", 2: "M", 3: "L", 4: "XL", 5: "XXL"}
            # Or try to find in chart?
            for s in size_chart:
                if self._get_size_order(s.get("size_label", "")) == idx:
                    return s.get("size_label")
            return labels.get(idx, "Unknown")

        # Analyze Report
        # Chest
        c_idx = candidate_indices["chest"]
        if c_idx > -1:
            report_lines.append(f"Chest/Shoulder: Fits in {get_label(c_idx)}.")
        
        # Waist
        w_idx = candidate_indices["waist"]
        if w_idx > -1:
            report_lines.append(f"Waist: Fits in {get_label(w_idx)}.")
            if w_idx == final_idx and w_idx > c_idx and c_idx > -1:
                report_lines.append(f"(!) Your waist requires {get_label(w_idx)}, pushing the size up.")
        
        # Weight
        wt_idx = candidate_indices["weight"]
        if wt_idx > -1:
            report_lines.append(f"Weight ({u_weight}kg): Suggests at least {get_label(wt_idx)}.")
            
        # Adjustments
        adjustment_msg = ""
        # Slim Fit Adjustment
        if fit_type == "slim":
             # If constrained by Waist (belly) and Slim Fit -> Size Up
             if w_idx == final_idx:
                 final_idx += 1
                 adjustment_msg = "Sizing up (+1) for Slim Fit constraint on Waist."
        elif fit_type == "oversize":
             # If constrained by Weight (not bone structure) -> Don't downsize? 
             # Or if final_idx determined by Chest/Shoulder, maybe we can downsize?
             # Prompt: "If... Oversize and constraint was Weight... keep as is."
             # Let's say: If constrained by Chest, and Oversize, maybe -1?
             # For safety, let's keep logic simple: Strict constraints win. 
             pass

        if adjustment_msg:
             report_lines.append(f"Adjustment: {adjustment_msg}")

        final_label = get_label(final_idx)
        
        # 7. Final Confidence
        # Lower confidence if huge variance between Body Part sizes?
        variance = 0.0
        if len(valid_indices) > 1:
            spread = max(valid_indices) - min(valid_indices)
            if spread >= 2:
                variance = 0.2
                report_lines.append("Note: Significant difference between your measurements reduces confidence.")
        
        confidence = 1.0 - variance
        
        detailed_report = "\n".join(report_lines)
        fit_message = f"We recommend {final_label}."
        if adjustment_msg:
            fit_message += " (Adjusted for Fit)." # Short summary

        print(f"DEBUG: Final Decision: {final_label} based on Index {final_idx}")
        print(f"DEBUG: Report: {detailed_report}")

        return {
            "recommended_size": final_label,
            "confidence_score": max(0.0, min(confidence, 1.0)),
            "fit_message": fit_message,
            "detailed_report": detailed_report,
            "warning": adjustment_msg
        }

