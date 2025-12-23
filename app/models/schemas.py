from typing import Optional
from pydantic import BaseModel, HttpUrl

class UserMeasurementCreate(BaseModel):
    user_id: str # Added user_id
    gender: str
    height: Optional[float] = None
    weight: Optional[float] = None
    chest: Optional[float] = None
    waist: Optional[float] = None
    hips: Optional[float] = None
    shoulder: Optional[float] = None
    arm_length: Optional[float] = None
    inseam: Optional[float] = None
    foot_length: Optional[float] = None
    foot_length: Optional[float] = None
    body_shape: Optional[str] = None # 'rectangular', 'triangle', 'inverted_triangle', 'oval'
    # Precision Features
    hand_span_cm: Optional[float] = None
    reference_brand: Optional[str] = None # Name of the brand (e.g. "Zara")
    reference_size_label: Optional[str] = None # e.g. "M", "32"
    garment_width_spans: Optional[float] = None # If user calibrated garment width

    class Config:
        from_attributes = True

class BrandSchema(BaseModel):
    id: Optional[int] = None
    name: str
    website_url: Optional[str] = None # Assuming website_url might be optional or string

    class Config:
        from_attributes = True

class SizeCatalogSchema(BaseModel):
    brand_id: int
    category: str
    gender: str
    size_label: str
    fit_type: Optional[str] = None
    min_chest: Optional[float] = None
    max_chest: Optional[float] = None
    # Add other min/max fields as implied by "etc" in requirements if needed, 
    # but sticking to specific requested fields plus generic extensibility if required.
    # User said "etc", so I will add common ones for sizing or keep it minimal as per specific instruction or leave as is.
    # The prompt listed: "min_chest, max_chest, etc."
    # I'll add a few reasonable ones like waist/hips since they match measurement fields.
    min_waist: Optional[float] = None
    max_waist: Optional[float] = None
    min_hips: Optional[float] = None
    max_hips: Optional[float] = None

    class Config:
        from_attributes = True

class HistoryItemCreate(BaseModel):
    user_id: str
    product_name: str
    brand: str
    product_url: str
    image_url: str
    price: str
    recommended_size: str
    confidence_score: float
    size_percentages: Optional[str] = None  # JSON string: {"31": 38, "30": 24, "32": 38}

    class Config:
        from_attributes = True

class ProductScrapeResult(BaseModel):
    brand: str
    product_name: str
    price: str
    image_url: str
    description: str
    product_url: str
    fabric_composition: Optional[str] = None
    model_height: Optional[str] = None
    model_size: Optional[str] = None
    error: Optional[str] = None

    class Config:
        from_attributes = True

class UserReferenceCreate(BaseModel):
    user_id: str
    brand: str
    size_label: str


class UserReferenceResponse(BaseModel):
    id: int
    user_id: str
    brand: str
    size_label: str
    created_at: Optional[str] = None

    class Config:
        from_attributes = True
