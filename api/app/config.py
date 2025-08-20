# api/app/config.py
from typing import List
from pydantic import Field, AliasChoices
from pydantic_settings import BaseSettings, SettingsConfigDict
import json

DEFAULT_ORIGINS = [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    "http://localhost:8080",
    "http://127.0.0.1:8080",
]

class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        case_sensitive=True,
        extra="ignore",
    )

    # --- App info ---
    app_name: str = Field("ERP API", validation_alias=AliasChoices("APP_NAME", "app_name"))
    version: str = Field("1.0.0", validation_alias=AliasChoices("VERSION", "version"))
    description: str = Field(
        "Sistema de Gestión Empresarial - API Backend",
        validation_alias=AliasChoices("DESCRIPTION", "description"),
    )

    # --- DB (ojo: host 'postgres' es el nombre del servicio en docker-compose) ---
    database_url: str = Field(
        "postgresql+asyncpg://erp_user:erp_password123@postgres:5432/erp_db",
        validation_alias=AliasChoices("DATABASE_URL", "database_url")
    )
    database_url_sync: str = Field(
        "postgresql://erp_user:erp_password123@postgres:5432/erp_db",
        validation_alias=AliasChoices("DATABASE_URL_SYNC", "database_url_sync")
    )

    # --- Server ---
    host: str = Field("0.0.0.0", validation_alias=AliasChoices("HOST", "host"))
    port: int = Field(8000, validation_alias=AliasChoices("PORT", "port"))
    debug: bool = Field(True, validation_alias=AliasChoices("DEBUG", "debug"))

    # --- Security ---
    secret_key: str = Field("cambia-esto-en-produccion", validation_alias=AliasChoices("SECRET_KEY", "secret_key"))
    algorithm: str = Field("HS256", validation_alias=AliasChoices("ALGORITHM", "algorithm"))
    access_token_expire_minutes: int = Field(
        30, validation_alias=AliasChoices("ACCESS_TOKEN_EXPIRE_MINUTES", "access_token_expire_minutes")
    )

    # --- CORS ---
    # Leer como string crudo y convertir a lista (soporta JSON o CSV)
    allowed_origins_raw: str = Field(
        "", validation_alias=AliasChoices("ALLOWED_ORIGINS", "allowed_origins")
    )

    # --- Misc ---
    max_upload_size: int = Field(10 * 1024 * 1024, validation_alias=AliasChoices("MAX_UPLOAD_SIZE", "max_upload_size"))
    items_per_page: int = Field(50, validation_alias=AliasChoices("ITEMS_PER_PAGE", "items_per_page"))

    @property
    def allowed_origins(self) -> List[str]:
        v = (self.allowed_origins_raw or "").strip()
        if not v:
            return DEFAULT_ORIGINS
        # 1) intenta JSON
        try:
            data = json.loads(v)
            if isinstance(data, list):
                return [str(x).strip() for x in data if str(x).strip()]
        except Exception:
            pass
        # 2) fallback CSV
        return [s.strip() for s in v.split(",") if s.strip()]

settings = Settings()

def get_database_url() -> str:
    return settings.database_url

def get_database_url_sync() -> str:
    return settings.database_url_sync
