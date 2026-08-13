import random
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
from app.models.worker_skill import WorkerSkill
from app.models.skill import Skill


CAPTION_TEMPLATES = {
    "Plumbing": [
        "Pipe installation completed",
        "Leak repair — before and after",
        "New fixture installation",
        "Drainage system work",
    ],
    "Electrical": [
        "Wiring installation completed",
        "Circuit panel upgrade",
        "Light fixture installation",
        "Electrical safety inspection work",
    ],
    "Carpentry": [
        "Custom woodwork piece",
        "Furniture repair completed",
        "Cabinet installation",
        "Framing and finishing work",
    ],
    "Painting": [
        "Fresh coat, interior wall",
        "Exterior painting project",
        "Detail trim work",
        "Full room repaint",
    ],
    "Mechanic": [
        "Engine repair completed",
        "Routine maintenance work",
        "Parts replacement job",
    ],
    "AC Technician": [
        "AC unit installation",
        "Cooling system repair",
        "Maintenance and servicing",
    ],
    "Cleaning": [
        "Deep cleaning — before and after",
        "Move-out cleaning completed",
        "Full home cleaning service",
    ],
}


DEFAULT_CAPTIONS = [
    "Completed work sample",
    "Recent project",
    "Job completed successfully",
]


router = APIRouter(prefix="/portfolio", tags=["Portfolio"])


UPLOAD_DIR = "uploads/portfolio"
ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png"}
MAX_FILE_SIZE = 5 * 1024 * 1024  # 5MB


def _generate_caption(skill_name: str | None) -> str:
    """
    Mock AI caption generation (template-based, per trade).

    Later, this function can be replaced with a real
    vision-language model that receives the actual image.
    """

    templates = CAPTION_TEMPLATES.get(skill_name, DEFAULT_CAPTIONS)

    return random.choice(templates)


@router.post("/upload")
async def upload_portfolio_image(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    # Only workers can upload portfolio images
    if current_user.user_type != "worker":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only workers can upload portfolio images",
        )

    # Validate file extension
    ext = os.path.splitext(file.filename)[1].lower()

    if ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=400,
            detail="Only JPG and PNG images are allowed",
        )

    # Read and validate file size
    contents = await file.read()

    if len(contents) > MAX_FILE_SIZE:
        raise HTTPException(
            status_code=400,
            detail="Image must be under 5MB",
        )

    # Find worker record
    worker = (
        db.query(Worker)
        .filter(Worker.user_id == current_user.id)
        .first()
    )

    if not worker:
        raise HTTPException(
            status_code=404,
            detail="Worker record not found",
        )

    # Generate unique filename
    filename = f"{uuid.uuid4().hex}{ext}"

    filepath = os.path.join(UPLOAD_DIR, filename)

    # Create upload directory if it doesn't exist
    os.makedirs(UPLOAD_DIR, exist_ok=True)

    # Save image
    async with aiofiles.open(filepath, "wb") as f:
        await f.write(contents)

    image_url = f"/uploads/portfolio/{filename}"

    # ---------------------------------------------------------
    # Get worker's primary skill
    # ---------------------------------------------------------

    primary_skill = (
        db.query(Skill.name)
        .join(WorkerSkill, WorkerSkill.skill_id == Skill.id)
        .filter(WorkerSkill.worker_id == worker.id)
        .first()
    )

    skill_name = primary_skill[0] if primary_skill else None

    # ---------------------------------------------------------
    # Generate trade-specific portfolio caption
    # ---------------------------------------------------------

    caption = _generate_caption(skill_name)

    # Save portfolio record
    portfolio_image = PortfolioImage(
        worker_id=worker.id,
        image_url=image_url,
        caption=caption,
    )

    db.add(portfolio_image)
    db.commit()
    db.refresh(portfolio_image)

    return {
        "id": portfolio_image.id,
        "image_url": image_url,
        "caption": caption,
    }


@router.get("/my-images")
def get_my_portfolio(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    worker = (
        db.query(Worker)
        .filter(Worker.user_id == current_user.id)
        .first()
    )

    if not worker:
        raise HTTPException(
            status_code=404,
            detail="Worker record not found",
        )

    images = (
        db.query(PortfolioImage)
        .filter(PortfolioImage.worker_id == worker.id)
        .all()
    )

    return [
        {
            "id": img.id,
            "image_url": img.image_url,
            "caption": img.caption,
        }
        for img in images
    ]