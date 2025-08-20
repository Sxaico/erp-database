# api/app/main.py

from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from contextlib import asynccontextmanager
from datetime import datetime, timezone
import logging
import uvicorn

from .config import settings
from .database import init_db, close_db, test_connection

# Importar todos los modelos para que SQLAlchemy los registre
from .auth import models as auth_models
from .projects import models as project_models

from .auth.routes import auth_router
from .projects.routes import router as projects_router

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("🚀 Iniciando ERP API...")
    try:
        await init_db()
        if await test_connection():
            logger.info("✅ Base de datos conectada correctamente")
        else:
            logger.error("❌ Error en la conexión a la base de datos")
    except Exception as e:
        logger.error(f"❌ Error durante el startup: {str(e)}")
        raise
    logger.info("🎉 ERP API iniciada correctamente")
    yield
    logger.info("🔄 Cerrando ERP API...")
    await close_db()
    logger.info("✅ ERP API cerrada correctamente")


app = FastAPI(
    title=settings.app_name,
    version=settings.version,
    description=settings.description,
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.exception_handler(HTTPException)
async def http_exception_handler(request, exc: HTTPException):
    return JSONResponse(status_code=exc.status_code, content={
        "detail": exc.detail,
        "status_code": exc.status_code,
        "success": False
    })


@app.exception_handler(Exception)
async def general_exception_handler(request, exc: Exception):
    logger.error(f"Error no controlado: {str(exc)}")
    return JSONResponse(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, content={
        "detail": "Error interno del servidor",
        "status_code": 500,
        "success": False
    })


@app.get("/")
async def root():
    return {
        "message": "ERP System API",
        "version": settings.version,
        "status": "active",
        "docs": "/docs",
        "redoc": "/redoc"
    }


@app.get("/health")
async def health_check():
    try:
        db_status = await test_connection()
        return {
            "status": "healthy" if db_status else "unhealthy",
            "database": "connected" if db_status else "disconnected",
            "version": settings.version,
            "timestamp": datetime.now(timezone.utc).isoformat()
        }
    except Exception as e:
        logger.error(f"Error en health check: {str(e)}")
        return JSONResponse(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            content={"status": "unhealthy", "database": "error", "error": str(e), "version": settings.version}
        )


# Routers
app.include_router(auth_router, prefix="/api/auth", tags=["Authentication"], responses={401: {"description": "Unauthorized"}, 403: {"description": "Forbidden"}})
app.include_router(projects_router, prefix="/api/projects", tags=["Projects & Tasks"])


def start_server():
    uvicorn.run(
        "app.main:app",
        host=settings.host,
        port=settings.port,
        reload=settings.debug,
        log_level="info"
    )


if __name__ == "__main__":
    start_server()