import { useState } from 'react';
import useMapStore from '../../store/mapStore';
import sosService from '../../services/sosService';
import { showToast } from '../../store/toastStore';
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
  const { sosList, requestList, mapInstance, removeSOS, removeRequest, updateRequest } = useMapStore();

  const handleResolve = async (e, id) => {
    e.stopPropagation();
    try {
      removeSOS(id);
      showToast(`SOS #${id} başarıyla kapatıldı`, 'success');
      await sosService.resolve(id);
    } catch (err) {
      console.error('Failed to resolve SOS', err);
      showToast('SOS kapatılırken hata oluştu', 'error');
    }
  };

  const handleDelete = async (e, id) => {
    e.stopPropagation();
    try {
      removeSOS(id);
      showToast(`SOS #${id} silindi`, 'info');
      await sosService.remove(id);
    } catch (err) {
      console.error('Failed to delete SOS', err);
      showToast('SOS silinirken hata oluştu', 'error');
    }
  };

  const handleRequestDelete = async (e, id) => {
    e.stopPropagation();
    try {
      removeRequest(id);
      showToast(`Talep #${id} silindi`, 'info');
      await needsService.remove(id);
    } catch (err) {
      console.error('Failed to delete request', err);
      showToast('Talep silinirken hata', 'error');
    }
  };

  const handleRequestStatus = async (e, id) => {
    e.stopPropagation();
    const newStatus = e.target.value;
    try {
      updateRequest(id, { status: newStatus });
      showToast(`Talep durumu: ${newStatus}`, 'success');
      await needsService.setStatus(id, newStatus);
    } catch (err) {
      console.error('Failed to update status', err);
      showToast('Hata oluştu', 'error');
    }
  };

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
                <div className="flex justify-between items-center mt-0.5">
                  <p className="font-nunito text-sm text-mesh-muted">Node: {sos.node_id}</p>
                  <div className="flex gap-1">
                    <button
                      onClick={(e) => handleResolve(e, sos.id)}
                      className="text-[10px] uppercase tracking-wider font-bebas bg-mesh-disabled hover:bg-mesh-success text-white px-2 py-1 rounded transition-colors"
                    >
                      Çözüldü
                    </button>
                    <button
                      onClick={(e) => handleDelete(e, sos.id)}
                      className="text-[10px] uppercase tracking-wider font-bebas bg-mesh-disabled hover:bg-mesh-danger text-white px-2 py-1 rounded transition-colors"
                    >
                      SİL
                    </button>
                  </div>
                </div>
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
                <div className="flex justify-between items-center mt-0.5">
                  <p className="font-nunito text-sm text-mesh-muted">
                    {req.people_count} kişi
                    {req.details ? ` · ${req.details}` : ''}
                  </p>
                </div>
                <div className="flex gap-2 items-center mt-2">
                  <select
                    value={req.status || 'pending'}
                    onChange={(e) => handleRequestStatus(e, req.id)}
                    onClick={(e) => e.stopPropagation()}
                    className="flex-1 bg-mesh-disabled text-white text-[10px] p-1 rounded font-nunito border border-mesh-border outline-none focus:border-mesh-accent"
                  >
                    <option value="pending">Bekliyor</option>
                    <option value="assigned">Atandı</option>
                    <option value="resolved">Çözüldü</option>
                  </select>
                  <button
                    onClick={(e) => handleRequestDelete(e, req.id)}
                    className="text-[10px] uppercase tracking-wider font-bebas bg-mesh-disabled hover:bg-mesh-danger text-white px-2 py-1 rounded transition-colors"
                  >
                    SİL
                  </button>
                </div>
              </div>
            ))
          )
        )}
      </div>
    </div>
  );
};

export default SosList;
