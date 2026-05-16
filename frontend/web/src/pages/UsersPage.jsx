import { useState, useEffect } from 'react';
import userService from '../services/userService';
import useToastStore from '../store/toastStore';
import Button from '../components/ui/Button';
import EmptyState from '../components/ui/EmptyState';

const UsersPage = () => {
  const [users, setUsers] = useState([]);
  const addToast = useToastStore((s) => s.addToast);

  const fetchUsers = async () => {
    try {
      const data = await userService.list();
      setUsers(data);
    } catch (err) {
      addToast({ type: 'error', title: 'Hata', message: 'Kullanıcılar yüklenemedi' });
    }
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  const handleMakeCoordinator = async (id) => {
    try {
      await userService.makeCoordinator(id);
      addToast({ type: 'success', message: 'Kullanıcı koordinatör yapıldı' });
      fetchUsers();
    } catch (err) {
      addToast({ type: 'error', title: 'Hata', message: 'İşlem başarısız' });
    }
  };

  const handleMakeUser = async (id) => {
    try {
      await userService.makeUser(id);
      addToast({ type: 'success', message: 'Kullanıcı normal role düşürüldü' });
      fetchUsers();
    } catch (err) {
      addToast({ type: 'error', title: 'Hata', message: 'İşlem başarısız' });
    }
  };

  const handleDelete = async (id) => {
    try {
      await userService.remove(id);
      addToast({ type: 'success', message: 'Kullanıcı silindi' });
      fetchUsers();
    } catch (err) {
      addToast({ type: 'error', title: 'Hata', message: 'Kullanıcı silinemedi' });
    }
  };

  return (
    <div className="p-6 max-w-7xl mx-auto">
      <h1 className="font-bebas text-4xl text-mesh-text tracking-widest mb-5">
        KULLANICI YÖNETİMİ
      </h1>

      {users.length === 0 ? (
        <div className="bg-mesh-card rounded-lg">
          <EmptyState
            icon="👥"
            title="KULLANICI YOK"
            description="Sistemde kayıtlı kullanıcı bulunamadı."
          />
        </div>
      ) : (
        <div className="bg-mesh-card rounded-lg overflow-hidden border border-mesh-disabled">
          <table className="w-full text-left font-nunito text-sm">
            <thead className="bg-mesh-bg text-mesh-muted border-b border-mesh-disabled">
              <tr>
                <th className="p-3">Kullanıcı (ID)</th>
                <th className="p-3">İsim</th>
                <th className="p-3">Rol</th>
                <th className="p-3 text-right">İşlemler</th>
              </tr>
            </thead>
            <tbody>
              {users.map((user) => (
                <tr key={user.id} className="border-b border-mesh-disabled/50 hover:bg-mesh-bg/50">
                  <td className="p-3">{user.username || user.id}</td>
                  <td className="p-3">{user.name} {user.surname}</td>
                  <td className="p-3">
                    <span className={`px-2 py-1 rounded text-xs ${
                      user.role === 'SUPER' ? 'bg-mesh-danger/20 text-mesh-danger border border-mesh-danger/30' :
                      user.role === 'COORD' ? 'bg-mesh-accent/20 text-mesh-accent border border-mesh-accent/30' :
                      'bg-mesh-disabled/50 text-mesh-muted'
                    }`}>
                      {user.role}
                    </span>
                  </td>
                  <td className="p-3 text-right">
                    <div className="flex justify-end gap-2">
                      {user.role === 'USER' && (
                        <Button variant="outline" size="sm" onClick={() => handleMakeCoordinator(user.id)} className="text-[10px]">
                          COORD YAP
                        </Button>
                      )}
                      {user.role === 'COORD' && (
                        <Button variant="outline" size="sm" onClick={() => handleMakeUser(user.id)} className="text-[10px]">
                          USER YAP
                        </Button>
                      )}
                      <button
                        onClick={() => handleDelete(user.id)}
                        className="text-[10px] uppercase tracking-wider font-bebas bg-mesh-disabled hover:bg-mesh-danger text-white px-2 py-1 rounded transition-colors"
                      >
                        SİL
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
};

export default UsersPage;
