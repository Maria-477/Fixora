from sqlalchemy.orm import Session

from app.models.user import User
from app.models.customer import Customer
from app.models.worker import Worker
from app.models.verification import Verification

from app.core.security import hash_password


def get_user_by_phone(db: Session, phone: str) -> User | None:
    return db.query(User).filter(User.phone == phone).first()


def create_user_with_profile(
    db: Session,
    phone: str,
    password: str,
    user_type: str,
    full_name: str,
) -> User:

    user = User(
        phone=phone,
        password_hash=hash_password(password),
        user_type=user_type,
        is_active=False,
    )

    db.add(user)
    db.flush()

    if user_type == "customer":
        db.add(
            Customer(
                user_id=user.id,
                full_name=full_name,
            )
        )

    else:
        worker = Worker(
            user_id=user.id,
        )

        db.add(worker)
        db.flush()  # Get worker.id before creating verification

        db.add(
            Verification(
                worker_id=worker.id,
                document_type="Registration",
                document_url="pending_upload",
                status="pending",
            )
        )

    db.commit()
    db.refresh(user)

    return user