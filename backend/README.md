# Can Bağı Backend

Backend, Can Bağı sisteminin merkezi iş mantığını barındırır. FastAPI tabanlıdır ve JSON API + WebSocket sunar.

## Amaç

- ESP32 gateway ve saha node'larından gelen verileri almak
- SOS, ihtiyaç talepleri ve görevleri yönetmek
- Kullanıcı kimlik doğrulamasını sağlamak
- Web dashboard ile gerçek zamanlı haberleşme kurmak

## Teknoloji

- Python 3
- FastAPI
- SQLAlchemy
- SQLite (`backend/meshaid.db`)
- WebSocket
- JWT auth

## Ana Modüller

- `main.py` : FastAPI uygulamasını başlatır, router'ları kaydeder, WebSocket endpointlerini açar
- `database.py` : SQLite bağlantısını ve `SessionLocal` yapılandırmasını içerir
- `models.py` : veri tabloları (`SOS`, `NeedRequest`, `Task`, `User`, `Node`)
- `schemas.py` : pydantic modelleri ile giriş/çıkış doğrulaması
- `routers/` : her API kategorisi için ayrılmış uç noktalar
- `websocket/` : gerçek zamanlı mesajların yönetimi

## Başlıca API Endpointleri

### Auth
- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/coordinator/login`
- `POST /auth/make-coordinator/{user_id}`
- `POST /auth/make-user/{user_id}`

### Kullanıcı
- `GET /user/profile`
- `PUT /user/profile`
- `GET /user/`
- `DELETE /user/{user_id}`

### SOS
- `POST /sos/`
- `GET /sos/`
- `GET /sos/prioritized`
- `GET /sos/{sos_id}`
- `PUT /sos/{sos_id}/resolve`
- `DELETE /sos/{sos_id}`

### İhtiyaç Talepleri
- `POST /needs/`
- `GET /needs/`
- `GET /needs/{need_id}`
- `PUT /needs/{need_id}/status`
- `DELETE /needs/{need_id}`

### Görevler
- `POST /tasks/`
- `GET /tasks/`
- `GET /tasks/{task_id}`
- `PUT /tasks/{task_id}`
- `POST /tasks/{task_id}/accept`
- `POST /tasks/{task_id}/complete`
- `DELETE /tasks/{task_id}`
- `GET /tasks/{task_id}/match`

### Node Yönetimi
- `POST /nodes/heartbeat`
- `POST /nodes/data`
- `GET /nodes/`
- `GET /nodes/{node_id}`
- `DELETE /nodes/{node_id}`

## WebSocket Endpointleri

- `ws://<host>:8000/ws/mobile`
- `ws://<host>:8000/ws/dashboard`

WebSocket ile yeni SOS, yeni ihtiyaç ve görev güncellemeleri canlı olarak yayınlanır.

## Çalıştırma

1. `cd backend`
2. `pip install -r requirements.txt`
3. `uvicorn main:app --reload --host 0.0.0.0 --port 8000`

## Veritabanı

`backend/database.py` SQLite kullanır:

```python
SQLALCHEMY_DATABASE_URL = "sqlite:///./meshaid.db"
```

Bu dosya yerel olarak `backend/meshaid.db` içinde oluşturulur.
