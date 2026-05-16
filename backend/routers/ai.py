from groq import Groq
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session
from database import get_db
from models import SOS, Task, NeedRequest, User, Node
from routers.auth import get_coordinator

# ai_service.py ile aynı Groq client'ı kullanıyoruz
client = Groq(api_key="REPLACED_SECRET")

SYSTEM_PROMPT = (
    "Sen bir afet yönetim asistanısın (Can Bağı sistemi). "
    "Sana aktif SOS sinyalleri, görevler, ihtiyaç talepleri, kullanıcılar ve node durumları hakkında güncel veritabanı verileri veriliyor. "
    "Koordinatörün sorularını bu verilere göre doğru ve net şekilde cevapla. "
    "Türkçe cevap ver. Kısa, net ve yardımcı ol. "
    "Eğer verilerde ilgili bilgi yoksa bunu açıkça belirt. "
    "Sayısal veriler sorulduğunda doğrudan veritabanındaki rakamları kullan, tahmin yapma."
)

router = APIRouter()


class ChatRequest(BaseModel):
    message: str


class ChatResponse(BaseModel):
    response: str


@router.post("/chat", response_model=ChatResponse)
def chat(
    req: ChatRequest,
    db: Session = Depends(get_db),
    coordinator=Depends(get_coordinator),
):
    # ─── DB'den tüm güncel verileri çek ───

    sos_list = db.query(SOS).filter(SOS.status == "active").all()
    sos_resolved = db.query(SOS).filter(SOS.status == "resolved").count()

    task_pending = db.query(Task).filter(Task.status == "pending").all()
    task_assigned = db.query(Task).filter(Task.status == "assigned").all()
    task_completed = db.query(Task).filter(Task.status == "completed").count()

    need_pending = db.query(NeedRequest).filter(NeedRequest.status == "pending").all()
    need_assigned = db.query(NeedRequest).filter(NeedRequest.status == "assigned").all()
    need_resolved = db.query(NeedRequest).filter(NeedRequest.status == "resolved").count()

    total_users = db.query(User).count()
    coordinators = db.query(User).filter(User.role.in_(["COORDINATOR", "SUPER"])).count()
    volunteers = db.query(User).filter(User.role == "USER").all()

    nodes = db.query(Node).all()
    active_nodes = [n for n in nodes if n.status == "active"]

    # ─── Bağlam oluştur ───

    sos_data = [
        {
            "id": s.id,
            "node_id": s.node_id,
            "lat": s.lat,
            "lon": s.lon,
            "tarih": str(s.created_at),
            "detay": s.details,
            "ai_skor": s.ai_score,
            "ai_oneri": s.ai_suggestion,
        }
        for s in sos_list
    ]

    task_pending_data = [
        {
            "id": t.id,
            "baslik": t.title,
            "tur": t.type,
            "konum": f"{t.lat},{t.lon}" if t.lat else "yok",
            "tarih": str(t.created_at),
        }
        for t in task_pending
    ]

    task_assigned_data = [
        {
            "id": t.id,
            "baslik": t.title,
            "tur": t.type,
            "atanan": t.assigned_to,
            "tarih": str(t.created_at),
        }
        for t in task_assigned
    ]

    need_pending_data = [
        {
            "id": n.id,
            "kategori": n.category,
            "kisi_sayisi": n.people_count,
            "detay": n.details,
            "konum": f"{n.lat},{n.lon}" if n.lat else "yok",
            "ai_skor": n.ai_score,
            "ai_oneri": n.ai_suggestion,
        }
        for n in need_pending
    ]

    need_assigned_data = [
        {
            "id": n.id,
            "kategori": n.category,
            "kisi_sayisi": n.people_count,
            "detay": n.details,
        }
        for n in need_assigned
    ]

    volunteer_data = [
        {
            "id": v.id,
            "isim": f"{v.name} {v.surname}",
            "yetenek": v.skills,
            "konum": f"{v.lat},{v.lon}" if v.lat else "yok",
        }
        for v in volunteers
    ]

    node_data = [
        {
            "node_id": n.node_id,
            "durum": n.status,
            "free_heap": n.free_heap,
            "son_gorulme": str(n.last_seen),
        }
        for n in nodes
    ]

    context = f"""
═══ SİSTEM DURUMU ═══

📍 AKTİF SOS SİNYALLERİ: {len(sos_list)} adet (çözülmüş: {sos_resolved})
{sos_data}

📋 GÖREVLER:
  Bekleyen: {len(task_pending)} adet
  {task_pending_data}
  Atanmış (devam eden): {len(task_assigned)} adet
  {task_assigned_data}
  Tamamlanmış: {task_completed} adet

🆘 İHTİYAÇ TALEPLERİ:
  Bekleyen: {len(need_pending)} adet
  {need_pending_data}
  Atanmış: {len(need_assigned)} adet
  {need_assigned_data}
  Çözülmüş: {need_resolved} adet

👥 KULLANICILAR: Toplam {total_users} (Koordinatör: {coordinators}, Gönüllü: {len(volunteers)})
{volunteer_data}

📡 NODE'LAR: Toplam {len(nodes)} (Aktif: {len(active_nodes)})
{node_data}
"""

    try:
        response = client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": f"Bağlam:\n{context}\n\nKoordinatörün sorusu: {req.message}"},
            ],
            temperature=0.3,
            max_tokens=2000,
        )
        answer = response.choices[0].message.content.strip()
        return ChatResponse(response=answer)
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"AI yanıt üretemedi: {str(e)}",
        )
