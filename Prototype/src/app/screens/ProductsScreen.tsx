import { useState } from 'react';
import { useNavigate } from 'react-router';
import { Plus, Search, ChevronDown, ChevronRight } from 'lucide-react';
import Card from '../components/Card';
import Badge from '../components/Badge';
import Button from '../components/Button';

export default function ProductsScreen() {
  const navigate = useNavigate();
  const [activeFilter, setActiveFilter] = useState('todos');
  const [searchQuery, setSearchQuery] = useState('');

  const filters = [
    { id: 'todos', label: 'Todos' },
    { id: 'activos', label: 'Activos' },
    { id: 'bajo', label: 'Stock bajo' },
    { id: 'agotados', label: 'Agotados' },
  ];

  const products = [
    {
      id: '1',
      name: 'Arroz 1kg',
      sku: 'ARR-001',
      category: 'Granos básicos',
      branch: 'Tienda Central',
      stock: 8,
      minStock: 10,
      status: 'bajo',
    },
    {
      id: '2',
      name: 'Frijoles negros 900g',
      sku: 'FRJ-001',
      category: 'Granos básicos',
      branch: 'Tienda Central',
      stock: 25,
      minStock: 12,
      status: 'disponible',
    },
    {
      id: '3',
      name: 'Aceite vegetal 900ml',
      sku: 'ACE-001',
      category: 'Abarrotes',
      branch: 'Tienda Norte',
      stock: 0,
      minStock: 8,
      status: 'agotado',
    },
  ];

  const filteredProducts = products.filter((product) => {
    const matchesSearch =
      product.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      product.sku.toLowerCase().includes(searchQuery.toLowerCase());

    if (activeFilter === 'todos') return matchesSearch;
    if (activeFilter === 'activos') return matchesSearch && product.stock > 0;
    if (activeFilter === 'bajo') return matchesSearch && product.status === 'bajo';
    if (activeFilter === 'agotados') return matchesSearch && product.status === 'agotado';
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
        <div className="flex items-center justify-between mb-4">
          <h1 style={{ color: 'var(--text-primary)' }}>Productos</h1>
          <button
            onClick={() => navigate('/productos/nuevo')}
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

        <div className="relative">
          <Search
            size={18}
            className="absolute left-3 top-1/2 -translate-y-1/2"
            style={{ color: 'var(--text-muted)' }}
          />
          <input
            type="text"
            placeholder="Buscar por nombre, SKU o código..."
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

        <div className="flex gap-2 overflow-x-auto mt-3 pb-1 -mx-1 px-1">
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

      {/* Products List */}
      <div className="px-5 mt-4 space-y-3">
        {filteredProducts.length === 0 ? (
          <div className="text-center py-12">
            <p style={{ color: 'var(--text-muted)' }}>No se encontraron productos</p>
          </div>
        ) : (
          filteredProducts.map((product) => (
            <Card
              key={product.id}
              variant="base"
              padding="md"
              className="cursor-pointer transition-all hover:border-opacity-20"
              onClick={() => navigate(`/productos/${product.id}`)}
            >
              <div className="flex items-start gap-3">
                <div
                  className="w-12 h-12 rounded-lg flex items-center justify-center flex-shrink-0"
                  style={{ backgroundColor: 'var(--surface-soft)' }}
                >
                  <span className="text-lg" style={{ color: 'var(--accent-primary)' }}>
                    📦
                  </span>
                </div>

                <div className="flex-1 min-w-0">
                  <div className="flex items-start justify-between gap-2 mb-1">
                    <h3 className="text-sm truncate" style={{ color: 'var(--text-primary)' }}>
                      {product.name}
                    </h3>
                    <ChevronRight size={16} className="flex-shrink-0" style={{ color: 'var(--text-muted)' }} />
                  </div>

                  <div className="flex items-center gap-2 mb-2 text-xs">
                    <span style={{ color: 'var(--text-secondary)' }}>{product.sku}</span>
                    <span style={{ color: 'var(--text-muted)' }}>·</span>
                    <span style={{ color: 'var(--text-muted)' }}>{product.category}</span>
                  </div>

                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2 text-xs">
                      <span style={{ color: 'var(--text-secondary)' }}>{product.branch}</span>
                      <span style={{ color: 'var(--text-muted)' }}>·</span>
                      <span style={{ color: 'var(--text-primary)' }}>{product.stock} unid.</span>
                    </div>
                    {getStatusBadge(product.status)}
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
