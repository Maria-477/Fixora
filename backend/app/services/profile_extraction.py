import re
from sqlalchemy.orm import Session
from app.models.skill import Skill


def extract_profile_from_text(db: Session, transcript: str) -> dict:
    """
    Rule-based extraction (mock AI).

    Input:
        Raw speech transcript.

    Output:
        Structured worker profile data.

    This function is intentionally designed so it can later be
    replaced with OpenAI/Gemini without changing the rest of
    the application.
    """
    text = transcript.lower().strip()

    full_name = _extract_name(text)
    city = _extract_city(text)
    experience_years = _extract_experience(text)
    matched_skill = _match_skill(db, text)

    bio = _build_bio(
        full_name,
        matched_skill,
        city,
        experience_years,
    )

    return {
        "full_name": full_name,
        "city": city,
        "experience_years": experience_years,
        "skill": matched_skill,
        "bio": bio,
        "raw_transcript": transcript,
    }


def _extract_name(text: str) -> str | None:
    match = re.search(r"my name is ([a-z]+(?: [a-z]+)?)", text)
    return match.group(1).title() if match else None


def _extract_city(text: str) -> str | None:
    match = re.search(r"from ([a-z]+(?: [a-z]+)?)", text)
    return match.group(1).title() if match else None


def _extract_experience(text: str) -> int:
    match = re.search(r"(\d+)\s*(?:years|year)", text)
    return int(match.group(1)) if match else 0


def _match_skill(db: Session, text: str) -> str | None:
    skills = db.query(Skill).all()

    for skill in skills:
        if skill.name.lower() in text:
            return skill.name

    keyword_map = {
        "plumber": "Plumbing",
        "electrician": "Electrical",
        "carpenter": "Carpentry",
        "painter": "Painting",
        "mechanic": "Mechanic",
        "cleaner": "Cleaning",
    }

    for keyword, skill_name in keyword_map.items():
        if keyword in text:
            return skill_name

    return None


def _build_bio(name, skill, city, years):
    parts = []

    if name and skill:
        parts.append(f"{name} is a {skill.lower()}")

    elif skill:
        parts.append(f"Experienced {skill.lower()}")

    if city:
        parts.append(f"based in {city}")

    if years:
        parts.append(f"with {years} years of experience")

    if parts:
        return " ".join(parts).capitalize() + "."

    return ""