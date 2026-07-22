from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database.session import get_db
from app.schemas.auth import RegisterRequest, RegisterResponse, VerifyOtpRequest, LoginRequest, TokenResponse
from app.crud.user import get_user_by_phone, create_user_with_profile
from app.core.security import verify_password, create_access_token
from app.core.otp_store import generate_otp, verify_otp

router = APIRouter(prefix="/auth", tags=["Authentication"])

@router.post("/register", response_model=RegisterResponse)
def register(payload: RegisterRequest, db: Session = Depends(get_db)):
    if get_user_by_phone(db, payload.phone):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Phone number already registered")

    create_user_with_profile(db, payload.phone, payload.password, payload.user_type, payload.full_name)
    otp = generate_otp(payload.phone)

    return RegisterResponse(message="OTP sent (mock)", phone=payload.phone, mock_otp=otp)

@router.post("/verify-otp", response_model=TokenResponse)
def verify_otp_endpoint(payload: VerifyOtpRequest, db: Session = Depends(get_db)):
    if not verify_otp(payload.phone, payload.otp):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid or expired OTP")

    user = get_user_by_phone(db, payload.phone)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    user.is_active = True
    db.commit()

    token = create_access_token({"sub": str(user.id)})
    return TokenResponse(access_token=token)

@router.post("/login", response_model=TokenResponse)
def login(payload: LoginRequest, db: Session = Depends(get_db)):
    user = get_user_by_phone(db, payload.phone)
    if not user or not verify_password(payload.password, user.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid phone or password")

    if not user.is_active:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Account not verified")

    token = create_access_token({"sub": str(user.id)})
    return TokenResponse(access_token=token)