import { Bell, ChevronDown, Package, AlertTriangle, XCircle, TrendingUp, Plus, ArrowRight } from 'lucide-react';
import { useNavigate } from 'react-router';
import Card from '../components/Card';
import Badge from '../components/Badge';

export default function DashboardScreen() {
  const navigate = useNavigate();

  const kpis = [
    { label: 'Productos activos', value: '2', icon: Package, color: 'var(--accent-primary)' },
    { label: 'Stock bajo', value: '1', icon: AlertTriangle, color: 'var(--status-warning)' },
    { label: 'Agotados', value: '1', icon: XCircle, color: 'var(--status-danger)' },
    { label: 'Movimientos hoy', value: '3', icon: TrendingUp, color: 'var(--status-info)' },
  ];

  const quickActions = [
    { label: 'Nuevo producto', path: '/productos/nuevo', icon: Package },
    { label: 'Registrar entrada', path: '/movimientos/nuevo', icon: Plus },
    { label: 'Registrar salida', path: '/movimientos/nuevo', icon: TrendingUp },
    { label: 'Ver historial', path: '/movimientos', icon: TrendingUp },
    { label: 'Sucursales', path: '/sucursales', icon: Package },
  ];

  const recentMovements = [
    {
      id: '3',
      type: 'Salida',
      product: 'Aceite vegetal 900ml',
      quantity: -2,
      stock: 0,
      branch: 'Tienda Norte',
      user: 'Ana Rodríguez',
      date: '3 jun, 16:45',
    },
    {
      id: '2',
      type: 'Salida',
      product: 'Arroz 1kg',
      quantity: -3,
      stock: 25,
      branch: 'Tienda Central',
      user: 'Ana Rodríguez',
      date: '3 jun, 14:15',
    },
    {
      id: '1',
      type: 'Entrada',
      product: 'Arroz 1kg',
      quantity: 20,
      stock: 28,
      branch: 'Tienda Central',
      user: 'Ana Rodríguez',
      date: '3 jun, 10:30',
    },
  ];

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
        <div className="flex items-center justify-between mb-3">
          <div className="flex items-center gap-3">
            <div
              className="w-10 h-10 rounded-full flex items-center justify-center"
              style={{ backgroundColor: 'var(--accent-primary)' }}
            >
              <span className="text-sm font-medium" style={{ color: 'var(--app-bg)' }}>
                AR
              </span>
            </div>
            <div>
              <p className="text-sm" style={{ color: 'var(--text-primary)' }}>
                Hola, Ana
              </p>
              <p className="text-xs" style={{ color: 'var(--text-muted)' }}>
                Administradora · Tienda Central
              </p>
            </div>
          </div>
          <button className="relative p-2">
            <Bell size={20} style={{ color: 'var(--text-secondary)' }} />
            <span
              className="absolute top-1.5 right-1.5 w-2 h-2 rounded-full"
              style={{ backgroundColor: 'var(--status-danger)' }}
            />
          </button>
        </div>

        <button
          className="flex items-center gap-2 px-3 py-2 rounded-lg border"
          style={{
            backgroundColor: 'var(--surface-soft)',
            borderColor: 'var(--border-subtle)',
          }}
        >
          <span className="text-sm" style={{ color: 'var(--text-primary)' }}>
            Tienda Central
          </span>
          <ChevronDown size={16} style={{ color: 'var(--text-muted)' }} />
        </button>
      </div>

      <div className="px-5 space-y-5 mt-5">
        {/* Hero Card */}
        <Card
          variant="elevated"
          padding="md"
          className="relative overflow-hidden"
          style={{
            background: 'linear-gradient(135deg, var(--surface-elevated) 0%, var(--surface-soft) 100%)',
          }}
        >
          <div className="space-y-3">
            <div className="flex items-start justify-between">
              <div className="flex-1">
                <Badge variant="default" size="sm">
                  Stock visibility
                </Badge>
                <h2 className="mt-2 mb-0.5 text-lg" style={{ color: 'var(--text-primary)' }}>
                  Inventario bajo control
                </h2>
                <p className="text-xs" style={{ color: 'var(--text-secondary)' }}>
                  Tienda Central · 2 productos activos · 3 movimientos hoy
                </p>
              </div>
            </div>

            <div className="space-y-1.5">
              <div className="flex items-center justify-between text-xs">
                <span style={{ color: 'var(--text-secondary)' }}>Disponibilidad</span>
                <span style={{ color: 'var(--text-primary)' }}>75%</span>
              </div>
              <div
                className="h-1.5 rounded-full overflow-hidden"
                style={{ backgroundColor: 'var(--surface-base)' }}
              >
                <div
                  className="h-full rounded-full"
                  style={{ width: '75%', backgroundColor: 'var(--accent-primary)' }}
                />
              </div>
            </div>

            <button
              className="flex items-center gap-1.5 text-xs"
              style={{ color: 'var(--accent-primary)' }}
              onClick={() => navigate('/stock')}
            >
              Ver resumen
              <ArrowRight size={14} />
            </button>
          </div>
        </Card>

        {/* KPI Cards - Compactas */}
        <div className="grid grid-cols-2 gap-2.5">
          {kpis.map((kpi, idx) => {
            const Icon = kpi.icon;
            return (
              <Card key={idx} variant="base" padding="sm" className="relative">
                <div className="flex items-center gap-2.5">
                  <div
                    className="p-1.5 rounded-lg flex-shrink-0"
                    style={{ backgroundColor: 'var(--surface-soft)' }}
                  >
                    <Icon size={16} style={{ color: kpi.color }} strokeWidth={2} />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-xl font-semibold leading-none mb-1" style={{ color: 'var(--text-primary)' }}>
                      {kpi.value}
                    </p>
                    <p className="text-[10px] leading-tight" style={{ color: 'var(--text-muted)' }}>
                      {kpi.label}
                    </p>
                  </div>
                </div>
              </Card>
            );
          })}
        </div>

        {/* Quick Actions - Compactas */}
        <div>
          <h3 className="mb-2.5 px-0.5 text-sm" style={{ color: 'var(--text-primary)' }}>
            Acciones rápidas
          </h3>
          <div className="space-y-2">
            {/* Primera fila: 2x2 grid */}
            <div className="grid grid-cols-2 gap-2">
              {quickActions.slice(0, 4).map((action, idx) => {
                const Icon = action.icon;
                return (
                  <button
                    key={idx}
                    onClick={() => navigate(action.path)}
                    className="flex items-center gap-2 p-2.5 rounded-lg border text-left transition-colors hover:border-opacity-20"
                    style={{
                      backgroundColor: 'var(--surface-base)',
                      borderColor: 'var(--border-subtle)',
                    }}
                  >
                    <Icon size={16} style={{ color: 'var(--accent-primary)' }} strokeWidth={2} />
                    <span className="text-xs leading-tight" style={{ color: 'var(--text-primary)' }}>
                      {action.label}
                    </span>
                  </button>
                );
              })}
            </div>
            {/* Quinta acción centrada */}
            {quickActions.slice(4).map((action, idx) => {
              const Icon = action.icon;
              return (
                <button
                  key={idx}
                  onClick={() => navigate(action.path)}
                  className="flex items-center justify-center gap-2 p-2.5 rounded-lg border w-full transition-colors hover:border-opacity-20"
                  style={{
                    backgroundColor: 'var(--surface-base)',
                    borderColor: 'var(--border-subtle)',
                  }}
                >
                  <Icon size={16} style={{ color: 'var(--accent-primary)' }} strokeWidth={2} />
                  <span className="text-xs" style={{ color: 'var(--text-primary)' }}>
                    {action.label}
                  </span>
                </button>
              );
            })}
          </div>
        </div>

        {/* Recent Movements - Compactos */}
        <div>
          <div className="flex items-center justify-between mb-2.5 px-0.5">
            <h3 className="text-sm" style={{ color: 'var(--text-primary)' }}>Últimos movimientos</h3>
            <button
              onClick={() => navigate('/movimientos')}
              className="text-xs"
              style={{ color: 'var(--accent-primary)' }}
            >
              Ver todos
            </button>
          </div>
          <div className="space-y-2">
            {recentMovements.map((movement) => (
              <Card
                key={movement.id}
                variant="base"
                padding="sm"
                className="cursor-pointer transition-colors hover:border-opacity-20"
                onClick={() => navigate(`/movimientos/${movement.id}`)}
              >
                <div className="flex items-start justify-between mb-1.5">
                  <div className="flex items-center gap-2">
                    <Badge variant={movement.type === 'Entrada' ? 'success' : 'info'} size="sm">
                      {movement.type}
                    </Badge>
                    <span className="text-xs leading-tight" style={{ color: 'var(--text-primary)' }}>
                      {movement.product}
                    </span>
                  </div>
                </div>
                <div className="flex items-center justify-between text-[10px]">
                  <span style={{ color: 'var(--text-secondary)' }}>{movement.branch}</span>
                  <span style={{ color: 'var(--text-muted)' }}>
                    {movement.quantity > 0 ? '+' : ''}
                    {movement.quantity} → Stock: {movement.stock}
                  </span>
                </div>
                <div className="flex items-center justify-between text-[10px] mt-1">
                  <span style={{ color: 'var(--text-muted)' }}>{movement.user}</span>
                  <span style={{ color: 'var(--text-muted)' }}>{movement.date}</span>
                </div>
              </Card>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
