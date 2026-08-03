from sqlalchemy import Column, Integer, String, TIMESTAMP, ForeignKey, func
from app.database.session import Base


class PortfolioImage(Base):
    __tablename__ = "portfolio_images"

    id = Column(Integer, primary_key=True, index=True)
    worker_id = Column(Integer, ForeignKey("workers.id", ondelete="CASCADE"), nullable=False)
    image_url = Column(String(500), nullable=False)
    caption = Column(String(255))
    uploaded_at = Column(TIMESTAMP, server_default=func.now())