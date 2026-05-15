import { useState } from 'react';
import { Outlet } from 'react-router-dom';
import SidebarNav from './SidebarNav';
import TopBar from './TopBar';
import SosList from './SosList';
import ToastContainer from '../ui/Toast';

const PageLayout = ({ wsStatus }) => {
  const [sosListOpen, setSosListOpen] = useState(true);

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
