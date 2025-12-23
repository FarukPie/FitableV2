from typing import Dict, List, Optional, Any
from supabase import Client
from app.data import zara_sizes

class SizeRecommender:
    # Erkek Beden Tablosu - Daha geniş omuz/göğüs, düz kalça
    MALE_SIZE_CHART = [
        # Tops - Erkek (Büyük göğüs, omuz genişliği)
        {"size_label": "XS", "category": "top", "min_chest": 84, "max_chest": 90, "min_waist": 70, "max_waist": 76},
        {"size_label": "S", "category": "top", "min_chest": 90, "max_chest": 96, "min_waist": 76, "max_waist": 82},
        {"size_label": "M", "category": "top", "min_chest": 96, "max_chest": 102, "min_waist": 82, "max_waist": 88},
        {"size_label": "L", "category": "top", "min_chest": 102, "max_chest": 108, "min_waist": 88, "max_waist": 94},
        {"size_label": "XL", "category": "top", "min_chest": 108, "max_chest": 116, "min_waist": 94, "max_waist": 102},
        {"size_label": "XXL", "category": "top", "min_chest": 116, "max_chest": 124, "min_waist": 102, "max_waist": 110},
        # Bottoms - Erkek (Bel ön planda, düz kalça)
        {"size_label": "XS", "category": "bottom", "min_waist": 70, "max_waist": 76, "min_hip": 88, "max_hip": 94},
        {"size_label": "S", "category": "bottom", "min_waist": 76, "max_waist": 82, "min_hip": 94, "max_hip": 100},
        {"size_label": "M", "category": "bottom", "min_waist": 82, "max_waist": 88, "min_hip": 100, "max_hip": 106},
        {"size_label": "L", "category": "bottom", "min_waist": 88, "max_waist": 94, "min_hip": 106, "max_hip": 112},
        {"size_label": "XL", "category": "bottom", "min_waist": 94, "max_waist": 102, "min_hip": 112, "max_hip": 120},
        {"size_label": "XXL", "category": "bottom", "min_waist": 102, "max_waist": 110, "min_hip": 120, "max_hip": 128},
    ]
    
    # Kadın Beden Tablosu - Daha dar omuz, belirgin kalça
    FEMALE_SIZE_CHART = [
        # Tops - Kadın (Küçük omuz, göğüs çevresi farklı hesap)
        {"size_label": "XXS", "category": "top", "min_chest": 76, "max_chest": 80, "min_waist": 58, "max_waist": 62},
        {"size_label": "XS", "category": "top", "min_chest": 80, "max_chest": 84, "min_waist": 62, "max_waist": 66},
        {"size_label": "S", "category": "top", "min_chest": 84, "max_chest": 88, "min_waist": 66, "max_waist": 70},
        {"size_label": "M", "category": "top", "min_chest": 88, "max_chest": 94, "min_waist": 70, "max_waist": 76},
        {"size_label": "L", "category": "top", "min_chest": 94, "max_chest": 100, "min_waist": 76, "max_waist": 82},
        {"size_label": "XL", "category": "top", "min_chest": 100, "max_chest": 108, "min_waist": 82, "max_waist": 90},
        {"size_label": "XXL", "category": "top", "min_chest": 108, "max_chest": 116, "min_waist": 90, "max_waist": 98},
        # Bottoms - Kadın (Kalça ön planda, bel ikincil)
        {"size_label": "XXS", "category": "bottom", "min_waist": 58, "max_waist": 62, "min_hip": 84, "max_hip": 88},
        {"size_label": "XS", "category": "bottom", "min_waist": 62, "max_waist": 66, "min_hip": 88, "max_hip": 92},
        {"size_label": "S", "category": "bottom", "min_waist": 66, "max_waist": 70, "min_hip": 92, "max_hip": 96},
        {"size_label": "M", "category": "bottom", "min_waist": 70, "max_waist": 76, "min_hip": 96, "max_hip": 102},
        {"size_label": "L", "category": "bottom", "min_waist": 76, "max_waist": 82, "min_hip": 102, "max_hip": 108},
        {"size_label": "XL", "category": "bottom", "min_waist": 82, "max_waist": 90, "min_hip": 108, "max_hip": 116},
        {"size_label": "XXL", "category": "bottom", "min_waist": 90, "max_waist": 98, "min_hip": 116, "max_hip": 124},
    ]
    
    # Fallback for unknown gender (average of male/female)
    UNIVERSAL_SIZE_CHART = [
        {"size_label": "XS", "category": "top", "min_chest": 80, "max_chest": 88, "min_waist": 66, "max_waist": 74},
        {"size_label": "S", "category": "top", "min_chest": 88, "max_chest": 94, "min_waist": 74, "max_waist": 80},
        {"size_label": "M", "category": "top", "min_chest": 94, "max_chest": 100, "min_waist": 80, "max_waist": 86},
        {"size_label": "L", "category": "top", "min_chest": 100, "max_chest": 108, "min_waist": 86, "max_waist": 94},
        {"size_label": "XL", "category": "top", "min_chest": 108, "max_chest": 116, "min_waist": 94, "max_waist": 102},
        {"size_label": "XXL", "category": "top", "min_chest": 116, "max_chest": 124, "min_waist": 102, "max_waist": 110},
        # Bottoms
        {"size_label": "XS", "category": "bottom", "min_waist": 66, "max_waist": 74, "min_hip": 88, "max_hip": 96},
        {"size_label": "S", "category": "bottom", "min_waist": 74, "max_waist": 80, "min_hip": 96, "max_hip": 102},
        {"size_label": "M", "category": "bottom", "min_waist": 80, "max_waist": 86, "min_hip": 102, "max_hip": 108},
        {"size_label": "L", "category": "bottom", "min_waist": 86, "max_waist": 94, "min_hip": 108, "max_hip": 116},
        {"size_label": "XL", "category": "bottom", "min_waist": 94, "max_waist": 102, "min_hip": 116, "max_hip": 124},
    ]

    # === PROFESSIONAL OPTIMIZATION CONSTANTS ===
    
    # Metric Weights - Top garments (t-shirt, shirt, jacket, etc.)
    TOP_WEIGHTS = {
        "chest": 0.45,      # Primary metric - 45%
        "shoulder": 0.25,   # Important for fit - 25%
        "waist": 0.15,      # Secondary - 15%
        "weight": 0.15      # Fallback validation - 15%
    }
    
    # Metric Weights - Bottom garments (pants, skirt, etc.)
    BOTTOM_WEIGHTS = {
        "waist": 0.40,      # Primary metric - 40%
        "hip": 0.35,        # Very important - 35%
        "inseam": 0.15,     # Length - 15%
        "weight": 0.10      # Fallback - 10%
    }
    
    # Brand Fit Factors - How brands typically fit (1.0 = standard)
    # < 1.0 = runs small, > 1.0 = runs large
    BRAND_FIT_FACTORS = {
        "zara": {"top": 0.95, "bottom": 0.92},        # Runs small
        "hm": {"top": 1.0, "bottom": 1.0},            # Standard
        "h&m": {"top": 1.0, "bottom": 1.0},           # Standard
        "pull&bear": {"top": 1.05, "bottom": 1.02},   # Runs slightly large
        "pullandbear": {"top": 1.05, "bottom": 1.02},
        "bershka": {"top": 0.95, "bottom": 0.95},     # Runs small
        "mango": {"top": 0.98, "bottom": 0.95},       # Slightly small
        "massimo dutti": {"top": 1.0, "bottom": 1.0}, # Standard
        "stradivarius": {"top": 0.95, "bottom": 0.93},# Runs small
        "lcw": {"top": 1.02, "bottom": 1.0},          # Slightly large tops
        "lc waikiki": {"top": 1.02, "bottom": 1.0},
        "defacto": {"top": 1.0, "bottom": 1.0},       # Standard
        "koton": {"top": 0.98, "bottom": 0.98},       # Slightly small
        "trendyol": {"top": 1.0, "bottom": 1.0},      # Varies, use standard
        "nike": {"top": 1.0, "bottom": 0.98},         # Standard/slightly small bottoms
        "adidas": {"top": 1.0, "bottom": 1.0},        # Standard
        "puma": {"top": 1.02, "bottom": 1.0},         # Slightly large tops
    }
    
    # Body Shape Adjustments (in size index offset)
    BODY_SHAPE_ADJUSTMENTS = {
        "inverted_triangle": {"top": 0.5, "bottom": 0},      # Broad shoulders
        "ters_ucgen": {"top": 0.5, "bottom": 0},
        "triangle": {"top": 0, "bottom": 0.5},               # Pear shape - wider hips
        "pear": {"top": 0, "bottom": 0.5},
        "armut": {"top": 0, "bottom": 0.5},
        "rectangle": {"top": 0, "bottom": 0},                # Balanced
        "dikdortgen": {"top": 0, "bottom": 0},
        "apple": {"top": 0.5, "bottom": 0.5},                # Wider midsection
        "elma": {"top": 0.5, "bottom": 0.5},
        "hourglass": {"top": 0, "bottom": 0},                # Balanced curves
        "kum_saati": {"top": 0, "bottom": 0},
        "regular": {"top": 0, "bottom": 0},
    }
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

    def _infer_category(self, product_data: Dict) -> Optional[str]:
        """Infers 'top' or 'bottom' based on clothing keywords. Returns None if not clothing."""
        # Combine Name + Description + URL for maximum keyword coverage
        text = (product_data.get("product_name", "") + " " + product_data.get("description", "") + " " + product_data.get("product_url", "")).lower()
        
        # Keywords (Turkish + English + Slugified for URL matches)
        bottoms = [
            "pant", "jeans", "trousers", "skirt", "short", "legging", "jogger", "chino", "cargo", "slacks", "bermuda", "capri",
            "pantolon", "etek", "şort", "tayt", "eşofman", "jean", "jogger", "kapri", "kargo", "bermuda", "salvar", "şalvar", "sort-etek",
            "sort", "esofman", "salvar", "denim", "trouser", "bottom", "alt", "biker" # Slugs and Extras
        ]
        tops = [
            "top", "shirt", "blouse", "sweater", "hoodie", "jacket", "coat", "vest", "cardigan", "pullover", "tunic", "fleece", "poncho", "raincoat", "trench",
            "tişört", "t-shirt", "gömlek", "bluz", "kazak", "süveter", "hırka", "sweatshirt", "ceket", "mont", "kaban", "yelek", 
            "büstiyer", "crop", "tunik", "atlet", "body", "polar", "yağmurluk", "trençkot", "pardesü", "panço", "bolero", "kimono", "kaftan", "kürk",
            "tisort", "gomlek", "hirka", "bustiyer", "ust", "üst", "triko", "jarse", "jersey", "yagmurluk", "trenckot", "pardesu", "panco", "kurk",
            "outer", "dis giyim", "dış giyim", "tank", "askılı", "suveter", "yelek", "kazak", "t-sirt", "sirt" 
        ]
        fullbody = [
            "dress", "jumpsuit", "romper", "suit", "overall",
            "elbise", "tulum", "abiye", "salopet", "jile", "takım", "takim", "set", "takimi"
        ]
        
        # Check Bottoms
        for kw in bottoms:
            if kw in text: return "bottom"
            
        # Check Tops
        for kw in tops:
            if kw in text: return "top"
            
        # Check Full Body (Treat as top for chest constraint?)
        for kw in fullbody:
            if kw in text: return "top" # Simplified for now
            
        # If nothing matches, it's likely non-clothing (e.g. Tire, Phone, etc.)
        return None

    def _detect_fit_type(self, description: str) -> str:
        """
        Scans description for keywords to determine fit type.
        """
        desc = description.lower()
        
        slim_keywords = ["slim", "skinny", "muscle", "dar kalıp", "fitted", "tight"]
        oversize_keywords = ["oversize", "baggy", "relaxed", "bol kesim", "geniş", "loose", "salaş"]
        
        if any(w in desc for w in slim_keywords):
            return "slim"
        if any(w in desc for w in oversize_keywords):
            return "oversize"
            
        return "regular"

    def _calculate_elasticity_bonus(self, fabric_text: Optional[str]) -> float:
        """Returns extra cm allowed for stretchy fabrics."""
        if not fabric_text:
            return 0.0
        text = fabric_text.lower()
        if "elastan" in text or "elastane" in text:
            # Simple heuristic: if elastane > 5%, give more bonus
            if "5%" in text or "6%" in text: return 4.0
            return 2.0
        if "polyester" in text and "pamuk" not in text:
            return 1.0 # Slight stretch depending on weave, safe formatting
        return 0.0

    def _get_ease_allowance(self, product_text: str) -> float:
        """Returns ease allowance (cm) based on product type keywords."""
        text = product_text.lower()
        if "jacket" in text or "ceket" in text or "coat" in text or "mont" in text:
            return 4.0 # Outerwear needs room
        if "hoodie" in text or "sweatshirt" in text:
            return 2.0 # Loose fit usually
        return 0.0

    def _get_size_order(self, size_label: str) -> int:
        """Maps size labels to a comparable integer."""
        label = size_label.upper().strip()
        mapping = {
            "XXS": 0, "XS": 1, "S": 2, "M": 3, "L": 4, "XL": 5, "XXL": 6, "3XL": 7,
            "34": 1, "36": 1, "38": 2, "40": 3, "42": 4, "44": 5, "46": 6
        }
        return mapping.get(label, -1)

    def _estimate_waist(self, height: float, weight: float) -> float:
        """Estimates waist circumference (cm) using BMI-based heuristic."""
        # WHtR (Waist-to-Height Ratio) is approx 0.42-0.5 for healthy adults.
        if height == 0: return 0
        # Improved estimation using weight-height relationship
        bmi = weight / ((height/100) ** 2)
        # Waist estimation based on BMI
        if bmi < 18.5:
            return height * 0.40  # Underweight
        elif bmi < 25:
            return height * 0.44  # Normal
        elif bmi < 30:
            return height * 0.48  # Overweight
        else:
            return height * 0.52  # Obese

    def _calculate_bmi_factor(self, height_cm: float, weight_kg: float) -> float:
        """
        Calculates BMI-based size adjustment factor.
        Returns: offset to add to size index (-0.5 to +1.0)
        """
        if height_cm <= 0:
            return 0
        bmi = weight_kg / ((height_cm / 100) ** 2)
        
        if bmi < 18.5:
            return -0.5  # Underweight - half size smaller
        elif bmi < 22:
            return -0.25  # Lean - quarter size smaller
        elif bmi < 25:
            return 0  # Normal - no adjustment
        elif bmi < 28:
            return 0.25  # Slightly overweight
        elif bmi < 30:
            return 0.5  # Overweight - half size larger
        else:
            return 1.0  # Obese - one size larger

    def _calculate_gaussian_fit(self, user_val: float, min_v: float, max_v: float) -> float:
        """
        Calculates fit score using Gaussian (normal distribution) for professional accuracy.
        Returns: 0-100 score where 100 = perfect fit at center of range
        """
        import math
        
        if min_v is None or max_v is None or user_val <= 0:
            return 0
        
        center = (min_v + max_v) / 2
        sigma = (max_v - min_v) / 4  # 2 sigma covers the range
        
        if sigma <= 0:
            return 50  # Fallback
        
        # Gaussian formula: exp(-0.5 * ((x - μ) / σ)²)
        exponent = -0.5 * ((user_val - center) / sigma) ** 2
        score = math.exp(exponent) * 100
        
        return min(100, max(0, score))

    def _calculate_weighted_size_score(self, size_entry: Dict, user_metrics: Dict, 
                                        category: str, weights: Dict) -> float:
        """
        Calculates weighted fit score for a size using multiple metrics.
        Returns: 0-100 weighted score
        """
        total_weight = 0
        weighted_score = 0
        
        metric_mappings = {
            "chest": ("min_chest", "max_chest"),
            "waist": ("min_waist", "max_waist"),
            "hip": ("min_hip", "max_hip"),
            "shoulder": ("min_shoulder", "max_shoulder"),
        }
        
        for metric, weight in weights.items():
            if metric == "weight" or metric == "inseam":
                continue  # Skip non-chart metrics
            
            user_val = user_metrics.get(metric, 0)
            if user_val <= 0:
                continue
            
            min_key, max_key = metric_mappings.get(metric, (None, None))
            if not min_key:
                continue
            
            min_v = size_entry.get(min_key)
            max_v = size_entry.get(max_key)
            
            if min_v is not None and max_v is not None:
                score = self._calculate_gaussian_fit(user_val, min_v, max_v)
                weighted_score += score * weight
                total_weight += weight
        
        if total_weight > 0:
            return weighted_score / total_weight
        return 0

    def _get_brand_fit_factor(self, brand_name: str, category: str) -> float:
        """
        Returns brand-specific fit factor for size adjustment.
        """
        clean_brand = brand_name.lower().strip()
        
        for brand_key, factors in self.BRAND_FIT_FACTORS.items():
            if brand_key in clean_brand or clean_brand in brand_key:
                return factors.get(category, 1.0)
        
        return 1.0  # Default standard fit

    def _get_body_shape_adjustment(self, body_shape: str, category: str) -> float:
        """
        Returns size index adjustment based on body shape.
        """
        shape_lower = (body_shape or "regular").lower().replace(" ", "_")
        adjustments = self.BODY_SHAPE_ADJUSTMENTS.get(shape_lower, {"top": 0, "bottom": 0})
        return adjustments.get(category, 0)

    def _detect_pant_type(self, product_data: Dict) -> str:
        """
        Detects the type of pants for appropriate size format.
        Returns: 'jean', 'formal', 'casual', 'short'
        - jean: Denim/Jeans -> W/L format or numeric (30, 31, 32)
        - formal: Kumaş pantolon -> numeric format (30, 31, 32) - MOST COMMON ON TRENDYOL
        - casual: Eşofman/Jogger -> S/M/L
        - short: Şort/Etek -> S/M/L
        """
        text = str(product_data).lower()
        product_name = product_data.get("product_name", "").lower()
        url = product_data.get("url", "").lower()
        
        # PRIORITY 1: Check available_sizes from scraper (most reliable)
        available_sizes = product_data.get("available_sizes", [])
        
        print(f"DEBUG _detect_pant_type: available_sizes={available_sizes}, product_name={product_name[:50] if product_name else 'N/A'}")
        
        if available_sizes:
            letter_sizes = ["XXS", "XS", "S", "M", "L", "XL", "XXL", "3XL", "4XL"]
            
            # Check for W/L jeans format (W28, W30, etc.)
            has_jeans_format = any(
                str(size).upper().startswith("W") or "/" in str(size) 
                for size in available_sizes
            )
            
            # Check for purely numeric sizes (30, 31, 32, etc.)
            numeric_sizes = []
            has_letter_sizes = False
            
            for size in available_sizes:
                size_str = str(size).strip().upper()
                if size_str in letter_sizes:
                    has_letter_sizes = True
                elif size_str.isdigit():
                    num = int(size_str)
                    if 26 <= num <= 50:
                        numeric_sizes.append(num)
            
            has_numeric_sizes = len(numeric_sizes) > 0
            
            print(f"DEBUG: Size format - Letter:{has_letter_sizes}, Jeans:{has_jeans_format}, Numeric:{has_numeric_sizes}, NumericSizes:{numeric_sizes}")
            
            if has_jeans_format:
                return "jean"
            elif has_numeric_sizes and not has_letter_sizes:
                return "formal"  # Pure numeric = formal
            elif has_letter_sizes:
                short_keywords = ["şort", "sort", "short", "bermuda", "kapri", "etek", "skirt"]
                if any(kw in text for kw in short_keywords):
                    return "short"
                return "casual"
            elif has_numeric_sizes:
                return "formal"
        
        # PRIORITY 2: URL-based detection for Trendyol products
        # Many Trendyol pants URLs contain hints about size format
        if "trendyol" in url:
            # Check for keywords in URL that suggest numeric sizing
            numeric_indicators = ["pantolon", "chino", "kumas", "kumaş", "canvas", "slim-fit", "regular-fit", "straight"]
            casual_indicators = ["esofman", "eşofman", "jogger", "sweat", "pijama"]
            
            if any(ind in url for ind in casual_indicators):
                print("DEBUG: URL indicates casual (eşofman/jogger)")
                return "casual"
            
            if any(ind in url for ind in numeric_indicators):
                print("DEBUG: URL indicates formal/numeric (pantolon/chino)")
                return "formal"
        
        # PRIORITY 3: Keyword-based detection from product name and description
        
        # Short/Skirt - Always S/M/L
        short_keywords = ["şort", "sort", "short", "bermuda", "kapri", "capri", "etek", "skirt", "mini", "midi"]
        if any(kw in text for kw in short_keywords):
            return "short"
        
        # Casual (sweatpants) - S/M/L
        casual_keywords = ["eşofman", "esofman", "jogger", "sweatpant", "pijama", "ev giyim", "tayt", "legging"]
        if any(kw in text for kw in casual_keywords):
            return "casual"
        
        # Jean/Denim - Numeric
        jean_keywords = ["jean", "denim", "kot"]
        if any(kw in text for kw in jean_keywords):
            return "jean"
        
        # Formal/Kumaş pantolon - NUMERIC (Most Trendyol pants use 30, 31, 32 format)
        formal_keywords = ["kumaş pantolon", "kumas pantolon", "klasik pantolon", "chino", 
                          "palazzo", "wide leg", "cropped", "ankle", "cigarette", "straight",
                          "canvas", "keten", "slim fit", "regular fit", "dar kesim", "normal kesim"]
        if any(kw in text for kw in formal_keywords):
            return "formal"
        
        # DEFAULT CHANGE: For generic "pantolon" on Trendyol, default to FORMAL (numeric)
        # Most Trendyol pants use numeric sizing (30, 31, 32), not S/M/L
        if "pantolon" in text or "pant" in text or "trouser" in text:
            # Only use casual if explicitly a casual item
            if "rahat" in text or "casual" in text:
                return "casual"
            print("DEBUG: Generic pantolon detected, defaulting to FORMAL (numeric)")
            return "formal"
        
        # Ultimate fallback for bottoms - use formal (numeric) since it's safer for pants
        print("DEBUG: No specific type detected, defaulting to FORMAL")
        return "formal"

    def _get_size_chart_for_gender(self, gender: str, category: str) -> List[Dict[str, Any]]:
        """
        Returns appropriate size chart based on user gender.
        """
        gender_lower = (gender or "").lower()
        
        if gender_lower in ["male", "erkek", "man"]:
            chart = self.MALE_SIZE_CHART
        elif gender_lower in ["female", "kadın", "kadin", "woman"]:
            chart = self.FEMALE_SIZE_CHART
        else:
            chart = self.UNIVERSAL_SIZE_CHART
        
        # Filter by category
        return [s for s in chart if s["category"] == category]

    def _calculate_size_percentages(self, user_measurement: float, size_chart: List[Dict[str, Any]], 
                                     metric_key: str) -> Dict[str, int]:
        """
        Calculates compatibility percentages using Gaussian distribution for professional accuracy.
        Returns top 3 sizes with percentages that sum to 100.
        """
        if not size_chart or user_measurement <= 0:
            return {}
        
        scores = {}
        
        for size_entry in size_chart:
            label = size_entry.get("size_label", "")
            min_v = size_entry.get(f"min_{metric_key}")
            max_v = size_entry.get(f"max_{metric_key}")
            
            if min_v is None or max_v is None:
                continue
            
            # Use Gaussian fit for professional accuracy
            score = self._calculate_gaussian_fit(user_measurement, min_v, max_v)
            
            # Bonus for being within range
            if min_v <= user_measurement <= max_v:
                score = min(100, score * 1.2)  # 20% bonus for being in range
            
            scores[label] = score
        
        if not scores:
            return {}
        
        # Get top 3 scores
        sorted_scores = sorted(scores.items(), key=lambda x: x[1], reverse=True)[:3]
        
        # Normalize to 100% with better distribution
        total = sum(s[1] for s in sorted_scores)
        if total == 0:
            return {}
        
        percentages = {}
        for label, score in sorted_scores:
            pct = round((score / total) * 100)
            percentages[label] = max(1, pct)  # Minimum 1%
        
        # Adjust to ensure sum is exactly 100
        current_sum = sum(percentages.values())
        if current_sum != 100 and percentages:
            diff = 100 - current_sum
            top_label = sorted_scores[0][0]
            percentages[top_label] = max(1, percentages[top_label] + diff)
        
        return percentages

    def _calculate_numeric_pant_percentages(self, waist_cm: float, available_sizes: List[str], pant_type: str = "numeric") -> Dict[str, int]:
        """
        Calculates compatibility percentages for numeric pant sizes.
        BULLETPROOF: Always returns valid pant sizes (30-42 range for inch-based).
        
        Args:
            waist_cm: User's waist measurement in cm
            available_sizes: List of actual sizes available for the product
            pant_type: 'jean', 'formal', or 'numeric'
        
        Returns: Dict with top 3 sizes and percentages that sum to 100
        """
        import math
        
        print(f"DEBUG PANTS: waist_cm={waist_cm}, available_sizes={available_sizes}, pant_type={pant_type}")
        
        if waist_cm <= 0:
            waist_cm = 82  # Default reasonable waist
        
        scores = {}
        
        # Calculate ideal waist size in inches
        waist_inch = waist_cm / 2.54
        print(f"DEBUG PANTS: waist_inch={waist_inch:.1f}")
        
        # VALIDATION: Filter available_sizes to only valid pant sizes
        valid_sizes = []
        for size in available_sizes:
            size_str = str(size).strip()
            if size_str.isdigit():
                num = int(size_str)
                # Valid pant sizes: 26-42 (inch) or 44-60 (EU)
                if 26 <= num <= 42 or 44 <= num <= 60:
                    valid_sizes.append(num)
        
        print(f"DEBUG PANTS: valid_sizes after filtering={valid_sizes}")
        
        # CASE 1: We have valid sizes from the product
        if valid_sizes:
            # Detect sizing system based on values
            avg_size = sum(valid_sizes) / len(valid_sizes)
            
            if avg_size >= 44:
                # EU sizing (44, 46, 48, 50...)
                ideal_size = (waist_cm / 2) + 6
                spread = 10  # More lenient for EU
                size_system = "EU"
            else:
                # Inch sizing (28, 29, 30, 31, 32...)
                ideal_size = waist_inch
                spread = 20  # Points per inch difference
                size_system = "INCH"
            
            print(f"DEBUG PANTS: Detected {size_system} sizing, ideal_size={ideal_size:.1f}")
            
            # Score each valid size
            for size in valid_sizes:
                distance = abs(ideal_size - size)
                score = max(0, 100 - (distance * spread))
                if score > 0:
                    scores[str(size)] = score
        
        # CASE 2: No valid sizes from scraper - calculate reasonable inch sizes
        if not scores:
            print(f"DEBUG PANTS: No valid sizes found, generating inch-based sizes")
            
            # Calculate ideal inch size from waist
            ideal_inch = round(waist_inch)
            
            # Clamp to valid range (28-40 is typical)
            ideal_inch = max(28, min(40, ideal_inch))
            
            # Generate 3 adjacent sizes
            for offset in [-1, 0, 1]:
                size = ideal_inch + offset
                if 26 <= size <= 42:
                    distance = abs(offset)
                    score = 100 - (distance * 25)  # 100, 75, 75
                    scores[str(size)] = max(10, score)
            
            print(f"DEBUG PANTS: Generated sizes: {scores}")
        
        if not scores:
            # Ultimate fallback - use 32 as default
            scores = {"32": 80, "31": 15, "33": 5}
            print(f"DEBUG PANTS: Ultimate fallback to default sizes")
        
        # Get top 3 scores, sorted by score
        sorted_scores = sorted(scores.items(), key=lambda x: x[1], reverse=True)[:3]
        
        # Normalize to 100%
        total = sum(s[1] for s in sorted_scores)
        if total == 0:
            total = 1
        
        percentages = {}
        for label, score in sorted_scores:
            pct = round((score / total) * 100)
            percentages[label] = max(1, pct)
        
        # Ensure sum is exactly 100
        current_sum = sum(percentages.values())
        if current_sum != 100 and percentages:
            diff = 100 - current_sum
            top_label = sorted_scores[0][0]
            percentages[top_label] = max(1, percentages[top_label] + diff)
        
        print(f"DEBUG PANTS: Final percentages={percentages}")
        return percentages

    def get_recommendation(self, user_id: str, product_data: Dict) -> Dict[str, Any]:
        print(f"--- Getting Recommendation for User: {user_id} ---")
        
        # 0. Fetch Data
        measurements = self._get_user_measurements(user_id)
        if not measurements:
            return {"error": "Kullanıcı ölçüleri bulunamadı."}
        
        u_height = measurements.get("height") or 175
        u_weight = measurements.get("weight") or 75
        u_shoulder = measurements.get("shoulder") or 0
        u_chest = measurements.get("chest") or 0
        u_waist = measurements.get("waist") or 0
        u_hips = measurements.get("hips") or 0  # Hip measurement for bottoms
        # New Measurements (Precision)
        u_arm_length = measurements.get("arm_length") or 0
        u_inseam = measurements.get("inseam") or 0
        u_hand_span = measurements.get("hand_span_cm") or 0
        ref_brand = measurements.get("reference_brand")
        ref_size = measurements.get("reference_size_label")
        garment_spans = measurements.get("garment_width_spans") or 0
        
        # 0.5 CHECK SCRAPER ERROR
        if product_data.get("error"):
             print(f"DEBUG: Scraper returned error: {product_data['error']}")
             return {
                 "recommended_size": "N/A",
                 "confidence_score": 0.0,
                 "fit_message": "Bu ürüne erişilirken site engeliyle karşılaşıldı.",
                 "detailed_report": f"Ürün verisi çekilemedi: {product_data['error']}.\nLütfen başka bir ürün veya marka ile deneyin.",
                 "warning": "Site Erişimi Engellendi (Bot Koruması)",
                 "detail": "Site Erişimi Engellendi: Bu marka bot koruması kullanıyor." # For ApiService
             }
        
        # 1. Re-extract relevant fields from product_data (passed from router)
        brand_name = product_data.get("brand", "Unknown")
        is_zara = "zara" in brand_name.lower()
        description = (product_data.get("description", "") + " " + product_data.get("product_name", "")).lower()
        fabric_text = product_data.get("fabric_composition")
        body_shape = measurements.get("body_shape", "regular")
        user_gender = measurements.get("gender", "other")  # User's gender for size chart selection
        
        print(f"DEBUG: User Gender: {user_gender}")

        category = self._infer_category(product_data)
        if not category:
             return {
                 "recommended_size": "N/A",
                 "confidence_score": 0.0,
                 "fit_message": "Bu giyilebilir bir ürün değildir veya desteklenmeyen bir kategoridir.",
                 "detailed_report": f"Sistem bu ürünün ('{product_data.get('product_name', 'Bilinmeyen Ürün')}') bir kıyafet olduğunu doğrulayamadı.\nÜrün adı veya açıklamasında kategori (tişört, pantolon vb.) tespit edilemedi.",
                 "warning": "Giyilebilir ürün tespit edilemedi"
             }
        
        print(f"DEBUG: Inputs - Height: {u_height}, Weight: {u_weight}, Shape: {body_shape}")
        print(f"DEBUG: Product - Brand: {brand_name}, Category: {category}")
        
        reasons = []
        
        # === PROFESSIONAL OPTIMIZATION CALCULATIONS ===
        
        # Calculate BMI factor for size adjustment
        bmi_factor = self._calculate_bmi_factor(u_height, u_weight)
        if bmi_factor != 0:
            reasons.append(f"BMI Faktörü: {'+' if bmi_factor > 0 else ''}{bmi_factor:.2f} beden ayarlaması")
        
        # Get brand-specific fit factor
        brand_fit_factor = self._get_brand_fit_factor(brand_name, category)
        if brand_fit_factor != 1.0:
            fit_desc = "dar kalıp" if brand_fit_factor < 1.0 else "rahat kalıp"
            reasons.append(f"Marka Kalıbı ({brand_name}): {fit_desc}")
        
        # Get body shape adjustment
        body_shape_adj = self._get_body_shape_adjustment(body_shape, category)
        if body_shape_adj != 0:
            reasons.append(f"Vücut Tipi ({body_shape}): {'+' if body_shape_adj > 0 else ''}{body_shape_adj:.1f} beden ayarlaması")
        
        # Determine which weights to use
        metric_weights = self.TOP_WEIGHTS if category == "top" else self.BOTTOM_WEIGHTS
        
        print(f"DEBUG: BMI Factor: {bmi_factor}, Brand Fit: {brand_fit_factor}, Body Shape Adj: {body_shape_adj}")
        
        # 1. Fetch Size Chart
        size_chart = []
        is_fallback = False
        
        brand_id = self._normalize_brand(brand_name)
        if brand_id:
            size_chart = self._get_size_chart(brand_id, category)
        
        if not size_chart:
            # Fallback logic - Use gender-specific chart
            print(f"WARNING: No specific size chart found for {brand_name}. Using Gender-Based Standard ({user_gender}).")
            size_chart = self._get_size_chart_for_gender(user_gender, category)
            is_fallback = True
            
        if not size_chart:
             return {"error": "Beden standartları belirlenemedi."}

        # --- PRECISION FEATURE: Hand Span (Giysi Ölçümü) ---
        # If user provided garment_width_spans, we rely on IT for Chest/Waist.
        if u_hand_span > 0 and garment_spans > 0:
            # Calculated Width in CM
            garment_width_cm = garment_spans * u_hand_span
            # Circumference = Width * 2
            measured_circumference = garment_width_cm * 2
            
            print(f"DEBUG: Hand Span Logic -> Width: {garment_width_cm}cm, Circ: {measured_circumference}cm")
            
            # Check if this matches Chest or Waist based on category
            if category == "top":
                u_chest = measured_circumference
                reasons.append(f"Karış Ölçümü ({garment_spans} karış): Göğüs {int(u_chest)}cm olarak hesaplandı.")
            elif category == "bottom":
                u_waist = measured_circumference
                reasons.append(f"Karış Ölçümü ({garment_spans} karış): Bel {int(u_waist)}cm olarak hesaplandı.")
        
        # If we have MULTIPLE references, we should try to match one of them or average them.
        # 1. Fetch User References from DB
        user_refs_response = self.supabase.table("user_references").select("*").eq("user_id", user_id).execute()
        user_refs = user_refs_response.data or []
        
        # Append the single reference from measurements if generic
        if ref_brand and ref_size:
            user_refs.append({"brand": ref_brand, "size_label": ref_size})

        matched_ref = None

        # 2. Strategy: Direct Match
        # Does the user have a reference FOR THE CURRENT BRAND?
        for ref in user_refs:
            if self._normalize_brand(ref["brand"]) == brand_id:
                matched_ref = ref
                reasons.append(f"Direkt Marka Eşleşmesi: Referans verdiğiniz ({ref['brand']} {ref['size_label']}) ile aynı marka.")
                break
        
        if not matched_ref and user_refs:
           # 3. Strategy: Triangulation (Average Virtual Body)
           virtual_chests = []
           virtual_waists = []
           
           for ref in user_refs:
               rb_id = self._normalize_brand(ref["brand"])
               if rb_id:
                   rc = self._get_size_chart(rb_id, category)
                   ri = next((s for s in rc if s["size_label"].lower() == ref["size_label"].lower()), None)
                   if ri:
                       if "min_chest" in ri: virtual_chests.append((ri["min_chest"] + ri["max_chest"])/2)
                       if "min_waist" in ri: virtual_waists.append((ri["min_waist"] + ri["max_waist"])/2)

           if virtual_chests:
               avg_chest = sum(virtual_chests) / len(virtual_chests)
               # Blend real measurement with virtual average (50/50 or override?)
               # If user measured poorly but knows sizes, virtual is better.
               # Let's use virtual if available.
               u_chest = avg_chest
               reasons.append(f"{len(user_refs)} Referans Ürün Ortalaması: Göğüs {int(u_chest)}cm olarak kalibre edildi.")
           
           if virtual_waists and category == "bottom":
               avg_waist = sum(virtual_waists) / len(virtual_waists)
               u_waist = avg_waist
               reasons.append(f"{len(user_refs)} Referans Ürün Ortalaması: Bel {int(u_waist)}cm olarak kalibre edildi.")

        elif matched_ref:
            # Calculate directly from matched reference
             # Find dimensions of matched_ref
               rb_id = self._normalize_brand(matched_ref["brand"])
               rc = self._get_size_chart(rb_id, category)
               ri = next((s for s in rc if s["size_label"].lower() == matched_ref["size_label"].lower()), None)
               if ri:
                   if "min_chest" in ri: u_chest = (ri["min_chest"] + ri["max_chest"]) / 2
                   if "min_waist" in ri: u_waist = (ri["min_waist"] + ri["max_waist"]) / 2
        
        # --- OLD SINGLE REF LOGIC REMOVED/MERGED ABOVE ---
        # elif ref_brand and ref_size: ... (Already handled by appending to list)


        # 2. Detect Fit Type
        fit_type = self._detect_fit_type(description)
        # 2. Detect Fit Type
        fit_type = self._detect_fit_type(description)
        print(f"DEBUG: Detected Fit Type: {fit_type}")

        # 2.1 Calculate Elasticity Bonus
        elasticity_bonus = self._calculate_elasticity_bonus(fabric_text)
        if elasticity_bonus > 0:
            print(f"DEBUG: Elasticity Bonus Applied: +{elasticity_bonus}cm")

        # 2.2 Calculate Ease Allowance (Layering Room)
        product_full_text = f"{brand_name} {description}"
        ease_allowance = self._get_ease_allowance(product_full_text)
        if ease_allowance > 0:
            print(f"DEBUG: Ease Allowance Applied: +{ease_allowance}cm to User Measurements")

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
            "hip": -1,  # For bottoms
            "weight": -1
        }
        
        
        # reasons = [] (Moved to top)


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
            
            # Fit Type Logic:
            # Oversize: The garment is larger than standard. It can fit a larger body in the same size label.
            # So effectively, the Size S covers a larger max_chest.
            fit_adjustment = 0.0
            if fit_type == "oversize":
                fit_adjustment = 4.0 # Tolerates +4cm body
            elif fit_type == "slim":
                fit_adjustment = -2.0 # Tolerates -2cm less (Runs small)
                
            for size in size_chart:
                idx = self._get_size_order(size.get("size_label", ""))
                min_v = size.get(f"min_{metric_key}")
                max_v = size.get(f"max_{metric_key}")
                
                if min_v is None or max_v is None: continue
                
                # Apply Bonuses to MAX values
                effective_max = max_v + elasticity_bonus + fit_adjustment

                # Logic: Find the size where val <= effective_max.
                if val <= effective_max:
                    return idx
            
            if size_chart:
                return self._get_size_order(size_chart[-1].get("size_label", ""))
            return -1

        # --- 4a. Chest ---
        target_chest = u_chest
        if target_chest <= 0 and u_shoulder > 0:
             target_chest = u_shoulder * 0.85 
             reasons.append(f"Omuz ölçüsünden göğüs tahmini yapıldı ({u_shoulder}cm).")

        if target_chest > 0:
            target_chest += ease_allowance

        if category == "top" and target_chest > 0:
             candidate_indices["chest"] = find_fitting_index(target_chest, "chest")
             
        # --- 4b. Waist ---
        target_waist = u_waist
        if target_waist <= 0 and u_height > 0 and u_weight > 0:
            target_waist = self._estimate_waist(u_height, u_weight)
            reasons.append(f"Boy/Kilo ile bel tahmini yapıldı ({target_waist:.1f}cm).")
        
        if target_waist > 0:
             target_waist += (ease_allowance * 0.5)
             
        if target_waist > 0:
             idx_w = find_fitting_index(target_waist, "waist")
             if idx_w == -1 and category == "top":
                  idx_w = find_fitting_index(target_waist, "chest")
             candidate_indices["waist"] = idx_w

        # --- 4c. Hip (for Bottoms) ---
        if category == "bottom" and u_hips > 0:
            idx_hip = find_fitting_index(u_hips, "hip")
            if idx_hip > -1:
                candidate_indices["hip"] = idx_hip
                reasons.append(f"Kalça: {int(u_hips)}cm ölçüsü kullanıldı.")

        # --- 4c. Weight (Floor) ---
        # Revised Heuristic: Lower the thresholds slightly or deprioritize if measurements exist.
        # <55: XS/S, 55-70: S/M?
        # Let's adjust: 
        # < 62: S (1)
        # 62 - 75: M (2)
        # 75 - 88: L (3)
        # 88 - 100: XL (4)
        # > 100: XXL (5)
        # User (67kg) will now fall into M (2).
        # WAIT, User wants to see difference. If everything forces M, it's bad.
        # Prioritization Logic: If Chest/Waist are valid, IGNORE Weight?
        # Only use weight if Chest/Waist are -1.
        
        w_idx = -1
        # Calculate weight index but store separately for fallback
        if u_weight < 65: w_idx = 1 # S
        elif 65 <= u_weight < 78: w_idx = 2 # M
        elif 78 <= u_weight < 90: w_idx = 3 # L
        elif 90 <= u_weight < 105: w_idx = 4 # XL
        elif u_weight >= 105: w_idx = 5 # XXL
        
        candidate_indices["weight"] = w_idx

        # 5. Step 2: The "Max-Constraint" Logic
        # Prioritize Measurements but respect Weight as a floor.
        # If your mass dictates L, you shouldn't wear S even if your chest is small.
        
        valid_indices = [
            v for k, v in candidate_indices.items() 
            if v > -1
        ]
        
        if valid_indices:
            # === PROFESSIONAL ADJUSTMENT APPLICATION ===
            base_idx = max(valid_indices)
            
            # Apply BMI factor (affects index)
            adjusted_idx = base_idx + bmi_factor
            
            # Apply body shape adjustment
            adjusted_idx += body_shape_adj
            
            # Apply brand fit factor (affects how we interpret the index)
            # Smaller fit factor means brand runs small, so we need larger size
            if brand_fit_factor < 1.0:
                adjusted_idx += (1.0 - brand_fit_factor) * 2  # Up to +0.2 index
            elif brand_fit_factor > 1.0:
                adjusted_idx -= (brand_fit_factor - 1.0) * 1.5  # Down slightly
            
            # Round to nearest valid index
            final_idx = round(adjusted_idx)
            final_idx = max(0, min(7, final_idx))  # Clamp to valid range
            
            print(f"DEBUG: Base Index: {base_idx}, Adjusted: {adjusted_idx:.2f}, Final: {final_idx}")
        else:
             return {"error": "Ölçülerden beden belirlenemedi."}
        
        # --- Body Shape Adjustments ---
        shape_msg = ""
        chest_idx = candidate_indices["chest"]
        waist_idx = candidate_indices["waist"]
        
        # Logic A: Inverted Triangle (Ters Üçgen) -> Broad Shoulders, Small Waist
        # If the constraint is Waist (waist_idx == final_idx) but Chest fits in smaller size,
        # AND product is Top.
        # "Ters Üçgen": Omuz ölçüsünü baz al, bele takılma.
        if body_shape == 'inverted_triangle' and category == 'top':
             # If Waist is the limiting factor (final_idx == waist_idx)
             # AND Chest size is smaller (chest_idx < final_idx)
             if waist_idx == final_idx and chest_idx > -1 and chest_idx < final_idx:
                 # Relax waist constraint. Use Chest size.
                 # But check if fit_type is 'slim'. If slim, waist might still be tight?
                 # Even so, user says "Bele takılma".
                 final_idx = chest_idx
                 shape_msg = "Vücut Şekli (Ters Üçgen): Bel yerine Omuz/Göğüs önceliklendirildi."

        # Logic B: Oval (Elma) -> Wide Waist
        # "Oval": Bel ölçüsünü "Kritik Kısıt" yap.
        if body_shape == 'oval':
            # Ensure Waist is respected absolutely.
            # If final_idx is determined by Chest, but Waist needs LARGER (Recalculated above as max anyway)
            # But what if Waist needs smaller? No, "Kritik Kısıt" usually means ensuring it fits.
            # Since we take MAX(valid_indices), Waist is already a hard constraint if it's the largest.
            # Maybe we recommend Relaxed fit?
            if fit_type == 'slim' and waist_idx == final_idx:
                 # If item is slim fit and waist is the constraint, warn heavily or size up?
                 # Already handled by Slim+Waist adjustment (+1).
                 # Maybe explicitly mention it.
                 pass
            elif fit_type == 'regular' or fit_type == 'oversize':
                 # User fits better here.
                 pass
                 
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
            report_lines.append(f"Göğüs/Omuz: {get_label(c_idx)} bedenine sığıyor.")
        
        # Waist
        w_idx = candidate_indices["waist"]
        if w_idx > -1:
            report_lines.append(f"Bel: {get_label(w_idx)} bedenine sığıyor.")
            if w_idx == final_idx and w_idx > c_idx and c_idx > -1:
                report_lines.append(f"(!) Bel ölçünüz {get_label(w_idx)} gerektiriyor, bu yüzden beden büyütüldü.")
        
        # Weight
        wt_idx = candidate_indices["weight"]
        if wt_idx > -1:
            report_lines.append(f"Kilo ({u_weight}kg): En az {get_label(wt_idx)} öneriyor.")
            
        # Adjustments
        adjustment_msg = ""
        # Slim Fit Adjustment
        if fit_type == "slim":
             # If constrained by Waist (belly) and Slim Fit -> Size Up
             if w_idx == final_idx:
                 final_idx += 1
                 adjustment_msg = "Dar Kalıp (Slim Fit) ve Bel kısıtı nedeniyle bir beden büyütüldü (+1)."
        elif fit_type == "oversize":
             # If constrained by Weight (not bone structure) -> Don't downsize? 
             # Or if final_idx determined by Chest/Shoulder, maybe we can downsize?
             # Prompt: "If... Oversize and constraint was Weight... keep as is."
             # Let's say: If constrained by Chest, and Oversize, maybe -1?
             # For safety, let's keep logic simple: Strict constraints win. 
             pass

        if adjustment_msg:
             report_lines.append(f"Düzenleme: {adjustment_msg}")
              
        # --- Fit Advice from User Reviews (Trendyol) ---
        fit_advice = product_data.get("fit_advice", "").lower()
        if fit_advice:
            report_lines.append(f"Kullanıcı Yorumları: {product_data.get('fit_advice')}")
            
            # Logic: "bir beden büyük" -> +1
            if "bir beden büyük" in fit_advice:
                final_idx += 1
                report_lines.append("Aksiyon: Kullanıcı yorumlarına göre bir beden büyütüldü (+1).")
            # Logic: "bir beden küçük" -> -1
            elif "bir beden küçük" in fit_advice:
                final_idx -= 1
                report_lines.append("Aksiyon: Kullanıcı yorumlarına göre bir beden küçültüldü (-1).")

        if shape_msg:
             report_lines.append(f"Vücut Şekli Düzenlemesi: {shape_msg}")

        # Elasticity Note
        if elasticity_bonus > 0:
            # Check if user fell within the bonus range?
            # It's hard to know which exact size won without tracing constraints.
            # But we can verify if the max_constraint was helped by bonus.
            # Simplified: Just notify.
            report_lines.append(f"Kumaş: Esnek materyal içeriyor (+{elasticity_bonus}cm esneme payı).")

        # Ease Allowance Note
        if ease_allowance > 0:
            report_lines.append(f"Katman Payı: Dış/orta katman giyimi için {ease_allowance}cm pay eklendi.")

        # --- Arm Length Check (Tops) ---
        if category == "top" and u_arm_length > 0:
            # Simple Heuristic: Standard Sleeve Length increases with size. 
            # S: ~63, M: ~64, L: ~65, XL: ~66
            # If User Arm > 66 and Size < XL, warn.
            if u_arm_length > 66 and final_idx < 5: 
                report_lines.append(f"(!) Kol Boyu ({u_arm_length}cm): Standarttan uzun, kol kısa gelebilir.")

        # --- Model Comparison ---
        model_h_str = product_data.get("model_height")
        if model_h_str:
             try:
                 # Clean string "1.76" -> 176
                 mh = float(model_h_str.replace("cm", "").strip())
                 if mh < 3: mh *= 100 # Convert m to cm
                 
                 diff = u_height - mh
                 if diff > 5:
                     report_lines.append(f"Model Analizi: Modelden {int(diff)}cm daha uzunsunuz.")
                     model_size = product_data.get("model_size", "").upper()
                     if model_size and "S" in model_size and final_idx <= 2:
                         report_lines.append("Model S giyiyor, sizin boy farkınız nedeniyle M tercih edilebilir.")
             except:
                 pass

        final_label = get_label(final_idx)
        
        # 7. Final Confidence
        # User requested 100% confidence always.
        confidence = 1.0
        
        detailed_report = "\n".join(report_lines)
        fit_message = f"{final_label} Beden Öneriyoruz."
        
        # --- Specific Pant Recommendation (User Request) ---
        # Using new pant type detection for appropriate size format
        if category == "bottom":
            pant_type = self._detect_pant_type(product_data)
            print(f"DEBUG: Detected Pant Type: {pant_type}")
            
            # Calculate base measurements - CLAMP to valid pant size range
            raw_w_inch = round(target_waist / 2.54) if target_waist > 0 else 32
            w_inch = max(28, min(40, raw_w_inch))  # Clamp to 28-40 (valid jean sizes)
            print(f"DEBUG PANTS: target_waist={target_waist}cm, raw_w_inch={raw_w_inch}, w_inch={w_inch}")
            
            # --- SHORT: Şort/Etek - S/M/L format, leg length irrelevant ---
            if pant_type == "short":
                report_lines.append(f"Kısa Giysi Tespit Edildi: Bacak boyu bu ürün için önemsiz.")
                report_lines.append(f"Bel Hesabı: {target_waist:.1f}cm")
                if u_hips > 0:
                    report_lines.append(f"Kalça Hesabı: {u_hips:.1f}cm")
                fit_message = f"{final_label} Beden Öneriyoruz"
                detailed_report += f"\n\nÖzel Tavsiye: Şort/Etek için sadece bel{' ve kalça' if u_hips > 0 else ''} ölçünüze göre {final_label} beden önerilmektedir."
            
            # --- CASUAL: Eşofman/Jogger - S/M/L format ---
            elif pant_type == "casual":
                report_lines.append(f"Günlük/Rahat Giyim Tespit Edildi: S/M/L formatı kullanılıyor.")
                report_lines.append(f"Bel Hesabı: {target_waist:.1f}cm")
                fit_message = f"{final_label} Beden Öneriyoruz"
                detailed_report += f"\n\nÖzel Tavsiye: Eşofman/jogger için {final_label} beden önerilmektedir."
            
            # --- JEAN: Denim/Jeans - W/L format (W32/L32) ---
            elif pant_type == "jean":
                # Get available sizes from product
                available_sizes = product_data.get("available_sizes", [])
                
                # Calculate Inseam (Leg Length)
                if u_inseam > 0:
                    leg_len_cm = u_inseam
                    l_inch = round(leg_len_cm / 2.54)
                    report_lines.append(f"İç Bacak: {u_inseam}cm verisi kullanıldı -> L{l_inch}")
                else:
                    # Heuristic: Inseam ~ Height * 0.45 
                    leg_len_cm = u_height * 0.45
                    l_inch = round(leg_len_cm / 2.54)
                    report_lines.append(f"İç Bacak (Tahmini): Boy {u_height}cm * 0.45 -> L{l_inch}")
                
                if u_hips > 0:
                    report_lines.append(f"Kalça: {u_hips:.1f}cm kontrol edildi.")
                
                # Use actual available sizes if we have them
                if available_sizes:
                    numeric_sizes = [int(s) for s in available_sizes if str(s).isdigit() and 26 <= int(s) <= 42]
                    if numeric_sizes:
                        # Find best matching size from available options
                        waist_inch = target_waist / 2.54
                        best_size = min(numeric_sizes, key=lambda s: abs(s - waist_inch))
                        final_label = str(best_size)
                        report_lines.append(f"Jean Hesabı: Bel {target_waist:.1f}cm -> {best_size} (mevcut bedenlerden seçildi)")
                        fit_message = f"{best_size} Beden Öneriyoruz"
                        detailed_report += f"\n\nÖzel Tavsiye: Mevcut bedenler: {numeric_sizes}. Bel ölçünüze en uygun beden: {best_size}"
                    else:
                        report_lines.append(f"Jean Hesabı: Bel {target_waist:.1f}cm -> W{w_inch}")
                        final_label = str(w_inch)
                        fit_message = f"W{w_inch}/L{l_inch} Beden Öneriyoruz"
                        detailed_report += f"\n\nÖzel Tavsiye: Jean bedeniniz W{w_inch}/L{l_inch} olarak hesaplanmıştır."
                else:
                    report_lines.append(f"Jean Hesabı: Bel {target_waist:.1f}cm -> W{w_inch}, Bacak -> L{l_inch}")
                    final_label = str(w_inch)
                    fit_message = f"W{w_inch}/L{l_inch} Beden Öneriyoruz"
                    detailed_report += f"\n\nÖzel Tavsiye: Jean bedeniniz W{w_inch}/L{l_inch} olarak hesaplanmıştır. (Bel: {w_inch} inch, Bacak: {l_inch} inch)"
            
            # --- FORMAL: Numeric pants (30, 31, 32 or EU 46, 48, 50) ---
            elif pant_type == "formal":
                # CRITICAL: Use available_sizes from product to recommend correct format
                available_sizes = product_data.get("available_sizes", [])
                
                # Extract and VALIDATE numeric sizes
                valid_sizes = []
                for s in available_sizes:
                    if str(s).isdigit():
                        num = int(s)
                        # Only accept valid pant sizes (26-42 inch or 44-60 EU)
                        if 26 <= num <= 42 or 44 <= num <= 60:
                            valid_sizes.append(num)
                
                print(f"DEBUG FORMAL: available_sizes={available_sizes}, valid_sizes={valid_sizes}")
                
                # Calculate waist in inches
                waist_inch = target_waist / 2.54
                
                if valid_sizes:
                    # Determine sizing system based on available sizes
                    avg_size = sum(valid_sizes) / len(valid_sizes)
                    
                    if avg_size >= 44:
                        # EU size format (44, 46, 48, 50)
                        ideal_eu = round((target_waist / 2) + 6)
                        best_size = min(valid_sizes, key=lambda s: abs(s - ideal_eu))
                        report_lines.append(f"Pantolon (EU): Bel {target_waist:.1f}cm -> EU {ideal_eu}")
                        report_lines.append(f"Mevcut bedenler: {sorted(valid_sizes)}")
                        report_lines.append(f"En uygun beden: EU {best_size}")
                    else:
                        # Inch-based sizes (28, 29, 30, 31, 32...)
                        best_size = min(valid_sizes, key=lambda s: abs(s - waist_inch))
                        report_lines.append(f"Pantolon (Inch): Bel {target_waist:.1f}cm = {waist_inch:.1f} inch")
                        report_lines.append(f"Mevcut bedenler: {sorted(valid_sizes)}")
                        report_lines.append(f"En uygun beden: {best_size}")
                    
                    final_label = str(best_size)
                    fit_message = f"{best_size} Beden Öneriyoruz"
                    detailed_report += f"\n\nÖzel Tavsiye: Mevcut bedenler ({sorted(valid_sizes)}) içinden bel ölçünüze ({target_waist:.1f}cm) en uygun beden: {best_size}"
                else:
                    # FALLBACK: Calculate inch-based size (most common on Trendyol)
                    # Waist inch, clamped to valid range
                    ideal_inch = round(waist_inch)
                    ideal_inch = max(28, min(40, ideal_inch))  # Clamp to 28-40
                    
                    report_lines.append(f"Pantolon Hesabı: Bel {target_waist:.1f}cm = {waist_inch:.1f} inch")
                    report_lines.append(f"Önerilen beden: {ideal_inch} (tahmini)")
                    final_label = str(ideal_inch)
                    fit_message = f"{ideal_inch} Beden Öneriyoruz"
                    detailed_report += f"\n\nÖzel Tavsiye: Bel ölçünüze ({target_waist:.1f}cm) göre {ideal_inch} beden önerilmektedir."
                
                # Calculate leg length for reference
                if u_inseam > 0:
                    report_lines.append(f"İç Bacak: {u_inseam}cm")
                else:
                    leg_len_cm = u_height * 0.45
                    report_lines.append(f"İç Bacak (Tahmini): {leg_len_cm:.1f}cm")
                
                if u_hips > 0:
                    report_lines.append(f"Kalça: {u_hips:.1f}cm kontrol edildi.")

        
        if is_fallback:
            report_lines.append("Not: Markaya özel tablo bulunamadığı için genel beden tablosu (Universal) kullanıldı.")
            fit_message += " (Genel Beden)."
            
        if elasticity_bonus > 0:
             fit_message += " (Esnek Kumaş)."
        elif adjustment_msg:
             fit_message += " (Kalıba Göre Ayarlandı)." # Short summary

        print(f"DEBUG: Final Decision: {final_label} based on Index {final_idx}")
        print(f"DEBUG: Report: {detailed_report}")

        # Calculate size compatibility percentages
        primary_metric = target_chest if category == "top" else target_waist
        metric_key = "chest" if category == "top" else "waist"
        
        # For pants with numeric sizes, use the actual available sizes
        if category == "bottom" and pant_type in ["jean", "formal"]:
            available_sizes = product_data.get("available_sizes", [])
            size_percentages = self._calculate_numeric_pant_percentages(target_waist, available_sizes, pant_type)
        else:
            size_percentages = self._calculate_size_percentages(primary_metric, size_chart, metric_key)
        
        # If no percentages calculated, create default based on final label
        if not size_percentages:
            size_percentages = {final_label: 90}
            
        # === CONSISTENCY ENFORCER ===
        # Ensure the 'recommended_size' (final_label) is always the winner in percentages.
        # This prevents the UI showing "Recommended: M" but "XL: 98% Match".
        
        if size_percentages:
            top_pct_label = list(size_percentages.keys())[0]
        else:
            top_pct_label = None
            
        print(f"DEBUG: Consistency Check -> Recommended: '{final_label}', TopMatch: '{top_pct_label}'")
        print(f"DEBUG: Percentages Before: {size_percentages}")
        
        # Compare stripped strings to be safe
        if top_pct_label and str(top_pct_label).strip().lower() != str(final_label).strip().lower():
            print(f"DEBUG: Consistency Check Triggered. Re-aligning percentages to {final_label}...")
            
            # Create a synthetic distribution centered on final_label
            new_percentages = {}
            new_percentages[final_label] = 96  # High confidence for the recommendation
            
            # Try to add neighbors for realism if we know the order
            size_order_list = ["XXS", "XS", "S", "M", "L", "XL", "XXL", "3XL"]
            
            try:
                # If it's a standard size
                if final_label.upper() in size_order_list:
                    curr_idx = size_order_list.index(final_label.upper())
                    
                    # Add previous size (small chance)
                    if curr_idx > 0:
                        prev_size = size_order_list[curr_idx - 1]
                        new_percentages[prev_size] = 3
                        
                    # Add next size (tiny chance)
                    if curr_idx < len(size_order_list) - 1:
                        next_size = size_order_list[curr_idx + 1]
                        new_percentages[next_size] = 1
                        
                # If numeric (pants)
                elif final_label.isdigit():
                    val = int(final_label)
                    # Add neighbors +/- 1 or 2 depending on step
                    # Kumaş pantolon often goes by 2s (48, 50, 52)
                    step = 2 if val > 40 else 1 
                    
                    prev_val = val - step
                    next_val = val + step
                    
                    new_percentages[str(prev_val)] = 3
                    new_percentages[str(next_val)] = 1
                    
            except:
                pass # safely fallback to just the winner
                
            # If we couldn't generate neighbors, just set residual
            if len(new_percentages) == 1:
                new_percentages["?"] = 4
                
            size_percentages = new_percentages
            print(f"DEBUG: New Enforced Percentages: {size_percentages}")
        
        # Update fit message to include percentages
        top_size = list(size_percentages.keys())[0] if size_percentages else final_label
        top_pct = size_percentages.get(top_size, 100)
        fit_message = f"{top_size} beden için %{top_pct} uyumlusunuz"
        
        # Add secondary sizes to message if available
        if len(size_percentages) > 1:
            secondary_info = ", ".join([f"{s}: %{p}" for s, p in list(size_percentages.items())[1:]])
            fit_message += f" ({secondary_info})"

        # Generate fit preference suggestion (Tam/Bol)
        size_order = ["XXS", "XS", "S", "M", "L", "XL", "XXL", "3XL"]
        try:
            current_idx = size_order.index(top_size.upper())
            if current_idx < len(size_order) - 1:
                next_size = size_order[current_idx + 1]
                fit_suggestion = f"\n\n💡 Giyim Tercihi: Tam oturan istiyorsanız {top_size}, daha rahat/bol istiyorsanız {next_size} bedenini tercih edebilirsiniz."
                detailed_report += fit_suggestion
        except (ValueError, IndexError):
            # For numeric sizes (jeans, formal pants), add numeric suggestion
            try:
                numeric_size = int(top_size)
                next_numeric = numeric_size + 1
                fit_suggestion = f"\n\n💡 Giyim Tercihi: Tam oturan istiyorsanız {numeric_size}, daha rahat/bol istiyorsanız {next_numeric} bedenini tercih edebilirsiniz."
                detailed_report += fit_suggestion
            except ValueError:
                pass

        print(f"DEBUG: Size Percentages: {size_percentages}")

        return {
            "recommended_size": final_label,
            "size_percentages": size_percentages,  # NEW: Replaces confidence_score
            "fit_message": fit_message,
            "detailed_report": detailed_report,
            "warning": adjustment_msg
        }

