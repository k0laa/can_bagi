import useMapStore from "../../store/mapStore";
import useTaskStore from "../../store/taskStore";

const StatItem = ({ icon, label, value, colorClass }) => (
  <div className="flex items-center gap-2.5">
    <span className="text-xl">{icon}</span>
    <div className="flex flex-col leading-tight">
      <span className="font-nunito text-[10px] uppercase tracking-wider text-mesh-muted">
        {label}
      </span>
      <span className={`font-bebas text-lg tracking-wider ${colorClass}`}>
        {value}
      </span>
    </div>
  </div>
);

const DashboardStatsBar = () => {
  const { sosList, requestList, nodeList } = useMapStore();
  const tasks = useTaskStore((s) => s.tasks);

  const activeNodes = nodeList.filter((n) => n.status === "active").length;
  const completedTasks = tasks.filter((t) => t.status === "completed").length;

  return (
    <div className="absolute bottom-3 left-3 z-[900] bg-mesh-card/90 backdrop-blur border border-mesh-disabled rounded-xl px-4 py-2 shadow-lg flex flex-wrap gap-5">
      <StatItem
        icon="🔴"
        label="Aktif SOS"
        value={sosList.length}
        colorClass="text-mesh-danger"
      />
      <StatItem
        icon="🟠"
        label="Talep"
        value={requestList.length}
        colorClass="text-mesh-accent"
      />
      <StatItem
        icon="📡"
        label="Aktif Node"
        value={`${activeNodes}/${nodeList.length}`}
        colorClass="text-mesh-success"
      />
      <StatItem
        icon="✅"
        label="Tamamlanan"
        value={completedTasks}
        colorClass="text-mesh-info"
      />
    </div>
  );
};

export default DashboardStatsBar;
