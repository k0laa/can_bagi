/*
 * EBST Hackathon 2026 - Gateway (USB/Serial)
 * ============================================
 * ESP32 → USB kablosu → Bilgisayar → Backend(Python)
 *
 * Çalışma mantığı:
 *   1. Mesh'teki tüm mesajları dinle
 *   2. Her mesajı Serial üzerinden JSON satırı olarak backende gönder
 *   3. Bilgisayardaki Python script okur ve backend'e gönderir
 */

#include <Arduino.h>
#include <painlessMesh.h>
#include <ArduinoJson.h>

#define MESH_PREFIX   "EBST_MESH"
#define MESH_PASSWORD "afet2026!"
#define MESH_PORT     5555
#define NODE_ID       "GATEWAY_01"
#define SERIAL_BAUD   115200

painlessMesh mesh;
Scheduler    taskScheduler;

// Mesh'ten gelen her mesajı Serial'a yaz (tek satır JSON)
void onMeshMessage(uint32_t from, String &raw) {
  StaticJsonDocument<1024> wrapper;
  // Değişiklik: gateway_id eklendi
  wrapper["gateway_id"]  = NODE_ID;
  wrapper["from_node"]   = from;
  wrapper["received_ms"] = millis();

  StaticJsonDocument<512> inner;
  deserializeJson(inner, raw);
  wrapper["payload"] = inner;

  String line;
  serializeJson(wrapper, line);
  Serial.println(line);
}

void onNewConnection(uint32_t id) {
  StaticJsonDocument<128> doc;
  doc["event"]   = "NODE_CONNECTED";
  // Değişiklik: String(id) → uint32_t taşma riskini önler
  doc["node_id"] = String(id);
  String line; serializeJson(doc, line);
  Serial.println(line);
}

void onDroppedConnection(uint32_t id) {
  StaticJsonDocument<128> doc;
  doc["event"]   = "NODE_DISCONNECTED";
  doc["node_id"] = String(id);
  String line; serializeJson(doc, line);
  Serial.println(line);
}

void setup() {
  Serial.begin(SERIAL_BAUD);
  delay(4500);
  Serial.println("{\"event\":\"GATEWAY_BOOT\",\"gateway_id\":\"" NODE_ID "\"}");

  mesh.setDebugMsgTypes(ERROR | STARTUP);   // sadece hataları logla
  mesh.init(MESH_PREFIX, MESH_PASSWORD, &taskScheduler, MESH_PORT);
  mesh.onReceive(&onMeshMessage);
  mesh.onNewConnection(&onNewConnection);
  mesh.onDroppedConnection(&onDroppedConnection);
}

void loop() {
  mesh.update();
}