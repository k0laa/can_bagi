import { Marker, Popup } from 'react-leaflet';
import { icons, categoryLabels, formatTime } from '../../utils/mapIcons';
import Button from '../ui/Button';
import needsService from '../../services/needsService';
import useMapStore from '../../store/mapStore';
import { showToast } from '../../store/toastStore';

const RequestMarker = ({ data, onCreateTask }) => {
  const { removeRequest, updateRequest } = useMapStore();

  const handleDelete = async () => {
    try {
      removeRequest(data.id);
      showToast(`Talep #${data.id} silindi`, 'info');
      await needsService.remove(data.id);
    } catch (e) {
      console.error('Failed to delete request', e);
      showToast('Hata oluştu', 'error');
    }
  };

  const handleStatusChange = async (e) => {
    const newStatus = e.target.value;
    try {
      updateRequest(data.id, { status: newStatus });
      showToast(`Durum güncellendi: ${newStatus}`, 'success');
      await needsService.setStatus(data.id, newStatus);
    } catch (err) {
      console.error('Failed to update status', err);
      showToast('Hata oluştu', 'error');
    }
  };
  return (
    <Marker position={[data.lat, data.lon]} icon={icons.request}>
      <Popup className="mesh-popup">
        <div className="bg-mesh-card rounded-lg p-3 min-w-52 border border-mesh-accent/30">
          <h3 className="font-bebas text-xl text-mesh-accent tracking-wider mb-2">
            🟠 {categoryLabels[data.category] || data.category}
          </h3>
          <div className="flex flex-col gap-1 mb-3">
            <p className="font-nunito text-xs text-mesh-muted">
              <span className="text-mesh-text font-semibold">Kişi:</span> {data.people_count} kişi
            </p>
            {data.details && (
              <p className="font-nunito text-xs text-mesh-muted">
                <span className="text-mesh-text font-semibold">Not:</span> {data.details}
              </p>
            )}
            <p className="font-nunito text-xs text-mesh-muted">
              <span className="text-mesh-text font-semibold">Node:</span> {data.node_id}
            </p>
            <p className="font-nunito text-xs text-mesh-muted">
              <span className="text-mesh-text font-semibold">Saat:</span> {formatTime(data.ts)}
            </p>
          </div>
          <div className="flex flex-col gap-2">
            <div className="flex gap-2 items-center">
              <select
                value={data.status || 'pending'}
                onChange={handleStatusChange}
                className="flex-1 bg-mesh-disabled text-white text-xs p-1 rounded font-nunito border border-mesh-border outline-none focus:border-mesh-accent"
              >
                <option value="pending">Bekliyor</option>
                <option value="assigned">Atandı</option>
                <option value="resolved">Çözüldü</option>
              </select>
              <Button
                variant="outline"
                size="sm"
                className="px-2 py-1 text-xs border-mesh-danger text-mesh-danger hover:bg-mesh-danger hover:text-white"
                onClick={handleDelete}
              >
                Sil
              </Button>
            </div>
            <Button
              variant="primary"
              size="sm"
              className="w-full"
              onClick={() => onCreateTask && onCreateTask(data)}
            >
              Görev Oluştur
            </Button>
          </div>
        </div>
      </Popup>
    </Marker>
  );
};

export default RequestMarker;
