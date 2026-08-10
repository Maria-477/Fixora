from pydantic import BaseModel


class ExtractProfileRequest(BaseModel):
    transcript: str
    source_language: str = "en"


class ExtractProfileResponse(BaseModel):
    full_name: str | None
    city: str | None
    experience_years: int
    skill: str | None
    bio: str
    raw_transcript: str


class SaveProfileRequest(BaseModel):
    full_name: str
    city: str
    experience_years: int
    bio: str
    skill_name: str | None = None