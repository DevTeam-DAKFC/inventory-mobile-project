import { useNavigate, useParams } from 'react-router';
import { ArrowLeft } from 'lucide-react';
import Card from '../components/Card';
import Badge from '../components/Badge';

export default function MovementDetailScreen() {
  const navigate = useNavigate();
  const { id } = useParams();

  const movement = {
    id: '2',
    type: 'Salida',
    product: 'Arroz 1kg',
    sku: 'ARR-001',
    quantity: -3,
    stock: 25,
    branch: 'Tienda Central',
    reason: 'Venta en mostrador',
    notes: 'Cliente compró 3 unidades para consumo personal',
    user: 'Ana Rodríguez',
    date: '3 jun, 2026',
    time: '14:15',
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
        <div className="flex items-center gap-3">
          <button onClick={() => navigate('/movimientos')} className="p-1">
            <ArrowLeft size={20} style={{ color: 'var(--text-primary)' }} />
          </button>
          <h1 style={{ color: 'var(--text-primary)' }}>Detalle de movimiento</h1>
        </div>
      </div>

      <div className="px-5 mt-6 space-y-6">
        {/* Movement Type Badge */}
        <div className="flex items-center gap-3">
          <Badge variant={movement.type === 'Entrada' ? 'success' : 'info'} size="md">
            {movement.type}
          </Badge>
          <span className="text-sm" style={{ color: 'var(--text-muted)' }}>
            {movement.date} · {movement.time}
          </span>
        </div>

        {/* Product Info */}
        <Card variant="base" padding="lg">
          <h3 className="mb-4" style={{ color: 'var(--text-primary)' }}>
            Información del producto
          </h3>

          <div className="space-y-3">
            <div className="flex justify-between py-2 border-b" style={{ borderColor: 'var(--border-subtle)' }}>
              <span className="text-sm" style={{ color: 'var(--text-secondary)' }}>
                Producto
              </span>
              <span className="text-sm" style={{ color: 'var(--text-primary)' }}>
                {movement.product}
              </span>
            </div>

            <div className="flex justify-between py-2 border-b" style={{ borderColor: 'var(--border-subtle)' }}>
              <span className="text-sm" style={{ color: 'var(--text-secondary)' }}>
                SKU
              </span>
              <span className="text-sm" style={{ color: 'var(--text-primary)' }}>
                {movement.sku}
              </span>
            </div>

            <div className="flex justify-between py-2" style={{ borderColor: 'var(--border-subtle)' }}>
              <span className="text-sm" style={{ color: 'var(--text-secondary)' }}>
                Sucursal
              </span>
              <span className="text-sm" style={{ color: 'var(--text-primary)' }}>
                {movement.branch}
              </span>
            </div>
          </div>
        </Card>

        {/* Movement Details */}
        <Card variant="base" padding="lg">
          <h3 className="mb-4" style={{ color: 'var(--text-primary)' }}>
            Detalles del movimiento
          </h3>

          <div className="space-y-3">
            <div className="flex justify-between py-2 border-b" style={{ borderColor: 'var(--border-subtle)' }}>
              <span className="text-sm" style={{ color: 'var(--text-secondary)' }}>
                Cantidad
              </span>
              <span
                className="text-sm font-semibold"
                style={{
                  color: movement.type === 'Entrada' ? 'var(--status-success)' : 'var(--status-info)',
                }}
              >
                {movement.quantity > 0 ? '+' : ''}
                {movement.quantity} unidades
              </span>
            </div>

            <div className="flex justify-between py-2 border-b" style={{ borderColor: 'var(--border-subtle)' }}>
              <span className="text-sm" style={{ color: 'var(--text-secondary)' }}>
                Stock resultante
              </span>
              <span className="text-sm font-semibold" style={{ color: 'var(--text-primary)' }}>
                {movement.stock} unidades
              </span>
            </div>

            <div className="flex justify-between py-2 border-b" style={{ borderColor: 'var(--border-subtle)' }}>
              <span className="text-sm" style={{ color: 'var(--text-secondary)' }}>
                Motivo
              </span>
              <span className="text-sm" style={{ color: 'var(--text-primary)' }}>
                {movement.reason}
              </span>
            </div>

            <div className="flex justify-between py-2" style={{ borderColor: 'var(--border-subtle)' }}>
              <span className="text-sm" style={{ color: 'var(--text-secondary)' }}>
                Usuario responsable
              </span>
              <span className="text-sm" style={{ color: 'var(--text-primary)' }}>
                {movement.user}
              </span>
            </div>
          </div>

          {movement.notes && (
            <div className="mt-4 pt-4 border-t" style={{ borderColor: 'var(--border-subtle)' }}>
              <p className="text-xs mb-1" style={{ color: 'var(--text-secondary)' }}>
                Notas
              </p>
              <p className="text-sm" style={{ color: 'var(--text-primary)' }}>
                {movement.notes}
              </p>
            </div>
          )}
        </Card>

        {/* Traceability Info */}
        <div
          className="p-4 rounded-lg text-xs"
          style={{
            backgroundColor: 'var(--accent-primary-soft)',
            border: '1px solid var(--border-active)',
          }}
        >
          <div className="flex items-start gap-2">
            <span style={{ color: 'var(--accent-primary)' }}>✓</span>
            <div>
              <p style={{ color: 'var(--text-primary)' }}>
                <strong>Trazabilidad completa:</strong> Este movimiento fue registrado por{' '}
                {movement.user} el {movement.date} a las {movement.time}.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
