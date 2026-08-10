import httpx


def translate_to_english(text: str, source_lang: str) -> str:
    """
    Translate text to English using the free MyMemory Translation API.
    """

    if source_lang == "en":
        return text

    try:
        response = httpx.get(
            "https://api.mymemory.translated.net/get",
            params={
                "q": text,
                "langpair": f"{source_lang}|en",
            },
            timeout=8.0,
        )

        response.raise_for_status()

        data = response.json()

        return data["responseData"]["translatedText"]

    except Exception:
        return text