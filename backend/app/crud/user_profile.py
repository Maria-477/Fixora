from sqlalchemy.orm import Session
from app.models.user import User
from app.models.customer import Customer
from app.models.worker import Worker

def get_full_name_for_user(db: Session, user: User) -> str | None:
    if user.user_type == "customer":
        customer = db.query(Customer).filter(Customer.user_id == user.id).first()
        return customer.full_name if customer else None
    if user.user_type == "worker":
        # worker_profiles isn't modeled yet (Milestone 9+); workers table has no name field yet
        return None
    if user.user_type == "admin":
        return "Admin"
    return None