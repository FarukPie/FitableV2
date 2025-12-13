from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel, EmailStr
from app.core.config import supabase, settings, supabase_admin as admin_client, supabase_anon

# Use the centralized admin client from config
# Use the centralized admin client from config
supabase_admin = admin_client or supabase

router = APIRouter(
    prefix="/auth",
    tags=["Authentication"]
)

class UserRegister(BaseModel):
    email: EmailStr
    password: str
    username: str | None = None

class UserLogin(BaseModel):
    email: EmailStr
    password: str

@router.post("/signup")
async def signup(user: UserRegister):
    try:
        # Use Supabase Admin API to create user with auto-confirmation
        params = {
            "email": user.email,
            "password": user.password,
            "email_confirm": True,
            "user_metadata": {
                "username": user.username
            }
        }
        
        # Check if we are running with service role key (we should be)
        # Attempt to use admin.create_user via dedicated admin client
        print(f"DEBUG: Attempting to create user {user.email} with admin privileges")
        response = supabase_admin.auth.admin.create_user(params)
        
        print(f"DEBUG: Create User Response: {response}")
        
        return {"status": "success", "message": "User registered and confirmed. You can now login.", "user": {"id": response.user.id, "email": response.user.email}}

    except Exception as e:
        print(f"Signup Error: {e}")
        # Extract meaningful error message if possible
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/login")
async def login(user: UserLogin):
    try:
        # Use Anon Client for standard password login
        response = supabase_anon.auth.sign_in_with_password({
            "email": user.email,
            "password": user.password
        })

        if response.session:
            return {
                "status": "success",
                "access_token": response.session.access_token,
                "refresh_token": response.session.refresh_token,
                "user": {
                    "id": response.user.id,
                    "email": response.user.email,
                    # Add other fields if needed from response.user.user_metadata
                }
            }
        else:
             raise HTTPException(status_code=401, detail="Invalid credentials or email not confirmed")

    except Exception as e:
        print(f"Login Error: {e}")
        raise HTTPException(status_code=401, detail=str(e))

@router.post("/logout")
async def logout():
    try:
        supabase.auth.sign_out()
        return {"status": "success"}
    except Exception as e:
         raise HTTPException(status_code=500, detail=str(e))
