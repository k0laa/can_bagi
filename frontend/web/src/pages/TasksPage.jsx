import { useState, useMemo, useEffect } from 'react';
import useTaskStore from '../store/taskStore';
import useAuthStore from '../store/authStore';
import useToastStore from '../store/toastStore';
import TaskCard from '../components/dashboard/TaskCard';
import TaskForm from '../components/dashboard/TaskForm';
import Button from '../components/ui/Button';
import Modal from '../components/ui/Modal';
import EmptyState from '../components/ui/EmptyState';
import tasksService from '../services/tasksService';
import userService from '../services/userService';

const FILTERS = [
  { key: 'all', label: 'Tümü' },
  { key: 'pending', label: 'Bekliyor' },
  { key: 'assigned', label: 'Atandı' },
  { key: 'completed', label: 'Tamamlandı' },
];

const TasksPage = () => {
  const { tasks, updateTask, deleteTask, upsertTask } = useTaskStore();
  const addToast = useToastStore((s) => s.addToast);
  const token = useAuthStore((s) => s.token);
  const isDemo = token === 'dev-test-token';

  useEffect(() => {
    tasksService.prioritized().then((list) => {
      list.forEach((t) => upsertTask(t));
    }).catch(() => {});
  }, []);

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

  const handleMatch = async (id) => {
    if (isDemo) {
      updateTask(id, { assigned_to: 'Demo Gönüllü', status: 'assigned' });
      addToast({ type: 'success', message: 'Gönüllü atandı (demo)' });
      return;
    }
    try {
      const matched = await tasksService.match(id);
      updateTask(id, matched);
      addToast({ type: 'success', message: 'En uygun gönüllü atandı' });
    } catch (err) {
      addToast({ type: 'error', title: 'Eşleşme Hatası', message: err.response?.data?.detail || err.message });
    }
  };
  const [activeFilter, setActiveFilter] = useState('all');
  const [showForm, setShowForm] = useState(false);
  const [confirmDel, setConfirmDel] = useState(null);
  const [assignModal, setAssignModal] = useState(null); // { task }
  const [users, setUsers] = useState([]);
  const [assigning, setAssigning] = useState(false);

  useEffect(() => {
    userService.list().then(setUsers).catch(() => {});
  }, []);

  const handleManualAssign = async (userId) => {
    if (!assignModal) return;
    setAssigning(true);
    try {
      const updated = await tasksService.assign(assignModal.task.id, userId);
      const user = users.find((u) => u.id === userId);
      updateTask(assignModal.task.id, { ...updated, assigned_to: user ? `${user.name} ${user.surname}` : String(userId) });
      addToast({ type: 'success', message: 'Görev başarıyla atandı' });
      setAssignModal(null);
    } catch (err) {
      addToast({ type: 'error', title: 'Atama Hatası', message: err.response?.data?.detail || err.message });
    } finally {
      setAssigning(false);
    }
  };

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
                onMatch={handleMatch}
                onManualAssign={(task) => setAssignModal({ task })}
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

      {assignModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60">
          <div className="bg-mesh-card rounded-xl p-6 w-full max-w-md shadow-xl border border-mesh-disabled">
            <h2 className="font-bebas text-2xl tracking-widest text-mesh-text mb-1">
              MANUEL ATA
            </h2>
            <p className="font-nunito text-xs text-mesh-muted mb-4">
              "{assignModal.task.title}" görevine kullanıcı seç:
            </p>
            <div className="flex flex-col gap-2 max-h-72 overflow-y-auto">
              {users.filter((u) => u.role === 'USER').map((u) => (
                <button
                  key={u.id}
                  disabled={assigning}
                  onClick={() => handleManualAssign(u.id)}
                  className="flex items-center justify-between bg-mesh-bg hover:bg-mesh-accent/10 border border-mesh-disabled hover:border-mesh-accent rounded-lg px-4 py-3 transition-colors text-left"
                >
                  <div>
                    <p className="font-nunito text-sm font-semibold text-mesh-text">
                      {u.name} {u.surname}
                    </p>
                    <p className="font-nunito text-xs text-mesh-muted">
                      {u.skills || 'GENERAL'} · {u.phone}
                      {u.active_task_id && <span className="ml-2 text-mesh-warning">⚠ Aktif görevi var</span>}
                    </p>
                  </div>
                  <span className="font-bebas text-sm text-mesh-accent">ATA →</span>
                </button>
              ))}
              {users.filter((u) => u.role === 'USER').length === 0 && (
                <p className="font-nunito text-sm text-mesh-muted text-center py-4">Kullanıcı bulunamadı</p>
              )}
            </div>
            <button
              onClick={() => setAssignModal(null)}
              className="mt-4 w-full font-nunito text-sm text-mesh-muted hover:text-mesh-text transition-colors"
            >
              İptal
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

export default TasksPage;
