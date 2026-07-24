from pydantic import BaseModel

class UserMeResponse(BaseModel):
    id: int
    phone: str
    user_type: str
    is_active: bool
    full_name: str | None = None

    class Config:
        from_attributes = True