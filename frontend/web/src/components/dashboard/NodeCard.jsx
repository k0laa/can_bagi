import { formatTime } from '../../utils/mapIcons';

const timeAgo = (iso) => {
  if (!iso) return '';
  const ms = Date.now() - new Date(iso).getTime();
  if (ms < 60000) return `${Math.floor(ms / 1000)}sn önce`;
  if (ms < 3600000) return `${Math.floor(ms / 60000)}dk önce`;
  return `${Math.floor(ms / 3600000)}sa önce`;
};

const NodeCard = ({ data }) => {
  const isActive = data.status === 'active';
  const heapKB = data.free_heap ? Math.round(data.free_heap / 1024) : 0;

  return (
    <div className={`
      bg-mesh-card rounded-lg p-4 border-l-4
      ${isActive ? 'border-mesh-success' : 'border-mesh-danger'}
    `}>
      <div className="flex justify-between items-start mb-3">
        <h3 className="font-bebas text-2xl tracking-wider text-mesh-text">
          {data.node_id}
        </h3>
        <div className="flex items-center gap-1.5">
          <div className={`w-2 h-2 rounded-full ${
            isActive ? 'bg-mesh-success animate-pulse' : 'bg-mesh-danger'
          }`} />
          <span className={`font-nunito text-xs font-semibold ${
            isActive ? 'text-mesh-success' : 'text-mesh-danger'
          }`}>
            {isActive ? 'AKTİF' : 'PASİF'}
          </span>
        </div>
      </div>

      <div className="space-y-1.5">
        {heapKB > 0 && (
          <div className="flex justify-between font-nunito text-xs">
            <span className="text-mesh-muted">Bellek:</span>
            <span className="text-mesh-text font-semibold">{heapKB} KB</span>
          </div>
        )}
        <div className="flex justify-between font-nunito text-xs">
          <span className="text-mesh-muted">Son görülme:</span>
          <span className="text-mesh-text">{formatTime(data.last_seen)}</span>
        </div>
        <div className="flex justify-between font-nunito text-xs">
          <span className="text-mesh-muted">Süre:</span>
          <span className="text-mesh-muted">{timeAgo(data.last_seen)}</span>
        </div>
      </div>
    </div>
  );
};

export default NodeCard;
