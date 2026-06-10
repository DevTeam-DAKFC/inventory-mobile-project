# Inventory Control Mobile - Prototipo Dark Premium

## 🎨 Diseño Visual

Prototipo completo con estética **dark premium global** para una app móvil de control de inventario.

### Paleta de colores

- **Backgrounds**: Degradados oscuros (#0C1013 → #111A20)
- **Surfaces**: #12181C (base), #182126 (elevated), #1F2A30 (soft)
- **Texto**: #F8FAFC (primary), #A9B4BE (secondary), #6F7C86 (muted)
- **Accent**: #14B8A6 (teal premium)
- **Estados**: Verde #22C55E, Amarillo #F59E0B, Rojo #EF4444, Azul #3B82F6

## 📱 Pantallas implementadas

### 1. Login
- Pantalla de autenticación con logo
- Campos de email y contraseña
- Estados de loading y error
- Diseño dark premium refinado

### 2. Dashboard / Inicio
- Header con usuario y notificaciones
- Selector de sucursal activa
- Hero card protagonista con barra de disponibilidad
- 4 KPI cards (productos, stock bajo, agotados, movimientos)
- Grid de acciones rápidas
- Últimos movimientos con navegación

### 3. Productos
- Header con botón de agregar
- Selector de sucursal
- Barra de búsqueda por nombre/SKU
- Filtros: Todos, Activos, Stock bajo, Agotados
- Product cards con imagen, info y badges de estado

### 4. Detalle de producto
- Imagen del producto
- Información completa (SKU, código de barras, categoría, etc.)
- Stock por sucursal con badges de estado
- Últimos movimientos del producto
- Botones de acción (registrar entrada/salida)

### 5. Crear/Editar producto
- Formulario completo con validaciones
- Upload de imagen con preview
- Campos: nombre, SKU, código de barras, categoría, descripción, stock mínimo
- Toggle de estado activo/inactivo
- Nota informativa sobre actualización de stock

### 6. Stock / Existencias
- Selector de sucursal
- Búsqueda de productos
- Filtros por estado
- Stock cards con:
  - Producto y SKU
  - Cantidad disponible vs mínimo
  - Estado con badge
  - Última actualización

### 7. Registrar movimiento
- Selector de tipo (Entrada/Salida)
- Selects de producto y sucursal
- Input de cantidad con validación
- Selector de motivo contextual
- Notas opcionales
- Card de resumen con cálculo de stock resultante
- Validación de existencias para salidas
- Estado de éxito con feedback visual

### 8. Historial de movimientos
- Lista completa de movimientos
- Filtros por tipo
- Búsqueda
- Movement cards con toda la info
- Navegación a detalle

### 9. Detalle de movimiento
- Información completa del movimiento
- Tipo con badge
- Detalles del producto
- Cantidad y stock resultante
- Usuario responsable
- Motivo y notas
- Card de trazabilidad

### 10. Alertas
- Filtros: Todas, No leídas, Stock
- Alert cards con iconos contextuales
- Indicador visual de no leídas
- 3 tipos: Stock bajo, Agotado, Movimiento registrado
- Navegación a secciones relacionadas

### 11. Sucursales
- Lista de sucursales activas
- Botón para agregar nueva
- Formulario simple: nombre, dirección, estado
- Branch cards con icono y badge

## 🧩 Componentes reutilizables

- **Button**: Primary, Secondary, Ghost con loading state
- **Input**: Con label, error y estilos dark
- **Select**: Dropdown estilizado
- **Textarea**: Campo de texto largo
- **Card**: Variantes base, elevated, soft
- **Badge**: 5 variantes de color (success, warning, danger, info, default)
- **BranchSelector**: Selector de sucursal consistente
- **EmptyState**: Estados vacíos con icono y acción
- **MobileLayout**: Layout con bottom navigation

## 🎯 Bottom Navigation

5 secciones principales:
1. Inicio (Dashboard)
2. Productos
3. Stock
4. Movimientos
5. Alertas

Navegación dark premium integrada con:
- Iconos de Lucide React
- Estados activo/inactivo
- Color teal para tab activo
- Labels compactos

## ✨ Características visuales

- ✅ Diseño 100% dark premium (sin pantallas claras)
- ✅ Degradados sutiles en backgrounds
- ✅ Bordes sutiles para definición
- ✅ Sombras y contraste de superficie
- ✅ Teal como acento principal
- ✅ Colores funcionales para estados
- ✅ Componentes consistentes en todas las pantallas
- ✅ Transiciones suaves
- ✅ Feedback visual en interacciones
- ✅ Badges y pills informativos
- ✅ Iconografía clara con Lucide React
- ✅ Tipografía legible y jerárquica
- ✅ Diseño compacto y eficiente
- ✅ Responsive (máx 448px centered)

## 🔄 Flujos funcionales implementados

### Login → Dashboard
Demo: cualquier email/password funciona

### Gestión de productos
1. Ver catálogo con filtros
2. Ver detalle de producto
3. Crear/editar producto
4. Stock por sucursal visible

### Control de stock
1. Ver existencias por sucursal
2. Filtrar por estado
3. Buscar productos
4. Ver stock actual vs mínimo

### Movimientos de inventario
1. Registrar entrada con motivo
2. Registrar salida con validación de stock
3. Ver historial completo
4. Ver detalle de cada movimiento
5. Trazabilidad (usuario, fecha, hora)

### Alertas
1. Stock bajo automático
2. Productos agotados
3. Registro de movimientos
4. Indicador de no leídas

### Sucursales
1. Ver lista de sucursales
2. Crear nueva sucursal
3. Gestión simple admin

## 📊 Datos mock incluidos

- **Usuario**: Ana Rodríguez (Administradora, Tienda Central)
- **Sucursales**: Tienda Central (San José), Tienda Norte (Heredia)
- **Productos**: Arroz 1kg, Frijoles 900g, Aceite 900ml
- **Movimientos**: 3 movimientos de ejemplo
- **Alertas**: Stock bajo, Agotado, Movimiento registrado

## 🛠 Stack técnico

- React 18.3.1
- React Router 7.13.0
- TypeScript
- Tailwind CSS v4
- Lucide React (iconos)
- Vite 6.3.5

## 🎓 Listo para presentar

Este prototipo es:
- ✅ Visualmente completo y profesional
- ✅ Funcionalmente coherente
- ✅ Estéticamente consistente
- ✅ Dark premium en todas las pantallas
- ✅ Listo para demostración en clase
- ✅ Con datos mock realistas
- ✅ Navegación completa entre todas las pantallas
- ✅ Validaciones y feedback visual
- ✅ Estados de loading, error y éxito

---

**Nota**: Este es un prototipo funcional frontend. Para producción requeriría integración con Firebase (Auth, Firestore, Storage, FCM) según la especificación original.
