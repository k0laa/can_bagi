import { Marker, Popup } from 'react-leaflet';
import { icons, formatTime } from '../../utils/mapIcons';
import Button from '../ui/Button';
import sosService from '../../services/sosService';
import useMapStore from '../../store/mapStore';
import { showToast } from '../../store/toastStore';

const SosMarker = ({ data, onCreateTask }) => {
  const removeSOS = useMapStore((s) => s.removeSOS);

  const handleResolve = async () => {
    try {
      removeSOS(data.id);
      showToast(`SOS #${data.id} başarıyla kapatıldı`, 'success');
      await sosService.resolve(data.id);
    } catch (e) {
      console.error('Failed to resolve SOS', e);
      showToast('SOS kapatılırken hata oluştu', 'error');
    }
  };

  return (
    <Marker position={[data.lat, data.lon]} icon={icons.sos}>
      <Popup className="mesh-popup">
        <div className="bg-mesh-card rounded-lg p-3 min-w-52 border border-mesh-danger/30">
          <h3 className="font-bebas text-xl text-mesh-danger tracking-wider mb-2">
            🔴 ACİL SOS
          </h3>
          <div className="flex flex-col gap-1 mb-3">
            <p className="font-nunito text-xs text-mesh-muted">
              <span className="text-mesh-text font-semibold">Node:</span> {data.node_id}
            </p>
            <p className="font-nunito text-xs text-mesh-muted">
              <span className="text-mesh-text font-semibold">Saat:</span> {formatTime(data.ts)}
            </p>
            <p className="font-nunito text-xs text-mesh-muted">
              <span className="text-mesh-text font-semibold">Konum:</span>{' '}
              {data.lat?.toFixed(4)}, {data.lon?.toFixed(4)}
            </p>
          </div>
          <div className="flex gap-2">
            <Button
              variant="danger"
              size="sm"
              className="flex-1"
              onClick={() => onCreateTask && onCreateTask(data)}
            >
              Görev
            </Button>
            <Button
              variant="outline"
              size="sm"
              className="flex-1 border-mesh-danger text-mesh-danger hover:bg-mesh-danger hover:text-white"
              onClick={handleResolve}
            >
              Çözüldü
            </Button>
          </div>
        </div>
      </Popup>
    </Marker>
  );
};

export default SosMarker;
