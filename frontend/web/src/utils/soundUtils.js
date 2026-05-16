// Web Audio API ile programatik bildirim sesleri (mp3 dosyasına ihtiyaç yok)

let audioCtx = null;

const getCtx = () => {
  if (!audioCtx) {
    try {
      const Ctor = window.AudioContext || window.webkitAudioContext;
      audioCtx = new Ctor();
    } catch (e) {
      console.warn('[sound] AudioContext yok:', e);
    }
  }
  return audioCtx;
};

const beep = ({ frequency = 800, duration = 0.2, type = 'sine', volume = 0.3 }) => {
  const ctx = getCtx();
  if (!ctx) return;
  if (ctx.state === 'suspended') ctx.resume();

  const osc = ctx.createOscillator();
  const gain = ctx.createGain();

  osc.type = type;
  osc.frequency.value = frequency;
  gain.gain.value = volume;

  osc.connect(gain);
  gain.connect(ctx.destination);

  const now = ctx.currentTime;
  gain.gain.setValueAtTime(volume, now);
  gain.gain.exponentialRampToValueAtTime(0.001, now + duration);

  osc.start(now);
  osc.stop(now + duration);
};

const playSequence = (notes) => {
  const ctx = getCtx();
  if (!ctx) return;
  let delay = 0;
  notes.forEach((note) => {
    setTimeout(() => beep(note), delay);
    delay += (note.duration || 0.2) * 1000 + 30;
  });
};

const sounds = {
  // Acil siren tarzı (yüksek-alçak iki ton tekrarlı)
  sos: () => playSequence([
    { frequency: 880, duration: 0.18, type: 'square', volume: 0.35 },
    { frequency: 660, duration: 0.18, type: 'square', volume: 0.35 },
    { frequency: 880, duration: 0.18, type: 'square', volume: 0.35 },
    { frequency: 660, duration: 0.18, type: 'square', volume: 0.35 },
  ]),
  // Normal bildirim (iki yumuşak ton)
  request: () => playSequence([
    { frequency: 700, duration: 0.12, type: 'sine', volume: 0.25 },
    { frequency: 950, duration: 0.18, type: 'sine', volume: 0.25 },
  ]),
  // Uyarı (alçak ton)
  nodeDown: () => playSequence([
    { frequency: 400, duration: 0.25, type: 'triangle', volume: 0.3 },
    { frequency: 300, duration: 0.3,  type: 'triangle', volume: 0.3 },
  ]),
};

export const playSound = (type) => {
  const fn = sounds[type];
  if (fn) {
    try {
      fn();
    } catch (err) {
      // Tarayıcı autoplay politikası nedeniyle sessizce başarısız ol
    }
  }
};

// İlk kullanıcı etkileşiminde AudioContext'i hazırla
export const primeAudio = () => {
  const ctx = getCtx();
  if (ctx && ctx.state === 'suspended') ctx.resume();
};
