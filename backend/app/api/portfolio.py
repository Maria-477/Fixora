import uuid
import os
from fastapi import APIRouter, Depends, UploadFile, File, HTTPException, status
from sqlalchemy.orm import Session
import aiofiles

from app.database.session import get_db
from app.api.dependencies import get_current_user
from app.models.user import User
from app.models.worker import Worker
from app.models.portfolio_image import PortfolioImage

router = APIRouter(prefix="/portfolio", tags=["Portfolio"])

UPLOAD_DIR = "uploads/portfolio"
ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png"}
MAX_FILE_SIZE = 5 * 1024 * 1024  # 5MB


def _generate_mock_caption(filename: str) -> str:
    # Mock AI caption — swap with a real vision model later
    return "Completed work sample"


@router.post("/upload")
async def upload_portfolio_image(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if current_user.user_type != "worker":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Only workers can upload portfolio images")

    ext = os.path.splitext(file.filename)[1].lower()
    if ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(status_code=400, detail="Only JPG and PNG images are allowed")

    contents = await file.read()
    if len(contents) > MAX_FILE_SIZE:
        raise HTTPException(status_code=400, detail="Image must be under 5MB")

    worker = db.query(Worker).filter(Worker.user_id == current_user.id).first()
    if not worker:
        raise HTTPException(status_code=404, detail="Worker record not found")

    filename = f"{uuid.uuid4().hex}{ext}"
    filepath = os.path.join(UPLOAD_DIR, filename)

    os.makedirs(UPLOAD_DIR, exist_ok=True)
    async with aiofiles.open(filepath, "wb") as f:
        await f.write(contents)

    image_url = f"/uploads/portfolio/{filename}"
    caption = _generate_mock_caption(file.filename)

    portfolio_image = PortfolioImage(worker_id=worker.id, image_url=image_url, caption=caption)
    db.add(portfolio_image)
    db.commit()
    db.refresh(portfolio_image)

    return {"id": portfolio_image.id, "image_url": image_url, "caption": caption}


@router.get("/my-images")
def get_my_portfolio(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    worker = db.query(Worker).filter(Worker.user_id == current_user.id).first()
    if not worker:
        raise HTTPException(status_code=404, detail="Worker record not found")

    images = db.query(PortfolioImage).filter(PortfolioImage.worker_id == worker.id).all()
    return [{"id": img.id, "image_url": img.image_url, "caption": img.caption} for img in images]