from sqlalchemy import Column, Integer, Text, TIMESTAMP, ForeignKey, func, CheckConstraint
from app.database.session import Base


class Review(Base):
    __tablename__ = "reviews"

    id = Column(Integer, primary_key=True, index=True)

    booking_id = Column(
        Integer,
        ForeignKey("bookings.id", ondelete="CASCADE"),
        unique=True,
        nullable=False,
    )

    customer_id = Column(
        Integer,
        ForeignKey("customers.id", ondelete="CASCADE"),
        nullable=False,
    )

    worker_id = Column(
        Integer,
        ForeignKey("workers.id", ondelete="CASCADE"),
        nullable=False,
    )

    rating = Column(Integer, nullable=False)

    comment = Column(Text)

    created_at = Column(
        TIMESTAMP,
        server_default=func.now(),
    )

    __table_args__ = (
        CheckConstraint(
            "rating BETWEEN 1 AND 5",
            name="check_rating_range",
        ),
    )