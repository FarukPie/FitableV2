from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel, EmailStr
from app.core.config import supabase

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
        # Supabase Auth Signup
        response = supabase.auth.sign_up({
            "email": user.email,
            "password": user.password,
            "options": {
                "data": {
                    "username": user.username
                }
            }
        })
        
        if not response.user:
             # In some configs, if email confirmation is on, user is created but session is null.
             # If error occurred, supabase-py usually raises GotrueError, but let's be safe.
             pass

        return {"status": "success", "message": "User registered successfully. Please check your email if confirmation is required.", "user": {"id": response.user.id, "email": response.user.email}}

    except Exception as e:
        print(f"Signup Error: {e}")
        # Extract meaningful error message if possible
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/login")
async def login(user: UserLogin):
    try:
        response = supabase.auth.sign_in_with_password({
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
