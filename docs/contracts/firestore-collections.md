# Firestore Collections — Sistema de Gestión de Inventario Multiusuario

## 1. Propósito del documento

Este documento define los contratos de datos para Cloud Firestore dentro del proyecto de inventario multiusuario.

Aunque la carpeta se llama `api-contracts`, este proyecto no usará una API REST propia como backend principal. Firebase será el backend principal, por lo que los contratos documentan:

- Colecciones de Firestore.
- Estructura de documentos.
- Campos requeridos.
- Relaciones lógicas.
- Operaciones esperadas desde los repositorios.
- Consultas principales.
- Reglas de validación relevantes.

Este documento se basa en:

```text
docs/architecture/project-scope.md
docs/architecture/technical-decisions.md
docs/architecture/data-model.md
```

---

## 2. Decisión general

La aplicación Flutter se comunicará con Firestore mediante los SDKs de Firebase.

No existirán endpoints propios como:

```text
POST /auth/login
GET /products
POST /inventory/movements
```

En su lugar, la app usará repositorios que accederán a las colecciones de Firestore.

Flujo esperado:

```text
UI
→ ViewModel
→ Repository
→ Firestore Data Source
→ Cloud Firestore
```

La UI no debe consultar Firestore directamente.

---

## 3. Convenciones generales

### 3.1 Identificadores

Los documentos pueden usar IDs generados automáticamente por Firestore, excepto cuando convenga usar un ID compuesto.

Caso recomendado para `stocks`:

```text
{productId}_{branchId}
```

Ejemplo:

```text
product_001_branch_001
```

Esto ayuda a garantizar que exista un solo registro de stock por producto y sucursal.

---

### 3.2 Fechas

Las fechas se almacenarán como `timestamp`.

Campos comunes:

```text
createdAt
updatedAt
lastMovementAt
```

---

### 3.3 Soft delete

Cuando aplique, no se recomienda eliminar físicamente documentos importantes.

En su lugar, se usará:

```text
isActive: false
```

Esto aplica principalmente para:

- `products`
- `branches`
- `users`

El historial de movimientos no debe eliminarse físicamente en el MVP.

---

### 3.4 Nombres de campos

Los campos se documentan en `camelCase`, alineados con Dart y con los modelos de la app.

Ejemplos:

```text
availableQuantity
createdAt
branchIds
imageUrl
```

---

## 4. Colecciones principales

Colecciones definidas para el MVP:

```text
users
branches
products
stocks
inventory_movements
notification_tokens
import_batches
```

`import_batches` es opcional para el MVP y se usará si se implementa importación CSV con historial.

---

# 5. Collection: users

## 5.1 Propósito

Guarda información del perfil del usuario autenticado.

Firebase Auth maneja la autenticación, pero Firestore guarda datos adicionales como nombre, rol y sucursales asociadas.

## 5.2 Ruta

```text
users/{userId}
```

El `userId` debe corresponder al UID de Firebase Auth.

## 5.3 Campos

| Campo | Tipo | Requerido | Descripción |
|---|---|---:|---|
| `name` | string | Sí | Nombre visible del usuario. |
| `email` | string | Sí | Correo del usuario. |
| `role` | string | Sí | `admin` o `collaborator`. |
| `branchIds` | list<string> | No | Sucursales asociadas al usuario. |
| `isActive` | bool | Sí | Indica si el usuario está activo. |
| `createdAt` | timestamp | Sí | Fecha de creación. |
| `updatedAt` | timestamp | No | Fecha de actualización. |

## 5.4 Ejemplo

```json
{
  "name": "Ana Gómez",
  "email": "ana@example.com",
  "role": "admin",
  "branchIds": ["branch_001", "branch_002"],
  "isActive": true,
  "createdAt": "2026-06-02T20:00:00Z",
  "updatedAt": "2026-06-02T20:00:00Z"
}
```

## 5.5 Operaciones esperadas

| Operación | Descripción |
|---|---|
| Create user profile | Crear documento del usuario después del registro. |
| Get current user | Obtener perfil del usuario autenticado. |
| Update user profile | Actualizar nombre o datos básicos. |
| Update user role | Actualizar rol, solo permitido para usuarios administradores. |

## 5.6 Reglas

- Un usuario autenticado solo puede leer su propio perfil, salvo que sea administrador.
- El rol define permisos funcionales dentro de la app.
- Para el MVP, el rol se almacena en Firestore, no en custom claims.

---

# 6. Collection: branches

## 6.1 Propósito

Guarda las sucursales de la cadena de tiendas.

La sucursal es obligatoria para stock y movimientos.

## 6.2 Ruta

```text
branches/{branchId}
```

## 6.3 Campos

| Campo | Tipo | Requerido | Descripción |
|---|---|---:|---|
| `name` | string | Sí | Nombre de la sucursal. |
| `address` | string | No | Dirección o descripción. |
| `isActive` | bool | Sí | Indica si está activa. |
| `createdAt` | timestamp | Sí | Fecha de creación. |
| `updatedAt` | timestamp | No | Fecha de actualización. |

## 6.4 Ejemplo

```json
{
  "name": "Sucursal Central",
  "address": "Centro",
  "isActive": true,
  "createdAt": "2026-06-02T20:00:00Z",
  "updatedAt": "2026-06-02T20:00:00Z"
}
```

## 6.5 Operaciones esperadas

| Operación | Descripción |
|---|---|
| List branches | Listar sucursales activas. |
| Get branch by ID | Obtener una sucursal específica. |
| Create branch | Crear sucursal. |
| Update branch | Actualizar datos de sucursal. |
| Deactivate branch | Cambiar `isActive` a `false`. |

## 6.6 Reglas

- `branchId` es obligatorio en `stocks` e `inventory_movements`.
- Una sucursal inactiva no debería usarse para nuevos movimientos.
- El MVP puede iniciar con sucursales precargadas.

---

# 7. Collection: products

## 7.1 Propósito

Guarda el catálogo general de productos.

El producto no contiene stock directo. La cantidad disponible se guarda en `stocks`.

## 7.2 Ruta

```text
products/{productId}
```

## 7.3 Campos

| Campo | Tipo | Requerido | Descripción |
|---|---|---:|---|
| `name` | string | Sí | Nombre del producto. |
| `sku` | string | Sí | Código interno único. |
| `barcode` | string | No | Código de barras, si aplica. |
| `category` | string | Sí | Categoría del producto. |
| `description` | string | No | Descripción. |
| `imageUrl` | string | No | Imagen del producto. |
| `minStock` | number | Sí | Stock mínimo recomendado. |
| `isActive` | bool | Sí | Estado del producto. |
| `createdAt` | timestamp | Sí | Fecha de creación. |
| `updatedAt` | timestamp | No | Fecha de actualización. |

## 7.4 Ejemplo

```json
{
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

## 7.5 Operaciones esperadas

| Operación | Descripción |
|---|---|
| List products | Listar productos activos. |
| Search products | Buscar por nombre, SKU o código de barras. |
| Get product by ID | Obtener detalle de producto. |
| Create product | Crear producto manualmente o desde API externa. |
| Update product | Editar datos del producto. |
| Deactivate product | Cambiar `isActive` a `false`. |

## 7.6 Reglas

- `name` y `sku` son obligatorios.
- `sku` debe ser único.
- `barcode` es opcional.
- `minStock` debe ser mayor o igual a cero.
- Un producto inactivo no debe usarse para nuevos movimientos.
- Un producto inactivo puede seguir apareciendo en historial.

## 7.7 Formas de creación

Los productos pueden crearse por:

1. Registro manual.
2. Autocompletado desde API externa.
3. Importación desde CSV.

Los datos externos siempre deben ser revisados por el usuario antes de guardarse.

---

# 8. Collection: stocks

## 8.1 Propósito

Guarda el stock disponible de cada producto por sucursal.

Esta colección permite que un mismo producto tenga cantidades distintas en diferentes sucursales.

## 8.2 Ruta

```text
stocks/{stockId}
```

ID recomendado:

```text
{productId}_{branchId}
```

Ejemplo:

```text
product_001_branch_001
```

## 8.3 Campos

| Campo | Tipo | Requerido | Descripción |
|---|---|---:|---|
| `productId` | string | Sí | Producto asociado. |
| `branchId` | string | Sí | Sucursal asociada. |
| `availableQuantity` | number | Sí | Cantidad disponible. |
| `lastMovementId` | string | No | Último movimiento asociado. |
| `lastMovementAt` | timestamp | No | Fecha del último movimiento. |
| `updatedAt` | timestamp | Sí | Fecha de actualización. |

## 8.4 Ejemplo

```json
{
  "productId": "product_001",
  "branchId": "branch_001",
  "availableQuantity": 40,
  "lastMovementId": "movement_001",
  "lastMovementAt": "2026-06-02T20:15:00Z",
  "updatedAt": "2026-06-02T20:15:00Z"
}
```

## 8.5 Operaciones esperadas

| Operación | Descripción |
|---|---|
| Get stock by product and branch | Obtener stock de un producto en una sucursal. |
| List stock by branch | Ver inventario de una sucursal. |
| List low stock | Consultar productos con stock bajo. |
| Update stock through movement | Actualizar stock únicamente mediante transacción de movimiento. |

## 8.6 Reglas

- Debe existir un único stock por `productId + branchId`.
- `availableQuantity` no puede ser negativo.
- El stock no se actualiza directamente desde la UI.
- El stock se actualiza mediante transacciones al registrar movimientos.
- Bajo stock ocurre cuando `availableQuantity <= product.minStock`.

---

# 9. Collection: inventory_movements

## 9.1 Propósito

Guarda el historial de entradas, salidas y ajustes de inventario.

Esta colección es clave para la trazabilidad.

## 9.2 Ruta

```text
inventory_movements/{movementId}
```

## 9.3 Campos

| Campo | Tipo | Requerido | Descripción |
|---|---|---:|---|
| `productId` | string | Sí | Producto afectado. |
| `branchId` | string | Sí | Sucursal afectada. |
| `userId` | string | Sí | Usuario responsable. |
| `type` | string | Sí | `incoming`, `outgoing` o `adjustment`. |
| `quantity` | number | Sí | Cantidad del movimiento. |
| `previousStock` | number | Sí | Stock antes del movimiento. |
| `resultingStock` | number | Sí | Stock después del movimiento. |
| `reason` | string | Sí | Motivo del movimiento. |
| `notes` | string | No | Observaciones. |
| `createdAt` | timestamp | Sí | Fecha de creación. |

## 9.4 Ejemplo

```json
{
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

## 9.5 Operaciones esperadas

| Operación | Descripción |
|---|---|
| Register incoming movement | Registrar entrada. |
| Register outgoing movement | Registrar salida. |
| List movements | Listar historial. |
| Filter movements | Filtrar por producto, sucursal, tipo, usuario o fecha. |
| Get movement detail | Consultar detalle. |

## 9.6 Reglas

- `quantity` debe ser mayor a cero.
- `productId`, `branchId` y `userId` son obligatorios.
- En salida, `quantity <= availableQuantity`.
- El movimiento debe registrar `previousStock` y `resultingStock`.
- Los movimientos no deben eliminarse físicamente en el MVP.

---

# 10. Collection: notification_tokens

## 10.1 Propósito

Guarda tokens FCM de dispositivos para notificaciones push.

## 10.2 Ruta

```text
notification_tokens/{tokenId}
```

## 10.3 Campos

| Campo | Tipo | Requerido | Descripción |
|---|---|---:|---|
| `userId` | string | Sí | Usuario asociado. |
| `token` | string | Sí | Token FCM. |
| `platform` | string | Sí | `android`, `ios`, `web` o `unknown`. |
| `createdAt` | timestamp | Sí | Fecha de creación. |
| `updatedAt` | timestamp | No | Fecha de actualización. |

## 10.4 Ejemplo

```json
{
  "userId": "user_001",
  "token": "fcm_device_token_example",
  "platform": "android",
  "createdAt": "2026-06-02T20:00:00Z",
  "updatedAt": "2026-06-02T20:00:00Z"
}
```

## 10.5 Operaciones esperadas

| Operación | Descripción |
|---|---|
| Save device token | Guardar token del dispositivo. |
| Update device token | Actualizar token si cambia. |
| Delete device token | Eliminar token si el usuario cierra sesión o si se invalida. |

## 10.6 Reglas

- Un usuario puede tener varios tokens.
- El MVP debe poder registrar el token FCM.
- El envío automático de push por bajo stock queda como mejora futura.

---

# 11. Collection: import_batches

## 11.1 Propósito

Guarda información sobre procesos de importación de productos desde CSV.

Esta colección es complementaria. Solo se usará si el equipo implementa importación CSV con historial.

## 11.2 Ruta

```text
import_batches/{importBatchId}
```

## 11.3 Campos

| Campo | Tipo | Requerido | Descripción |
|---|---|---:|---|
| `fileName` | string | Sí | Nombre del archivo importado. |
| `importedBy` | string | Sí | Usuario que realiza la importación. |
| `status` | string | Sí | `pending`, `validated`, `completed` o `failed`. |
| `totalRows` | number | Sí | Total de filas leídas. |
| `validRows` | number | Sí | Total de filas válidas. |
| `invalidRows` | number | Sí | Total de filas inválidas. |
| `errors` | list<object> | No | Errores detectados. |
| `createdAt` | timestamp | Sí | Fecha de creación. |
| `completedAt` | timestamp | No | Fecha de finalización. |

## 11.4 Ejemplo

```json
{
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

## 11.5 Reglas

- La importación debe validarse antes de guardar.
- No deben guardarse productos inválidos sin revisión.
- Si se crea stock inicial, se recomienda crear movimientos `incoming` con motivo `Initial import`.
- Importación Excel `.xlsx` avanzada queda fuera del MVP.

---

# 12. Transacción para registrar movimiento

## 12.1 Propósito

Registrar movimientos y actualizar stock de forma consistente.

## 12.2 Flujo de transacción

```text
1. Recibir productId, branchId, userId, type, quantity y reason.
2. Leer producto.
3. Validar que el producto exista y esté activo.
4. Leer sucursal.
5. Validar que la sucursal exista y esté activa.
6. Leer stock por productId + branchId.
7. Calcular nuevo stock.
8. Si type = outgoing, validar stock suficiente.
9. Actualizar stocks/{stockId}.
10. Crear inventory_movements/{movementId}.
11. Devolver resultado al ViewModel.
```

## 12.3 Reglas de cálculo

### Entrada

```text
resultingStock = previousStock + quantity
```

### Salida

```text
if quantity > previousStock:
    reject operation

resultingStock = previousStock - quantity
```

### Ajuste

```text
resultingStock = quantity
```

El ajuste queda como funcionalidad opcional para el MVP.

---

# 13. Consultas principales

## 13.1 Productos activos

```text
products
where isActive == true
orderBy name
```

## 13.2 Productos por categoría

```text
products
where isActive == true
where category == selectedCategory
orderBy name
```

## 13.3 Stock por sucursal

```text
stocks
where branchId == selectedBranchId
orderBy updatedAt desc
```

## 13.4 Stock de un producto en una sucursal

```text
stocks/{productId}_{branchId}
```

## 13.5 Movimientos por sucursal

```text
inventory_movements
where branchId == selectedBranchId
orderBy createdAt desc
```

## 13.6 Movimientos por producto

```text
inventory_movements
where productId == selectedProductId
orderBy createdAt desc
```

## 13.7 Movimientos por tipo

```text
inventory_movements
where type == selectedType
orderBy createdAt desc
```

## 13.8 Movimientos por rango de fecha

```text
inventory_movements
where createdAt >= startDate
where createdAt <= endDate
orderBy createdAt desc
```

## 13.9 Tokens por usuario

```text
notification_tokens
where userId == currentUserId
```

---

# 14. Índices recomendados

Firestore puede solicitar índices compuestos cuando se combinen filtros y ordenamientos.

Índices recomendados:

| Colección | Campos |
|---|---|
| `products` | `isActive`, `name` |
| `products` | `isActive`, `category`, `name` |
| `stocks` | `branchId`, `updatedAt` |
| `stocks` | `productId`, `branchId` |
| `inventory_movements` | `branchId`, `createdAt` |
| `inventory_movements` | `productId`, `createdAt` |
| `inventory_movements` | `type`, `createdAt` |
| `inventory_movements` | `branchId`, `type`, `createdAt` |
| `inventory_movements` | `branchId`, `productId`, `createdAt` |

---

# 15. Reglas de seguridad esperadas

Las reglas finales de Firestore se definirán durante implementación, pero conceptualmente deben cumplir:

- Solo usuarios autenticados pueden acceder al sistema.
- Un usuario solo puede leer datos permitidos por su rol.
- Solo administradores pueden gestionar productos y sucursales de forma completa.
- Colaboradores pueden registrar movimientos permitidos.
- Nadie debe escribir stock directamente desde una pantalla sin pasar por el flujo de movimiento.
- Los campos críticos no deben aceptarse sin validación en la app.

Limitación:

La validación cuantitativa completa de stock es más segura en un backend o Cloud Function. Para el MVP, se manejará mediante Firestore transaction desde la app y reglas de seguridad como defensa adicional.

---

# 16. Relación con API externa

La API externa de productos no se documenta en este archivo.

Su contrato se documentará en:

```text
docs/contracts/external-product-api.md
```

Relación con Firestore:

```text
API externa
→ devuelve sugerencias
→ usuario revisa
→ ProductRepository guarda producto en Firestore
```

Los datos externos no se guardan automáticamente sin confirmación del usuario.

---

# 17. Relación con Firebase Storage

Las imágenes no se guardan como archivo dentro de Firestore.

Firestore solo guarda la URL:

```text
products/{productId}.imageUrl
```

El archivo real vive en Firebase Storage.

Ruta sugerida:

```text
product-images/{productId}/{fileName}
```

---

# 18. Relación con almacenamiento local

Firestore será la fuente principal de datos.

El almacenamiento local se usará para preferencias simples como:

- Última sucursal seleccionada.
- Filtros recientes.
- Preferencia de tema.

No se promete modo offline completo en el MVP.

---

# 19. Criterios de aceptación del contrato de datos

Este contrato se considera correcto si permite:

- Crear usuarios.
- Asociar roles.
- Crear sucursales.
- Crear productos.
- Consultar productos activos.
- Consultar stock por sucursal.
- Registrar entradas.
- Registrar salidas.
- Impedir salidas mayores al stock disponible.
- Crear historial de movimientos.
- Filtrar historial.
- Detectar bajo stock.
- Registrar tokens FCM.
- Soportar importación CSV si se implementa.

---

# 20. Estado del documento

Este documento debe actualizarse si cambian:

- Las entidades del dominio.
- Las colecciones de Firestore.
- Los campos requeridos.
- Las reglas de stock.
- El enfoque de notificaciones.
- La decisión sobre importación CSV.
- La decisión de usar o no Cloud Functions.

