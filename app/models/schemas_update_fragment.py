
class UserReferenceCreate(BaseModel):
    user_id: str
    brand: str
    size_label: str
    category: Optional[str] = None # 'top', 'bottom'

class UserReferenceResponse(BaseModel):
    id: int
    user_id: str
    brand: str
    size_label: str
    created_at: Optional[str] = None

    class Config:
        from_attributes = True
