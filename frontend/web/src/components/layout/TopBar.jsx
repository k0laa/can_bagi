import useAuthStore from '../../store/authStore';
import { useNavigate } from 'react-router-dom';
import Button from '../ui/Button';

const TopBar = ({ wsStatus }) => {
  const { coordinator, logout } = useAuthStore();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  return (
    <div className="h-14 shrink-0 bg-mesh-card border-b border-mesh-disabled flex items-center px-4 gap-4">
      <span className="font-bebas text-xl tracking-widest text-mesh-text flex-1">
        MESHAİD KOMİTA MERKEZİ
      </span>

      <div className="flex items-center gap-4">
        <div className="flex items-center gap-2">
          <div
            className={`w-2 h-2 rounded-full ${wsStatus === 'connected'
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
