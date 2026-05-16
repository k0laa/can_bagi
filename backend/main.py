from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from database import engine, Base
from websocket.manager import manager
from routers import sos, tasks, needs, auth, users,nodes
Base.metadata.create_all(bind=engine)

app = FastAPI(title="MeshAid Backend")
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(sos.router, prefix="/sos", tags=["SOS"])
app.include_router(tasks.router, prefix="/tasks", tags=["Tasks"])
app.include_router(needs.router, prefix="/needs", tags=["Needs"])
app.include_router(auth.router, prefix="/auth", tags=["Auth"])
app.include_router(users.router, prefix="/user", tags=["User"])
app.include_router(nodes.router, prefix="/nodes", tags=["Nodes"])

@app.websocket("/ws/mobile")
async def mobile_endpoint(websocket: WebSocket):
    await manager.connect(websocket, "mobile")
    try:
        while True:
            await websocket.receive_text()
    except WebSocketDisconnect:
        manager.disconnect(websocket, "mobile")


@app.websocket("/ws/dashboard")
async def dashboard_endpoint(websocket: WebSocket):
    await manager.connect(websocket, "dashboard")
    try:
        while True:
            await websocket.receive_text()
    except WebSocketDisconnect:
        manager.disconnect(websocket, "dashboard")


@app.get("/")
def root():
    return {"status": "MeshAid Backend çalışıyor"}