import { Marker, Popup } from 'react-leaflet';
import { icons, categoryLabels, formatTime } from '../../utils/mapIcons';
import Button from '../ui/Button';

const RequestMarker = ({ data, onCreateTask }) => {
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
          <Button
            variant="primary"
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

export default RequestMarker;
