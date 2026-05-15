import { Marker, Popup } from 'react-leaflet';
import { icons, formatTime } from '../../utils/mapIcons';
import Button from '../ui/Button';

const SosMarker = ({ data, onCreateTask }) => {
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
          <Button
            variant="danger"
            size="sm"
            className="w-full"
            onClick={() => onCreateTask && onCreateTask(data)}
          >
            Görev Oluştur
          </Button>
        </div>
      </Popup>
    </Marker>
  );
};

export default SosMarker;
