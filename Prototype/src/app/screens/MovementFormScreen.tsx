import { useState } from 'react';
import { useNavigate } from 'react-router';
import { ArrowLeft, AlertCircle, CheckCircle } from 'lucide-react';
import Button from '../components/Button';
import Input from '../components/Input';
import Card from '../components/Card';

export default function MovementFormScreen() {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState(false);
  const [formData, setFormData] = useState({
    type: 'entrada',
    product: '',
    branch: 'Tienda Central',
    quantity: '',
    reason: '',
    notes: '',
  });

  const currentStock = 8;
  const resultingStock = formData.quantity
    ? formData.type === 'entrada'
      ? currentStock + parseInt(formData.quantity)
      : currentStock - parseInt(formData.quantity)
    : currentStock;

  const hasError =
    formData.type === 'salida' &&
    formData.quantity &&
    parseInt(formData.quantity) > currentStock;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (hasError) return;

    setLoading(true);
    setTimeout(() => {
      setLoading(false);
      setSuccess(true);
      setTimeout(() => {
        navigate('/movimientos');
      }, 1500);
    }, 1000);
  };

  if (success) {
    return (
      <div
        className="flex flex-col items-center justify-center min-h-screen px-6"
        style={{
          background: 'linear-gradient(to bottom, var(--bg-gradient-start), var(--bg-gradient-end))',
        }}
      >
        <div className="text-center space-y-4">
          <div
            className="w-16 h-16 rounded-full flex items-center justify-center mx-auto"
            style={{ backgroundColor: 'rgba(34, 197, 94, 0.14)' }}
          >
            <CheckCircle size={32} style={{ color: 'var(--status-success)' }} />
          </div>
          <h2 style={{ color: 'var(--text-primary)' }}>Movimiento registrado</h2>
          <p style={{ color: 'var(--text-secondary)' }}>El stock se ha actualizado correctamente</p>
        </div>
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
        <div className="flex items-center gap-3">
          <button onClick={() => navigate(-1)} className="p-1">
            <ArrowLeft size={20} style={{ color: 'var(--text-primary)' }} />
          </button>
          <h1 style={{ color: 'var(--text-primary)' }}>Registrar movimiento</h1>
        </div>
      </div>

      <form onSubmit={handleSubmit} className="px-5 mt-6 space-y-6">
        {/* Movement Type */}
        <div className="flex flex-col gap-1.5">
          <label className="text-sm" style={{ color: 'var(--text-secondary)' }}>
            Tipo de movimiento *
          </label>
          <div className="grid grid-cols-2 gap-2">
            <button
              type="button"
              onClick={() => setFormData({ ...formData, type: 'entrada' })}
              className="h-11 rounded-xl border transition-colors"
              style={{
                backgroundColor:
                  formData.type === 'entrada' ? 'rgba(34, 197, 94, 0.14)' : 'var(--surface-base)',
                borderColor:
                  formData.type === 'entrada' ? 'rgba(34, 197, 94, 0.3)' : 'var(--border-subtle)',
                color: formData.type === 'entrada' ? 'var(--status-success)' : 'var(--text-primary)',
              }}
            >
              Entrada
            </button>
            <button
              type="button"
              onClick={() => setFormData({ ...formData, type: 'salida' })}
              className="h-11 rounded-xl border transition-colors"
              style={{
                backgroundColor:
                  formData.type === 'salida' ? 'rgba(59, 130, 246, 0.14)' : 'var(--surface-base)',
                borderColor:
                  formData.type === 'salida' ? 'rgba(59, 130, 246, 0.3)' : 'var(--border-subtle)',
                color: formData.type === 'salida' ? 'var(--status-info)' : 'var(--text-primary)',
              }}
            >
              Salida
            </button>
          </div>
        </div>

        {/* Product Select */}
        <div className="flex flex-col gap-1.5">
          <label className="text-sm" style={{ color: 'var(--text-secondary)' }}>
            Producto *
          </label>
          <select
            value={formData.product}
            onChange={(e) => setFormData({ ...formData, product: e.target.value })}
            required
            className="h-11 px-4 rounded-xl border"
            style={{
              backgroundColor: 'var(--surface-soft)',
              borderColor: 'var(--border-subtle)',
              color: 'var(--text-primary)',
            }}
          >
            <option value="">Seleccionar producto</option>
            <option value="arroz">Arroz 1kg</option>
            <option value="frijoles">Frijoles negros 900g</option>
            <option value="aceite">Aceite vegetal 900ml</option>
          </select>
        </div>

        {/* Branch Select */}
        <div className="flex flex-col gap-1.5">
          <label className="text-sm" style={{ color: 'var(--text-secondary)' }}>
            Sucursal *
          </label>
          <select
            value={formData.branch}
            onChange={(e) => setFormData({ ...formData, branch: e.target.value })}
            required
            className="h-11 px-4 rounded-xl border"
            style={{
              backgroundColor: 'var(--surface-soft)',
              borderColor: 'var(--border-subtle)',
              color: 'var(--text-primary)',
            }}
          >
            <option value="Tienda Central">Tienda Central</option>
            <option value="Tienda Norte">Tienda Norte</option>
          </select>
        </div>

        {/* Quantity */}
        <Input
          label="Cantidad *"
          type="number"
          value={formData.quantity}
          onChange={(e) => setFormData({ ...formData, quantity: e.target.value })}
          placeholder="0"
          required
          min="1"
          error={hasError ? 'No hay existencias suficientes' : undefined}
        />

        {/* Reason */}
        <div className="flex flex-col gap-1.5">
          <label className="text-sm" style={{ color: 'var(--text-secondary)' }}>
            Motivo *
          </label>
          <select
            value={formData.reason}
            onChange={(e) => setFormData({ ...formData, reason: e.target.value })}
            required
            className="h-11 px-4 rounded-xl border"
            style={{
              backgroundColor: 'var(--surface-soft)',
              borderColor: 'var(--border-subtle)',
              color: 'var(--text-primary)',
            }}
          >
            <option value="">Seleccionar motivo</option>
            {formData.type === 'entrada' ? (
              <>
                <option value="compra">Compra a proveedor</option>
                <option value="devolucion">Devolución de cliente</option>
                <option value="ajuste">Ajuste de inventario</option>
              </>
            ) : (
              <>
                <option value="venta">Venta en mostrador</option>
                <option value="merma">Merma o deterioro</option>
                <option value="traspaso">Traspaso a otra sucursal</option>
              </>
            )}
          </select>
        </div>

        {/* Notes */}
        <div className="flex flex-col gap-1.5">
          <label className="text-sm" style={{ color: 'var(--text-secondary)' }}>
            Notas (opcional)
          </label>
          <textarea
            value={formData.notes}
            onChange={(e) => setFormData({ ...formData, notes: e.target.value })}
            placeholder="Observaciones adicionales..."
            rows={3}
            className="px-4 py-3 rounded-xl border resize-none"
            style={{
              backgroundColor: 'var(--surface-soft)',
              borderColor: 'var(--border-subtle)',
              color: 'var(--text-primary)',
            }}
          />
        </div>

        {/* Summary Card */}
        {formData.product && formData.quantity && (
          <Card variant="elevated" padding="md">
            <h3 className="text-sm mb-3" style={{ color: 'var(--text-primary)' }}>
              Resumen del movimiento
            </h3>
            <div className="space-y-2">
              <div className="flex justify-between text-sm">
                <span style={{ color: 'var(--text-secondary)' }}>Stock actual en {formData.branch}</span>
                <span style={{ color: 'var(--text-primary)' }}>{currentStock}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span style={{ color: 'var(--text-secondary)' }}>Cantidad a mover</span>
                <span
                  style={{
                    color: formData.type === 'entrada' ? 'var(--status-success)' : 'var(--status-info)',
                  }}
                >
                  {formData.type === 'entrada' ? '+' : '-'}
                  {formData.quantity}
                </span>
              </div>
              <div
                className="flex justify-between text-sm pt-2 border-t"
                style={{ borderColor: 'var(--border-subtle)' }}
              >
                <span style={{ color: 'var(--text-secondary)' }}>Stock resultante</span>
                <span className="font-semibold" style={{ color: 'var(--text-primary)' }}>
                  {resultingStock}
                </span>
              </div>
            </div>
          </Card>
        )}

        {/* Error Message */}
        {hasError && (
          <div
            className="flex items-start gap-3 p-3 rounded-lg"
            style={{
              backgroundColor: 'rgba(239, 68, 68, 0.14)',
              border: '1px solid rgba(239, 68, 68, 0.3)',
            }}
          >
            <AlertCircle size={20} className="flex-shrink-0 mt-0.5" style={{ color: 'var(--status-danger)' }} />
            <div>
              <p className="text-sm font-medium mb-1" style={{ color: 'var(--status-danger)' }}>
                No hay existencias suficientes
              </p>
              <p className="text-xs" style={{ color: 'var(--text-secondary)' }}>
                Solo hay {currentStock} unidades disponibles en {formData.branch}
              </p>
            </div>
          </div>
        )}

        <Button type="submit" variant="primary" fullWidth loading={loading} disabled={hasError}>
          Registrar movimiento
        </Button>
      </form>
    </div>
  );
}
