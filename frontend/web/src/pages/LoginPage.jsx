import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import useAuthStore from '../store/authStore';
import Input from '../components/ui/Input';
import Button from '../components/ui/Button';

const LoginPage = () => {
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const { login, loading, error, clearError } = useAuthStore();
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    clearError();
    const success = await login(phone, password);
    if (success) navigate('/');
  };

  return (
    <div className="min-h-screen bg-mesh-bg flex items-center justify-center p-4">
      <div className="w-full max-w-sm">
        <div className="bg-mesh-card rounded-2xl p-8 border border-mesh-disabled shadow-2xl">
          <div className="text-center mb-8">
            <h1 className="font-bebas text-5xl text-mesh-accent tracking-widest">
              MeshAid
            </h1>
            <p className="font-bebas text-xl text-mesh-muted tracking-widest mt-1">
              KOMİTA MERKEZİ
            </p>
          </div>

          <form onSubmit={handleSubmit} className="flex flex-col gap-4">
            <Input
              label="Telefon"
              placeholder="05551234567"
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              autoComplete="tel"
              required
            />
            <Input
              label="Şifre"
              type="password"
              placeholder="••••••••"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              autoComplete="current-password"
              required
            />

            {error && (
              <p className="font-nunito text-sm text-mesh-danger text-center">
                {error}
              </p>
            )}

            <Button
              type="submit"
              variant="primary"
              size="lg"
              loading={loading}
              className="mt-2 w-full"
            >
              GİRİŞ YAP
            </Button>
          </form>

          <div className="mt-6 pt-4 border-t border-mesh-disabled text-center">
            <p className="font-nunito text-xs text-mesh-disabled">
              ESP32 Mesh Ağı · Afet Koordinasyon Sistemi
            </p>
            {import.meta.env.DEV && (
              <p className="font-nunito text-xs text-mesh-warning mt-2">
                🔧 Demo: <strong>test</strong> / <strong>test</strong>
              </p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default LoginPage;
