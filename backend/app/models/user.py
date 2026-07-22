from sqlalchemy import Column, Integer, String, Boolean, Enum, TIMESTAMP, func
from app.database.session import Base
import enum

class UserType(str, enum.Enum):
    customer = "customer"
    worker = "worker"
    admin = "admin"

class Language(str, enum.Enum):
    en = "en"
    ur = "ur"
    pa = "pa"

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    phone = Column(String(20), unique=True, nullable=False, index=True)
    password_hash = Column(String(255), nullable=False)
    user_type = Column(Enum(UserType), nullable=False)
    preferred_language = Column(Enum(Language), nullable=False, default=Language.en)
    is_active = Column(Boolean, nullable=False, default=True)
    created_at = Column(TIMESTAMP, server_default=func.now())
    updated_at = Column(TIMESTAMP, server_default=func.now(), onupdate=func.now())