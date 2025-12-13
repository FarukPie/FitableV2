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

    class Config:
        from_attributes = True
