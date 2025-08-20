# api/app/database.py
import logging
from sqlalchemy import create_engine, MetaData, text
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker, declarative_base
from .config import settings

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# --- Motores ---
async_engine = create_async_engine(
    settings.database_url,
    echo=settings.debug,
    pool_pre_ping=True,
    pool_recycle=300,
)

sync_engine = create_engine(
    settings.database_url_sync,
    echo=settings.debug,
    pool_pre_ping=True,
    pool_recycle=300,
)

# --- Sesiones ---
AsyncSessionLocal = sessionmaker(
    bind=async_engine,
    class_=AsyncSession,
    expire_on_commit=False,
)

SessionLocal = sessionmaker(
    bind=sync_engine,
    autocommit=False,
    autoflush=False,
)

# --- Base & metadata ---
Base = declarative_base()
metadata = MetaData()


async def get_async_db() -> AsyncSession:
    """
    Dependency: sesión async
    """
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise


def get_db():
    """
    Dependency: sesión sync
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


async def init_db():
    """
    Refleja tablas existentes y valida la conexión.
    """
    try:
        async with async_engine.begin() as conn:
            # Ejecuta la reflexión en el hilo sync del engine async
            await conn.run_sync(lambda sc: metadata.reflect(bind=sc))
            logger.info("✅ Conexión a PostgreSQL OK")
            logger.info(f"📊 Tablas encontradas: {len(metadata.tables)}")
            if metadata.tables:
                logger.info(f"📋 {', '.join(list(metadata.tables.keys()))}")
    except Exception as e:
        logger.error(f"❌ Error al conectar/reflejar DB: {e}")
        raise


async def close_db():
    try:
        await async_engine.dispose()
        sync_engine.dispose()
        logger.info("✅ Conexiones DB cerradas")
    except Exception as e:
        logger.error(f"❌ Error al cerrar DB: {e}")


async def test_connection() -> bool:
    """
    SELECT 1 usando SQLAlchemy 2.0 (text()).
    """
    try:
        async with AsyncSessionLocal() as session:
            result = await session.execute(text("SELECT 1"))
            return result.scalar() == 1
    except Exception as e:
        logger.error(f"❌ Test de conexión falló: {e}")
        return False
