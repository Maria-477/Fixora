from sqlalchemy import Column, Integer, String
from app.database.session import Base

class BookingStatus(Base):
    __tablename__ = "booking_status"

    id = Column(Integer, primary_key=True)
    name = Column(String(30), unique=True, nullable=False)