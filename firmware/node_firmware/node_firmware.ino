/**
 * EBST Hackathon 2026 - Saha Node'u
 */

#include <Arduino.h>
#include <painlessMesh.h>
#include <WiFi.h>
#include <AsyncTCP.h>
#include <ESPAsyncWebServer.h>
#include <ArduinoJson.h>

#define MESH_PREFIX   "EBST_MESH"
#define MESH_PASSWORD "afet2026!"
#define MESH_PORT     5555
#define NODE_ID       "NODE_03"
#define AP_SSID       "EBST-KURTARMA"
#define HEARTBEAT_MS  30000

painlessMesh   mesh;
AsyncWebServer server(80);
AsyncWebSocket ws("/ws/mobile");
Scheduler      taskScheduler;

// ── Heartbeat ─────────────────────────────────────────────────────────────────
Task taskHeartbeat(HEARTBEAT_MS, TASK_FOREVER, []() {
  StaticJsonDocument<160> doc;
  doc["type"]      = "HEARTBEAT";
  doc["node_id"]   = NODE_ID;
  doc["free_heap"] = ESP.getFreeHeap();
  doc["ts"]        = millis();
  String msg; serializeJson(doc, msg);
  mesh.sendBroadcast(msg);
});

// ── Yardımcı ──────────────────────────────────────────────────────────────────
void broadcast(JsonDocument &doc) {
  String out; serializeJson(doc, out);
  mesh.sendBroadcast(out);
  Serial.printf("[MESH→] %s\n", out.c_str());
}

// ── HTTP API ───────────────────────────────────────────────────────────────────
void setupPhoneAPI() {
  DefaultHeaders::Instance().addHeader("Access-Control-Allow-Origin",  "*");
  DefaultHeaders::Instance().addHeader("Access-Control-Allow-Methods", "GET,POST,OPTIONS");
  DefaultHeaders::Instance().addHeader("Access-Control-Allow-Headers", "Content-Type");

  server.onNotFound([](AsyncWebServerRequest *req) {
    if (req->method() == HTTP_OPTIONS) { req->send(200); return; }
    req->send(404);
  });

  server.on("/ping", HTTP_GET, [](AsyncWebServerRequest *req) {
    StaticJsonDocument<256> doc;
    doc["status"]    = "pong";
    doc["node_id"]   = NODE_ID;
    doc["free_heap"] = ESP.getFreeHeap();
    doc["ip"]        = "192.168.4.1";
    String out; serializeJson(doc, out);
    req->send(200, "application/json", out);
  });

  server.on("/status", HTTP_GET, [](AsyncWebServerRequest *req) {
    StaticJsonDocument<256> doc;
    doc["node_id"]    = NODE_ID;
    doc["mesh_nodes"] = mesh.getNodeList().size();
    doc["free_heap"]  = ESP.getFreeHeap();
    doc["uptime_ms"]  = millis();
    String out; serializeJson(doc, out);
    req->send(200, "application/json", out);
  });

  // ── Tüm POST istekleri tek handler ────────────────────────────────────────
  server.onRequestBody([](AsyncWebServerRequest *req, uint8_t *data, size_t len, size_t index, size_t total) {
    String url = req->url();

    StaticJsonDocument<512> body;
    if (deserializeJson(body, data, len)) {
      req->send(400, "application/json", "{\"error\":\"bad_json\"}");
      return;
    }

    StaticJsonDocument<512> msg;
    msg["node_id"] = NODE_ID;

    if (url == "/sos") {
      msg["type"] = "SOS";
      msg["ts"]   = millis();
      msg["lat"]  = body["lat"] | 0.0;
      msg["lon"]  = body["lon"] | 0.0;

    } else if (url == "/needs" || url == "/request") {
      msg["type"]         = "REQUEST";
      msg["ts"]           = millis();
      msg["category"]     = body["category"]     | "UNKNOWN";
      msg["lat"]          = body["lat"]           | 0.0;
      msg["lon"]          = body["lon"]           | 0.0;
      msg["people_count"] = body["people_count"]  | 1;
      msg["details"]      = body["details"]       | "";

    } else if (url == "/tasks/my/request") {
      msg["type"]  = "GET_MY_TASKS";
      msg["token"] = body["token"] | "";

    } else if (url == "/tasks/accept") {
      msg["type"]    = "TASK_ACCEPT";
      msg["token"]   = body["token"] | "";
      msg["task_id"] = body["task_id"] | 0;

    } else if (url == "/tasks/reject") {
      msg["type"]    = "TASK_REJECT";
      msg["token"]   = body["token"] | "";
      msg["task_id"] = body["task_id"] | 0;

    } else if (url == "/tasks/complete") {
      msg["type"]    = "TASK_COMPLETE";
      msg["token"]   = body["token"] | "";
      msg["task_id"] = body["task_id"] | 0;

    } else if (url == "/user/profile/request") {
      msg["type"]  = "GET_PROFILE";
      msg["token"] = body["token"] | "";

    } else {
      req->send(404);
      return;
    }

    broadcast(msg);
    req->send(200, "application/json", "{\"status\":\"sent\"}");
  });

  // ── WebSocket ─────────────────────────────────────────────────────────────
  ws.onEvent([](AsyncWebSocket *s, AsyncWebSocketClient *client, AwsEventType type, void *arg, uint8_t *data, size_t len) {
    if (type == WS_EVT_CONNECT)
      Serial.printf("[WS] Flutter bağlandı: %s\n", client->remoteIP().toString().c_str());
    else if (type == WS_EVT_DISCONNECT)
      Serial.println("[WS] Flutter bağlantıyı kesti.");
  });
  server.addHandler(&ws);

  server.begin();
  Serial.println("[API] HTTP sunucu hazır → http://192.168.4.1");
}

// ── Mesh callbacks ─────────────────────────────────────────────────────────────
void onNewConnection(uint32_t id) {
  Serial.printf("[MESH] Node bağlandı: %u\n", id);
}

void onDroppedConnection(uint32_t id) {
  Serial.printf("[MESH] Node ayrıldı: %u\n", id);
}

void onMeshMessage(uint32_t from, String &raw) {
  Serial.printf("[MESH←] %s\n", raw.c_str());

  StaticJsonDocument<1024> doc;
  if (deserializeJson(doc, raw)) return;

  String eventType = doc["event"] | "";

  if (eventType == "YOUR_TASKS"        ||
      eventType == "TASK_ASSIGNED"     ||
      eventType == "TASK_ACTION_RESULT"||
      eventType == "USER_PROFILE") {
    ws.textAll(raw);
    Serial.println("[WS→] Veri Flutter'a gönderildi.");
  }
}

// ── Setup ──────────────────────────────────────────────────────────────────────
void setup() {
  Serial.begin(115200);
  delay(500);
  Serial.println("\n=== EBST Node (" NODE_ID ") ===");

  mesh.setDebugMsgTypes(ERROR | STARTUP | CONNECTION);
  mesh.init(MESH_PREFIX, MESH_PASSWORD, &taskScheduler, MESH_PORT);
  mesh.onReceive(&onMeshMessage);
  mesh.onNewConnection(&onNewConnection);
  mesh.onDroppedConnection(&onDroppedConnection);

  taskScheduler.addTask(taskHeartbeat);
  taskHeartbeat.enable();

  uint8_t ch = WiFi.channel();
  WiFi.mode(WIFI_AP_STA);
  WiFi.softAP(AP_SSID, nullptr, ch);
  Serial.printf("[AP] Açıldı  kanal=%u  IP=192.168.4.1\n", ch);
  setupPhoneAPI();

  Serial.println("[BOOT] Hazır!");
}

void loop() {
  mesh.update();
  static uint32_t lastClean = 0;
  if (millis() - lastClean > 10000) {
    ws.cleanupClients();
    lastClean = millis();
  }
}