from pydantic import BaseModel, Field


class CreateReviewRequest(BaseModel):
    booking_id: int
    rating: int = Field(..., ge=1, le=5)
    comment: str | None = None


class ReviewResponse(BaseModel):
    id: int
    rating: int
    comment: str | None
    customer_name: str | None
    created_at: str