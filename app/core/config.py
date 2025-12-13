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
settings = get_settings()
# Prefer Service Key if available to bypass RLS, otherwise fallback to Anon Key
key_to_use = settings.SUPABASE_SERVICE_KEY if settings.SUPABASE_SERVICE_KEY else settings.SUPABASE_KEY
supabase: Client = create_client(settings.SUPABASE_URL, key_to_use)
