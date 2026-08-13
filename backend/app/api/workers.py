from app.models.worker_profile import WorkerProfile
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

from app.models.worker_skill import WorkerSkill
from app.models.skill import Skill
from app.models.portfolio_image import PortfolioImage
from app.services.translation_service import translate_to_english
from app.crud.review import get_worker_rating_summary

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

    english_text = translate_to_english(
    payload.transcript,
    payload.source_language,
    )

    result = extract_profile_from_text(
       db,
       english_text,
    )

    result["raw_transcript"] = payload.transcript

    return result


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


@router.get("/profile/me")
def get_my_profile(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    _require_worker(current_user)

    worker = _get_worker(
        db,
        current_user.id,
    )

    profile = (
        db.query(WorkerProfile)
        .filter(WorkerProfile.worker_id == worker.id)
        .first()
    )

    if not profile:
        return {"exists": False}

    return {
        "exists": True,
        "full_name": profile.full_name,
        "city": profile.city,
        "experience_years": profile.experience_years,
        "bio": profile.bio,
    }

@router.get("/{worker_id}")
def get_worker_details(
    worker_id: int,
    db: Session = Depends(get_db),
):
    worker = db.query(Worker).filter(
        Worker.id == worker_id
    ).first()

    if not worker:
        raise HTTPException(
            status_code=404,
            detail="Worker not found",
        )

    profile = (
        db.query(WorkerProfile)
        .filter(WorkerProfile.worker_id == worker_id)
        .first()
    )

    if not profile:
        raise HTTPException(
            status_code=404,
            detail="This worker has not completed their profile yet",
        )

    skills = (
        db.query(Skill.name)
        .join(
            WorkerSkill,
            WorkerSkill.skill_id == Skill.id,
        )
        .filter(
            WorkerSkill.worker_id == worker_id,
        )
        .all()
    )
    portfolio = (
    db.query(PortfolioImage)
    .filter(PortfolioImage.worker_id == worker_id)
    .all()
    )

    rating_summary = get_worker_rating_summary(
    db,
    worker_id,
    )

    return {
        "worker_id": worker.id,
        "full_name": profile.full_name,
        "city": profile.city,
        "experience_years": profile.experience_years,
        "bio": profile.bio,
        "profile_image_url": profile.profile_image_url,
        "is_verified": worker.is_verified,
        "skills": [s.name for s in skills],
        "portfolio_images": [
           {
              "url": p.image_url,
              "caption": p.caption,
           }
           for p in portfolio
        ],
        "average_rating": rating_summary["average_rating"],
        "review_count": rating_summary["review_count"],
    }