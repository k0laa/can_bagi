import { Marker, Popup } from 'react-leaflet';
import { icons, formatTime } from '../../utils/mapIcons';

const NodeMarker = ({ data }) => {
  if (data.lat == null || data.lon == null) return null;

  const isActive = data.status === 'active';
  const heapKB = data.free_heap ? Math.round(data.free_heap / 1024) : 0;

  return (
    <Marker
      position={[data.lat, data.lon]}
      icon={isActive ? icons.node : icons.nodeInactive}
    >
      <Popup className="mesh-popup">
        <div className={`bg-mesh-card rounded-lg p-3 min-w-52 border ${isActive ? 'border-purple-500/30' : 'border-mesh-disabled/30'}`}>
          <h3 className={`font-bebas text-xl tracking-wider mb-2 ${isActive ? 'text-purple-400' : 'text-mesh-muted'}`}>
            🟣 {data.node_id}
          </h3>
          <div className="flex flex-col gap-1">
            <div className="flex items-center gap-2">
              <div className={`w-2 h-2 rounded-full ${isActive ? 'bg-mesh-success animate-pulse' : 'bg-mesh-danger'}`} />
              <span className={`font-nunito text-xs font-semibold ${isActive ? 'text-mesh-success' : 'text-mesh-danger'}`}>
                {isActive ? 'Aktif' : 'Pasif'}
              </span>
            </div>
            {heapKB > 0 && (
              <p className="font-nunito text-xs text-mesh-muted">
                <span className="text-mesh-text font-semibold">Bellek:</span> {heapKB} KB
              </p>
            )}
            <p className="font-nunito text-xs text-mesh-muted">
              <span className="text-mesh-text font-semibold">Son görülme:</span>{' '}
              {formatTime(data.last_seen)}
            </p>
          </div>
        </div>
      </Popup>
    </Marker>
  );
};

export default NodeMarker;
