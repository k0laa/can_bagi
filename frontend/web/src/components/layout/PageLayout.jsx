import { useState } from 'react';
import { Outlet } from 'react-router-dom';
import SidebarNav from './SidebarNav';
import TopBar from './TopBar';
import SosList from './SosList';
import ToastContainer from '../ui/Toast';

const PageLayout = ({ wsStatus }) => {
  const [sidebarOpen, setSidebarOpen] = useState(true);
  const [sosListOpen, setSosListOpen] = useState(true);

  return (
    <div className="relative w-screen h-screen overflow-hidden bg-mesh-bg">
      <TopBar
        onToggleSidebar={() => setSidebarOpen((v) => !v)}
        wsStatus={wsStatus}
      />

      <SidebarNav isOpen={sidebarOpen} />

      <SosList
        isOpen={sosListOpen}
        onToggle={() => setSosListOpen((v) => !v)}
      />

      <div className="absolute inset-0 top-14 overflow-auto">
        <Outlet context={{ sidebarOpen, sosListOpen }} />
      </div>

      {!sosListOpen && (
        <button
          onClick={() => setSosListOpen(true)}
          className="fixed right-4 bottom-6 z-30 bg-mesh-danger text-white rounded-full px-4 py-2 font-bebas text-sm shadow-lg hover:bg-red-600 transition-colors"
        >
          📋 Çağrılar
        </button>
      )}

      <ToastContainer />
    </div>
  );
};

export default PageLayout;
