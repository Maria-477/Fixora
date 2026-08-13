from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database.session import get_db
from app.api.dependencies import get_current_user
from app.models.user import User
from app.models.customer import Customer

from app.schemas.review import CreateReviewRequest
from app.crud.review import (
    create_review,
    get_reviews_for_worker,
    get_worker_rating_summary,
)


router = APIRouter(
    prefix="/reviews",
    tags=["Reviews"],
)


@router.post("")
def submit_review(
    payload: CreateReviewRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):

    if current_user.user_type != "customer":
        raise HTTPException(
            status_code=403,
            detail="Only customers can leave reviews",
        )

    customer = (
        db.query(Customer)
        .filter(Customer.user_id == current_user.id)
        .first()
    )

    if not customer:
        raise HTTPException(
            status_code=404,
            detail="Customer profile not found",
        )

    try:
        review = create_review(
            db,
            customer.id,
            payload,
        )

    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=str(e),
        )

    except PermissionError as e:
        raise HTTPException(
            status_code=403,
            detail=str(e),
        )

    return {
        "id": review.id,
        "message": "Review submitted",
    }


@router.get("/worker/{worker_id}")
def get_worker_reviews(
    worker_id: int,
    db: Session = Depends(get_db),
):

    reviews = get_reviews_for_worker(
        db,
        worker_id,
    )

    summary = get_worker_rating_summary(
        db,
        worker_id,
    )

    return {
        "average_rating": summary["average_rating"],
        "review_count": summary["review_count"],
        "reviews": [
            {
                "id": r["id"],
                "rating": r["rating"],
                "comment": r["comment"],
                "customer_name": r["customer_name"],
                "created_at": (
                    r["created_at"].isoformat()
                    if r["created_at"]
                    else None
                ),
            }
            for r in reviews
        ],
    }