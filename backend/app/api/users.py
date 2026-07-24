from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database.session import get_db
from app.api.dependencies import get_current_user
from app.models.user import User
from app.schemas.user import UserMeResponse
from app.crud.user_profile import get_full_name_for_user

router = APIRouter(prefix="/users", tags=["Users"])

@router.get("/me", response_model=UserMeResponse)
def get_me(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    full_name = get_full_name_for_user(db, current_user)
    return UserMeResponse(
        id=current_user.id,
        phone=current_user.phone,
        user_type=current_user.user_type.value,
        is_active=current_user.is_active,
        full_name=full_name,
    )