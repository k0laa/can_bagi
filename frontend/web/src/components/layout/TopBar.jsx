import useAuthStore from '../../store/authStore';
import { useNavigate } from 'react-router-dom';
import Button from '../ui/Button';

const TopBar = ({ onToggleSidebar, wsStatus }) => {
  const { coordinator, logout } = useAuthStore();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  return (
    <div className="absolute top-0 left-0 right-0 z-30 h-14 bg-mesh-card/95 backdrop-blur border-b border-mesh-disabled flex items-center px-4 gap-4">
      <button
        onClick={onToggleSidebar}
        className="text-mesh-muted hover:text-white transition-colors text-xl leading-none"
        title="Menüyü Aç/Kapat"
      >
        ☰
      </button>

      <span className="font-bebas text-xl tracking-widest text-mesh-text flex-1">
        MESHAİD KOMİTA MERKEZİ
      </span>

      <div className="flex items-center gap-4">
        <div className="flex items-center gap-2">
          <div
            className={`w-2 h-2 rounded-full ${
              wsStatus === 'connected'
                ? 'bg-mesh-success animate-pulse'
                : 'bg-mesh-danger'
            }`}
          />
          <span className="font-nunito text-xs text-mesh-muted">
            {wsStatus === 'connected' ? 'Canlı' : 'Bağlantı Yok'}
          </span>
        </div>

        {coordinator && (
          <span className="font-nunito text-sm text-mesh-muted hidden md:block">
            {coordinator.name || coordinator.username}
          </span>
        )}

        <Button variant="outline" size="sm" onClick={handleLogout}>
          Çıkış
        </Button>
      </div>
    </div>
  );
};

export default TopBar;
