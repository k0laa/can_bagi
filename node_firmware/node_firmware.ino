/**
 * EBST Hackathon 2026 - Saha Node'u
 * ===================================
 * - WiFi AP: ŞİFRESİZ (enkaz altındaki kişi direkt bağlanır)
 * - Mesh: şifreli (sadece EBST cihazları konuşur)
 * - HTTP API: telefon → node iletişimi
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
Scheduler      taskScheduler;
bool           apStarted = false;   // tek seferlik guard

// ── Heartbeat ────────────────────────────────
Task taskHeartbeat(HEARTBEAT_MS, TASK_FOREVER, []() {
  StaticJsonDocument<128> doc;
  doc["type"]    = "HEARTBEAT";
  doc["node_id"] = NODE_ID;
  doc["ts"]      = millis();
  String msg; serializeJson(doc, msg);
  mesh.sendBroadcast(msg);
});

// ── Yardımcı ─────────────────────────────────
void broadcast(JsonDocument &doc) {
  String out; serializeJson(doc, out);
  mesh.sendBroadcast(out);
  Serial.printf("[MESH→] %s\n", out.c_str());
}

// ── HTTP API ──────────────────────────────────
void setupPhoneAPI() {
  DefaultHeaders::Instance().addHeader("Access-Control-Allow-Origin",  "*");
  DefaultHeaders::Instance().addHeader("Access-Control-Allow-Methods", "GET,POST,OPTIONS");
  DefaultHeaders::Instance().addHeader("Access-Control-Allow-Headers", "Content-Type");

  server.onNotFound([](AsyncWebServerRequest *req) {
    if (req->method() == HTTP_OPTIONS) req->send(200);
    else req->send(404);
  });

  server.on("/status", HTTP_GET, [](AsyncWebServerRequest *req) {
    StaticJsonDocument<256> doc;
    doc["node_id"]    = NODE_ID;
    doc["mesh_nodes"] = mesh.getNodeList().size();
    doc["uptime_ms"]  = millis();
    String out; serializeJson(doc, out);
    req->send(200, "application/json", out);
  });

  server.on("/sos", HTTP_POST, [](AsyncWebServerRequest *req){}, nullptr,
    [](AsyncWebServerRequest *req, uint8_t *data, size_t len, size_t, size_t) {
      StaticJsonDocument<256> body;
      deserializeJson(body, data, len);

      StaticJsonDocument<512> msg;
      msg["type"]    = "SOS";
      msg["node_id"] = NODE_ID;
      msg["ts"]      = millis();
      msg["lat"]     = body["lat"] | 0.0;
      msg["lon"]     = body["lon"] | 0.0;
      broadcast(msg);

      req->send(200, "application/json", "{\"status\":\"sent\"}");
    }
  );

  server.on("/request", HTTP_POST, [](AsyncWebServerRequest *req){}, nullptr,
    [](AsyncWebServerRequest *req, uint8_t *data, size_t len, size_t, size_t) {
      StaticJsonDocument<512> body;
      if (deserializeJson(body, data, len)) {
        req->send(400, "application/json", "{\"error\":\"bad_json\"}");
        return;
      }

      StaticJsonDocument<768> msg;
      msg["type"]         = "REQUEST";
      msg["node_id"]      = NODE_ID;
      msg["ts"]           = millis();
      msg["category"]     = body["category"]    | "UNKNOWN";
      msg["lat"]          = body["lat"]          | 0.0;
      msg["lon"]          = body["lon"]          | 0.0;
      msg["people_count"] = body["people_count"] | 1;
      msg["details"]      = body["details"]      | "";
      broadcast(msg);

      req->send(200, "application/json", "{\"status\":\"sent\"}");
    }
  );

  server.begin();
  Serial.println("[API] HTTP sunucu hazır → http://192.168.4.1");
}

// ── Mesh callbacks ───────────────────────────
void onNewConnection(uint32_t id) {
  Serial.printf("[MESH] Node bağlandı: %u\n", id);

  if (!apStarted) {
    apStarted = true;
    uint8_t ch = WiFi.channel();
    WiFi.mode(WIFI_AP_STA);
    WiFi.softAP(AP_SSID, nullptr, ch);
    Serial.printf("[AP] Açıldı  kanal=%u  IP=%s\n", ch, WiFi.softAPIP().toString().c_str());
    setupPhoneAPI();
  }
}

void onDroppedConnection(uint32_t id) {
  Serial.printf("[MESH] Node ayrıldı: %u\n", id);
}

void onMeshMessage(uint32_t from, String &raw) {
  Serial.printf("[MESH←] %s\n", raw.c_str());
}

// ── Setup ────────────────────────────────────
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

  // Mesh init'ten sonra kanal sabit kalıyor, direkt AP aç
  delay(100);
  uint8_t ch = WiFi.channel();
  WiFi.mode(WIFI_AP_STA);
  WiFi.softAP(AP_SSID, nullptr, ch);
  Serial.printf("[AP] Açıldı  kanal=%u  IP=%s\n", ch, WiFi.softAPIP().toString().c_str());
  setupPhoneAPI();

  Serial.println("[BOOT] Hazır!");
}

void loop() {
  mesh.update();
}
