from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import text

from app.database.session import get_db
from app.api.dependencies import get_current_user
from app.models.user import User

router = APIRouter(prefix="/search", tags=["Search"])


@router.get("/workers")
def search_workers(
    lat: float = Query(...),
    lng: float = Query(...),
    skill: str | None = Query(None),
    radius_km: float = Query(20.0),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    base_query = """
        SELECT
            w.id AS worker_id,
            wp.full_name,
            wp.city,
            wp.experience_years,
            wp.profile_image_url,
            l.latitude,
            l.longitude,
            (
                6371 * acos(
                    cos(radians(:lat)) * cos(radians(l.latitude)) *
                    cos(radians(l.longitude) - radians(:lng)) +
                    sin(radians(:lat)) * sin(radians(l.latitude))
                )
            ) AS distance_km
        FROM workers w
        JOIN worker_profiles wp ON wp.worker_id = w.id
        JOIN locations l ON l.user_id = w.user_id
        WHERE w.is_verified = 1
    """

    params = {"lat": lat, "lng": lng}

    if skill:
        base_query += """
            AND w.id IN (
                SELECT ws.worker_id FROM worker_skills ws
                JOIN skills s ON s.id = ws.skill_id
                WHERE s.name = :skill
            )
        """
        params["skill"] = skill

    base_query += " HAVING distance_km <= :radius ORDER BY distance_km ASC LIMIT 50"
    params["radius"] = radius_km

    result = db.execute(text(base_query), params)
    rows = result.mappings().all()

    return [
        {
            "worker_id": row["worker_id"],
            "full_name": row["full_name"],
            "city": row["city"],
            "experience_years": row["experience_years"],
            "profile_image_url": row["profile_image_url"],
            "distance_km": round(row["distance_km"], 1),
        }
        for row in rows
    ]