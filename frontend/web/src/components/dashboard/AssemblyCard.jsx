const AssemblyCard = ({ point, onDelete, onSelect }) => {
  const pct = point.capacity > 0
    ? Math.round((point.current_count / point.capacity) * 100)
    : 0;

  return (
    <div
      className="bg-mesh-card rounded-lg p-4 border-l-4 border-mesh-success cursor-pointer hover:bg-mesh-bg transition-colors"
      onClick={() => onSelect && onSelect(point)}
    >
      <div className="flex justify-between items-start mb-2">
        <h3 className="font-bebas text-lg tracking-wider text-mesh-text flex-1">
          🟢 {point.name}
        </h3>
        {onDelete && (
          <button
            onClick={(e) => { e.stopPropagation(); onDelete(point); }}
            className="text-mesh-danger hover:text-red-400 text-sm shrink-0"
            title="Sil"
          >
            🗑
          </button>
        )}
      </div>

      <div className="font-nunito text-xs space-y-1.5">
        <div className="flex justify-between">
          <span className="text-mesh-muted">Konum:</span>
          <span className="text-mesh-text">
            {point.lat?.toFixed(4)}, {point.lon?.toFixed(4)}
          </span>
        </div>
        <div className="flex justify-between">
          <span className="text-mesh-muted">Doluluk:</span>
          <span className="text-mesh-text font-semibold">
            {point.current_count} / {point.capacity}
          </span>
        </div>
        <div className="w-full bg-mesh-disabled rounded-full h-1.5">
          <div
            className="bg-mesh-success h-1.5 rounded-full transition-all"
            style={{ width: `${Math.min(pct, 100)}%` }}
          />
        </div>
      </div>
    </div>
  );
};

export default AssemblyCard;
