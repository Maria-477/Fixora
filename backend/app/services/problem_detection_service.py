"""
Mock AI problem detection (rule-based).

Scans a customer's job description for urgency and category signals.

This is intentionally rule-based for now and can later be replaced
with a real LLM classification call using the same input/output shape.
"""


URGENCY_KEYWORDS = {
    "emergency": "critical",
    "urgent": "high",
    "asap": "high",
    "flooding": "critical",
    "flood": "critical",
    "no power": "critical",
    "gas smell": "critical",
    "sparking": "critical",
    "burst": "high",
    "leak": "medium",
    "not working": "medium",
    "broken": "medium",
}


RISK_FLAGS = {
    "gas smell": "Possible gas leak — recommend immediate professional attention",
    "sparking": "Electrical hazard — avoid contact with affected area until resolved",
    "flooding": "Water damage risk — act quickly to prevent further damage",
    "flood": "Water damage risk — act quickly to prevent further damage",
    "no power": "Full power outage reported — may indicate a serious electrical issue",
    "burst": "Burst pipe/line — risk of significant water damage",
}


URGENCY_LABELS = {
    "critical": "🚨 Critical — immediate attention recommended",
    "high": "⚠️ High priority",
    "medium": "🔧 Standard priority",
    "low": "📋 Routine",
}


def detect_problem(description: str) -> dict:
    """
    Analyze a customer job description and return urgency information.
    """

    text = description.lower()

    urgency_level = "low"

    for keyword, level in URGENCY_KEYWORDS.items():

        if keyword in text:

            if level == "critical":
                urgency_level = "critical"
                break

            elif level == "high" and urgency_level != "critical":
                urgency_level = "high"

            elif level == "medium" and urgency_level not in ("critical", "high"):
                urgency_level = "medium"

    risk_notes = [
        note
        for keyword, note in RISK_FLAGS.items()
        if keyword in text
    ]

    return {
        "urgency_level": urgency_level,
        "urgency_label": URGENCY_LABELS[urgency_level],
        "risk_notes": risk_notes,
    }