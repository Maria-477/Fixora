from pydantic import BaseModel

class SaveLocationRequest(BaseModel):
    address_line: str
    city: str
    latitude: float
    longitude: float

class LocationResponse(BaseModel):
    id: int
    address_line: str
    city: str
    latitude: float
    longitude: float