from fastapi import WebSocket
from typing import Dict, List
import json


class ConnectionManager:
    def __init__(self):
        self.mobile: List[WebSocket] = []
        self.dashboard: List[WebSocket] = []

    async def connect(self, websocket: WebSocket, client_type: str):
        await websocket.accept()
        if client_type == "mobile":
            self.mobile.append(websocket)
        elif client_type == "dashboard":
            self.dashboard.append(websocket)

    def disconnect(self, websocket: WebSocket, client_type: str):
        if client_type == "mobile":
            self.mobile.remove(websocket)
        elif client_type == "dashboard":
            self.dashboard.remove(websocket)

    async def broadcast_to_dashboard(self, event: str, data: dict):
        message = json.dumps({"event": event, "data": data})
        for connection in self.dashboard:
            await connection.send_text(message)

    async def broadcast_to_mobile(self, event: str, data: dict):
        message = json.dumps({"event": event, "data": data})
        for connection in self.mobile:
            await connection.send_text(message)

    async def broadcast_to_all(self, event: str, data: dict):
        message = json.dumps({"event": event, "data": data})
        for connection in self.mobile + self.dashboard:
            await connection.send_text(message)


manager = ConnectionManager()