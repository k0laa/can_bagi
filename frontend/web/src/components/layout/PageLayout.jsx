import { useState, useEffect } from 'react';
import { Outlet } from 'react-router-dom';
import SidebarNav from './SidebarNav';
import TopBar from './TopBar';
import SosList from './SosList';
import ToastContainer from '../ui/Toast';
import useWebSocket from '../../hooks/useWebSocket';
import useKeyboardShortcuts from '../../hooks/useKeyboardShortcuts';
import { primeAudio } from '../../utils/soundUtils';
import useMapStore from '../../store/mapStore';
import useTaskStore from '../../store/taskStore';
import useAuthStore from '../../store/authStore';
import useToastStore from '../../store/toastStore';
import { mockSOS, mockRequests, mockNodes, mockAssembly, mockTasks } from '../../utils/mockData';
import sosService from '../../services/sosService';
import needsService from '../../services/needsService';
import nodesService from '../../services/nodesService';
import tasksService from '../../services/tasksService';

const PageLayout = () => {
  const [sosListOpen, setSosListOpen] = useState(true);
  const { status: wsStatus } = useWebSocket();
  useKeyboardShortcuts();
  const { setSosList, setRequestList, setNodeList, setAssemblyList } = useMapStore();
  const setTasks = useTaskStore((s) => s.setTasks);
  const token = useAuthStore((s) => s.token);
  const addToast = useToastStore((s) => s.addToast);

  useEffect(() => {
    if (!token) return;
    const isDemo = token === 'dev-test-token';

    if (isDemo) {
      setSosList(mockSOS);
      setRequestList(mockRequests);
      setNodeList(mockNodes);
      setAssemblyList(mockAssembly);
      setTasks(mockTasks);
      return;
    }

    // Backend'den paralel olarak çek; her biri ayrı catch ile fail-safe
    sosService.list().then(setSosList).catch(() => setSosList([]));
    needsService.list().then(setRequestList).catch(() => setRequestList([]));
    nodesService.list().then(setNodeList).catch(() => setNodeList([]));
    tasksService.list().then(setTasks).catch(() => setTasks([]));
    // Toplanma noktaları için backend endpoint'i tanımlı değil → boş başlat
    setAssemblyList(mockAssembly);
  }, [token]);

  useEffect(() => {
    const handler = () => primeAudio();
    window.addEventListener('click', handler, { once: true });
    window.addEventListener('keydown', handler, { once: true });
    return () => {
      window.removeEventListener('click', handler);
      window.removeEventListener('keydown', handler);
    };
  }, []);

  return (
    <div className="flex w-screen h-screen overflow-hidden bg-mesh-bg">
      {/* Sol sabit sidebar */}
      <SidebarNav />

      {/* Sağ ana alan */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Üst bar */}
        <TopBar wsStatus={wsStatus} />

        {/* İçerik alanı */}
        <div className="flex-1 flex overflow-hidden relative">
          {/* Sayfa içeriği */}
          <div className="flex-1 overflow-y-auto relative">
            <Outlet context={{ sosListOpen }} />
          </div>

          {/* Sağ SOS listesi */}
          <SosList
            isOpen={sosListOpen}
            onToggle={() => setSosListOpen((v) => !v)}
          />
        </div>
      </div>

      {!sosListOpen && (
        <button
          onClick={() => setSosListOpen(true)}
          style={{ zIndex: 1100 }}
          className="fixed right-4 bottom-6 bg-mesh-danger text-white rounded-full px-4 py-2 font-bebas text-sm shadow-lg hover:bg-red-600 transition-colors"
        >
          📋 Çağrılar
        </button>
      )}

      <ToastContainer />
    </div>
  );
};

export default PageLayout;
