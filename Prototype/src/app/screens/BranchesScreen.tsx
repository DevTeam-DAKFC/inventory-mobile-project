import { useState } from 'react';
import { Plus, X, MapPin } from 'lucide-react';
import Card from '../components/Card';
import Badge from '../components/Badge';
import Button from '../components/Button';
import Input from '../components/Input';

export default function BranchesScreen() {
  const [showForm, setShowForm] = useState(false);
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    name: '',
    address: '',
    active: true,
  });

  const branches = [
    {
      id: '1',
      name: 'Tienda Central',
      address: 'San José centro',
      active: true,
    },
    {
      id: '2',
      name: 'Tienda Norte',
      address: 'Heredia',
      active: true,
    },
  ];

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    setTimeout(() => {
      setLoading(false);
      setShowForm(false);
      setFormData({ name: '', address: '', active: true });
    }, 1000);
  };

  if (showForm) {
    return (
      <div className="min-h-screen pb-6">
        {/* Header */}
        <div
          className="px-5 pt-6 pb-4 border-b"
          style={{
            backgroundColor: 'var(--surface-base)',
            borderColor: 'var(--border-subtle)',
          }}
        >
          <div className="flex items-center justify-between">
            <h1 style={{ color: 'var(--text-primary)' }}>Nueva sucursal</h1>
            <button onClick={() => setShowForm(false)} className="p-1">
              <X size={20} style={{ color: 'var(--text-primary)' }} />
            </button>
          </div>
        </div>

        <form onSubmit={handleSubmit} className="px-5 mt-6 space-y-6">
          <Input
            label="Nombre de la sucursal *"
            value={formData.name}
            onChange={(e) => setFormData({ ...formData, name: e.target.value })}
            placeholder="Ej: Tienda Central"
            required
          />

          <div className="flex flex-col gap-1.5">
            <label className="text-sm" style={{ color: 'var(--text-secondary)' }}>
              Dirección o descripción
            </label>
            <textarea
              value={formData.address}
              onChange={(e) => setFormData({ ...formData, address: e.target.value })}
              placeholder="Ej: San José centro"
              rows={3}
              className="px-4 py-3 rounded-xl border resize-none"
              style={{
                backgroundColor: 'var(--surface-soft)',
                borderColor: 'var(--border-subtle)',
                color: 'var(--text-primary)',
              }}
            />
          </div>

          <div
            className="flex items-center justify-between p-4 rounded-xl border"
            style={{
              backgroundColor: 'var(--surface-base)',
              borderColor: 'var(--border-subtle)',
            }}
          >
            <div>
              <p className="text-sm mb-0.5" style={{ color: 'var(--text-primary)' }}>
                Sucursal activa
              </p>
              <p className="text-xs" style={{ color: 'var(--text-muted)' }}>
                Las sucursales inactivas no aparecen en los registros
              </p>
            </div>
            <button
              type="button"
              onClick={() => setFormData({ ...formData, active: !formData.active })}
              className={`relative w-12 h-6 rounded-full transition-colors ${
                formData.active ? 'bg-[var(--accent-primary)]' : 'bg-[var(--surface-soft)]'
              }`}
            >
              <div
                className={`absolute top-0.5 w-5 h-5 rounded-full bg-white transition-transform ${
                  formData.active ? 'translate-x-6' : 'translate-x-0.5'
                }`}
              />
            </button>
          </div>

          <Button type="submit" variant="primary" fullWidth loading={loading}>
            Guardar sucursal
          </Button>
        </form>
      </div>
    );
  }

  return (
    <div className="min-h-screen pb-6">
      {/* Header */}
      <div
        className="px-5 pt-6 pb-4 border-b"
        style={{
          backgroundColor: 'var(--surface-base)',
          borderColor: 'var(--border-subtle)',
        }}
      >
        <div className="flex items-center justify-between mb-4">
          <h1 style={{ color: 'var(--text-primary)' }}>Sucursales</h1>
          <button
            onClick={() => setShowForm(true)}
            className="p-2 rounded-lg"
            style={{
              backgroundColor: 'var(--accent-primary)',
              color: 'var(--app-bg)',
            }}
          >
            <Plus size={20} strokeWidth={2.5} />
          </button>
        </div>
      </div>

      {/* Branches List */}
      <div className="px-5 mt-4 space-y-3">
        {branches.map((branch) => (
          <Card key={branch.id} variant="base" padding="md">
            <div className="flex items-start gap-3">
              <div
                className="w-12 h-12 rounded-lg flex items-center justify-center flex-shrink-0"
                style={{ backgroundColor: 'var(--surface-soft)' }}
              >
                <MapPin size={20} style={{ color: 'var(--accent-primary)' }} />
              </div>

              <div className="flex-1 min-w-0">
                <div className="flex items-start justify-between gap-2 mb-1">
                  <h3 className="text-sm" style={{ color: 'var(--text-primary)' }}>
                    {branch.name}
                  </h3>
                  <Badge variant="success" size="sm">
                    {branch.active ? 'Activa' : 'Inactiva'}
                  </Badge>
                </div>

                <p className="text-xs" style={{ color: 'var(--text-secondary)' }}>
                  {branch.address}
                </p>
              </div>
            </div>
          </Card>
        ))}
      </div>

      <div className="px-5 mt-6">
        <div
          className="p-3 rounded-lg text-xs"
          style={{
            backgroundColor: 'var(--accent-primary-soft)',
            color: 'var(--text-secondary)',
            border: '1px solid var(--border-active)',
          }}
        >
          <strong style={{ color: 'var(--accent-primary)' }}>Nota:</strong> La gestión de sucursales
          es básica. Solo administradores pueden crear y modificar sucursales.
        </div>
      </div>
    </div>
  );
}
