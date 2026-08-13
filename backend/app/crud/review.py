from sqlalchemy.orm import Session
from sqlalchemy import text
from sqlalchemy.exc import IntegrityError

from app.models.review import Review
from app.models.booking import Booking


def create_review(db: Session, customer_id: int, payload) -> Review:

    booking = (
        db.query(Booking)
        .filter(Booking.id == payload.booking_id)
        .first()
    )

    if not booking:
        raise ValueError("Booking not found")

    if booking.customer_id != customer_id:
        raise PermissionError("Not your booking")

    status_row = db.execute(
        text(
            "SELECT name FROM booking_status WHERE id = :id"
        ),
        {"id": booking.status_id},
    ).first()

    if not status_row:
        raise ValueError("Booking status not found")

    if status_row[0] != "completed":
        raise ValueError(
            "You can only review a completed booking"
        )

    review = Review(
        booking_id=payload.booking_id,
        customer_id=customer_id,
        worker_id=booking.worker_id,
        rating=payload.rating,
        comment=payload.comment,
    )

    db.add(review)

    try:
        db.commit()

    except IntegrityError:
        db.rollback()

        raise ValueError(
            "This booking has already been reviewed"
        )

    db.refresh(review)

    return review


def get_reviews_for_worker(db: Session, worker_id: int):

    query = text(
        """
        SELECT
            r.id,
            r.rating,
            r.comment,
            r.created_at,
            c.full_name AS customer_name
        FROM reviews r
        JOIN customers c ON c.id = r.customer_id
        WHERE r.worker_id = :worker_id
        ORDER BY r.created_at DESC
        """
    )

    return db.execute(
        query,
        {"worker_id": worker_id},
    ).mappings().all()


def get_worker_rating_summary(
    db: Session,
    worker_id: int,
) -> dict:

    result = db.execute(
        text(
            """
            SELECT
                AVG(rating) AS avg_rating,
                COUNT(*) AS review_count
            FROM reviews
            WHERE worker_id = :worker_id
            """
        ),
        {"worker_id": worker_id},
    ).first()

    avg = (
        float(result[0])
        if result[0] is not None
        else None
    )

    return {
        "average_rating": round(avg, 1) if avg else None,
        "review_count": result[1],
    }