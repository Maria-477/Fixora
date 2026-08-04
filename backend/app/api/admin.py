from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database.session import get_db
from app.api.dependencies import get_current_user

from app.models.user import User
from app.models.worker import Worker
from app.models.verification import Verification

from app.services.notification_service import create_notification

router = APIRouter(
    prefix="/admin",
    tags=["Admin"],
)


def _require_admin(current_user: User) -> None:
    if current_user.user_type != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin access required",
        )


@router.get("/verifications/pending")
def get_pending_verifications(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    _require_admin(current_user)

    pending = (
        db.query(Verification)
        .filter(Verification.status == "pending")
        .all()
    )

    results = []

    for v in pending:
        worker = (
            db.query(Worker)
            .filter(Worker.id == v.worker_id)
            .first()
        )

        results.append(
            {
                "verification_id": v.id,
                "worker_id": v.worker_id,
                "document_type": v.document_type,
                "document_url": v.document_url,
                "submitted_at": v.submitted_at.isoformat(),
            }
        )

    return results


@router.patch("/verifications/{verification_id}")
def review_verification(
    verification_id: int,
    approve: bool,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    _require_admin(current_user)

    verification = (
        db.query(Verification)
        .filter(Verification.id == verification_id)
        .first()
    )

    if not verification:
        raise HTTPException(
            status_code=404,
            detail="Verification request not found",
        )

    verification.status = "approved" if approve else "rejected"

    from datetime import datetime

    verification.reviewed_at = datetime.utcnow()

    worker = (
        db.query(Worker)
        .filter(Worker.id == verification.worker_id)
        .first()
    )

    if worker and approve:
        worker.is_verified = True

    db.commit()

    if worker:
        title = (
            "Verification approved"
            if approve
            else "Verification rejected"
        )

        message = (
            "You're now verified and visible in search!"
            if approve
            else "Please resubmit your documents."
        )

        create_notification(
            db,
            worker.user_id,
            title,
            message,
        )

    return {
        "message": f"Verification {'approved' if approve else 'rejected'}"
    }