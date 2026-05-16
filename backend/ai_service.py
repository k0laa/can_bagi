from groq import Groq
import json

client = Groq(api_key="REPLACED_SECRET")


def analyze_sos(details: str) -> dict:
    if not details:
        return {"score": 5, "suggestion": "Detay bilgisi yok"}

    prompt = f"""
    Afet yönetimi asistanısın. Aşağıdaki SOS mesajını analiz et.
    Sadece JSON formatında cevap ver, başka hiçbir şey yazma.

    SOS mesajı: "{details}"

    Şu formatta cevap ver:
    {{"score": 1-10 arası aciliyet skoru, "suggestion": "kısa öneri"}}
    """

    response = client.chat.completions.create(
        model="llama-3.3-70b-versatile",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.3,
    )

    text = response.choices[0].message.content.strip()
    if text.startswith("```"):
        text = text.split("```")[1]
        if text.startswith("json"):
            text = text[4:]

    return json.loads(text.strip())


def analyze_need(details: str, category: str) -> dict:
    if not details:
        return {"score": 5, "suggestion": "Detay bilgisi yok"}

    prompt = f"""
    Afet yönetimi asistanısın. Aşağıdaki ihtiyaç bildirimini analiz et.
    Sadece JSON formatında cevap ver, başka hiçbir şey yazma.

    Kategori: "{category}"
    Detay: "{details}"

    Şu formatta cevap ver:
    {{"score": 1-10 arası öncelik skoru, "suggestion": "kısa öneri"}}
    """

    response = client.chat.completions.create(
        model="llama-3.3-70b-versatile",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.3,
    )

    text = response.choices[0].message.content.strip()
    if text.startswith("```"):
        text = text.split("```")[1]
        if text.startswith("json"):
            text = text[4:]

    return json.loads(text.strip())