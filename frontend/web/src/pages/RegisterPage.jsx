import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import useAuthStore from '../store/authStore';
import useToastStore from '../store/toastStore';
import Input from '../components/ui/Input';
import Select from '../components/ui/Select';
import Button from '../components/ui/Button';

const BLOOD_TYPES = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', '0+', '0-'];

const SKILLS = [
  { value: 'GENERAL', label: '🤝 Genel Yardım' },
  { value: 'MEDICAL', label: '🏥 Sağlık' },
  { value: 'RESCUE', label: '🚨 Arama-Kurtarma' },
  { value: 'LOGISTICS', label: '📦 Lojistik / Taşıma' },
];

const RegisterPage = () => {
  const { register, loading, error, clearError } = useAuthStore();
  const addToast = useToastStore((s) => s.addToast);
  const navigate = useNavigate();

  const [form, setForm] = useState({
    name: '',
    surname: '',
    phone: '',
    blood_type: 'A+',
    skills: 'GENERAL',
    password: '',
  });
  const [confirmPwd, setConfirmPwd] = useState('');

  const setField = (k, v) => setForm((f) => ({ ...f, [k]: v }));

  const handleSubmit = async (e) => {
    e.preventDefault();
    clearError();

    if (form.password.length < 4) {
      addToast({ type: 'warning', title: 'Zayıf şifre', message: 'En az 4 karakter girin' });
      return;
    }
    if (form.password !== confirmPwd) {
      addToast({ type: 'warning', title: 'Şifreler eşleşmiyor', message: 'Tekrar kontrol edin' });
      return;
    }
    if (!/^0?5\d{9}$/.test(form.phone.replace(/\s/g, ''))) {
      addToast({ type: 'warning', title: 'Geçersiz telefon', message: '05XXXXXXXXX biçiminde girin' });
      return;
    }

    const result = await register({
      name: form.name.trim(),
      surname: form.surname.trim(),
      phone: form.phone.trim(),
      blood_type: form.blood_type,
      skills: form.skills,
      password: form.password,
    });

    if (result.success) {
      addToast({
        type: 'success',
        title: 'Kayıt başarılı',
        message: 'Şimdi giriş yapabilirsiniz.',
      });
      navigate('/login');
    }
  };

  return (
    <div className="min-h-screen bg-mesh-bg flex items-center justify-center p-4">
      <div className="w-full max-w-md">
        <div className="bg-mesh-card rounded-2xl p-8 border border-mesh-disabled shadow-2xl">
          <div className="text-center mb-6">
            <h1 className="font-bebas text-5xl text-mesh-accent tracking-widest">
              MeshAid
            </h1>
            <p className="font-bebas text-xl text-mesh-muted tracking-widest mt-1">
              KAYIT OL
            </p>
          </div>

          <form onSubmit={handleSubmit} className="flex flex-col gap-3">
            <div className="grid grid-cols-2 gap-3">
              <Input
                label="Ad"
                placeholder="Ahmet"
                value={form.name}
                onChange={(e) => setField('name', e.target.value)}
                autoComplete="given-name"
                required
              />
              <Input
                label="Soyad"
                placeholder="Yılmaz"
                value={form.surname}
                onChange={(e) => setField('surname', e.target.value)}
                autoComplete="family-name"
                required
              />
            </div>

            <Input
              label="Telefon"
              placeholder="05551234567"
              value={form.phone}
              onChange={(e) => setField('phone', e.target.value)}
              autoComplete="tel"
              required
            />

            <div className="grid grid-cols-2 gap-3">
              <Select
                label="Kan Grubu"
                value={form.blood_type}
                onChange={(e) => setField('blood_type', e.target.value)}
                required
              >
                {BLOOD_TYPES.map((b) => (
                  <option key={b} value={b}>{b}</option>
                ))}
              </Select>

              <Select
                label="Yetkinlik"
                value={form.skills}
                onChange={(e) => setField('skills', e.target.value)}
                required
              >
                {SKILLS.map((s) => (
                  <option key={s.value} value={s.value}>{s.label}</option>
                ))}
              </Select>
            </div>

            <Input
              label="Şifre"
              type="password"
              placeholder="••••••••"
              value={form.password}
              onChange={(e) => setField('password', e.target.value)}
              autoComplete="new-password"
              required
            />

            <Input
              label="Şifre Tekrar"
              type="password"
              placeholder="••••••••"
              value={confirmPwd}
              onChange={(e) => setConfirmPwd(e.target.value)}
              autoComplete="new-password"
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
              KAYIT OL
            </Button>
          </form>

          <div className="mt-5 pt-4 border-t border-mesh-disabled text-center">
            <p className="font-nunito text-xs text-mesh-muted">
              Zaten hesabın var mı?{' '}
              <Link to="/login" className="text-mesh-accent hover:underline font-semibold">
                Giriş Yap
              </Link>
            </p>
            <p className="font-nunito text-[10px] text-mesh-disabled mt-2">
              ⚠️ Kayıt sonrası koordinatör yetkisi için yöneticiye başvurun.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default RegisterPage;
