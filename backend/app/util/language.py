LANGUAGE_NAMES: dict[str, str] = {
    "en": "English",
    "uk": "Ukrainian",
    "ru": "Russian",
    "de": "German",
    "fr": "French",
    "es": "Spanish",
    "pt": "Portuguese",
    "it": "Italian",
    "pl": "Polish",
    "cs": "Czech",
    "tr": "Turkish",
    "ar": "Arabic",
    "zh": "Chinese",
    "ja": "Japanese",
    "ko": "Korean",
}


def resolve_language_name(language_code: str) -> str:
    return LANGUAGE_NAMES.get(language_code, "English")
