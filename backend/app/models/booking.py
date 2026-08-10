from sqlalchemy import Column, Integer, Text, DateTime, TIMESTAMP, ForeignKey, func, DECIMAL
from app.database.session import Base

class Booking(Base):
    __tablename__ = "bookings"

    id = Column(Integer, primary_key=True, index=True)
    customer_id = Column(Integer, ForeignKey("customers.id", ondelete="CASCADE"), nullable=False)
    worker_id = Column(Integer, ForeignKey("workers.id", ondelete="CASCADE"), nullable=False)
    location_id = Column(Integer, ForeignKey("locations.id"), nullable=False)
    status_id = Column(Integer, ForeignKey("booking_status.id"), nullable=False)
    service_description = Column(Text)
    scheduled_at = Column(DateTime, nullable=False)
    created_at = Column(TIMESTAMP, server_default=func.now())
    updated_at = Column(TIMESTAMP, server_default=func.now(), onupdate=func.now())
    suggested_price = Column(DECIMAL(10,2), nullable=True)