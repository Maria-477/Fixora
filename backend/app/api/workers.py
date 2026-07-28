from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_user
from app.database.session import get_db

from app.models.user import User
from app.models.worker import Worker

from app.schemas.worker import (
    ExtractProfileRequest,
    ExtractProfileResponse,
    SaveProfileRequest,
)

from app.services.profile_extraction import extract_profile_from_text
from app.crud.worker_profile import create_or_update_profile

router = APIRouter(
    prefix="/workers",
    tags=["Workers"],
)


def _require_worker(current_user: User):
    if current_user.user_type != "worker":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only workers can access this endpoint.",
        )


def _get_worker(db: Session, user_id: int) -> Worker:
    worker = (
        db.query(Worker)
        .filter(Worker.user_id == user_id)
        .first()
    )

    if not worker:
        raise HTTPException(
            status_code=404,
            detail="Worker record not found.",
        )

    return worker


@router.post(
    "/extract-profile",
    response_model=ExtractProfileResponse,
)
def extract_profile(
    payload: ExtractProfileRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    _require_worker(current_user)

    return extract_profile_from_text(
        db,
        payload.transcript,
    )


@router.post("/profile")
def save_profile(
    payload: SaveProfileRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    _require_worker(current_user)

    worker = _get_worker(
        db,
        current_user.id,
    )

    profile = create_or_update_profile(
        db,
        worker.id,
        payload,
    )

    return {
        "message": "Profile saved successfully.",
        "profile_id": profile.id,
    }