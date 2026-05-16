import { useRef, useState } from 'react';
import MapContainer from '../components/map/MapContainer';
import MapFilters from '../components/map/MapFilters';
import Modal from '../components/ui/Modal';
import TaskForm from '../components/dashboard/TaskForm';
import DashboardStatsBar from '../components/dashboard/DashboardStatsBar';

const DashboardPage = () => {
  const mapRef = useRef(null);
  const [taskFormOpen, setTaskFormOpen] = useState(false);
  const [taskSource, setTaskSource] = useState(null);

  const handleCreateTask = (markerData) => {
    setTaskSource(markerData);
    setTaskFormOpen(true);
  };

  return (
    <div className="relative w-full" style={{ height: '100%' }}>
      <MapContainer mapRef={mapRef} onCreateTask={handleCreateTask} />
      <DashboardStatsBar />
      <MapFilters />

      <Modal
        isOpen={taskFormOpen}
        onClose={() => setTaskFormOpen(false)}
        title={taskSource ? `Görev Oluştur — ${taskSource.node_id || ''}` : 'Görev Oluştur'}
        size="lg"
      >
        <TaskForm
          onCreated={() => setTaskFormOpen(false)}
          onCancel={() => setTaskFormOpen(false)}
        />
      </Modal>
    </div>
  );
};

export default DashboardPage;
