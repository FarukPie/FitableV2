import sys
import asyncio
import uvicorn

if __name__ == "__main__":
    # Enforce WindowsProactorEventLoopPolicy on Windows for Playwright compatibility
    if sys.platform.startswith("win"):
        asyncio.set_event_loop_policy(asyncio.WindowsProactorEventLoopPolicy())
    
    # Note: 'reload=True' is disabled because on Windows the Uvicorn reloader subprocess 
    # fails to inherit the ProactorEventLoopPolicy required by Playwright.
    print("Starting server... (Auto-reload disabled for Playwright compatibility on Windows)")
    uvicorn.run("app.main:app", host="127.0.0.1", port=8000, reload=False)
