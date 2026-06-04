# Data Model - Sistema de Gestión de Inventario Multiusuario

## 1. Propósito del documento

Este documento define el modelo de datos conceptual del sistema de gestión de inventario multiusuario.

Su objetivo es establecer las entidades principales, sus campos, relaciones y reglas de negocio asociadas antes de pasar al diseño específico de persistencia.

Este documento se basa en el alcance definido en:

```text
docs/architecture/project-scope.md
```

y en las decisiones técnicas definidas en:

```text
docs/architecture/technical-decisions.md
```

---

## 2. Resumen del modelo

El sistema se centra en controlar inventario entre sucursales mediante productos, stock y movimientos.

La idea principal es:

```text
Product
→ define el catálogo general

Branch
→ representa una sucursal

Stock
→ representa cuánto hay de un producto en una sucursal

InventoryMovement
→ representa cada entrada o salida que modifica el stock

User
→ representa quién realiza acciones dentro del sistema
```

Regla central:

```text
El stock no se edita directamente.
El stock cambia mediante movimientos de inventario.
```

---

## 3. Entidades principales

El modelo de datos incluye las siguientes entidades:

```text
User
Branch
Product
Stock
InventoryMovement
NotificationToken
ImportBatch
```

`ImportBatch` es una entidad complementaria y opcional para registrar procesos de importación desde archivo CSV.

---

## 4. User

Representa a un usuario autenticado dentro de la aplicación.

Los usuarios pueden tener distintos niveles de acceso según su rol.

### Campos

| Campo | Tipo | Requerido | Descripción |
|---|---|---:|---|
| `id` | string | Sí | Identificador único del usuario, asignado por el servicio de autenticación del backend planificado. |
| `name` | string | Sí | Nombre visible del usuario. |
| `email` | string | Sí | Correo electrónico del usuario. |
| `role` | string | Sí | Rol del usuario: `admin` o `collaborator`. |
| `branchIds` | list<string> | No | Sucursales asociadas al usuario. |
| `isActive` | bool | Sí | Indica si el usuario está activo. |
| `createdAt` | timestamp | Sí | Fecha de creación del usuario. |
| `updatedAt` | timestamp | No | Fecha de última actualización. |

### Reglas

- Todo usuario debe estar autenticado.
- Todo usuario debe tener un rol.
- El rol se almacenará en SQL Server a través del backend ASP.NET Core Web API.
- Flutter recibirá el rol y los datos de perfil mediante endpoints de autenticación o perfil.
- El usuario puede estar asociado a una o varias sucursales.

### Ejemplo conceptual

```json
{
  "id": "user_001",
  "name": "Ana Gómez",
  "email": "ana@example.com",
  "role": "admin",
  "branchIds": ["branch_001", "branch_002"],
  "isActive": true,
  "createdAt": "2026-06-02T20:00:00Z",
  "updatedAt": "2026-06-02T20:00:00Z"
}
```

---

## 5. Branch

Representa una tienda o sucursal de la cadena local.

La sucursal es una entidad central del sistema porque el inventario debe poder consultarse por ubicación.

### Campos

| Campo | Tipo | Requerido | Descripción |
|---|---|---:|---|
| `id` | string | Sí | Identificador único de la sucursal. |
| `name` | string | Sí | Nombre de la sucursal. |
| `address` | string | No | Dirección o descripción de ubicación. |
| `isActive` | bool | Sí | Indica si la sucursal está activa. |
| `createdAt` | timestamp | Sí | Fecha de creación. |
| `updatedAt` | timestamp | No | Fecha de última actualización. |

### Reglas

- La sucursal no es opcional para stock ni movimientos.
- Una sucursal inactiva no debería utilizarse en nuevos movimientos.
- El MVP puede iniciar con sucursales precargadas o con gestión simple.

### Ejemplo conceptual

```json
{
  "id": "branch_001",
  "name": "Sucursal Central",
  "address": "Centro",
  "isActive": true,
  "createdAt": "2026-06-02T20:00:00Z",
  "updatedAt": "2026-06-02T20:00:00Z"
}
```

---

## 6. Product

Representa un producto del catálogo general.

El producto contiene información descriptiva, pero no contiene stock directo. La cantidad disponible se maneja mediante la entidad `Stock`.

### Campos

| Campo | Tipo | Requerido | Descripción |
|---|---|---:|---|
| `id` | string | Sí | Identificador único del producto. |
| `name` | string | Sí | Nombre del producto. |
| `sku` | string | Sí | Código interno del producto. |
| `barcode` | string | No | Código de barras, si aplica. |
| `category` | string | Sí | Categoría del producto. |
| `description` | string | No | Descripción del producto. |
| `imageUrl` | string | No | URL o referencia de imagen del producto. Puede venir de Firebase Storage o de un flujo de almacenamiento gestionado por backend; la decisión final está pendiente. |
| `minStock` | number | Sí | Cantidad mínima recomendada para activar alerta de bajo stock. |
| `isActive` | bool | Sí | Indica si el producto está activo. |
| `createdAt` | timestamp | Sí | Fecha de creación. |
| `updatedAt` | timestamp | No | Fecha de última actualización. |

### Reglas

- El producto debe tener nombre y SKU.
- El SKU no debería repetirse dentro del catálogo.
- El código de barras es opcional, porque no todos los productos lo tendrán.
- El stock no se guarda dentro del producto.
- Un producto inactivo no debería usarse en nuevos movimientos.
- Un producto inactivo puede seguir apareciendo en historial.

### Formas de creación de producto

El sistema contempla tres vías:

1. Registro manual.
2. Registro asistido por API externa.
3. Importación desde archivo CSV.

La API externa y la importación son ayudas. El registro manual debe mantenerse siempre disponible.

### Ejemplo conceptual

```json
{
  "id": "product_001",
  "name": "Arroz 80% 1kg",
  "sku": "ARR-001",
  "barcode": "7441000000012",
  "category": "Abarrotes",
  "description": "Arroz en bolsa de 1kg",
  "imageUrl": "https://example.com/product-image.jpg",
  "minStock": 10,
  "isActive": true,
  "createdAt": "2026-06-02T20:00:00Z",
  "updatedAt": "2026-06-02T20:00:00Z"
}
```

---

## 7. Stock

Representa la cantidad disponible de un producto en una sucursal específica.

Esta entidad permite que un mismo producto tenga cantidades distintas en cada sucursal.

### Campos

| Campo | Tipo | Requerido | Descripción |
|---|---|---:|---|
| `id` | string | Sí | Identificador único del registro de stock. |
| `productId` | string | Sí | Producto asociado. |
| `branchId` | string | Sí | Sucursal asociada. |
| `availableQuantity` | number | Sí | Cantidad disponible actual. |
| `lastMovementId` | string | No | Último movimiento que modificó este stock. |
| `lastMovementAt` | timestamp | No | Fecha del último movimiento. |
| `updatedAt` | timestamp | Sí | Fecha de última actualización. |

### Reglas

- Debe existir como máximo un registro de stock para una combinación `productId + branchId`.
- `availableQuantity` no debe ser negativo.
- El stock solo cambia mediante movimientos.
- Las salidas no pueden superar el stock disponible.
- El bajo stock se detecta comparando `availableQuantity` con `Product.minStock`.

### Identificador recomendado

Para facilitar la unicidad, se puede usar un identificador compuesto:

```text
{productId}_{branchId}
```

Ejemplo:

```text
product_001_branch_001
```

### Ejemplo conceptual

```json
{
  "id": "product_001_branch_001",
  "productId": "product_001",
  "branchId": "branch_001",
  "availableQuantity": 40,
  "lastMovementId": "movement_001",
  "lastMovementAt": "2026-06-02T20:15:00Z",
  "updatedAt": "2026-06-02T20:15:00Z"
}
```

---

## 8. InventoryMovement

Representa una entrada, salida o ajuste de inventario.

Para el MVP, los tipos principales son `incoming` y `outgoing`. El tipo `adjustment` puede quedar como mejora si el tiempo lo permite.

### Campos

| Campo | Tipo | Requerido | Descripción |
|---|---|---:|---|
| `id` | string | Sí | Identificador único del movimiento. |
| `productId` | string | Sí | Producto afectado. |
| `branchId` | string | Sí | Sucursal afectada. |
| `userId` | string | Sí | Usuario responsable. |
| `type` | string | Sí | Tipo: `incoming`, `outgoing` o `adjustment`. |
| `quantity` | number | Sí | Cantidad del movimiento. |
| `previousStock` | number | Sí | Stock antes del movimiento. |
| `resultingStock` | number | Sí | Stock después del movimiento. |
| `reason` | string | Sí | Motivo del movimiento. |
| `notes` | string | No | Observaciones adicionales. |
| `createdAt` | timestamp | Sí | Fecha de creación del movimiento. |

### Reglas

- La cantidad debe ser mayor a cero.
- Todo movimiento debe estar asociado a usuario, producto y sucursal.
- El producto debe estar activo.
- La sucursal debe estar activa.
- Una salida debe validar stock suficiente.
- Cada movimiento debe dejar trazabilidad.
- Un movimiento confirmado no debería eliminarse físicamente.

### Tipos de movimiento

| Tipo | Efecto |
|---|---|
| `incoming` | Aumenta el stock. |
| `outgoing` | Disminuye el stock. |
| `adjustment` | Corrige stock con justificación. Opcional para MVP. |

### Ejemplo conceptual

```json
{
  "id": "movement_001",
  "productId": "product_001",
  "branchId": "branch_001",
  "userId": "user_001",
  "type": "incoming",
  "quantity": 20,
  "previousStock": 20,
  "resultingStock": 40,
  "reason": "Initial import",
  "notes": "Stock inicial cargado desde CSV",
  "createdAt": "2026-06-02T20:15:00Z"
}
```

---

## 9. NotificationToken

Representa el token del dispositivo usado para Firebase Cloud Messaging.

### Campos

| Campo | Tipo | Requerido | Descripción |
|---|---|---:|---|
| `id` | string | Sí | Identificador único del token. |
| `userId` | string | Sí | Usuario asociado al dispositivo. |
| `token` | string | Sí | Token FCM del dispositivo. |
| `platform` | string | Sí | Plataforma: `android`, `ios` u otra. |
| `createdAt` | timestamp | Sí | Fecha de registro. |
| `updatedAt` | timestamp | No | Fecha de actualización. |

### Reglas

- Un usuario puede tener varios tokens si usa varios dispositivos.
- El token puede actualizarse.
- Flutter enviará el token FCM al backend ASP.NET Core Web API cuando exista el endpoint correspondiente.
- El backend persistirá los tokens en SQL Server.
- El backend podrá usar FCM para enviar notificaciones push.
- El envío automático de push por bajo stock queda como mejora futura.

### Ejemplo conceptual

```json
{
  "id": "token_001",
  "userId": "user_001",
  "token": "fcm_device_token_example",
  "platform": "android",
  "createdAt": "2026-06-02T20:00:00Z",
  "updatedAt": "2026-06-02T20:00:00Z"
}
```

---

## 10. ImportBatch

Representa un proceso de importación de productos desde un archivo CSV.

Esta entidad es complementaria. Puede implementarse si el equipo decide registrar historial de importaciones.

### Campos

| Campo | Tipo | Requerido | Descripción |
|---|---|---:|---|
| `id` | string | Sí | Identificador único de la importación. |
| `fileName` | string | Sí | Nombre del archivo importado. |
| `importedBy` | string | Sí | Usuario que realizó la importación. |
| `status` | string | Sí | Estado: `pending`, `validated`, `completed`, `failed`. |
| `totalRows` | number | Sí | Total de filas leídas. |
| `validRows` | number | Sí | Filas válidas. |
| `invalidRows` | number | Sí | Filas inválidas. |
| `errors` | list<object> | No | Errores encontrados durante la validación. |
| `createdAt` | timestamp | Sí | Fecha de creación. |
| `completedAt` | timestamp | No | Fecha de finalización. |

### Reglas

- La importación debe validarse antes de guardar.
- No deben guardarse productos inválidos sin confirmación.
- Si se importa stock inicial, se recomienda crear movimientos de tipo `incoming` con motivo `Initial import`.
- La importación CSV es complementaria. El flujo principal sigue siendo el registro manual.

### Ejemplo conceptual

```json
{
  "id": "import_001",
  "fileName": "inventory_initial.csv",
  "importedBy": "user_001",
  "status": "completed",
  "totalRows": 25,
  "validRows": 23,
  "invalidRows": 2,
  "errors": [
    {
      "row": 8,
      "field": "initialStock",
      "message": "Stock inicial no puede ser negativo"
    }
  ],
  "createdAt": "2026-06-02T20:00:00Z",
  "completedAt": "2026-06-02T20:05:00Z"
}
```

---

## 11. Relaciones entre entidades

### User → InventoryMovement

Un usuario puede registrar muchos movimientos.

```text
User 1 ─── * InventoryMovement
```

Cada movimiento debe tener un `userId`.

---

### Branch → Stock

Una sucursal puede tener muchos registros de stock.

```text
Branch 1 ─── * Stock
```

Cada stock pertenece a una sucursal.

---

### Product → Stock

Un producto puede tener muchos registros de stock, uno por sucursal.

```text
Product 1 ─── * Stock
```

Cada stock pertenece a un producto.

---

### Product + Branch → Stock

La combinación `productId + branchId` debe ser única.

```text
Product + Branch ─── 1 Stock
```

Esto permite representar el stock de un producto en una sucursal específica.

---

### Product → InventoryMovement

Un producto puede aparecer en muchos movimientos.

```text
Product 1 ─── * InventoryMovement
```

---

### Branch → InventoryMovement

Una sucursal puede tener muchos movimientos.

```text
Branch 1 ─── * InventoryMovement
```

---

### User → NotificationToken

Un usuario puede tener varios tokens de notificación.

```text
User 1 ─── * NotificationToken
```

---

### User → ImportBatch

Un usuario puede realizar varias importaciones.

```text
User 1 ─── * ImportBatch
```

---

## 12. Reglas de integridad

### 12.1 Producto activo

Para registrar un movimiento, el producto debe estar activo.

---

### 12.2 Sucursal activa

Para registrar un movimiento, la sucursal debe estar activa.

---

### 12.3 Stock no negativo

El stock disponible no puede ser menor a cero.

---

### 12.4 Salida con stock suficiente

Para registrar una salida:

```text
quantity <= availableQuantity
```

Si la cantidad solicitada supera el stock disponible, el movimiento no debe guardarse.

---

### 12.5 Movimiento obligatorio para cambios de stock

Todo cambio de stock debe generar un `InventoryMovement`.

---

### 12.6 Trazabilidad mínima

Todo movimiento debe guardar:

- Producto.
- Sucursal.
- Usuario.
- Tipo.
- Cantidad.
- Stock anterior.
- Stock resultante.
- Fecha.
- Motivo.

---

### 12.7 SKU único

El SKU debe ser único para evitar duplicidad de productos dentro del catálogo.

---

### 12.8 Código de barras opcional

El código de barras puede ser nulo o vacío, ya que no todos los productos lo tendrán.

Si existe, se recomienda evitar duplicados.

---

## 13. Enumeraciones recomendadas

### UserRole

```text
admin
collaborator
```

---

### MovementType

```text
incoming
outgoing
adjustment
```

Para el MVP solo son obligatorios:

```text
incoming
outgoing
```

---

### ImportStatus

```text
pending
validated
completed
failed
```

---

### PlatformType

```text
android
ios
web
unknown
```

---

## 14. Consideraciones de persistencia

Este documento define el modelo conceptual.

La persistencia principal planificada será SQL Server detrás del backend ASP.NET Core Web API. El contrato de esquema planificado se documenta en:

```text
docs/api-contracts/sqlserver-schema.md
```

`sqlserver-schema.md` guía futuras entidades EF Core, migraciones y repositorios. No implica que SQL Server, las migraciones o el backend ya existan.

El contrato REST vigente se documenta en:

```text
docs/api-contracts/openapi.inventory-api.yaml
```

`openapi.inventory-api.yaml` describe el contrato REST que deberá implementar el backend ASP.NET Core Web API. No implica que el backend ya esté implementado.

Sin embargo, desde este modelo se adelantan las siguientes decisiones:

- Usuarios, perfiles y roles se persistirán en SQL Server a través del backend.
- Sucursales, productos, stock y movimientos se persistirán en SQL Server a través del backend.
- `notification_tokens` representará tokens FCM enviados desde Flutter y almacenados por el backend.
- `import_batches` podrá representar importaciones, si se implementa.
- Firebase se mantiene para FCM y almacenamiento opcional de imágenes, no como persistencia principal.

---

## 15. Decisiones fuera del modelo inicial

No se incluyen como parte del modelo inicial:

- Proveedores.
- Facturas.
- Órdenes de compra.
- Ventas.
- Reportes financieros.
- Transferencias complejas entre sucursales.
- Auditoría empresarial avanzada.
- Permisos granulares.
- Panel administrativo web.

Estas entidades pueden agregarse en versiones futuras si el alcance del sistema crece.

---

## 16. Criterio de validación del modelo

El modelo se considera suficiente para el MVP si permite:

- Registrar usuarios.
- Asociar usuarios con roles.
- Gestionar sucursales.
- Gestionar productos.
- Visualizar stock por sucursal.
- Registrar entradas.
- Registrar salidas.
- Validar stock suficiente.
- Mantener historial de movimientos.
- Detectar bajo stock.
- Registrar tokens de notificación.
- Soportar importación CSV si se implementa.

El modelo debe mantenerse simple, pero lo bastante claro para resolver la problemática principal del proyecto.

