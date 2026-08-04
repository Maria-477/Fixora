from sqlalchemy import Column, Integer, String, TIMESTAMP, ForeignKey, func
from app.database.session import Base


class Verification(Base):
    __tablename__ = "verification"

    id = Column(Integer, primary_key=True, index=True)
    worker_id = Column(
        Integer,
        ForeignKey("workers.id", ondelete="CASCADE"),
        nullable=False,
    )
    document_type = Column(String(50), nullable=False)
    document_url = Column(String(500), nullable=False)
    status = Column(String(20), nullable=False, default="pending")
    submitted_at = Column(TIMESTAMP, server_default=func.now())
    reviewed_at = Column(TIMESTAMP, nullable=True)