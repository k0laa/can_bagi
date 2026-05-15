import { useState } from 'react';
import useMapStore from '../../store/mapStore';

const formatTime = (ts) => {
  if (!ts) return '--:--';
  const date = new Date(typeof ts === 'number' && ts < 1e12 ? ts * 1000 : ts);
  return date.toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit', second: '2-digit' });
};

const categoryLabels = {
  MEDICAL: '🏥 Tıbbi',
  RESCUE: '🚨 Kurtarma',
  FOOD: '🍞 Gıda',
  SHELTER: '🏕️ Barınma',
  CLOTHES: '👕 Giysi',
  VULNERABLE: '👶 Kırılgan',
};

const SosList = ({ isOpen, onToggle }) => {
  const [activeTab, setActiveTab] = useState('sos');
  const { sosList, requestList, mapInstance } = useMapStore();

  const flyTo = (lat, lon) => {
    if (mapInstance) {
      mapInstance.flyTo([lat, lon], 16);
    }
  };

  return (
    <div
      className={`
        shrink-0 h-full
        bg-mesh-card border-l border-mesh-disabled
        transition-all duration-300 flex flex-col
        ${isOpen ? 'w-80' : 'w-0 overflow-hidden'}
      `}
    >
      <div className="flex justify-between items-center p-4 border-b border-mesh-disabled shrink-0">
        <h2 className="font-bebas text-xl tracking-wider">AKTİF ÇAĞRILAR</h2>
        <button onClick={onToggle} className="text-mesh-muted hover:text-white">✕</button>
      </div>

      <div className="flex border-b border-mesh-disabled shrink-0">
        <button
          onClick={() => setActiveTab('sos')}
          className={`flex-1 py-2.5 font-bebas text-sm tracking-wider transition-colors ${activeTab === 'sos'
            ? 'text-mesh-danger border-b-2 border-mesh-danger'
            : 'text-mesh-muted hover:text-white'
            }`}
        >
          SOS ({sosList.length})
        </button>
        <button
          onClick={() => setActiveTab('requests')}
          className={`flex-1 py-2.5 font-bebas text-sm tracking-wider transition-colors ${activeTab === 'requests'
            ? 'text-mesh-accent border-b-2 border-mesh-accent'
            : 'text-mesh-muted hover:text-white'
            }`}
        >
          Talepler ({requestList.length})
        </button>
      </div>

      <div className="flex-1 overflow-y-auto">
        {activeTab === 'sos' && (
          sosList.length === 0 ? (
            <div className="flex flex-col items-center justify-center h-32 text-mesh-disabled">
              <span className="text-3xl">🟢</span>
              <p className="font-nunito text-xs mt-2">Aktif SOS yok</p>
            </div>
          ) : (
            sosList.map((sos) => (
              <div
                key={sos.id}
                className="p-3 border-l-4 border-mesh-danger cursor-pointer hover:bg-mesh-bg transition-colors border-b border-mesh-disabled/30"
                onClick={() => sos.lat && flyTo(sos.lat, sos.lon)}
              >
                <div className="flex justify-between items-center">
                  <span className="font-bebas text-mesh-danger">🔴 ACİL SOS</span>
                  <span className="font-nunito text-xs text-mesh-muted">{formatTime(sos.ts)}</span>
                </div>
                <p className="font-nunito text-sm text-mesh-muted mt-0.5">Node: {sos.node_id}</p>
              </div>
            ))
          )
        )}

        {activeTab === 'requests' && (
          requestList.length === 0 ? (
            <div className="flex flex-col items-center justify-center h-32 text-mesh-disabled">
              <span className="text-3xl">✅</span>
              <p className="font-nunito text-xs mt-2">Bekleyen talep yok</p>
            </div>
          ) : (
            requestList.map((req) => (
              <div
                key={req.id}
                className="p-3 border-l-4 border-mesh-accent cursor-pointer hover:bg-mesh-bg transition-colors border-b border-mesh-disabled/30"
                onClick={() => req.lat && flyTo(req.lat, req.lon)}
              >
                <div className="flex justify-between items-center">
                  <span className="font-bebas text-mesh-accent">
                    🟠 {categoryLabels[req.category] || req.category}
                  </span>
                  <span className="font-nunito text-xs text-mesh-muted">{formatTime(req.ts)}</span>
                </div>
                <p className="font-nunito text-sm text-mesh-muted mt-0.5">
                  {req.people_count} kişi
                  {req.details ? ` · ${req.details}` : ''}
                </p>
              </div>
            ))
          )
        )}
      </div>
    </div>
  );
};

export default SosList;
