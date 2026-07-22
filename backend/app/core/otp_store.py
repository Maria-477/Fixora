import random

_otp_store: dict[str, str] = {}

def generate_otp(phone: str) -> str:
    otp = f"{random.randint(1000, 9999)}"
    _otp_store[phone] = otp
    return otp

def verify_otp(phone: str, otp: str) -> bool:
    stored = _otp_store.get(phone)
    if stored and stored == otp:
        del _otp_store[phone]
        return True
    return False