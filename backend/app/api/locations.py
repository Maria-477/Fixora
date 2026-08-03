from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database.session import get_db
from app.api.dependencies import get_current_user
from app.models.user import User
from app.models.location import Location
from app.schemas.location import SaveLocationRequest, LocationResponse

router = APIRouter(prefix="/locations", tags=["Locations"])

@router.post("/me", response_model=LocationResponse)
def save_my_location(
    payload: SaveLocationRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    location = db.query(Location).filter(
        Location.user_id == current_user.id, Location.is_primary == True
    ).first()

    if location:
        location.address_line = payload.address_line
        location.city = payload.city
        location.latitude = payload.latitude
        location.longitude = payload.longitude
    else:
        location = Location(user_id=current_user.id, is_primary=True, **payload.model_dump())
        db.add(location)

    db.commit()
    db.refresh(location)
    return location

@router.get("/me", response_model=LocationResponse)
def get_my_location(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    location = db.query(Location).filter(
        Location.user_id == current_user.id, Location.is_primary == True
    ).first()
    if not location:
        raise HTTPException(status_code=404, detail="No location set")
    return location