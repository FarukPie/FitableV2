import sys
import asyncio
# Fix for "NotImplementedError" in asyncio on Windows with Playwright
if sys.platform.startswith("win"):
    asyncio.set_event_loop_policy(asyncio.WindowsProactorEventLoopPolicy())

from fastapi import FastAPI, HTTPException, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import supabase
from app.routers import scraper, recommendation, user, auth

app = FastAPI(
    title="FitableV2 API",
    description="Backend API for FitableV2 with Supabase integration",
    version="1.0.0"
)

# Add CORS Middleware to allow Flutter Web to communicate with Backend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # Allow all origins for development
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    print(f"Validation Error: {exc.errors()}")
    print(f"Body: {await request.body()}")
    return JSONResponse(
        status_code=422,
        content={"detail": exc.errors(), "body": str(exc)},
    )

app.include_router(scraper.router)
app.include_router(recommendation.router)
app.include_router(user.router)
app.include_router(auth.router)

@app.get("/")
def health_check():
    try:
        # Simple query to verify connection
        # Check if the 'profiles' table exists or is accessible
        response = supabase.table("profiles").select("*").limit(1).execute()
        return {"status": "active", "db": "connected"}
    except Exception as e:
        # Log error in a real app
        print(f"Health check DB error: {e}")
        return {"status": "active", "db": "disconnected", "error": str(e)}
