import { useState } from 'react';
import Input from '../ui/Input';
import Select from '../ui/Select';
import Button from '../ui/Button';
import useMapStore from '../../store/mapStore';
import useTaskStore from '../../store/taskStore';
import useToastStore from '../../store/toastStore';
import { taskTypeLabels } from '../../utils/mockData';

const TaskForm = ({ onCreated, onCancel }) => {
  const { assemblyList } = useMapStore();
  const addTask = useTaskStore((s) => s.addTask);
  const addToast = useToastStore((s) => s.addToast);

  const [form, setForm] = useState({
    type: 'FOOD_DISTRIBUTION',
    assembly_point_id: assemblyList[0]?.id || '',
    start_time: '14:00',
    end_time: '16:00',
    people_needed: 2,
    description: '',
  });

  const setField = (k, v) => setForm((f) => ({ ...f, [k]: v }));

  const submit = (e) => {
    e.preventDefault();
    if (!form.type || !form.assembly_point_id) {
      addToast({ type: 'warning', title: 'Eksik bilgi', message: 'Tür ve toplanma noktası seçin' });
      return;
    }
    addTask({
      ...form,
      assembly_point_id: Number(form.assembly_point_id),
      people_needed: Number(form.people_needed),
    });
    addToast({ type: 'success', title: 'Görev oluşturuldu', message: 'Yeni görev listede.' });
    if (onCreated) onCreated();
  };

  return (
    <form onSubmit={submit} className="bg-mesh-card rounded-lg p-4 border border-mesh-disabled flex flex-col gap-3">
      <h3 className="font-bebas text-2xl text-mesh-accent tracking-wider">YENİ GÖREV</h3>

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

      <Select
        label="Toplanma Noktası"
        value={form.assembly_point_id}
        onChange={(e) => setField('assembly_point_id', e.target.value)}
        required
      >
        <option value="">Seçiniz...</option>
        {assemblyList.map((a) => (
          <option key={a.id} value={a.id}>{a.name}</option>
        ))}
      </Select>

      <div className="grid grid-cols-2 gap-2">
        <Input
          label="Başlangıç"
          type="time"
          value={form.start_time}
          onChange={(e) => setField('start_time', e.target.value)}
          required
        />
        <Input
          label="Bitiş"
          type="time"
          value={form.end_time}
          onChange={(e) => setField('end_time', e.target.value)}
          required
        />
      </div>

      <Input
        label="Gerekli Kişi"
        type="number"
        min="1"
        value={form.people_needed}
        onChange={(e) => setField('people_needed', e.target.value)}
        required
      />

      <div>
        <label className="font-nunito text-xs font-semibold text-mesh-muted block mb-1">
          Açıklama
        </label>
        <textarea
          rows={3}
          value={form.description}
          onChange={(e) => setField('description', e.target.value)}
          placeholder="Detaylar..."
          className="w-full bg-mesh-bg border border-mesh-disabled rounded-lg px-3 py-2 font-nunito text-sm text-mesh-text placeholder:text-mesh-disabled focus:outline-none focus:border-mesh-accent resize-none"
        />
      </div>

      <div className="flex gap-2 mt-1">
        <Button type="submit" variant="primary" className="flex-1">GÖREV OLUŞTUR</Button>
        {onCancel && (
          <Button type="button" variant="outline" onClick={onCancel}>İptal</Button>
        )}
      </div>
    </form>
  );
};

export default TaskForm;
