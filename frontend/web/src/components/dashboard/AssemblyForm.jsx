import { useState, useEffect } from 'react';
import Input from '../ui/Input';
import Button from '../ui/Button';
import useMapStore from '../../store/mapStore';
import useToastStore from '../../store/toastStore';

const AssemblyForm = ({ pickedCoord, onPickRequest, onPickCancel, isPicking }) => {
  const addAssembly = useMapStore((s) => s.addAssembly);
  const addToast = useToastStore((s) => s.addToast);

  const [form, setForm] = useState({
    name: '',
    capacity: 100,
    lat: '',
    lon: '',
  });

  useEffect(() => {
    if (pickedCoord) {
      setForm((f) => ({
        ...f,
        lat: pickedCoord.lat.toFixed(6),
        lon: pickedCoord.lon.toFixed(6),
      }));
    }
  }, [pickedCoord]);

  const setField = (k, v) => setForm((f) => ({ ...f, [k]: v }));

  const submit = (e) => {
    e.preventDefault();
    const lat = parseFloat(form.lat);
    const lon = parseFloat(form.lon);
    if (!form.name.trim()) {
      addToast({ type: 'warning', title: 'Eksik', message: 'Nokta adı girin' });
      return;
    }
    if (Number.isNaN(lat) || Number.isNaN(lon)) {
      addToast({ type: 'warning', title: 'Geçersiz konum', message: 'Lat/Lon değerleri sayı olmalı' });
      return;
    }
    addAssembly({
      name: form.name.trim(),
      capacity: Number(form.capacity) || 1,
      lat,
      lon,
    });
    addToast({ type: 'success', title: 'Eklendi', message: `${form.name} toplanma noktası oluşturuldu` });
    setForm({ name: '', capacity: 100, lat: '', lon: '' });
  };

  return (
    <form onSubmit={submit} className="bg-mesh-card rounded-lg p-4 border border-mesh-disabled flex flex-col gap-3">
      <h3 className="font-bebas text-2xl text-mesh-accent tracking-wider">YENİ NOKTA</h3>

      <Input
        label="Nokta Adı"
        placeholder="örn. Atatürk İlkokulu"
        value={form.name}
        onChange={(e) => setField('name', e.target.value)}
        required
      />

      <Input
        label="Kapasite"
        type="number"
        min="1"
        value={form.capacity}
        onChange={(e) => setField('capacity', e.target.value)}
        required
      />

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

      <Button
        type="button"
        variant={isPicking ? 'danger' : 'outline'}
        onClick={isPicking ? onPickCancel : onPickRequest}
      >
        {isPicking ? '✕ Seçimi İptal Et' : '🗺️ Haritadan Seç'}
      </Button>

      <Button type="submit" variant="primary">NOKTA EKLE</Button>
    </form>
  );
};

export default AssemblyForm;
