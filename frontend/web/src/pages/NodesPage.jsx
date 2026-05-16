import { useMemo } from 'react';
import useMapStore from '../store/mapStore';
import StatCard from '../components/dashboard/StatCard';
import NodeCard from '../components/dashboard/NodeCard';

const NodesPage = () => {
  const nodeList = useMapStore((s) => s.nodeList);

  const { active, inactive } = useMemo(() => ({
    active: nodeList.filter((n) => n.status === 'active').length,
    inactive: nodeList.filter((n) => n.status !== 'active').length,
  }), [nodeList]);

  return (
    <div className="p-6 max-w-7xl mx-auto">
      <h1 className="font-bebas text-4xl text-mesh-text tracking-widest mb-5">
        NODE DURUMU
      </h1>

      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
        <StatCard label="Toplam Node" value={nodeList.length} color="info" icon="📡" />
        <StatCard label="Aktif" value={active} color="success" icon="🟢" />
        <StatCard label="Pasif" value={inactive} color="danger" icon="🔴" />
      </div>

      {nodeList.length === 0 ? (
        <div className="bg-mesh-card rounded-lg p-8 text-center">
          <p className="font-bebas text-2xl text-mesh-muted tracking-widest">
            NODE BULUNAMADI
          </p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {nodeList.map((node) => (
            <NodeCard key={node.node_id} data={node} />
          ))}
        </div>
      )}
    </div>
  );
};

export default NodesPage;
