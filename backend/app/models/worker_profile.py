from sqlalchemy import Column, Integer, String, Text, TIMESTAMP, ForeignKey, func
from app.database.session import Base


class WorkerProfile(Base):
    __tablename__ = "worker_profiles"

    id = Column(Integer, primary_key=True, index=True)

    worker_id = Column(
        Integer,
        ForeignKey("workers.id", ondelete="CASCADE"),
        unique=True,
        nullable=False,
    )

    full_name = Column(String(100), nullable=False)

    bio = Column(Text)

    city = Column(String(100), nullable=False)

    experience_years = Column(Integer, nullable=False, default=0)

    profile_image_url = Column(String(500))

    created_at = Column(TIMESTAMP, server_default=func.now())

    updated_at = Column(
        TIMESTAMP,
        server_default=func.now(),
        onupdate=func.now(),
    )