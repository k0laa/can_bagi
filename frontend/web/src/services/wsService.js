import { WS_URL } from "../utils/constants";

class WebSocketService {
  constructor() {
    this.ws = null;
    this.reconnectInterval = 3000;
    this.listeners = {};
    this.shouldReconnect = true;
    this.reconnectTimer = null;
  }

  connect(token) {
    if (!token) return;
    this.shouldReconnect = true;

    // Eski bağlantı varsa önce kapat
    if (this.ws) {
      this.ws.onclose = null;
      this.ws.onerror = null;
      this.ws.onmessage = null;
      this.ws.close();
      this.ws = null;
    }

    try {
      this.ws = new WebSocket(`${WS_URL}?token=${encodeURIComponent(token)}`);
    } catch (err) {
      console.warn("[WS] connect error:", err);
      this._scheduleReconnect(token);
      return;
    }

    this.ws.onopen = () => {
      console.log("[WS] bağlandı");
      this._emit("connected");
    };

    this.ws.onmessage = (event) => {
      try {
        const payload = JSON.parse(event.data);
        const { event: type, data } = payload;
        if (type) this._emit(type, data);
      } catch (err) {
        console.warn("[WS] parse hatası:", err);
      }
    };

    this.ws.onclose = () => {
      console.log("[WS] koptu");
      this._emit("disconnected");
      if (this.shouldReconnect) this._scheduleReconnect(token);
    };

    this.ws.onerror = () => {
      // Hata loglarını basit tutuyoruz; onclose zaten reconnect tetikler.
    };
  }

  _scheduleReconnect(token) {
    if (this.reconnectTimer) return;
    this.reconnectTimer = setTimeout(() => {
      this.reconnectTimer = null;
      this.connect(token);
    }, this.reconnectInterval);
  }

  on(event, callback) {
    if (!this.listeners[event]) this.listeners[event] = [];
    this.listeners[event].push(callback);
    return () => this.off(event, callback); // Return unsubscribe function
  }

  once(event, callback) {
    const wrapper = (data) => {
      callback(data);
      this.off(event, wrapper);
    };
    this.on(event, wrapper);
  }

  off(event, callback) {
    if (!this.listeners[event]) return;
    this.listeners[event] = this.listeners[event].filter(
      (cb) => cb !== callback,
    );
  }

  _emit(event, data) {
    (this.listeners[event] || []).forEach((cb) => {
      try {
        cb(data);
      } catch (err) {
        console.error("[WS] listener hatası:", err);
      }
    });
  }

  disconnect() {
    this.shouldReconnect = false;
    if (this.reconnectTimer) {
      clearTimeout(this.reconnectTimer);
      this.reconnectTimer = null;
    }
    if (this.ws) {
      this.ws.close();
      this.ws = null;
    }
  }
}

const wsService = new WebSocketService();
export default wsService;
