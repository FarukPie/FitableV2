from fastapi import APIRouter, HTTPException
from app.core.config import supabase
from app.models.schemas import UserMeasurementCreate, HistoryItemCreate

router = APIRouter(
    prefix="", # Root level to match /update-measurements requirement
    tags=["User"]
)

@router.post("/update-measurements")
async def update_measurements(measurements: UserMeasurementCreate):
    try:
        data = measurements.model_dump(exclude_unset=True)
        
        # DEBUG: Print data being sent
        print(f"DEBUG: Upserting user measurements: {data}")

        # FIX 22P02: smallint columns cannot accept "175.0" (float strings). Cast to int.
        # Iterate over known numeric keys and cast them if present
        numeric_fields = ["height", "weight", "chest", "waist", "hips", "shoulder", "arm_length", "inseam", "foot_length"]
        for field in numeric_fields:
            if field in data and data[field] is not None:
                try:
                    data[field] = int(float(data[field]))
                except ValueError:
                    pass # Keep original if conversion fails

        # Check if user measurements already exist (get all to handle duplicates)
        existing = supabase.table("user_measurements").select("id").eq("user_id", data["user_id"]).order("updated_at", desc=True).execute()
        
        if existing.data and len(existing.data) > 0:
            # Use the most recent one as the source of truth.
            record_id = existing.data[0]['id']
            
            # If there are duplicates (more than 1 row), delete old ones to enforce "one line per user"
            if len(existing.data) > 1:
                print(f"DEBUG: Found {len(existing.data)} records for user {data['user_id']}. Cleaning up duplicates.")
                for i in range(1, len(existing.data)):
                    dup_id = existing.data[i]['id']
                    # Delete duplicate
                    supabase.table("user_measurements").delete().eq("id", dup_id).execute()
            
            # Update the latest record
            response = supabase.table("user_measurements").update(data).eq("id", record_id).execute()
        else:
            # Insert new
            response = supabase.table("user_measurements").insert(data).execute()
        
        return {"status": "success", "data": response.data}
    except Exception as e:
        print(f"Error updating measurements: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/measurements/{user_id}")
async def get_measurements(user_id: str):
    try:
        # Get the latest updated measurement
        response = supabase.table("user_measurements").select("*").eq("user_id", user_id).order("updated_at", desc=True).limit(1).execute()
        
        if not response.data:
            return {"status": "success", "data": None}
            
        return {"status": "success", "data": response.data[0]}
    except Exception as e:
        print(f"Error fetching measurements: {e}")
        raise HTTPException(status_code=500, detail=str(e))
@router.get("/history/{user_id}")
async def get_user_history(user_id: str):
    try:
        response = supabase.table("recommendation_history").select("*").eq("user_id", user_id).order("created_at", desc=True).execute()
        return {"status": "success", "data": response.data}
    except Exception as e:
        print(f"Error fetching history: {e}")
        raise HTTPException(status_code=500, detail=str(e))
@router.post("/history/add")
async def add_history(item: HistoryItemCreate):
    try:
        data = item.model_dump()
        response = supabase.table("recommendation_history").insert(data).execute()
        return {"status": "success", "data": response.data}
    except Exception as e:
        print(f"Error adding history: {e}")
        raise HTTPException(status_code=500, detail=str(e))
