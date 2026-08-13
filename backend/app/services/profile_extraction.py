import re
import random
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
    patterns = [
        r"my name is ([a-z]+(?: [a-z]+)?)",
        r"i am ([a-z]+(?: [a-z]+)?)(?:,| and| from| a )",
        r"this is ([a-z]+(?: [a-z]+)?)",
        r"call me ([a-z]+(?: [a-z]+)?)",
    ]
    for pattern in patterns:
        match = re.search(pattern, text)
        if match:
            return match.group(1).title()
    return None


def _extract_city(text: str) -> str | None:
    patterns = [
        r"from ([a-z]+(?: [a-z]+)?)",
        r"i live in ([a-z]+(?: [a-z]+)?)",
        r"living in ([a-z]+(?: [a-z]+)?)",
        r"based in ([a-z]+(?: [a-z]+)?)",
        r"located in ([a-z]+(?: [a-z]+)?)",
        r"in ([a-z]+(?: [a-z]+)?) city",
    ]
    for pattern in patterns:
        match = re.search(pattern, text)
        if match:
            return match.group(1).title()
    return None


def _extract_experience(text: str) -> int:
    patterns = [
        r"(\d+)\s*(?:years|year)",
        r"(\d+)\s*(?:yrs)",
        r"experience of (\d+)",
        r"working for (\d+)",
    ]
    for pattern in patterns:
        match = re.search(pattern, text)
        if match:
            return int(match.group(1))
    return 0


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

BIO_TEMPLATES = [
    "{name} is a skilled {skill} based in {city}, with {years} years of hands-on experience.",
    "With {years} years in the trade, {name} is an experienced {skill} serving {city} and nearby areas.",
    "{name} brings {years} years of {skill} experience to every job in {city}.",
    "A dependable {skill} from {city}, {name} has {years} years of professional experience.",
]

BIO_TEMPLATES_NO_YEARS = [
    "{name} is a {skill} based in {city}, ready to help with your project.",
    "{name} works as a {skill} serving {city} and the surrounding area.",
]

BIO_TEMPLATES_MINIMAL = [
    "Experienced {skill} available in {city}.",
    "Professional {skill} serving the {city} area.",
]

def _build_bio(name: str | None, skill: str | None, city: str | None, years: int) -> str:
    """
    Mock AI bio generation (template-based).
    """

    skill_display = skill.lower() if skill else "tradesperson"

    if name and city and years > 0:
        template = random.choice(BIO_TEMPLATES)
        return template.format(
            name=name,
            skill=skill_display,
            city=city,
            years=years
        )

    if name and city:
        template = random.choice(BIO_TEMPLATES_NO_YEARS)
        return template.format(
            name=name,
            skill=skill_display,
            city=city
        )

    if city:
        template = random.choice(BIO_TEMPLATES_MINIMAL)
        return template.format(
            skill=skill_display,
            city=city
        )

    return f"Professional {skill_display} ready to help with your project."