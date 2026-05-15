import useMapStore from '../../store/mapStore';

const filters = [
  { key: 'all',          label: 'Tümü',      color: 'text-mesh-text' },
  { key: 'sos',          label: '🔴 SOS',     color: 'text-mesh-danger' },
  { key: 'request',      label: '🟠 Talepler', color: 'text-mesh-accent' },
  { key: 'assembly',     label: '🟢 Toplanma', color: 'text-mesh-success' },
  { key: 'distribution', label: '🔵 Dağıtım', color: 'text-mesh-info' },
  { key: 'node',         label: '🟣 Nodlar',  color: 'text-purple-400' },
];

const MapFilters = () => {
  const { activeFilter, setFilter } = useMapStore();

  return (
    <div className="absolute top-16 left-1/2 -translate-x-1/2 z-20 flex gap-1 bg-mesh-card/90 backdrop-blur border border-mesh-disabled rounded-xl p-1.5 shadow-lg">
      {filters.map((f) => (
        <button
          key={f.key}
          onClick={() => setFilter(f.key)}
          className={`
            font-nunito text-xs font-semibold px-3 py-1.5 rounded-lg transition-all whitespace-nowrap
            ${activeFilter === f.key
              ? 'bg-mesh-accent text-white shadow'
              : `${f.color} hover:bg-mesh-bg`
            }
          `}
        >
          {f.label}
        </button>
      ))}
    </div>
  );
};

export default MapFilters;
