"""
Mock AI pricing service.

Calculates a suggested price for a job based on the worker's skill and
keywords in the customer's job description. This is intentionally simple
and rule-based (per the project's "mock now, real AI later" pattern) —
swap the body of suggest_price() with a real model later (factoring in
worker rating, demand, historical job data, etc.) while keeping the same
input/output shape: (skill_name: str | None, description: str) -> float.
"""

# Base rates per skill, in PKR. Tune these freely to match realistic local pricing.
BASE_RATES = {
    "Plumbing": 1500,
    "Electrical": 1800,
    "Carpentry": 2000,
    "Painting": 2500,
    "Mechanic": 2200,
    "AC Technician": 2000,
    "Cleaning": 1200,
}

DEFAULT_BASE_RATE = 1500

# Keywords that adjust the base price up or down.
# If multiple keywords match, we take the strongest upward adjustment
# and the strongest downward adjustment, then apply the more significant one.
COMPLEXITY_KEYWORDS = {
    "urgent": 1.3,
    "emergency": 1.4,
    "leak": 1.1,
    "install": 1.2,
    "installation": 1.2,
    "new": 1.15,
    "replace": 1.15,
    "repair": 1.0,
    "fix": 1.0,
    "small": 0.8,
    "minor": 0.8,
    "quick": 0.85,
    "simple": 0.85,
}


def suggest_price(skill_name: str | None, description: str) -> float:
    """
    Returns a suggested price in PKR based on the worker's primary skill
    and any complexity/urgency keywords found in the job description.
    """
    base = BASE_RATES.get(skill_name, DEFAULT_BASE_RATE) if skill_name else DEFAULT_BASE_RATE

    text = description.lower()

    highest_multiplier = 1.0
    lowest_multiplier = 1.0

    for keyword, factor in COMPLEXITY_KEYWORDS.items():
        if keyword in text:
            if factor > highest_multiplier:
                highest_multiplier = factor
            if factor < lowest_multiplier:
                lowest_multiplier = factor

    # If both an "urgent" word and a "small" word appear, the urgency
    # premium wins — emergencies cost more even if described as minor.
    multiplier = highest_multiplier if highest_multiplier > 1.0 else lowest_multiplier

    price = base * multiplier
    # Round to the nearest 10 for a cleaner-looking quote
    price = round(price / 10) * 10

    return float(price)
