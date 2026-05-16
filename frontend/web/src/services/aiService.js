import api from './api';

const aiService = {
  /**
   * Koordinatör mesajını AI asistana gönderir
   * @param {string} message - Koordinatörün sorusu
   * @returns {Promise<string>} - AI yanıtı
   */
  chat: (message) =>
    api
      .post('/ai/chat', { message }, { timeout: 30000 })
      .then((r) => r.data.response),
};

export default aiService;
