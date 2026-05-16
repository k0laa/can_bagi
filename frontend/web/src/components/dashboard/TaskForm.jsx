import { useState } from 'react';
import Input from '../ui/Input';
import Select from '../ui/Select';
import Button from '../ui/Button';
import useTaskStore from '../../store/taskStore';
import useToastStore from '../../store/toastStore';
import useAuthStore from '../../store/authStore';
import { taskTypeLabels } from '../../utils/mockData';
import tasksService from '../../services/tasksService';

const BALIKESIR = { lat: 39.6484, lon: 27.8826 };

const TaskForm = ({ onCreated, onCancel, prefill }) => {
  const addTask = useTaskStore((s) => s.addTask);
  const addToast = useToastStore((s) => s.addToast);
  const token = useAuthStore((s) => s.token);
  const isDemo = token === 'dev-test-token';

  const [form, setForm] = useState({
    title: '',
    type: 'FOOD',
    lat: prefill?.lat ?? BALIKESIR.lat,
    lon: prefill?.lon ?? BALIKESIR.lon,
  });
  const [submitting, setSubmitting] = useState(false);

  const setField = (k, v) => setForm((f) => ({ ...f, [k]: v }));

  const submit = async (e) => {
    e.preventDefault();
    if (!form.title.trim() || !form.type) {
      addToast({ type: 'warning', title: 'Eksik bilgi', message: 'Başlık ve tür gerekli' });
      return;
    }
    const payload = {
      title: form.title.trim(),
      type: form.type,
      lat: parseFloat(form.lat),
      lon: parseFloat(form.lon),
    };

    if (isDemo) {
      addTask(payload);
      addToast({ type: 'success', title: 'Görev oluşturuldu', message: 'Demo modda eklendi.' });
      if (onCreated) onCreated();
      return;
    }

    setSubmitting(true);
    try {
      const created = await tasksService.create(payload);
      addTask(created || payload);
      addToast({ type: 'success', title: 'Görev oluşturuldu', message: 'Backend kaydetti.' });
      if (onCreated) onCreated();
    } catch (err) {
      addToast({
        type: 'error',
        title: 'Görev oluşturulamadı',
        message: err.response?.data?.detail || err.message,
      });
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <form onSubmit={submit} className="bg-mesh-card rounded-lg p-4 border border-mesh-disabled flex flex-col gap-3">
      <h3 className="font-bebas text-2xl text-mesh-accent tracking-wider">YENİ GÖREV</h3>

      <Input
        label="Başlık"
        placeholder="örn. Gıda dağıtımı"
        value={form.title}
        onChange={(e) => setField('title', e.target.value)}
        required
      />

      <Select
        label="Görev Türü"
        value={form.type}
        onChange={(e) => setField('type', e.target.value)}
        required
      >
        {Object.entries(taskTypeLabels).map(([k, v]) => (
          <option key={k} value={k}>{v}</option>
        ))}
      </Select>

      <div className="grid grid-cols-2 gap-2">
        <Input
          label="Enlem (lat)"
          type="number"
          step="any"
          value={form.lat}
          onChange={(e) => setField('lat', e.target.value)}
          required
        />
        <Input
          label="Boylam (lon)"
          type="number"
          step="any"
          value={form.lon}
          onChange={(e) => setField('lon', e.target.value)}
          required
        />
      </div>

      <div className="flex gap-2 mt-1">
        <Button type="submit" variant="primary" loading={submitting} className="flex-1">
          GÖREV OLUŞTUR
        </Button>
        {onCancel && (
          <Button type="button" variant="outline" onClick={onCancel}>İptal</Button>
        )}
      </div>
    </form>
  );
};

export default TaskForm;
