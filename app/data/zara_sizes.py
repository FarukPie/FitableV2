
# Zara Size Charts with Ranges
# Calculated midpoints for single-point values to create contiguous ranges.

ZARA_WOMEN_TOPS = [
    {"size_label": "XXS (32)", "min_chest": 0, "max_chest": 81, "min_waist": 0, "max_waist": 60, "min_hips": 0, "max_hips": 88},
    {"size_label": "XS (34)", "min_chest": 81, "max_chest": 84, "min_waist": 60, "max_waist": 64, "min_hips": 88, "max_hips": 92},
    {"size_label": "S (36)", "min_chest": 84, "max_chest": 88, "min_waist": 64, "max_waist": 68, "min_hips": 92, "max_hips": 96},
    {"size_label": "M (38)", "min_chest": 88, "max_chest": 93, "min_waist": 68, "max_waist": 73, "min_hips": 96, "max_hips": 101},
    {"size_label": "L (40-42)", "min_chest": 93, "max_chest": 99, "min_waist": 73, "max_waist": 79, "min_hips": 101, "max_hips": 107},
    {"size_label": "XL (44)", "min_chest": 99, "max_chest": 105, "min_waist": 79, "max_waist": 85, "min_hips": 107, "max_hips": 113},
    {"size_label": "XXL (46)", "min_chest": 105, "max_chest": 200, "min_waist": 85, "max_waist": 200, "min_hips": 113, "max_hips": 200},
]

# Using same base structure for bottoms as women's sizes usually apply to both or specific parts are prioritized
ZARA_WOMEN_BOTTOMS = ZARA_WOMEN_TOPS 

ZARA_MEN_TOPS = [
    {"size_label": "S", "min_chest": 91, "max_chest": 96},
    {"size_label": "M", "min_chest": 97, "max_chest": 102},
    {"size_label": "L", "min_chest": 103, "max_chest": 108},
    {"size_label": "XL", "min_chest": 109, "max_chest": 114},
    {"size_label": "XXL", "min_chest": 115, "max_chest": 120},
]

ZARA_MEN_BOTTOMS = [
    {"size_label": "S (38)", "min_waist": 76, "max_waist": 79},
    {"size_label": "M (40)", "min_waist": 80, "max_waist": 84},
    {"size_label": "L (42)", "min_waist": 85, "max_waist": 89},
    {"size_label": "XL (44)", "min_waist": 90, "max_waist": 95},
    {"size_label": "XXL (46)", "min_waist": 96, "max_waist": 100},
]

ZARA_KIDS = [
    {"size_label": "0-1 Ay", "min_height": 0, "max_height": 56},
    {"size_label": "1-3 Ay", "min_height": 56, "max_height": 62},
    {"size_label": "3-6 Ay", "min_height": 62, "max_height": 68},
    {"size_label": "6-9 Ay", "min_height": 68, "max_height": 74},
    {"size_label": "9-12 Ay", "min_height": 74, "max_height": 80},
    {"size_label": "12-18 Ay", "min_height": 80, "max_height": 86},
    {"size_label": "18-24 Ay", "min_height": 86, "max_height": 92},
    {"size_label": "2-3 Yaş", "min_height": 92, "max_height": 98},
    {"size_label": "3-4 Yaş", "min_height": 98, "max_height": 104},
    {"size_label": "4-5 Yaş", "min_height": 104, "max_height": 110},
    {"size_label": "5-6 Yaş", "min_height": 110, "max_height": 116},
    {"size_label": "7-8 Yaş", "min_height": 116, "max_height": 128},
    {"size_label": "9-10 Yaş", "min_height": 128, "max_height": 140},
    {"size_label": "11-12 Yaş", "min_height": 140, "max_height": 152},
    {"size_label": "13-14 Yaş", "min_height": 152, "max_height": 164},
]
