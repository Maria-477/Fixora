from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session
from sqlalchemy import text
from app.database.session import get_db
from app.api import auth, users, workers

app = FastAPI(
    title="Fixora API",
    description="AI-powered marketplace connecting customers with local skilled workers",
    version="0.1.0"
)

app.include_router(auth.router)
app.include_router(users.router)
app.include_router(workers.router)

@app.get("/health")
def health_check():
    return {"status": "ok", "message": "Fixora API is running"}

@app.get("/health/db")
def db_health_check(db: Session = Depends(get_db)):
    result = db.execute(text("SELECT COUNT(*) FROM skills"))
    return {"status": "ok", "skills_count": result.scalar()}