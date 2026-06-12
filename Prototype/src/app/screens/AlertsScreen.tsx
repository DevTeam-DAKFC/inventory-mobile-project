import { useState } from 'react';
import { useNavigate } from 'react-router';
import { AlertTriangle, XCircle, CheckCircle } from 'lucide-react';
import Card from '../components/Card';

export default function AlertsScreen() {
  const navigate = useNavigate();
  const [activeFilter, setActiveFilter] = useState('todas');

  const filters = [
    { id: 'todas', label: 'Todas' },
    { id: 'no-leidas', label: 'No leídas' },
    { id: 'stock', label: 'Stock' },
  ];

  const alerts = [
    {
      id: '1',
      type: 'bajo',
      title: 'Stock bajo',
      message: 'Arroz 1kg está por debajo del stock mínimo en Tienda Central.',
      product: 'Arroz 1kg',
      branch: 'Tienda Central',
      date: '3 jun, 10:30',
      read: false,
    },
    {
      id: '2',
      type: 'agotado',
      title: 'Producto agotado',
      message: 'Aceite vegetal 900ml no tiene existencias en Tienda Norte.',
      product: 'Aceite vegetal 900ml',
      branch: 'Tienda Norte',
      date: '3 jun, 16:45',
      read: false,
    },
    {
      id: '3',
      type: 'movimiento',
      title: 'Movimiento registrado',
      message: 'Se registró una salida de Arroz 1kg en Tienda Central.',
      product: 'Arroz 1kg',
      branch: 'Tienda Central',
      date: '3 jun, 14:15',
      read: true,
    },
  ];

  const filteredAlerts = alerts.filter((alert) => {
    if (activeFilter === 'todas') return true;
    if (activeFilter === 'no-leidas') return !alert.read;
    if (activeFilter === 'stock') return alert.type === 'bajo' || alert.type === 'agotado';
    return true;
  });

  const getAlertIcon = (type: string) => {
    if (type === 'bajo') return <AlertTriangle size={20} style={{ color: 'var(--status-warning)' }} />;
    if (type === 'agotado') return <XCircle size={20} style={{ color: 'var(--status-danger)' }} />;
    return <CheckCircle size={20} style={{ color: 'var(--status-info)' }} />;
  };

  const getAlertBg = (type: string) => {
    if (type === 'bajo') return 'rgba(245, 158, 11, 0.14)';
    if (type === 'agotado') return 'rgba(239, 68, 68, 0.14)';
    return 'rgba(59, 130, 246, 0.14)';
  };

  const getAlertBorder = (type: string) => {
    if (type === 'bajo') return 'rgba(245, 158, 11, 0.3)';
    if (type === 'agotado') return 'rgba(239, 68, 68, 0.3)';
    return 'rgba(59, 130, 246, 0.3)';
  };

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
        <h1 className="mb-4" style={{ color: 'var(--text-primary)' }}>
          Alertas
        </h1>

        <div className="flex gap-2 overflow-x-auto pb-1 -mx-1 px-1">
          {filters.map((filter) => (
            <button
              key={filter.id}
              onClick={() => setActiveFilter(filter.id)}
              className="px-3 py-1.5 rounded-lg text-sm whitespace-nowrap transition-colors border"
              style={{
                backgroundColor:
                  activeFilter === filter.id ? 'var(--accent-primary-soft)' : 'var(--surface-soft)',
                borderColor:
                  activeFilter === filter.id ? 'var(--border-active)' : 'var(--border-subtle)',
                color: activeFilter === filter.id ? 'var(--accent-primary)' : 'var(--text-secondary)',
              }}
            >
              {filter.label}
            </button>
          ))}
        </div>
      </div>

      {/* Alerts List */}
      <div className="px-5 mt-4 space-y-3">
        {filteredAlerts.length === 0 ? (
          <div className="text-center py-12">
            <p style={{ color: 'var(--text-muted)' }}>No hay alertas</p>
          </div>
        ) : (
          filteredAlerts.map((alert) => (
            <Card
              key={alert.id}
              variant="base"
              padding="none"
              className="overflow-hidden cursor-pointer transition-all hover:border-opacity-20"
              onClick={() => {
                if (alert.type === 'movimiento') {
                  navigate('/movimientos');
                } else {
                  navigate('/stock');
                }
              }}
            >
              <div className="flex">
                {/* Unread Indicator */}
                {!alert.read && (
                  <div
                    className="w-1 flex-shrink-0"
                    style={{ backgroundColor: 'var(--accent-primary)' }}
                  />
                )}

                <div className="flex-1 p-4">
                  <div className="flex items-start gap-3">
                    <div
                      className="p-2 rounded-lg flex-shrink-0"
                      style={{
                        backgroundColor: getAlertBg(alert.type),
                        border: `1px solid ${getAlertBorder(alert.type)}`,
                      }}
                    >
                      {getAlertIcon(alert.type)}
                    </div>

                    <div className="flex-1 min-w-0">
                      <div className="flex items-start justify-between gap-2 mb-1">
                        <h3 className="text-sm font-medium" style={{ color: 'var(--text-primary)' }}>
                          {alert.title}
                        </h3>
                        {!alert.read && (
                          <div
                            className="w-2 h-2 rounded-full flex-shrink-0 mt-1.5"
                            style={{ backgroundColor: 'var(--accent-primary)' }}
                          />
                        )}
                      </div>

                      <p className="text-sm mb-2" style={{ color: 'var(--text-secondary)' }}>
                        {alert.message}
                      </p>

                      <div className="flex items-center gap-2 text-xs">
                        <span style={{ color: 'var(--text-muted)' }}>{alert.branch}</span>
                        <span style={{ color: 'var(--text-muted)' }}>·</span>
                        <span style={{ color: 'var(--text-muted)' }}>{alert.date}</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </Card>
          ))
        )}
      </div>
    </div>
  );
}
