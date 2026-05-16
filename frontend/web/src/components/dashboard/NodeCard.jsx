import { formatTime } from '../../utils/mapIcons';
import useMapStore from '../../store/mapStore';
import nodesService from '../../services/nodesService';
import { showToast } from '../../store/toastStore';
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
  const removeNode = useMapStore((s) => s.removeNode);

  const handleDelete = async () => {
    try {
      removeNode(data.node_id);
      showToast(`Node ${data.node_id} silindi`, 'info');
      await nodesService.remove(data.node_id);
    } catch (e) {
      console.error('Failed to delete node', e);
      showToast('Node silinemedi', 'error');
    }
  };

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
      <div className="mt-3 text-right">
        <button
          onClick={handleDelete}
          className="text-[10px] uppercase tracking-wider font-bebas bg-mesh-disabled hover:bg-mesh-danger text-white px-3 py-1 rounded transition-colors"
        >
          Node'u Sil
        </button>
      </div>
    </div>
  );
};

export default NodeCard;
