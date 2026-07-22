from fastapi import FastAPI

app = FastAPI(
    title="Fixora API",
    description="AI-powered marketplace connecting customers with local skilled workers",
    version="0.1.0"
)

@app.get("/health")
def health_check():
    return {"status": "ok", "message": "Fixora API is running"}

from fastapi import Depends
from sqlalchemy.orm import Session
from sqlalchemy import text

from app.database.session import get_db

@app.get("/health/db")
def db_health_check(db: Session = Depends(get_db)):
    result = db.execute(text("SELECT COUNT(*) FROM skills"))
    count = result.scalar()

    return {
        "status": "ok",
        "skills_count": count
    }