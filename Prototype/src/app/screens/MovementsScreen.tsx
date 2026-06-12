import { useState } from 'react';
import { useNavigate } from 'react-router';
import { Plus, Search, ChevronDown } from 'lucide-react';
import Card from '../components/Card';
import Badge from '../components/Badge';

export default function MovementsScreen() {
  const navigate = useNavigate();
  const [activeFilter, setActiveFilter] = useState('todos');
  const [searchQuery, setSearchQuery] = useState('');

  const filters = [
    { id: 'todos', label: 'Todos' },
    { id: 'entrada', label: 'Entrada' },
    { id: 'salida', label: 'Salida' },
  ];

  const movements = [
    {
      id: '3',
      type: 'Salida',
      product: 'Aceite vegetal 900ml',
      quantity: -2,
      stock: 0,
      branch: 'Tienda Norte',
      reason: 'Venta en mostrador',
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
      reason: 'Venta en mostrador',
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
      reason: 'Compra a proveedor',
      user: 'Ana Rodríguez',
      date: '3 jun, 10:30',
    },
  ];

  const filteredMovements = movements.filter((movement) => {
    const matchesSearch = movement.product.toLowerCase().includes(searchQuery.toLowerCase());

    if (activeFilter === 'todos') return matchesSearch;
    if (activeFilter === 'entrada') return matchesSearch && movement.type === 'Entrada';
    if (activeFilter === 'salida') return matchesSearch && movement.type === 'Salida';
    return matchesSearch;
  });

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
          <h1 style={{ color: 'var(--text-primary)' }}>Historial</h1>
          <button
            onClick={() => navigate('/movimientos/nuevo')}
            className="p-2 rounded-lg"
            style={{
              backgroundColor: 'var(--accent-primary)',
              color: 'var(--app-bg)',
            }}
          >
            <Plus size={20} strokeWidth={2.5} />
          </button>
        </div>

        <button
          className="flex items-center gap-2 px-3 py-2 rounded-lg border mb-3"
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

        <div className="relative mb-3">
          <Search
            size={18}
            className="absolute left-3 top-1/2 -translate-y-1/2"
            style={{ color: 'var(--text-muted)' }}
          />
          <input
            type="text"
            placeholder="Buscar movimiento..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full h-10 pl-10 pr-4 rounded-lg border"
            style={{
              backgroundColor: 'var(--surface-soft)',
              borderColor: 'var(--border-subtle)',
              color: 'var(--text-primary)',
            }}
          />
        </div>

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

      {/* Movements List */}
      <div className="px-5 mt-4 space-y-3">
        {filteredMovements.length === 0 ? (
          <div className="text-center py-12">
            <p style={{ color: 'var(--text-muted)' }}>No se encontraron movimientos</p>
          </div>
        ) : (
          filteredMovements.map((movement) => (
            <Card
              key={movement.id}
              variant="base"
              padding="md"
              className="cursor-pointer transition-all hover:border-opacity-20"
              onClick={() => navigate(`/movimientos/${movement.id}`)}
            >
              <div className="space-y-2">
                <div className="flex items-start justify-between">
                  <div className="flex items-center gap-2">
                    <Badge variant={movement.type === 'Entrada' ? 'success' : 'info'} size="sm">
                      {movement.type}
                    </Badge>
                    <span className="text-sm" style={{ color: 'var(--text-primary)' }}>
                      {movement.product}
                    </span>
                  </div>
                </div>

                <div className="flex items-center justify-between text-xs">
                  <span style={{ color: 'var(--text-secondary)' }}>{movement.branch}</span>
                  <span style={{ color: 'var(--text-muted)' }}>
                    {movement.quantity > 0 ? '+' : ''}
                    {movement.quantity} → Stock: {movement.stock}
                  </span>
                </div>

                <div
                  className="flex items-center justify-between text-xs pt-2 border-t"
                  style={{ borderColor: 'var(--border-subtle)' }}
                >
                  <span style={{ color: 'var(--text-muted)' }}>{movement.user}</span>
                  <span style={{ color: 'var(--text-muted)' }}>{movement.date}</span>
                </div>

                <div className="text-xs" style={{ color: 'var(--text-secondary)' }}>
                  Motivo: {movement.reason}
                </div>
              </div>
            </Card>
          ))
        )}
      </div>
    </div>
  );
}
