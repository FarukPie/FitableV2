from typing import Optional
from functools import lru_cache
from pydantic_settings import BaseSettings, SettingsConfigDict
from supabase import create_client, Client

class Settings(BaseSettings):
    SUPABASE_URL: str
    SUPABASE_KEY: str
    SUPABASE_SERVICE_KEY: Optional[str] = None # Key to bypass RLS

    model_config = SettingsConfigDict(env_file=".env", case_sensitive=True, extra="ignore")

@lru_cache()
def get_settings():
    return Settings()

# Initialize Supabase Client
# Initialize Clients
settings = get_settings()

# Anon Client (For Auth/Login)
supabase_anon: Client = create_client(settings.SUPABASE_URL, settings.SUPABASE_KEY)

# Admin/Service Client (For DB Ops / Admin Auth)
supabase_admin: Optional[Client] = None
if settings.SUPABASE_SERVICE_KEY:
    try:
        supabase_admin = create_client(settings.SUPABASE_URL, settings.SUPABASE_SERVICE_KEY)
        print("DEBUG: Initialized supabase_admin with Service Key.")
    except Exception as e:
        print(f"WARNING: Failed to init supabase_admin: {e}")

# Default 'supabase' client: Use Admin if available (for backend DB access), else Anon
# This preserves existing behavior for recommendation/scraper logic that uses 'supabase' variable.
if supabase_admin:
    print("DEBUG: Using SUPABASE_SERVICE_KEY for default 'supabase' client.")
    supabase = supabase_admin
else:
    print("WARNING: Using SUPABASE_KEY (Anon) for default 'supabase' client. RLS may apply.")
    supabase = supabase_anon
