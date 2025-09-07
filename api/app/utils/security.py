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
    return jwt.encode(claims, settings.secret_key, algorithm=settings.algorithm)


def _jwt_decode(token: str) -> Dict[str, Any]:
    return jwt.decode(token, settings.secret_key, algorithms=[settings.algorithm])


def create_access_token(data: Dict[str, Any], expires_minutes: Optional[int] = None) -> str:
    to_encode = data.copy()
    exp_minutes = expires_minutes if expires_minutes is not None else settings.access_token_expire_minutes
    expire = datetime.now(timezone.utc) + timedelta(minutes=int(exp_minutes))
    if "sub" in to_encode:
        to_encode["sub"] = str(to_encode["sub"])
    to_encode.update({"exp": expire, "type": "access"})
    return _jwt_encode(to_encode)


def create_refresh_token(user_id: int, days: int = 30) -> str:
    expire = datetime.now(timezone.utc) + timedelta(days=days)
    to_encode = {"sub": str(user_id), "exp": expire, "type": "refresh"}
    return _jwt_encode(to_encode)


def get_user_id_from_token(token: str) -> int:
    try:
        payload = _jwt_decode(token)
        sub = payload.get("sub")
        if sub is None:
            raise JWTError("Token sin 'sub'")
        return int(sub)
    except Exception as e:
        raise JWTError(f"Token inválido: {e}") from e


def get_user_id_from_refresh_token(token: str) -> int:
    """
    Decodifica y valida que sea un refresh token.
    """
    try:
        payload = _jwt_decode(token)
        if payload.get("type") != "refresh":
            raise JWTError("El token no es de tipo 'refresh'")
        sub = payload.get("sub")
        if not sub:
            raise JWTError("Refresh token sin 'sub'")
        return int(sub)
    except Exception as e:
        raise JWTError(f"Refresh token inválido: {e}") from e
