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


def create_task_with_ai(event_type: str, event_data: dict, users: list) -> dict:
    """
    event_type: 'SOS' veya 'NEED'
    event_data: {id, lat, lon, details, ai_score, priority_score, category (need için)}
    users: [{id, name, skills, lat, lon, active_task_id}]
    """

    available_users = [u for u in users if u["active_task_id"] is None and u["lat"] and u["lon"]]

    if not available_users:
        return {"error": "Uygun kullanıcı yok"}

    prompt = f"""
    Sen bir afet yönetim yapay zekasısın. Aşağıdaki {event_type} olayına göre görev oluştur ve uygun kişileri ata.
    Sadece JSON formatında cevap ver, başka hiçbir şey yazma.

    Olay bilgisi:
    - Tip: {event_type}
    - Konum: lat={event_data.get('lat')}, lon={event_data.get('lon')}
    - Detay: {event_data.get('details', 'Detay yok')}
    - Öncelik skoru: {event_data.get('priority_score', 5)}
    {"- Kategori: " + event_data.get('category', '') if event_type == 'NEED' else ''}

    Müsait kullanıcılar:
    {json.dumps(available_users, ensure_ascii=False)}

    Kurallar:
    - Her kullanıcı aynı anda sadece 1 görev alabilir
    - Öncelik skoru yüksekse daha fazla kişi ata
    - Skill uyumuna dikkat et (MEDICAL→MEDICAL, RESCUE→RESCUE, diğerleri→GENERAL)
    - Konuma yakın kişileri tercih et
    - Öncelik 8+ ise max_assignees 3, 5-8 arası 2, 5 altı 1 olsun

    Şu formatta cevap ver:
    {{
        "title": "görev başlığı",
        "type": "MEDICAL|RESCUE|FOOD|SHELTER|LOGISTICS|GENERAL",
        "priority_score": float,
        "max_assignees": int,
        "assigned_user_ids": [user_id listesi]
    }}
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