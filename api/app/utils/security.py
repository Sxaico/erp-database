# api/app/utils/security.py
from datetime import datetime, timedelta, timezone
from typing import Any, Optional, Dict

from jose import jwt, JWTError
from passlib.context import CryptContext

from ..config import settings

# BCrypt para hash/verify
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(plain_password: str, password_hash: str) -> bool:
    try:
        return pwd_context.verify(plain_password, password_hash)
    except Exception:
        return False


def _jwt_encode(claims: Dict[str, Any]) -> str:
    """
    Encapsula el encode, usa secret y algorithm de settings.
    """
    return jwt.encode(claims, settings.secret_key, algorithm=settings.algorithm)


def _jwt_decode(token: str) -> Dict[str, Any]:
    """
    Decodifica y valida firma/exp.
    Lanza JWTError si no es válido/expirado.
    """
    return jwt.decode(token, settings.secret_key, algorithms=[settings.algorithm])


def create_access_token(data: Dict[str, Any], expires_minutes: Optional[int] = None) -> str:
    """
    Crea un access token JWT.
    Debe incluir data["sub"] como string o int del user_id.
    """
    to_encode = data.copy()

    exp_minutes = expires_minutes if expires_minutes is not None else settings.access_token_expire_minutes
    expire = datetime.now(timezone.utc) + timedelta(minutes=int(exp_minutes))

    # Asegurar string en "sub"
    if "sub" in to_encode:
        to_encode["sub"] = str(to_encode["sub"])

    to_encode.update({"exp": expire, "type": "access"})
    return _jwt_encode(to_encode)


def create_refresh_token(user_id: int, days: int = 30) -> str:
    """
    Crea un refresh token simple.
    """
    expire = datetime.now(timezone.utc) + timedelta(days=days)
    to_encode = {"sub": str(user_id), "exp": expire, "type": "refresh"}
    return _jwt_encode(to_encode)


def get_user_id_from_token(token: str, expected_type: Optional[str] = "access") -> int:
    """
    Devuelve el user_id (int) desde "sub" del JWT.
    Si expected_type es "access" o "refresh", exige ese tipo.
    Lanza JWTError si es inválido/expirado.
    """
    try:
        payload = _jwt_decode(token)
        tok_type = payload.get("type")
        sub = payload.get("sub")
        if sub is None:
            raise JWTError("Token sin 'sub'")
        if expected_type and tok_type != expected_type:
            raise JWTError(f"Tipo de token inválido: se esperaba '{expected_type}', vino '{tok_type}'")
        return int(sub)
    except Exception as e:
        # Re-empaquetar como JWTError para que los callers traten 401
        raise JWTError(f"Token inválido: {e}") from e


def get_user_id_from_refresh_token(token: str) -> int:
    """
    Helper explícito para refresh tokens.
    """
    return get_user_id_from_token(token, expected_type="refresh")
