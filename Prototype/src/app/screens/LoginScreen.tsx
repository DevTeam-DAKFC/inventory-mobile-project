import { useState } from 'react';
import { Package } from 'lucide-react';
import Button from '../components/Button';
import Input from '../components/Input';

interface LoginScreenProps {
  onLogin: () => void;
}

export default function LoginScreen({ onLogin }: LoginScreenProps) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    setTimeout(() => {
      if (email && password) {
        onLogin();
      } else {
        setError('Credenciales inválidas');
        setLoading(false);
      }
    }, 800);
  };

  return (
    <div
      className="flex flex-col items-center justify-center min-h-screen px-6"
      style={{
        background: 'linear-gradient(to bottom, var(--bg-gradient-start), var(--bg-gradient-end))',
      }}
    >
      <div className="w-full max-w-sm space-y-8">
        <div className="flex flex-col items-center gap-4 text-center">
          <div
            className="flex items-center justify-center w-16 h-16 rounded-2xl"
            style={{
              backgroundColor: 'var(--surface-elevated)',
              border: '1px solid var(--border-subtle)',
            }}
          >
            <Package size={32} style={{ color: 'var(--accent-primary)' }} strokeWidth={2} />
          </div>

          <div>
            <h1 className="mb-2" style={{ color: 'var(--text-primary)' }}>
              Inventory Control
            </h1>
            <p className="text-sm" style={{ color: 'var(--text-secondary)' }}>
              Gestiona productos, stock y movimientos por sucursal
            </p>
          </div>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <Input
            label="Correo electrónico"
            type="email"
            placeholder="tu@email.com"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
          />

          <Input
            label="Contraseña"
            type="password"
            placeholder="••••••••"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
          />

          {error && (
            <div
              className="p-3 rounded-lg text-sm text-center"
              style={{
                backgroundColor: 'rgba(239, 68, 68, 0.14)',
                color: 'var(--status-danger)',
                border: '1px solid rgba(239, 68, 68, 0.2)',
              }}
            >
              {error}
            </div>
          )}

          <Button type="submit" variant="primary" fullWidth loading={loading}>
            Iniciar sesión
          </Button>
        </form>

        <div className="text-center">
          <p className="text-xs" style={{ color: 'var(--text-muted)' }}>
            Demo: usa cualquier email y contraseña
          </p>
        </div>
      </div>
    </div>
  );
}
