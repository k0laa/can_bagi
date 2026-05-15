#!/usr/bin/env python3
"""
EBST Serial Bridge
===================
Gateway ESP32'yi USB'ye takarsın, bu script okur ve backend'e gönderir.

Kurulum:  pip install pyserial httpx
Çalıştır: python serial_bridge.py
          python serial_bridge.py --port COM11
          python serial_bridge.py --port /dev/ttyUSB0
"""

import argparse
import json
import sys
import time
import threading
from collections import deque

try:
    import serial
    import serial.tools.list_ports
    import httpx
except ImportError:
    print("pip install pyserial httpx")
    sys.exit(1)

BAUD_RATE     = 115200
BACKEND_URL   = "http://localhost:8000"
GATEWAY_TOKEN = "ebst-gateway-secret-token"
QUEUE_MAX     = 500

HEADERS = {
    "Content-Type":    "application/json",
    "X-Gateway-Token": GATEWAY_TOKEN,
}

queue: deque = deque(maxlen=QUEUE_MAX)

# ── Mesaj tipine göre endpoint ────────────────
def endpoint(msg: dict) -> str:
    t = msg.get("payload", {}).get("type") or msg.get("type", "")
    return {
        "SOS":       "/sos/",
        "REQUEST":   "/needs/",
        "HEARTBEAT": "/nodes/heartbeat",
    }.get(t, "/nodes/data")

# ── Gateway wrapper'ını düzleştir ────────────
# Gateway: {"from_node":123,"received_ms":456,"payload":{...}}
# Backend payload'ı direkt bekliyor
def extract_payload(msg: dict) -> dict:
    if "payload" in msg:
        return msg["payload"]
    return msg

# ── Port bul ─────────────────────────────────
def find_port() -> str | None:
    for p in serial.tools.list_ports.comports():
        desc = (p.description or "").lower()
        if any(k in desc for k in ["cp210", "ch340", "ftdi", "uart", "usb serial"]):
            return p.device
    ports = serial.tools.list_ports.comports()
    return ports[0].device if ports else None

# ── Gönderici thread ─────────────────────────
def sender_loop():
    with httpx.Client(timeout=5) as client:
        while True:
            if not queue:
                time.sleep(0.1)
                continue

            raw = queue[0]
            payload = extract_payload(raw)
            ep = endpoint(raw)

            try:
                r = client.post(BACKEND_URL + ep, json=payload, headers=HEADERS)
                queue.popleft()
                icon = "✅" if r.is_success else "⚠️"
                print(f"  {icon} HTTP {r.status_code} → {ep}")
            except httpx.ConnectError:
                print(f"  ❌ Backend'e ulaşılamıyor ({BACKEND_URL}), 3s bekliyorum...")
                time.sleep(3)
            except Exception as e:
                print(f"  ❌ {e}")
                time.sleep(1)

# ── Serial okuma ─────────────────────────────
def read_serial(port: str):
    print(f"[Serial] {port} @ {BAUD_RATE} baud bağlanıyor...")
    try:
        ser = serial.Serial(port, BAUD_RATE, timeout=1)
    except serial.SerialException as e:
        print(f"[Serial] HATA: {e}")
        sys.exit(1)

    print(f"[Serial] Bağlandı!\n")

    while True:
        try:
            line = ser.readline().decode("utf-8", errors="replace").strip()
        except serial.SerialException as e:
            print(f"[Serial] Kesildi: {e}")
            time.sleep(2)
            continue

        if not line:
            continue

        # JSON olmayan satırları atla (mesh debug logları)
        if not line.startswith("{"):
            continue

        try:
            msg = json.loads(line)
        except json.JSONDecodeError:
            continue

        # Sadece event mesajlarını logla, kuyruğa alma
        event = msg.get("event", "")
        if event:
            print(f"[Event] {event}")
            continue

        msg_type = msg.get("payload", {}).get("type", "?")
        print(f"[MSG] type={msg_type}  →  kuyruğa eklendi (kuyruk: {len(queue)+1})")
        queue.append(msg)

# ── Main ─────────────────────────────────────
def main():
    global BACKEND_URL
    parser = argparse.ArgumentParser()
    parser.add_argument("--port",    help="Serial port")
    parser.add_argument("--backend", default=BACKEND_URL)
    args = parser.parse_args()

    BACKEND_URL = args.backend

    port = args.port or find_port()
    if not port:
        print("HATA: Port bulunamadı.")
        print("Mevcut portlar:")
        for p in serial.tools.list_ports.comports():
            print(f"  {p.device}  {p.description}")
        sys.exit(1)

    print(f"[Bridge] Backend: {BACKEND_URL}")
    threading.Thread(target=sender_loop, daemon=True).start()

    try:
        read_serial(port)
    except KeyboardInterrupt:
        print(f"\nDurduruldu. Kuyrukta {len(queue)} gönderilmemiş mesaj.")

if __name__ == "__main__":
    main()