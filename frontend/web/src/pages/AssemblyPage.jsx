import { useState } from 'react';
import useMapStore from '../store/mapStore';
import useToastStore from '../store/toastStore';
import MiniMap from '../components/map/MiniMap';
import AssemblyCard from '../components/dashboard/AssemblyCard';
import AssemblyForm from '../components/dashboard/AssemblyForm';
import Modal from '../components/ui/Modal';

const AssemblyPage = () => {
  const { assemblyList, removeAssembly } = useMapStore();
  const addToast = useToastStore((s) => s.addToast);

  const [pickMode, setPickMode] = useState(false);
  const [pickedCoord, setPickedCoord] = useState(null);
  const [flyTarget, setFlyTarget] = useState(null);
  const [confirmDel, setConfirmDel] = useState(null);

  const handlePick = (coord) => {
    setPickedCoord(coord);
    setPickMode(false);
    addToast({ type: 'info', message: 'Konum seçildi, formu doldurmaya devam edin.' });
  };

  return (
    <div className="h-full flex flex-col">
      <div className="px-6 pt-6 pb-3 shrink-0">
        <h1 className="font-bebas text-4xl text-mesh-text tracking-widest">
          TOPLANMA NOKTALARI
        </h1>
        {pickMode && (
          <p className="font-nunito text-xs text-mesh-warning mt-1">
            🗺️ Haritaya tıklayarak konum seçin...
          </p>
        )}
      </div>

      <div className="flex-1 grid grid-cols-1 lg:grid-cols-2 gap-4 px-6 pb-6 min-h-0">
        <div className="rounded-lg overflow-hidden border border-mesh-disabled min-h-[400px]">
          <MiniMap
            pickEnabled={pickMode}
            onPick={handlePick}
            flyTarget={flyTarget}
          />
        </div>

        <div className="flex flex-col gap-4 overflow-y-auto pr-1">
          <AssemblyForm
            pickedCoord={pickedCoord}
            isPicking={pickMode}
            onPickRequest={() => setPickMode(true)}
            onPickCancel={() => setPickMode(false)}
          />

          <h2 className="font-bebas text-2xl text-mesh-text tracking-wider mt-2">
            MEVCUT NOKTALAR ({assemblyList.length})
          </h2>

          {assemblyList.length === 0 ? (
            <div className="bg-mesh-card rounded-lg p-6 text-center">
              <p className="font-nunito text-sm text-mesh-muted">
                Henüz toplanma noktası yok.
              </p>
            </div>
          ) : (
            <div className="flex flex-col gap-3">
              {assemblyList.map((p) => (
                <AssemblyCard
                  key={p.id}
                  point={p}
                  onSelect={(point) => setFlyTarget({ ...point, _t: Date.now() })}
                  onDelete={(point) => setConfirmDel(point)}
                />
              ))}
            </div>
          )}
        </div>
      </div>

      <Modal
        isOpen={confirmDel !== null}
        onClose={() => setConfirmDel(null)}
        title="Toplanma Noktasını Sil"
        confirmText="Sil"
        variant="danger"
        onConfirm={() => {
          removeAssembly(confirmDel.id);
          addToast({ type: 'success', message: `${confirmDel.name} silindi` });
          setConfirmDel(null);
        }}
      >
        <p className="font-nunito text-sm text-mesh-muted">
          <strong className="text-mesh-text">{confirmDel?.name}</strong> noktasını silmek istediğinize emin misiniz?
        </p>
      </Modal>
    </div>
  );
};

export default AssemblyPage;
