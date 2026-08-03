from datetime import datetime
from pydantic import BaseModel


class CreateBookingRequest(BaseModel):
    worker_id: int
    location_id: int
    service_description: str
    scheduled_at: datetime


class BookingResponse(BaseModel):
    id: int
    worker_id: int
    customer_id: int
    status: str
    service_description: str | None
    scheduled_at: datetime
    worker_name: str | None = None
    customer_name: str | None = None


class UpdateStatusRequest(BaseModel):
    status: str  # confirmed, cancelled, in_progress, completed