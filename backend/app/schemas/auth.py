from pydantic import BaseModel, Field

class RegisterRequest(BaseModel):
    phone: str = Field(..., min_length=10, max_length=20)
    password: str = Field(..., min_length=6)
    user_type: str = Field(..., pattern="^(customer|worker)$")
    full_name: str = Field(..., min_length=2, max_length=100)

class RegisterResponse(BaseModel):
    message: str
    phone: str
    mock_otp: str

class VerifyOtpRequest(BaseModel):
    phone: str
    otp: str

class LoginRequest(BaseModel):
    phone: str
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"