import L from 'leaflet';

const createCircleIcon = (color, size = 28, pulseColor = null) => {
  const pulse = pulseColor
    ? `<div style="
        position:absolute; top:50%; left:50%;
        transform:translate(-50%,-50%);
        width:${size * 2}px; height:${size * 2}px;
        background:${pulseColor}33;
        border-radius:50%;
        animation:iconPulse 1.5s ease-out infinite;
      "></div>`
    : '';

  return L.divIcon({
    html: `
      <div style="position:relative; width:${size}px; height:${size}px;">
        ${pulse}
        <div style="
          width:${size}px; height:${size}px;
          background:${color};
          border-radius:50%;
          border:3px solid rgba(255,255,255,0.9);
          box-shadow:0 0 10px ${color}99, 0 2px 6px rgba(0,0,0,0.4);
          position:relative; z-index:1;
        "></div>
      </div>
    `,
    iconSize: [size, size],
    iconAnchor: [size / 2, size / 2],
    popupAnchor: [0, -(size / 2 + 4)],
    className: '',
  });
};

export const icons = {
  sos:          createCircleIcon('#E63946', 36, '#E63946'),
  request:      createCircleIcon('#FF6B35', 28),
  assembly:     createCircleIcon('#2DC653', 28),
  distribution: createCircleIcon('#4A9EFF', 28),
  node:         createCircleIcon('#9B59B6', 22),
  nodeInactive: createCircleIcon('#445566', 22),
};

export const categoryLabels = {
  MEDICAL:    '🏥 Tıbbi Yardım',
  RESCUE:     '🚨 Kurtarma',
  FOOD:       '🍞 Gıda & Su',
  SHELTER:    '🏕️ Barınma',
  CLOTHES:    '👕 Giysi',
  VULNERABLE: '👶 Kırılgan Grup',
};

export const formatTime = (ts) => {
  if (!ts) return '--:--';
  const date = new Date(typeof ts === 'number' && ts < 1e12 ? ts * 1000 : ts);
  return date.toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit', second: '2-digit' });
};
