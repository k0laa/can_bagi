import { useState, useRef, useEffect } from 'react';
import aiService from '../services/aiService';

const QUICK_QUESTIONS = [
  { label: '📍 Aktif SOS sayısı', message: 'Şu anda kaç aktif SOS sinyali var? Konumlarıyla birlikte listele.' },
  { label: '📋 Bekleyen görevler', message: 'Bekleyen ve devam eden görevleri listele.' },
  { label: '🆘 Acil ihtiyaçlar', message: 'Çözülmemiş ihtiyaç taleplerini önem sırasına göre listele.' },
  { label: '📊 Genel durum', message: 'Tüm sistemin genel durumunu özetle: SOS, görev ve ihtiyaç sayıları.' },
  { label: '🗺️ Bölge analizi', message: 'Aktif SOS sinyallerinin coğrafi dağılımını analiz et.' },
  { label: '⚡ Öncelik önerisi', message: 'Mevcut verilere göre hangi alanlara öncelik verilmeli? Önerilerin neler?' },
];

const AIChatPage = () => {
  const [messages, setMessages] = useState([
    {
      role: 'assistant',
      content:
        'Merhaba! Ben MeshAid AI asistanıyım. 🤖\n\nAktif SOS sinyalleri, görevler ve ihtiyaç talepleri hakkında sorularınızı yanıtlayabilirim. Aşağıdaki hızlı sorulardan birini seçebilir veya kendi sorunuzu yazabilirsiniz.',
      timestamp: new Date(),
    },
  ]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const messagesEndRef = useRef(null);
  const textareaRef = useRef(null);

  // Otomatik scroll
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages, loading]);

  // Textarea auto-resize
  useEffect(() => {
    if (textareaRef.current) {
      textareaRef.current.style.height = 'auto';
      textareaRef.current.style.height =
        Math.min(textareaRef.current.scrollHeight, 120) + 'px';
    }
  }, [input]);

  const sendMessage = async (text) => {
    const messageText = text || input.trim();
    if (!messageText || loading) return;

    const userMsg = {
      role: 'user',
      content: messageText,
      timestamp: new Date(),
    };

    setMessages((prev) => [...prev, userMsg]);
    setInput('');
    setLoading(true);
    setError(null);

    try {
      const response = await aiService.chat(messageText);
      const aiMsg = {
        role: 'assistant',
        content: response,
        timestamp: new Date(),
      };
      setMessages((prev) => [...prev, aiMsg]);
    } catch (err) {
      const detail =
        err.response?.data?.detail || 'AI yanıt veremedi. Tekrar deneyin.';
      setError(detail);
      const errMsg = {
        role: 'assistant',
        content: `⚠️ Hata: ${detail}`,
        timestamp: new Date(),
        isError: true,
      };
      setMessages((prev) => [...prev, errMsg]);
    } finally {
      setLoading(false);
    }
  };

  const handleKeyDown = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      sendMessage();
    }
  };

  const formatTime = (date) => {
    return date.toLocaleTimeString('tr-TR', {
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  // Markdown-like formatting for AI responses
  const formatContent = (content) => {
    // Bold text
    let formatted = content.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
    // Line breaks
    formatted = formatted.replace(/\n/g, '<br/>');
    return formatted;
  };

  return (
    <div className="flex flex-col h-full bg-mesh-bg">
      {/* Header */}
      <div className="shrink-0 px-6 py-4 border-b border-mesh-disabled bg-mesh-card/50 backdrop-blur-sm">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-mesh-accent to-orange-600 flex items-center justify-center text-xl shadow-lg shadow-mesh-accent/20">
            🤖
          </div>
          <div>
            <h1 className="font-bebas text-2xl tracking-wider text-white">
              AI Asistan
            </h1>
            <p className="font-nunito text-xs text-mesh-muted">
              Groq AI destekli afet yönetim asistanı • Anlık veri analizi
            </p>
          </div>
          <div className="ml-auto flex items-center gap-2">
            <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-mesh-success/15 border border-mesh-success/30">
              <span className="w-2 h-2 rounded-full bg-mesh-success animate-pulse" />
              <span className="font-nunito text-xs text-mesh-success font-semibold">
                Çevrimiçi
              </span>
            </span>
          </div>
        </div>
      </div>

      {/* Messages Area */}
      <div className="flex-1 overflow-y-auto px-6 py-4 space-y-4 ai-chat-scroll">
        {messages.map((msg, i) => (
          <div
            key={i}
            className={`flex ${msg.role === 'user' ? 'justify-end' : 'justify-start'} ai-message-enter`}
          >
            <div
              className={`flex items-start gap-3 max-w-[75%] ${msg.role === 'user' ? 'flex-row-reverse' : ''}`}
            >
              {/* Avatar */}
              <div
                className={`shrink-0 w-8 h-8 rounded-lg flex items-center justify-center text-sm shadow-md ${
                  msg.role === 'user'
                    ? 'bg-gradient-to-br from-mesh-info to-blue-600 shadow-mesh-info/20'
                    : msg.isError
                      ? 'bg-gradient-to-br from-mesh-danger to-red-700 shadow-mesh-danger/20'
                      : 'bg-gradient-to-br from-mesh-accent to-orange-600 shadow-mesh-accent/20'
                }`}
              >
                {msg.role === 'user' ? '👤' : '🤖'}
              </div>

              {/* Bubble */}
              <div
                className={`rounded-2xl px-4 py-3 font-nunito text-sm leading-relaxed shadow-lg ${
                  msg.role === 'user'
                    ? 'bg-mesh-info/20 border border-mesh-info/30 text-white rounded-tr-md'
                    : msg.isError
                      ? 'bg-mesh-danger/10 border border-mesh-danger/30 text-mesh-danger rounded-tl-md'
                      : 'bg-mesh-card border border-mesh-disabled/50 text-gray-200 rounded-tl-md'
                }`}
              >
                <div
                  dangerouslySetInnerHTML={{
                    __html: formatContent(msg.content),
                  }}
                />
                <div
                  className={`text-[10px] mt-2 ${
                    msg.role === 'user' ? 'text-mesh-info/60 text-right' : 'text-mesh-muted/60'
                  }`}
                >
                  {formatTime(msg.timestamp)}
                </div>
              </div>
            </div>
          </div>
        ))}

        {/* Typing Indicator */}
        {loading && (
          <div className="flex justify-start ai-message-enter">
            <div className="flex items-start gap-3 max-w-[75%]">
              <div className="shrink-0 w-8 h-8 rounded-lg bg-gradient-to-br from-mesh-accent to-orange-600 flex items-center justify-center text-sm shadow-md shadow-mesh-accent/20">
                🤖
              </div>
              <div className="rounded-2xl rounded-tl-md px-5 py-4 bg-mesh-card border border-mesh-disabled/50 shadow-lg">
                <div className="flex items-center gap-1.5">
                  <span className="typing-dot" style={{ animationDelay: '0ms' }} />
                  <span className="typing-dot" style={{ animationDelay: '150ms' }} />
                  <span className="typing-dot" style={{ animationDelay: '300ms' }} />
                </div>
              </div>
            </div>
          </div>
        )}

        <div ref={messagesEndRef} />
      </div>

      {/* Quick Questions */}
      {messages.length <= 1 && !loading && (
        <div className="shrink-0 px-6 pb-2">
          <p className="font-nunito text-xs text-mesh-muted mb-2 font-semibold uppercase tracking-wider">
            Hızlı Sorular
          </p>
          <div className="flex flex-wrap gap-2">
            {QUICK_QUESTIONS.map((q, i) => (
              <button
                key={i}
                onClick={() => sendMessage(q.message)}
                className="px-3 py-1.5 rounded-lg bg-mesh-card border border-mesh-disabled/50 text-mesh-muted font-nunito text-xs
                           hover:border-mesh-accent/50 hover:text-mesh-accent hover:bg-mesh-accent/5
                           transition-all duration-200 shadow-sm hover:shadow-md hover:shadow-mesh-accent/10"
              >
                {q.label}
              </button>
            ))}
          </div>
        </div>
      )}

      {/* Input Area */}
      <div className="shrink-0 px-6 py-4 border-t border-mesh-disabled bg-mesh-card/30 backdrop-blur-sm">
        <div className="flex items-end gap-3">
          <div className="flex-1 relative">
            <textarea
              ref={textareaRef}
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onKeyDown={handleKeyDown}
              placeholder="Mesajınızı yazın... (Shift+Enter yeni satır)"
              disabled={loading}
              rows={1}
              className="w-full px-4 py-3 rounded-xl bg-mesh-bg border border-mesh-disabled/50 text-white font-nunito text-sm
                         placeholder:text-mesh-disabled resize-none
                         focus:outline-none focus:border-mesh-accent/50 focus:ring-1 focus:ring-mesh-accent/20
                         disabled:opacity-50 disabled:cursor-not-allowed
                         transition-all duration-200"
              style={{ minHeight: '44px', maxHeight: '120px' }}
            />
          </div>
          <button
            onClick={() => sendMessage()}
            disabled={!input.trim() || loading}
            className="shrink-0 w-11 h-11 rounded-xl flex items-center justify-center text-white text-lg
                       bg-gradient-to-r from-mesh-accent to-orange-600
                       hover:from-orange-600 hover:to-mesh-accent
                       disabled:from-mesh-disabled disabled:to-mesh-disabled disabled:cursor-not-allowed
                       transition-all duration-300 shadow-lg shadow-mesh-accent/30
                       disabled:shadow-none
                       active:scale-95"
          >
            {loading ? (
              <svg className="w-5 h-5 animate-spin" viewBox="0 0 24 24" fill="none">
                <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="3" />
                <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
              </svg>
            ) : (
              '➤'
            )}
          </button>
        </div>
        <p className="font-nunito text-[10px] text-mesh-disabled mt-2 text-center">
          Groq AI · Veriler anlık olarak veritabanından çekilir
        </p>
      </div>
    </div>
  );
};

export default AIChatPage;
