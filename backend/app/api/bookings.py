from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import text

from app.database.session import get_db
from app.api.dependencies import get_current_user

from app.models.user import User
from app.models.customer import Customer
from app.models.worker import Worker
from app.models.worker_profile import WorkerProfile

from app.schemas.booking import CreateBookingRequest, UpdateStatusRequest

from app.crud.booking import (
    create_booking,
    get_bookings_for_worker,
    get_bookings_for_customer,
    update_booking_status,
)

from app.services.notification_service import create_notification


STATUS_MESSAGES = {
    "confirmed": ("Booking confirmed", "Your booking request was accepted."),
    "cancelled": ("Booking declined", "Your booking request was declined."),
    "in_progress": ("Job started", "The worker has started your job."),
    "completed": ("Job completed", "Your job has been marked as completed."),
}


router = APIRouter(prefix="/bookings", tags=["Bookings"])


VALID_TRANSITIONS = {
    "pending": {"confirmed", "cancelled"},
    "confirmed": {"in_progress", "cancelled"},
    "in_progress": {"completed"},
}


@router.post("")
def create_new_booking(
    payload: CreateBookingRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if current_user.user_type != "customer":
        raise HTTPException(
            status_code=403,
            detail="Only customers can create bookings",
        )

    worker_profile = (
        db.query(WorkerProfile)
        .filter(WorkerProfile.worker_id == payload.worker_id)
        .first()
    )

    if not worker_profile:
        raise HTTPException(
            status_code=404,
            detail="This worker has not completed their profile yet",
        )

    customer = (
        db.query(Customer)
        .filter(Customer.user_id == current_user.id)
        .first()
    )

    booking = create_booking(
        db,
        customer.id,
        payload,
    )

    # Notify worker about new booking request
    worker = (
        db.query(Worker)
        .filter(Worker.id == payload.worker_id)
        .first()
    )

    if worker:
        create_notification(
            db,
            worker.user_id,
            "New booking request",
            f"{customer.full_name} wants to book you.",
        )

    return {
        "id": booking.id,
        "status": "pending",
        "message": "Booking request sent",
    }


@router.get("/my")
def get_my_bookings(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if current_user.user_type == "worker":

        worker = (
            db.query(Worker)
            .filter(Worker.user_id == current_user.id)
            .first()
        )

        return list(
            get_bookings_for_worker(
                db,
                worker.id,
            )
        )

    customer = (
        db.query(Customer)
        .filter(Customer.user_id == current_user.id)
        .first()
    )

    return list(
        get_bookings_for_customer(
            db,
            customer.id,
        )
    )


@router.patch("/{booking_id}/status")
def change_status(
    booking_id: int,
    payload: UpdateStatusRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    from app.models.booking import Booking

    booking = (
        db.query(Booking)
        .filter(Booking.id == booking_id)
        .first()
    )

    if not booking:
        raise HTTPException(
            status_code=404,
            detail="Booking not found",
        )

    current_status_query = db.execute(
        text(
            "SELECT name FROM booking_status WHERE id = :id"
        ),
        {"id": booking.status_id},
    ).first()

    current_status = current_status_query[0]

    if payload.status not in VALID_TRANSITIONS.get(
        current_status,
        set(),
    ):
        raise HTTPException(
            status_code=400,
            detail=f"Cannot change status from '{current_status}' to '{payload.status}'",
        )

    updated = update_booking_status(
        db,
        booking_id,
        payload.status,
    )

    # Notify customer about booking status change
    customer = (
        db.query(Customer)
        .filter(Customer.id == booking.customer_id)
        .first()
    )

    if customer and payload.status in STATUS_MESSAGES:
        title, message = STATUS_MESSAGES[payload.status]
        create_notification(
            db,
            customer.user_id,
            title,
            message,
        )

    return {
        "id": updated.id,
        "status": payload.status,
    }


