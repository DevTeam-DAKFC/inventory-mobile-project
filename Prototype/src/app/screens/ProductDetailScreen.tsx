import { useNavigate, useParams } from 'react-router';
import { ArrowLeft, Edit, Package } from 'lucide-react';
import Card from '../components/Card';
import Badge from '../components/Badge';
import Button from '../components/Button';

export default function ProductDetailScreen() {
  const navigate = useNavigate();
  const { id } = useParams();

  const product = {
    id: '1',
    name: 'Arroz 1kg',
    sku: 'ARR-001',
    barcode: '744100100001',
    category: 'Granos básicos',
    description: 'Arroz blanco de primera calidad, empaque de 1 kilogramo',
    minStock: 10,
    active: true,
    stockByBranch: [
      { branch: 'Tienda Central', stock: 8, status: 'bajo' },
      { branch: 'Tienda Norte', stock: 0, status: 'agotado' },
    ],
    recentMovements: [
      {
        id: '2',
        type: 'Salida',
        quantity: -3,
        stock: 25,
        branch: 'Tienda Central',
        date: '3 jun, 14:15',
      },
      {
        id: '1',
        type: 'Entrada',
        quantity: 20,
        stock: 28,
        branch: 'Tienda Central',
        date: '3 jun, 10:30',
      },
    ],
  };

  const getStatusBadge = (status: string) => {
    if (status === 'bajo') return <Badge variant="warning">Stock bajo</Badge>;
    if (status === 'agotado') return <Badge variant="danger">Agotado</Badge>;
    return <Badge variant="success">Disponible</Badge>;
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
        <div className="flex items-center gap-3 mb-4">
          <button onClick={() => navigate('/productos')} className="p-1">
            <ArrowLeft size={20} style={{ color: 'var(--text-primary)' }} />
          </button>
          <h1 className="flex-1" style={{ color: 'var(--text-primary)' }}>
            Detalle de producto
          </h1>
          <button
            onClick={() => navigate(`/productos/${id}/editar`)}
            className="p-2 rounded-lg"
            style={{
              backgroundColor: 'var(--surface-soft)',
              color: 'var(--text-primary)',
            }}
          >
            <Edit size={18} />
          </button>
        </div>
      </div>

      <div className="px-5 mt-6 space-y-6">
        {/* Product Image */}
        <div
          className="w-full h-48 rounded-xl flex items-center justify-center"
          style={{ backgroundColor: 'var(--surface-base)', border: '1px solid var(--border-subtle)' }}
        >
          <Package size={48} style={{ color: 'var(--text-muted)' }} />
        </div>

        {/* Product Info */}
        <Card variant="base" padding="lg">
          <h2 className="mb-4" style={{ color: 'var(--text-primary)' }}>
            {product.name}
          </h2>

          <div className="space-y-3">
            <div className="flex justify-between py-2 border-b" style={{ borderColor: 'var(--border-subtle)' }}>
              <span className="text-sm" style={{ color: 'var(--text-secondary)' }}>
                SKU
              </span>
              <span className="text-sm" style={{ color: 'var(--text-primary)' }}>
                {product.sku}
              </span>
            </div>

            <div className="flex justify-between py-2 border-b" style={{ borderColor: 'var(--border-subtle)' }}>
              <span className="text-sm" style={{ color: 'var(--text-secondary)' }}>
                Código de barras
              </span>
              <span className="text-sm" style={{ color: 'var(--text-primary)' }}>
                {product.barcode}
              </span>
            </div>

            <div className="flex justify-between py-2 border-b" style={{ borderColor: 'var(--border-subtle)' }}>
              <span className="text-sm" style={{ color: 'var(--text-secondary)' }}>
                Categoría
              </span>
              <span className="text-sm" style={{ color: 'var(--text-primary)' }}>
                {product.category}
              </span>
            </div>

            <div className="flex justify-between py-2 border-b" style={{ borderColor: 'var(--border-subtle)' }}>
              <span className="text-sm" style={{ color: 'var(--text-secondary)' }}>
                Stock mínimo
              </span>
              <span className="text-sm" style={{ color: 'var(--text-primary)' }}>
                {product.minStock} unid.
              </span>
            </div>

            <div className="flex justify-between py-2">
              <span className="text-sm" style={{ color: 'var(--text-secondary)' }}>
                Estado
              </span>
              <Badge variant="success">{product.active ? 'Activo' : 'Inactivo'}</Badge>
            </div>
          </div>

          {product.description && (
            <div className="mt-4 pt-4 border-t" style={{ borderColor: 'var(--border-subtle)' }}>
              <p className="text-sm" style={{ color: 'var(--text-secondary)' }}>
                {product.description}
              </p>
            </div>
          )}
        </Card>

        {/* Stock by Branch */}
        <div>
          <h3 className="mb-3 px-1" style={{ color: 'var(--text-primary)' }}>
            Stock por sucursal
          </h3>
          <div className="space-y-2">
            {product.stockByBranch.map((item, idx) => (
              <Card key={idx} variant="base" padding="md">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm mb-1" style={{ color: 'var(--text-primary)' }}>
                      {item.branch}
                    </p>
                    <p className="text-xs" style={{ color: 'var(--text-muted)' }}>
                      {item.stock} unid.
                    </p>
                  </div>
                  {getStatusBadge(item.status)}
                </div>
              </Card>
            ))}
          </div>
        </div>

        {/* Recent Movements */}
        <div>
          <h3 className="mb-3 px-1" style={{ color: 'var(--text-primary)' }}>
            Últimos movimientos
          </h3>
          <div className="space-y-2">
            {product.recentMovements.map((movement) => (
              <Card
                key={movement.id}
                variant="base"
                padding="md"
                className="cursor-pointer"
                onClick={() => navigate(`/movimientos/${movement.id}`)}
              >
                <div className="flex items-start justify-between mb-2">
                  <Badge variant={movement.type === 'Entrada' ? 'success' : 'info'} size="sm">
                    {movement.type}
                  </Badge>
                  <span className="text-xs" style={{ color: 'var(--text-muted)' }}>
                    {movement.date}
                  </span>
                </div>
                <div className="flex items-center justify-between text-xs">
                  <span style={{ color: 'var(--text-secondary)' }}>{movement.branch}</span>
                  <span style={{ color: 'var(--text-primary)' }}>
                    {movement.quantity > 0 ? '+' : ''}
                    {movement.quantity} → Stock: {movement.stock}
                  </span>
                </div>
              </Card>
            ))}
          </div>
        </div>

        {/* Actions */}
        <div className="space-y-2">
          <Button variant="primary" fullWidth onClick={() => navigate('/movimientos/nuevo')}>
            Registrar entrada
          </Button>
          <Button variant="secondary" fullWidth onClick={() => navigate('/movimientos/nuevo')}>
            Registrar salida
          </Button>
        </div>
      </div>
    </div>
  );
}
