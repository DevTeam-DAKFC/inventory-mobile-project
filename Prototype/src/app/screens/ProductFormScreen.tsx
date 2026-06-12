import { useState } from 'react';
import { useNavigate, useParams } from 'react-router';
import { ArrowLeft, Upload, X } from 'lucide-react';
import Button from '../components/Button';
import Input from '../components/Input';

export default function ProductFormScreen() {
  const navigate = useNavigate();
  const { id } = useParams();
  const isEditing = Boolean(id);

  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    name: isEditing ? 'Arroz 1kg' : '',
    sku: isEditing ? 'ARR-001' : '',
    barcode: isEditing ? '744100100001' : '',
    category: isEditing ? 'Granos básicos' : '',
    description: isEditing ? 'Arroz blanco de primera calidad' : '',
    minStock: isEditing ? '10' : '',
    active: true,
  });
  const [imagePreview, setImagePreview] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    setTimeout(() => {
      setLoading(false);
      navigate('/productos');
    }, 1000);
  };

  const handleImageUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setImagePreview(reader.result as string);
      };
      reader.readAsDataURL(file);
    }
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
          <button onClick={() => navigate(-1)} className="p-1">
            <ArrowLeft size={20} style={{ color: 'var(--text-primary)' }} />
          </button>
          <h1 style={{ color: 'var(--text-primary)' }}>
            {isEditing ? 'Editar producto' : 'Nuevo producto'}
          </h1>
        </div>
      </div>

      <form onSubmit={handleSubmit} className="px-5 mt-6 space-y-6">
        {/* Image Upload */}
        <div>
          <label className="block mb-2 text-sm" style={{ color: 'var(--text-secondary)' }}>
            Imagen del producto
          </label>
          <div
            className="relative w-full h-40 rounded-xl border-2 border-dashed flex items-center justify-center overflow-hidden"
            style={{ borderColor: 'var(--border-subtle)', backgroundColor: 'var(--surface-base)' }}
          >
            {imagePreview ? (
              <>
                <img src={imagePreview} alt="Preview" className="w-full h-full object-cover" />
                <button
                  type="button"
                  onClick={() => setImagePreview(null)}
                  className="absolute top-2 right-2 p-1.5 rounded-lg"
                  style={{ backgroundColor: 'var(--surface-base)', color: 'var(--text-primary)' }}
                >
                  <X size={16} />
                </button>
              </>
            ) : (
              <label className="flex flex-col items-center gap-2 cursor-pointer">
                <Upload size={32} style={{ color: 'var(--text-muted)' }} />
                <span className="text-sm" style={{ color: 'var(--text-secondary)' }}>
                  Toca para seleccionar imagen
                </span>
                <input type="file" accept="image/*" onChange={handleImageUpload} className="hidden" />
              </label>
            )}
          </div>
        </div>

        {/* Form Fields */}
        <Input
          label="Nombre del producto *"
          value={formData.name}
          onChange={(e) => setFormData({ ...formData, name: e.target.value })}
          placeholder="Ej: Arroz 1kg"
          required
        />

        <Input
          label="SKU *"
          value={formData.sku}
          onChange={(e) => setFormData({ ...formData, sku: e.target.value })}
          placeholder="Ej: ARR-001"
          required
        />

        <Input
          label="Código de barras"
          value={formData.barcode}
          onChange={(e) => setFormData({ ...formData, barcode: e.target.value })}
          placeholder="Ej: 744100100001"
        />

        <Input
          label="Categoría"
          value={formData.category}
          onChange={(e) => setFormData({ ...formData, category: e.target.value })}
          placeholder="Ej: Granos básicos"
        />

        <div className="flex flex-col gap-1.5">
          <label className="text-sm" style={{ color: 'var(--text-secondary)' }}>
            Descripción
          </label>
          <textarea
            value={formData.description}
            onChange={(e) => setFormData({ ...formData, description: e.target.value })}
            placeholder="Descripción del producto"
            rows={3}
            className="px-4 py-3 rounded-xl border resize-none"
            style={{
              backgroundColor: 'var(--surface-soft)',
              borderColor: 'var(--border-subtle)',
              color: 'var(--text-primary)',
            }}
          />
        </div>

        <Input
          label="Stock mínimo *"
          type="number"
          value={formData.minStock}
          onChange={(e) => setFormData({ ...formData, minStock: e.target.value })}
          placeholder="10"
          required
          min="0"
        />

        {isEditing && (
          <div className="flex items-center justify-between p-4 rounded-xl border"
            style={{
              backgroundColor: 'var(--surface-base)',
              borderColor: 'var(--border-subtle)',
            }}
          >
            <div>
              <p className="text-sm mb-0.5" style={{ color: 'var(--text-primary)' }}>
                Producto activo
              </p>
              <p className="text-xs" style={{ color: 'var(--text-muted)' }}>
                Los productos inactivos no aparecen en búsquedas
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
        )}

        <div
          className="p-3 rounded-lg text-xs"
          style={{
            backgroundColor: 'var(--accent-primary-soft)',
            color: 'var(--text-secondary)',
            border: '1px solid var(--border-active)',
          }}
        >
          <strong style={{ color: 'var(--accent-primary)' }}>Nota:</strong> El stock se actualiza únicamente
          mediante movimientos de inventario. No se puede editar directamente.
        </div>

        <Button type="submit" variant="primary" fullWidth loading={loading}>
          {isEditing ? 'Guardar cambios' : 'Crear producto'}
        </Button>
      </form>
    </div>
  );
}
