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
    full_name: str
    gender: str
    age: int

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
                "username": user.username,
                "full_name": user.full_name,
                "gender": user.gender,
                "age": user.age
            }
        }
        
        # Check if we are running with service role key (we should be)
        # Attempt to use admin.create_user via dedicated admin client
        print(f"DEBUG: Attempting to create user {user.email} with admin privileges")
        response = supabase_admin.auth.admin.create_user(params)
        
        print(f"DEBUG: Create User Response: {response}")
        
        # Auto-Login: Immediately sign in with password to get tokens
        login_response = supabase_anon.auth.sign_in_with_password({
            "email": user.email,
            "password": user.password
        })

        if login_response.session:
            return {
                "status": "success",
                "message": "User registered and logged in.",
                "access_token": login_response.session.access_token,
                "refresh_token": login_response.session.refresh_token,
                "user": {
                    "id": response.user.id,
                    "email": response.user.email,
                    "user_metadata": response.user.user_metadata
                }
            }
        else:
             # Should not happen if create_user succeeded with auto-confirm
             return {"status": "success", "message": "User registered. Please login manually."}

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
                    "user_metadata": response.user.user_metadata
                }
            }
        else:
             raise HTTPException(status_code=401, detail="Invalid credentials or email not confirmed")

    except Exception as e:
        print(f"Login Error: {e}")
        raise HTTPException(status_code=401, detail=str(e))

    except Exception as e:
         raise HTTPException(status_code=500, detail=str(e))

@router.get("/me")
async def get_user_me(token: str = Depends(lambda x: x)):
    # This is a bit of a hack since we are not using a proper dependency for Bearer token extraction
    # Normally we would use fastapi.security.HTTPBearer.
    # But let's assume the frontend sends the token in the header and we use Supabase to validate it.
    pass 

from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
security = HTTPBearer()

@router.get("/me")
async def get_user_me(credentials: HTTPAuthorizationCredentials = Depends(security)):
    try:
        token = credentials.credentials
        response = supabase_anon.auth.get_user(token)
        
        if response.user:
            return {
                "status": "success",
                "user": {
                    "id": response.user.id,
                    "email": response.user.email,
                    "user_metadata": response.user.user_metadata
                }
            }
        else:
             raise HTTPException(status_code=401, detail="Invalid token")
    except Exception as e:
        print(f"Get Me Error: {e}")
        raise HTTPException(status_code=401, detail=str(e))

class UserGoogleLogin(BaseModel):
    id_token: str
    access_token: str | None = None

@router.post("/google")
async def google_login(data: UserGoogleLogin):
    try:
        print(f"DEBUG: Attempting Google Login with token: {data.id_token[:10]}...")
        response = supabase_anon.auth.sign_in_with_id_token({
            "provider": "google",
            "token": data.id_token,
            "access_token": data.access_token
        })

        if response.session:
            return {
                "status": "success",
                "access_token": response.session.access_token,
                "refresh_token": response.session.refresh_token,
                "user": {
                    "id": response.user.id,
                    "email": response.user.email,
                }
            }
        else:
             raise HTTPException(status_code=401, detail="Google authentication failed")

    except Exception as e:
        print(f"Google Login Error: {e}")
        raise HTTPException(status_code=401, detail=str(e))

@router.delete("/delete/{user_id}")
async def delete_user(user_id: str):
    try:
        # Use Supabase Admin API to delete user
        print(f"DEBUG: Attempting to delete user {user_id}")
        response = supabase_admin.auth.admin.delete_user(user_id)
        print(f"DEBUG: Delete User Response: {response}")
        return {"status": "success", "message": "User deleted successfully"}
    except Exception as e:
        print(f"Delete User Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))
