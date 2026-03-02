"""Auth routes – register, login."""

from fastapi import APIRouter, HTTPException, status
from passlib.hash import bcrypt

from app.auth import create_token
from app.database import execute, query
from app.schemas import (
    LoginRequest,
    RegisterRequest,
    TokenResponse,
    UserResponse,
)

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post(
    "/register",
    response_model=TokenResponse,
    status_code=status.HTTP_201_CREATED,
)
def register(body: RegisterRequest):
    """Create a new user account and return a JWT."""
    existing = query("SELECT id FROM users WHERE email = %s", (body.email,))
    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")

    hashed = bcrypt.hash(body.password)
    row = execute(
        "INSERT INTO users (email, name, password) VALUES (%s, %s, %s) RETURNING *",
        (body.email, body.name, hashed),
    )
    token = create_token(row["id"])
    return TokenResponse(token=token, user=UserResponse(**row))


@router.post("/login", response_model=TokenResponse)
def login(body: LoginRequest):
    """Authenticate and return a JWT."""
    rows = query("SELECT * FROM users WHERE email = %s", (body.email,))
    if not rows:
        raise HTTPException(status_code=401, detail="Invalid credentials")

    user = rows[0]
    if not bcrypt.verify(body.password, user["password"]):
        raise HTTPException(status_code=401, detail="Invalid credentials")

    token = create_token(user["id"])
    return TokenResponse(token=token, user=UserResponse(**user))
    )
