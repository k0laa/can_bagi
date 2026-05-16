import useMapStore from '../../store/mapStore';
import { taskTypeLabels } from '../../utils/mockData';
import { formatTime } from '../../utils/mapIcons';

const statusConfig = {
  pending: { label: 'Bekliyor', border: 'border-mesh-warning', dot: 'bg-mesh-warning', text: 'text-mesh-warning' },
  assigned: { label: 'Atandı', border: 'border-mesh-accent', dot: 'bg-mesh-accent', text: 'text-mesh-accent' },
  completed: { label: 'Tamamlandı', border: 'border-mesh-success', dot: 'bg-mesh-success', text: 'text-mesh-success' },
};

const STATUS_OPTIONS = ['pending', 'assigned', 'completed'];

const TaskCard = ({ task, onChangeStatus, onDelete }) => {
  const mapInstance = useMapStore((s) => s.mapInstance);
  const cfg = statusConfig[task.status] || statusConfig.pending;

  const flyToCoords = () => {
    if (mapInstance && task.lat != null && task.lon != null) {
      mapInstance.flyTo([task.lat, task.lon], 16);
    }
  };

  return (
    <div className={`bg-mesh-card rounded-lg p-4 border-l-4 ${cfg.border}`}>
      <div className="flex justify-between items-start gap-3 mb-2">
        <div className="flex-1 min-w-0">
          <h3 className="font-bebas text-xl tracking-wider text-mesh-text">
            {task.title || taskTypeLabels[task.type] || task.type}
          </h3>
          <p className="font-nunito text-xs text-mesh-muted mt-0.5">
            {taskTypeLabels[task.type] || task.type}
            {task.lat != null && task.lon != null && (
              <button
                type="button"
                onClick={flyToCoords}
                className="ml-2 text-mesh-info hover:underline"
                title="Haritada göster"
              >
                📍 {task.lat.toFixed(4)}, {task.lon.toFixed(4)}
              </button>
            )}
          </p>
        </div>
        <div className="flex items-center gap-1.5 shrink-0">
          <div className={`w-2 h-2 rounded-full ${cfg.dot}`} />
          <span className={`font-nunito text-xs font-semibold ${cfg.text}`}>
            {cfg.label}
          </span>
        </div>
      </div>

      {task.assigned_to && (
        <div className="font-nunito text-xs mb-3">
          <span className="text-mesh-muted">Atanan: </span>
          <span className="text-mesh-text font-semibold">{task.assigned_to}</span>
        </div>
      )}

      <div className="flex items-center justify-between gap-2 pt-2 border-t border-mesh-disabled">
        <select
          value={task.status}
          onChange={(e) => onChangeStatus && onChangeStatus(task.id, e.target.value)}
          className="bg-mesh-bg border border-mesh-disabled rounded px-2 py-1 font-nunito text-xs text-mesh-text focus:outline-none focus:border-mesh-accent"
        >
          {STATUS_OPTIONS.map((s) => (
            <option key={s} value={s}>{statusConfig[s].label}</option>
          ))}
        </select>
        <span className="font-nunito text-xs text-mesh-disabled">
          {formatTime(task.created_at)}
        </span>
        {onDelete && (
          <button
            onClick={() => onDelete(task.id)}
            className="font-nunito text-xs text-mesh-danger hover:text-red-400"
            title="Sil"
          >
            🗑
          </button>
        )}
      </div>
    </div>
  );
};

export default TaskCard;
