import { useState } from 'react';
import { Search, ChevronDown } from 'lucide-react';
import Card from '../components/Card';
import Badge from '../components/Badge';

export default function StockScreen() {
  const [activeFilter, setActiveFilter] = useState('todos');
  const [searchQuery, setSearchQuery] = useState('');

  const filters = [
    { id: 'todos', label: 'Todos' },
    { id: 'disponible', label: 'Disponible' },
    { id: 'bajo', label: 'Stock bajo' },
    { id: 'agotado', label: 'Agotado' },
  ];

  const stockItems = [
    {
      id: '1',
      product: 'Arroz 1kg',
      sku: 'ARR-001',
      branch: 'Tienda Central',
      available: 8,
      minStock: 10,
      status: 'bajo',
      lastUpdate: '3 jun, 10:30',
    },
    {
      id: '2',
      product: 'Frijoles negros 900g',
      sku: 'FRJ-001',
      branch: 'Tienda Central',
      available: 25,
      minStock: 12,
      status: 'disponible',
      lastUpdate: '2 jun, 15:20',
    },
    {
      id: '3',
      product: 'Aceite vegetal 900ml',
      sku: 'ACE-001',
      branch: 'Tienda Norte',
      available: 0,
      minStock: 8,
      status: 'agotado',
      lastUpdate: '3 jun, 16:45',
    },
  ];

  const filteredStock = stockItems.filter((item) => {
    const matchesSearch =
      item.product.toLowerCase().includes(searchQuery.toLowerCase()) ||
      item.sku.toLowerCase().includes(searchQuery.toLowerCase());

    if (activeFilter === 'todos') return matchesSearch;
    if (activeFilter === 'disponible') return matchesSearch && item.status === 'disponible';
    if (activeFilter === 'bajo') return matchesSearch && item.status === 'bajo';
    if (activeFilter === 'agotado') return matchesSearch && item.status === 'agotado';
    return matchesSearch;
  });

  const getStatusBadge = (status: string) => {
    if (status === 'disponible') return <Badge variant="success">Disponible</Badge>;
    if (status === 'bajo') return <Badge variant="warning">Stock bajo</Badge>;
    if (status === 'agotado') return <Badge variant="danger">Agotado</Badge>;
    return null;
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
          Existencias
        </h1>

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
            placeholder="Buscar producto..."
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

      {/* Stock List */}
      <div className="px-5 mt-4 space-y-3">
        {filteredStock.length === 0 ? (
          <div className="text-center py-12">
            <p style={{ color: 'var(--text-muted)' }}>No se encontraron existencias</p>
          </div>
        ) : (
          filteredStock.map((item) => (
            <Card key={item.id} variant="base" padding="md">
              <div className="space-y-3">
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <h3 className="text-sm mb-1" style={{ color: 'var(--text-primary)' }}>
                      {item.product}
                    </h3>
                    <div className="flex items-center gap-2 text-xs">
                      <span style={{ color: 'var(--text-secondary)' }}>{item.sku}</span>
                      <span style={{ color: 'var(--text-muted)' }}>·</span>
                      <span style={{ color: 'var(--text-muted)' }}>{item.branch}</span>
                    </div>
                  </div>
                  {getStatusBadge(item.status)}
                </div>

                <div
                  className="grid grid-cols-2 gap-3 pt-3 border-t"
                  style={{ borderColor: 'var(--border-subtle)' }}
                >
                  <div>
                    <p className="text-xs mb-1" style={{ color: 'var(--text-muted)' }}>
                      Disponible
                    </p>
                    <p className="text-lg font-semibold" style={{ color: 'var(--text-primary)' }}>
                      {item.available}
                    </p>
                  </div>
                  <div>
                    <p className="text-xs mb-1" style={{ color: 'var(--text-muted)' }}>
                      Mínimo
                    </p>
                    <p className="text-lg font-semibold" style={{ color: 'var(--text-primary)' }}>
                      {item.minStock}
                    </p>
                  </div>
                </div>

                <div className="flex items-center justify-between text-xs pt-2 border-t"
                  style={{ borderColor: 'var(--border-subtle)' }}
                >
                  <span style={{ color: 'var(--text-muted)' }}>Última actualización</span>
                  <span style={{ color: 'var(--text-secondary)' }}>{item.lastUpdate}</span>
                </div>
              </div>
            </Card>
          ))
        )}
      </div>
    </div>
  );
}
