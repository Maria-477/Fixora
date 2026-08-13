from sqlalchemy.orm import Session
from sqlalchemy import text
from app.models.booking import Booking
from app.models.booking_status import BookingStatus


def get_status_id(db: Session, name: str) -> int:
    status = db.query(BookingStatus).filter(BookingStatus.name == name).first()
    if not status:
        raise ValueError(f"Unknown status: {name}")
    return status.id


def create_booking(db: Session, customer_id: int, data) -> Booking:
    pending_id = get_status_id(db, "pending")

    booking = Booking(
        customer_id=customer_id,
        worker_id=data.worker_id,
        location_id=data.location_id,
        status_id=pending_id,
        service_description=data.service_description,
        scheduled_at=data.scheduled_at,
        suggested_price=data.suggested_price,
    )

    db.add(booking)
    db.commit()
    db.refresh(booking)

    return booking


def get_bookings_for_worker(db: Session, worker_id: int):
    query = text("""
        SELECT b.id, b.worker_id, b.customer_id, bs.name AS status,
               b.service_description, b.scheduled_at, b.suggested_price,
               c.full_name AS customer_name,
               r.rating AS review_rating, r.comment AS review_comment
        FROM bookings b
        JOIN booking_status bs ON bs.id = b.status_id
        JOIN customers c ON c.id = b.customer_id
        LEFT JOIN reviews r ON r.booking_id = b.id
        WHERE b.worker_id = :worker_id
        ORDER BY b.scheduled_at DESC
    """)
    return db.execute(query, {"worker_id": worker_id}).mappings().all()


def get_bookings_for_customer(db: Session, customer_id: int):
    query = text("""
        SELECT b.id, b.worker_id, b.customer_id, bs.name AS status,
               b.service_description, b.scheduled_at, b.suggested_price,
               wp.full_name AS worker_name,
               r.rating AS review_rating, r.comment AS review_comment
        FROM bookings b
        JOIN booking_status bs ON bs.id = b.status_id
        JOIN worker_profiles wp ON wp.worker_id = b.worker_id
        LEFT JOIN reviews r ON r.booking_id = b.id
        WHERE b.customer_id = :customer_id
        ORDER BY b.scheduled_at DESC
    """)
    return db.execute(query, {"customer_id": customer_id}).mappings().all()


def update_booking_status(db: Session, booking_id: int, new_status: str) -> Booking | None:
    booking = db.query(Booking).filter(Booking.id == booking_id).first()

    if not booking:
        return None

    booking.status_id = get_status_id(db, new_status)

    db.commit()
    db.refresh(booking)

    return booking