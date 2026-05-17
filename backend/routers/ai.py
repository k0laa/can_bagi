from groq import Groq
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session
from database import get_db
from models import SOS, Task, NeedRequest, User, Node
from routers.auth import get_coordinator
from ai_service import client as groq_client

SYSTEM_INSTRUCTION = (
    "Sen bir afet yönetim asistanısın (MeshAid sistemi). "
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

    sos_data = [{"id": s.id, "node_id": s.node_id, "detay": s.details, "ai_skor": s.ai_score} for s in sos_list]
    task_pending_data = [{"id": t.id, "baslik": t.title, "tur": t.type} for t in task_pending]
    task_assigned_data = [{"id": t.id, "baslik": t.title, "atanan": t.assigned_to} for t in task_assigned]
    need_pending_data = [{"id": n.id, "kategori": n.category, "kisi": n.people_count, "detay": n.details} for n in need_pending]
    volunteer_data = [{"id": v.id, "isim": f"{v.name} {v.surname}", "yetenek": v.skills} for v in volunteers]
    node_data = [{"node_id": n.node_id, "durum": n.status} for n in nodes]

    context = f"""
SİSTEM DURUMU:
AKTİF SOS: {len(sos_list)} adet (çözülmüş: {sos_resolved}) → {sos_data}
GÖREVLER: Bekleyen {len(task_pending)} → {task_pending_data} | Atanmış {len(task_assigned)} → {task_assigned_data} | Tamamlanan: {task_completed}
İHTİYAÇLAR: Bekleyen {len(need_pending)} → {need_pending_data} | Atanmış: {len(need_assigned)} | Çözülmüş: {need_resolved}
KULLANICILAR: Toplam {total_users} (Koordinatör: {coordinators}, Gönüllü: {len(volunteers)}) → {volunteer_data}
NODE'LAR: Toplam {len(nodes)} (Aktif: {len(active_nodes)}) → {node_data}
"""

    try:
        response = groq_client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[
                {"role": "system", "content": SYSTEM_INSTRUCTION},
                {"role": "user", "content": f"Bağlam:\n{context}\n\nSoru: {req.message}"},
            ],
            temperature=0.3,
            max_tokens=1000,
        )
        return ChatResponse(response=response.choices[0].message.content)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"AI yanıt üretemedi: {str(e)}")
