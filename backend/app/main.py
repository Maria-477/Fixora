from fastapi import FastAPI

app = FastAPI(
    title="Fixora API",
    description="AI-powered marketplace connecting customers with local skilled workers",
    version="0.1.0"
)

@app.get("/health")
def health_check():
    return {"status": "ok", "message": "Fixora API is running"}