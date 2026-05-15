import { Marker, Popup } from 'react-leaflet';
import { icons } from '../../utils/mapIcons';
import Button from '../ui/Button';

const AssemblyMarker = ({ data, onEdit }) => {
  const pct = data.capacity > 0
    ? Math.round((data.current_count / data.capacity) * 100)
    : 0;

  return (
    <Marker position={[data.lat, data.lon]} icon={icons.assembly}>
      <Popup className="mesh-popup">
        <div className="bg-mesh-card rounded-lg p-3 min-w-52 border border-mesh-success/30">
          <h3 className="font-bebas text-xl text-mesh-success tracking-wider mb-2">
            🟢 {data.name}
          </h3>
          <div className="flex flex-col gap-1 mb-3">
            <p className="font-nunito text-xs text-mesh-muted">Toplanma Noktası</p>
            <div className="flex justify-between">
              <span className="font-nunito text-xs text-mesh-muted">Kapasite:</span>
              <span className="font-nunito text-xs text-mesh-text font-semibold">
                {data.current_count} / {data.capacity}
              </span>
            </div>
            <div className="w-full bg-mesh-disabled rounded-full h-1.5 mt-1">
              <div
                className="bg-mesh-success h-1.5 rounded-full transition-all"
                style={{ width: `${Math.min(pct, 100)}%` }}
              />
            </div>
          </div>
          {onEdit && (
            <Button variant="outline" size="sm" className="w-full" onClick={() => onEdit(data)}>
              Düzenle
            </Button>
          )}
        </div>
      </Popup>
    </Marker>
  );
};

export default AssemblyMarker;
