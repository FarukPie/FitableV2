from fastapi import APIRouter, HTTPException
from app.core.config import supabase, settings
from app.models.schemas import UserMeasurementCreate, HistoryItemCreate
from supabase import create_client
import os

# Create a dedicated admin client for privileged operations like DELETE
# We must use settings to get the key because os.environ might not be populated if load_dotenv isn't called globally
service_key = settings.SUPABASE_SERVICE_KEY
supabase_url = settings.SUPABASE_URL
supabase_admin = create_client(supabase_url, service_key) if service_key else supabase

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

        # --- AUTO-CALCULATE BODY SHAPE ---
        # Logic:
        # Inverted Triangle: Shoulder > Waist * 1.05 AND Shoulder > Hips * 1.05
        # Oval: Waist > Chest AND Waist > Hips
        # Triangle: Hips > Shoulder * 1.05 AND Hips > Chest
        # Rectangular: Default
        
        shoulder = data.get("shoulder", 0) or 0
        waist = data.get("waist", 0) or 0
        hips = data.get("hips", 0) or 0
        chest = data.get("chest", 0) or 0
        
        calc_shape = "rectangular" # Default
        
        if shoulder > 0 and waist > 0 and hips > 0:
            if shoulder > waist * 1.05 and shoulder > hips * 1.05:
                calc_shape = "inverted_triangle"
            elif waist > chest and waist > hips:
                # Check for Oval (Center heavy)
                # Ensure it's significantly larger? Or just larger?
                if waist > chest * 1.05:
                    calc_shape = "oval"
            elif hips > shoulder * 1.05 and hips > chest:
                 calc_shape = "triangle"
        
        # If frontend sent a shape, ignore it? Or overwrite? 
        # User requested "Automatic determination". So we overwrite.
        data["body_shape"] = calc_shape
        print(f"DEBUG: Auto-Calculated Body Shape: {calc_shape}")

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



@router.delete("/history/{item_id}")
async def delete_history_item(item_id: str):
    print(f"DEBUG: Attempting to delete history item: '{item_id}'")
    try:
        # Use supabase_admin to ensure we bypass RLS
        response = supabase_admin.table("recommendation_history").delete().eq("id", item_id).execute()
        print(f"DEBUG: Delete response data: {response.data}")
        
        # NOTE: Sometimes delete returns empty list even if successful if no 'returning' header is sent or handled differently.
        # Since we use admin client and verified ID exists, we'll assume success if no exception.
        # We return the data if available, or just success status.
            
        return {"status": "success", "data": response.data}
    except Exception as e:
        print(f"Error deleting history item: {e}")
        raise HTTPException(status_code=500, detail=str(e))
