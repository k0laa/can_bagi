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
  // Wrapper: kim gönderdi + ham mesaj
  StaticJsonDocument<1024> wrapper;
  wrapper["from_node"] = from;
  wrapper["received_ms"] = millis();

  // Ham JSON'u parse et (tip bilgisi için)
  StaticJsonDocument<512> inner;
  deserializeJson(inner, raw);   // hata olsa boş kalır
  wrapper["payload"] = inner;

  String line;
  serializeJson(wrapper, line);
  Serial.println(line);   // ← Python bu satırı okur
}

void onNewConnection(uint32_t id) {
  // Bilgi amaçlı, Python tarafında loglanır
  StaticJsonDocument<128> doc;
  doc["event"]   = "NODE_CONNECTED";
  doc["node_id"] = id;
  String line; serializeJson(doc, line);
  Serial.println(line);
}

void onDroppedConnection(uint32_t id) {
  StaticJsonDocument<128> doc;
  doc["event"]   = "NODE_DISCONNECTED";
  doc["node_id"] = id;
  String line; serializeJson(doc, line);
  Serial.println(line);
}

void setup() {
  Serial.begin(SERIAL_BAUD);
  //sistem güç aldığından, ve porta bağlandığından emin olup veri kaybı yaşamamak için delay.
  delay(4500);
  Serial.println("{\"event\":\"GATEWAY_BOOT\",\"node_id\":\"" NODE_ID "\"}");

  mesh.setDebugMsgTypes(ERROR | STARTUP);   // sadece hataları logla
  mesh.init(MESH_PREFIX, MESH_PASSWORD, &taskScheduler, MESH_PORT);
  mesh.onReceive(&onMeshMessage);
  mesh.onNewConnection(&onNewConnection);
  mesh.onDroppedConnection(&onDroppedConnection);
}

void loop() {
  mesh.update();
}
