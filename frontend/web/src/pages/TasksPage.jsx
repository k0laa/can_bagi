import { useState, useMemo } from 'react';
import useTaskStore from '../store/taskStore';
import useAuthStore from '../store/authStore';
import useToastStore from '../store/toastStore';
import TaskCard from '../components/dashboard/TaskCard';
import TaskForm from '../components/dashboard/TaskForm';
import Button from '../components/ui/Button';
import Modal from '../components/ui/Modal';
import EmptyState from '../components/ui/EmptyState';
import tasksService from '../services/tasksService';

const FILTERS = [
  { key: 'all', label: 'Tümü' },
  { key: 'pending', label: 'Bekliyor' },
  { key: 'assigned', label: 'Atandı' },
  { key: 'completed', label: 'Tamamlandı' },
];

const TasksPage = () => {
  const { tasks, updateTask, deleteTask } = useTaskStore();
  const addToast = useToastStore((s) => s.addToast);
  const token = useAuthStore((s) => s.token);
  const isDemo = token === 'dev-test-token';

  const handleStatusChange = async (id, status) => {
    updateTask(id, { status });
    if (isDemo) {
      addToast({ type: 'success', message: 'Görev durumu güncellendi (demo)' });
      return;
    }
    try {
      await tasksService.update(id, { status });
      addToast({ type: 'success', message: 'Görev durumu güncellendi' });
    } catch (err) {
      addToast({ type: 'error', title: 'Güncellenemedi', message: err.response?.data?.detail || err.message });
    }
  };

  const handleDelete = async (id) => {
    deleteTask(id);
    if (isDemo) {
      addToast({ type: 'success', message: 'Görev silindi (demo)' });
      return;
    }
    try {
      await tasksService.remove(id);
      addToast({ type: 'success', message: 'Görev silindi' });
    } catch (err) {
      addToast({ type: 'error', title: 'Silinemedi', message: err.response?.data?.detail || err.message });
    }
  };
  const [activeFilter, setActiveFilter] = useState('all');
  const [showForm, setShowForm] = useState(false);
  const [confirmDel, setConfirmDel] = useState(null);

  const filtered = useMemo(() => {
    if (activeFilter === 'all') return tasks;
    return tasks.filter((t) => t.status === activeFilter);
  }, [tasks, activeFilter]);

  const counts = useMemo(() => ({
    all: tasks.length,
    pending: tasks.filter((t) => t.status === 'pending').length,
    assigned: tasks.filter((t) => t.status === 'assigned').length,
    completed: tasks.filter((t) => t.status === 'completed').length,
  }), [tasks]);

  return (
    <div className="p-6 max-w-7xl mx-auto">
      <div className="flex items-center justify-between mb-5">
        <h1 className="font-bebas text-4xl text-mesh-text tracking-widest">
          GÖREV YÖNETİMİ
        </h1>
        <Button variant="primary" onClick={() => setShowForm((v) => !v)}>
          {showForm ? '✕ FORMU KAPAT' : '+ YENİ GÖREV'}
        </Button>
      </div>

      <div className="flex gap-2 mb-5 flex-wrap">
        {FILTERS.map((f) => (
          <button
            key={f.key}
            onClick={() => setActiveFilter(f.key)}
            className={`
              font-nunito text-sm font-semibold px-4 py-2 rounded-lg transition-all
              ${activeFilter === f.key
                ? 'bg-mesh-accent text-white'
                : 'bg-mesh-card text-mesh-muted hover:text-white'}
            `}
          >
            {f.label} ({counts[f.key]})
          </button>
        ))}
      </div>

      <div className={`grid gap-5 ${showForm ? 'grid-cols-1 lg:grid-cols-3' : 'grid-cols-1'}`}>
        <div className={`${showForm ? 'lg:col-span-2' : ''} flex flex-col gap-3`}>
          {filtered.length === 0 ? (
            <div className="bg-mesh-card rounded-lg">
              <EmptyState
                icon="✅"
                title="GÖREV YOK"
                description="Bu durumda görev bulunmuyor. Yeni görev oluşturmak için sağ üstteki butona basın."
              />
            </div>
          ) : (
            filtered.map((task) => (
              <TaskCard
                key={task.id}
                task={task}
                onChangeStatus={handleStatusChange}
                onDelete={(id) => setConfirmDel(id)}
              />
            ))
          )}
        </div>

        {showForm && (
          <div className="lg:col-span-1">
            <TaskForm onCreated={() => setShowForm(false)} onCancel={() => setShowForm(false)} />
          </div>
        )}
      </div>

      <Modal
        isOpen={confirmDel !== null}
        onClose={() => setConfirmDel(null)}
        title="Görevi Sil"
        confirmText="Sil"
        variant="danger"
        onConfirm={() => {
          handleDelete(confirmDel);
          setConfirmDel(null);
        }}
      >
        <p className="font-nunito text-sm text-mesh-muted">
          Bu görevi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.
        </p>
      </Modal>
    </div>
  );
};

export default TasksPage;
