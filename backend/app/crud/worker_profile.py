from sqlalchemy.orm import Session

from app.models.worker_profile import WorkerProfile
from app.models.skill import Skill
from app.models.worker_skill import WorkerSkill


def create_or_update_profile(
    db: Session,
    worker_id: int,
    data,
) -> WorkerProfile:

    profile = (
        db.query(WorkerProfile)
        .filter(WorkerProfile.worker_id == worker_id)
        .first()
    )

    if profile:
        profile.full_name = data.full_name
        profile.city = data.city
        profile.experience_years = data.experience_years
        profile.bio = data.bio

    else:
        profile = WorkerProfile(
            worker_id=worker_id,
            full_name=data.full_name,
            city=data.city,
            experience_years=data.experience_years,
            bio=data.bio,
        )
        db.add(profile)

    db.commit()
    db.refresh(profile)

    if data.skill_name:
        _link_skill(db, worker_id, data.skill_name)

    return profile


def _link_skill(
    db: Session,
    worker_id: int,
    skill_name: str,
):

    skill = (
        db.query(Skill)
        .filter(Skill.name == skill_name)
        .first()
    )

    if not skill:
        return

    existing = (
        db.query(WorkerSkill)
        .filter(
            WorkerSkill.worker_id == worker_id,
            WorkerSkill.skill_id == skill.id,
        )
        .first()
    )

    if not existing:
        db.add(
            WorkerSkill(
                worker_id=worker_id,
                skill_id=skill.id,
            )
        )
        db.commit()