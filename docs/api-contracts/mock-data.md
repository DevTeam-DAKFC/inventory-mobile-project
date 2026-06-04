# Mock Data - Sistema de Gestión de Inventario Multiusuario

## 1. Propósito del documento

Este documento define datos de prueba para desarrollo, testing y demos del producto.

El objetivo es que el equipo utilice una base común de usuarios, sucursales, productos, stock y movimientos al momento de probar la aplicación y demostrar sus funcionalidades.

Este archivo complementa:

```text
docs/architecture/project-scope.md
docs/architecture/data-model.md
docs/api-contracts/openapi.inventory-api.yaml
```

`docs/api-contracts/firestore-collections.md` documenta un enfoque anterior basado en Firestore. Ya no es el contrato activo de persistencia y queda pendiente de reemplazo o archivo cuando se documente el esquema SQL Server.

---

## 2. Uso esperado

Estos datos pueden utilizarse para:

- Alimentar `MockDataSource` durante desarrollo, pruebas y demos.
- Sembrar datos de prueba para SQL Server cuando el backend ASP.NET Core Web API esté implementado.
- Apoyar ejemplos del contrato `openapi.inventory-api.yaml`.
- Probar pantallas con información realista.
- Preparar capturas para documentación.
- Ejecutar casos de prueba manuales.

Los datos son ficticios y pueden ajustarse según las necesidades del equipo.

---

## 3. Usuarios demo

### Admin demo

```json
{
  "id": "user_admin_001",
  "name": "María Rodríguez",
  "email": "admin@inventario-demo.com",
  "role": "admin",
  "branchIds": ["branch_central", "branch_north"],
  "isActive": true,
  "createdAt": "2026-06-02T20:00:00Z",
  "updatedAt": "2026-06-02T20:00:00Z"
}
```

### Collaborator demo

```json
{
  "id": "user_collaborator_001",
  "name": "Carlos Pérez",
  "email": "colaborador@inventario-demo.com",
  "role": "collaborator",
  "branchIds": ["branch_central"],
  "isActive": true,
  "createdAt": "2026-06-02T20:00:00Z",
  "updatedAt": "2026-06-02T20:00:00Z"
}
```

---

## 4. Sucursales demo

### Sucursal Central

```json
{
  "id": "branch_central",
  "name": "Sucursal Central",
  "address": "Centro de la ciudad",
  "isActive": true,
  "createdAt": "2026-06-02T20:00:00Z",
  "updatedAt": "2026-06-02T20:00:00Z"
}
```

### Sucursal Norte

```json
{
  "id": "branch_north",
  "name": "Sucursal Norte",
  "address": "Zona norte",
  "isActive": true,
  "createdAt": "2026-06-02T20:00:00Z",
  "updatedAt": "2026-06-02T20:00:00Z"
}
```

---

## 5. Productos demo

### Arroz 80% 1kg

```json
{
  "id": "product_rice_001",
  "name": "Arroz 80% 1kg",
  "sku": "ARR-001",
  "barcode": "7441000000012",
  "category": "Abarrotes",
  "description": "Bolsa de arroz 80% de 1 kilogramo.",
  "imageUrl": "https://example.com/images/arroz-1kg.jpg",
  "minStock": 10,
  "isActive": true,
  "createdAt": "2026-06-02T20:00:00Z",
  "updatedAt": "2026-06-02T20:00:00Z"
}
```

### Frijoles negros 900g

```json
{
  "id": "product_beans_001",
  "name": "Frijoles negros 900g",
  "sku": "FRJ-001",
  "barcode": "7441000000029",
  "category": "Abarrotes",
  "description": "Bolsa de frijoles negros de 900 gramos.",
  "imageUrl": "https://example.com/images/frijoles-negros.jpg",
  "minStock": 8,
  "isActive": true,
  "createdAt": "2026-06-02T20:00:00Z",
  "updatedAt": "2026-06-02T20:00:00Z"
}
```

### Café molido 500g

```json
{
  "id": "product_coffee_001",
  "name": "Café molido 500g",
  "sku": "CAF-001",
  "barcode": "7441000000036",
  "category": "Bebidas",
  "description": "Café molido de 500 gramos.",
  "imageUrl": "https://example.com/images/cafe-molido.jpg",
  "minStock": 6,
  "isActive": true,
  "createdAt": "2026-06-02T20:00:00Z",
  "updatedAt": "2026-06-02T20:00:00Z"
}
```

### Aceite vegetal 1L

```json
{
  "id": "product_oil_001",
  "name": "Aceite vegetal 1L",
  "sku": "ACE-001",
  "barcode": "7441000000043",
  "category": "Abarrotes",
  "description": "Botella de aceite vegetal de 1 litro.",
  "imageUrl": "https://example.com/images/aceite-1l.jpg",
  "minStock": 12,
  "isActive": true,
  "createdAt": "2026-06-02T20:00:00Z",
  "updatedAt": "2026-06-02T20:00:00Z"
}
```

### Producto inactivo demo

```json
{
  "id": "product_inactive_001",
  "name": "Producto descontinuado",
  "sku": "DISC-001",
  "barcode": "",
  "category": "General",
  "description": "Producto usado para validar comportamiento de productos inactivos.",
  "imageUrl": "",
  "minStock": 5,
  "isActive": false,
  "createdAt": "2026-06-02T20:00:00Z",
  "updatedAt": "2026-06-02T20:00:00Z"
}
```

---

## 6. Stock demo

### Arroz en Sucursal Central

```json
{
  "id": "product_rice_001_branch_central",
  "productId": "product_rice_001",
  "branchId": "branch_central",
  "availableQuantity": 40,
  "lastMovementId": "movement_001",
  "lastMovementAt": "2026-06-02T20:15:00Z",
  "updatedAt": "2026-06-02T20:15:00Z"
}
```

### Arroz en Sucursal Norte

```json
{
  "id": "product_rice_001_branch_north",
  "productId": "product_rice_001",
  "branchId": "branch_north",
  "availableQuantity": 6,
  "lastMovementId": "movement_002",
  "lastMovementAt": "2026-06-02T20:20:00Z",
  "updatedAt": "2026-06-02T20:20:00Z"
}
```

### Frijoles en Sucursal Central

```json
{
  "id": "product_beans_001_branch_central",
  "productId": "product_beans_001",
  "branchId": "branch_central",
  "availableQuantity": 25,
  "lastMovementId": "movement_003",
  "lastMovementAt": "2026-06-02T20:25:00Z",
  "updatedAt": "2026-06-02T20:25:00Z"
}
```

### Café en Sucursal Central

```json
{
  "id": "product_coffee_001_branch_central",
  "productId": "product_coffee_001",
  "branchId": "branch_central",
  "availableQuantity": 4,
  "lastMovementId": "movement_004",
  "lastMovementAt": "2026-06-02T20:30:00Z",
  "updatedAt": "2026-06-02T20:30:00Z"
}
```

### Aceite en Sucursal Norte

```json
{
  "id": "product_oil_001_branch_north",
  "productId": "product_oil_001",
  "branchId": "branch_north",
  "availableQuantity": 18,
  "lastMovementId": "movement_005",
  "lastMovementAt": "2026-06-02T20:35:00Z",
  "updatedAt": "2026-06-02T20:35:00Z"
}
```

---

## 7. Movimientos demo

### Entrada inicial de arroz

```json
{
  "id": "movement_001",
  "productId": "product_rice_001",
  "branchId": "branch_central",
  "userId": "user_admin_001",
  "type": "incoming",
  "quantity": 40,
  "previousStock": 0,
  "resultingStock": 40,
  "reason": "Initial import",
  "notes": "Carga inicial de inventario.",
  "createdAt": "2026-06-02T20:15:00Z"
}
```

### Salida de arroz en Sucursal Norte

```json
{
  "id": "movement_002",
  "productId": "product_rice_001",
  "branchId": "branch_north",
  "userId": "user_collaborator_001",
  "type": "outgoing",
  "quantity": 4,
  "previousStock": 10,
  "resultingStock": 6,
  "reason": "Sale",
  "notes": "Salida por venta registrada.",
  "createdAt": "2026-06-02T20:20:00Z"
}
```

### Entrada de frijoles

```json
{
  "id": "movement_003",
  "productId": "product_beans_001",
  "branchId": "branch_central",
  "userId": "user_admin_001",
  "type": "incoming",
  "quantity": 25,
  "previousStock": 0,
  "resultingStock": 25,
  "reason": "Initial import",
  "notes": "Carga inicial de inventario.",
  "createdAt": "2026-06-02T20:25:00Z"
}
```

### Salida de café con bajo stock

```json
{
  "id": "movement_004",
  "productId": "product_coffee_001",
  "branchId": "branch_central",
  "userId": "user_collaborator_001",
  "type": "outgoing",
  "quantity": 3,
  "previousStock": 7,
  "resultingStock": 4,
  "reason": "Sale",
  "notes": "Movimiento deja el producto bajo stock mínimo.",
  "createdAt": "2026-06-02T20:30:00Z"
}
```

### Entrada de aceite

```json
{
  "id": "movement_005",
  "productId": "product_oil_001",
  "branchId": "branch_north",
  "userId": "user_admin_001",
  "type": "incoming",
  "quantity": 18,
  "previousStock": 0,
  "resultingStock": 18,
  "reason": "Initial import",
  "notes": "Carga inicial de inventario.",
  "createdAt": "2026-06-02T20:35:00Z"
}
```

---

## 8. Tokens de notificación demo

```json
{
  "id": "token_001",
  "userId": "user_admin_001",
  "token": "fcm_device_token_admin_demo",
  "platform": "android",
  "createdAt": "2026-06-02T20:00:00Z",
  "updatedAt": "2026-06-02T20:00:00Z"
}
```

```json
{
  "id": "token_002",
  "userId": "user_collaborator_001",
  "token": "fcm_device_token_collaborator_demo",
  "platform": "android",
  "createdAt": "2026-06-02T20:00:00Z",
  "updatedAt": "2026-06-02T20:00:00Z"
}
```

---

## 9. Importación CSV demo

### Archivo sugerido

```text
inventory_initial.csv
```

### Columnas esperadas

```csv
name,sku,barcode,category,description,minStock,branchName,initialStock
```

### Ejemplo válido

```csv
name,sku,barcode,category,description,minStock,branchName,initialStock
Arroz 80% 1kg,ARR-001,7441000000012,Abarrotes,Bolsa de arroz 1kg,10,Sucursal Central,40
Frijoles negros 900g,FRJ-001,7441000000029,Abarrotes,Bolsa de frijoles 900g,8,Sucursal Central,25
Café molido 500g,CAF-001,7441000000036,Bebidas,Café molido 500g,6,Sucursal Central,7
Aceite vegetal 1L,ACE-001,7441000000043,Abarrotes,Aceite vegetal 1L,12,Sucursal Norte,18
```

### Ejemplo con errores

```csv
name,sku,barcode,category,description,minStock,branchName,initialStock
,ARR-002,7441000000050,Abarrotes,Producto sin nombre,10,Sucursal Central,20
Azúcar 1kg,,7441000000067,Abarrotes,Producto sin SKU,10,Sucursal Central,15
Sal 500g,SAL-001,7441000000074,Abarrotes,Stock negativo,5,Sucursal Central,-3
Producto X,PROD-X,7441000000081,General,Sucursal inexistente,5,Sucursal Fantasma,10
```

---

## 10. ImportBatch demo

```json
{
  "id": "import_001",
  "fileName": "inventory_initial.csv",
  "importedBy": "user_admin_001",
  "status": "completed",
  "totalRows": 4,
  "validRows": 4,
  "invalidRows": 0,
  "errors": [],
  "createdAt": "2026-06-02T20:00:00Z",
  "completedAt": "2026-06-02T20:05:00Z"
}
```

### ImportBatch con errores

```json
{
  "id": "import_002",
  "fileName": "inventory_with_errors.csv",
  "importedBy": "user_admin_001",
  "status": "failed",
  "totalRows": 4,
  "validRows": 0,
  "invalidRows": 4,
  "errors": [
    {
      "row": 1,
      "field": "name",
      "message": "El nombre es obligatorio"
    },
    {
      "row": 2,
      "field": "sku",
      "message": "El SKU es obligatorio"
    },
    {
      "row": 3,
      "field": "initialStock",
      "message": "El stock inicial no puede ser negativo"
    },
    {
      "row": 4,
      "field": "branchName",
      "message": "La sucursal no existe"
    }
  ],
  "createdAt": "2026-06-02T20:10:00Z",
  "completedAt": "2026-06-02T20:12:00Z"
}
```

---

## 11. Datos para probar bajo stock

Productos bajo stock esperados:

| Producto | Sucursal | Stock actual | Stock mínimo | Resultado |
|---|---|---:|---:|---|
| Arroz 80% 1kg | Sucursal Norte | 6 | 10 | Bajo stock |
| Café molido 500g | Sucursal Central | 4 | 6 | Bajo stock |

Estos datos pueden usarse para demostrar:

- Alerta visual de bajo stock.
- Notificación local.
- Filtro de productos bajo stock.
- Dashboard o resumen de inventario.

---

## 12. Datos para probar salida con stock insuficiente

Caso sugerido:

```json
{
  "productId": "product_coffee_001",
  "branchId": "branch_central",
  "type": "outgoing",
  "quantity": 10,
  "availableQuantity": 4
}
```

Resultado esperado:

```text
La salida no debe registrarse.
El stock debe mantenerse en 4.
La app debe mostrar un mensaje de error claro.
No debe crearse InventoryMovement.
```

Mensaje sugerido:

```text
No hay stock suficiente para registrar esta salida.
```

---

## 13. Datos para probar búsqueda y filtros

### Búsqueda por nombre

```text
arroz
```

Resultado esperado:

```text
Arroz 80% 1kg
```

### Búsqueda por SKU

```text
CAF-001
```

Resultado esperado:

```text
Café molido 500g
```

### Filtro por categoría

```text
Abarrotes
```

Resultado esperado:

```text
Arroz 80% 1kg
Frijoles negros 900g
Aceite vegetal 1L
```

### Filtro por sucursal

```text
Sucursal Central
```

Resultado esperado:

```text
Stock y movimientos asociados a branch_central
```

### Filtro por tipo de movimiento

```text
outgoing
```

Resultado esperado:

```text
movement_002
movement_004
```

---

## 14. Datos para probar API externa

Código de barras sugerido para prueba con Open Food Facts:

```text
3017624010701
```

Resultado esperado:

```text
La app intenta obtener datos sugeridos del producto.
Si la API responde correctamente, muestra nombre, categoría, marca o imagen cuando estén disponibles.
El usuario puede editar los datos antes de guardar.
```

Caso no encontrado:

```text
0000000000000
```

Resultado esperado:

```text
La app informa que no encontró el producto y permite registro manual.
```

---

## 15. Criterios de uso

Estos datos no son definitivos. Se pueden adaptar, pero deben mantener coherencia con las reglas del modelo:

- `Stock` siempre usa `productId + branchId`.
- `InventoryMovement` siempre registra usuario, producto y sucursal.
- Una salida no puede dejar stock negativo.
- Productos inactivos no deben usarse en nuevos movimientos.
- El registro manual debe funcionar aunque falle la API externa.
- La importación CSV debe validar datos antes de guardar.

---

## 16. Estado del documento

Este archivo debe actualizarse cuando cambien:

- Los datos de prueba oficiales.
- Las sucursales demo.
- Los productos demo.
- Las reglas de importación.
- Los flujos que se mostrarán en demos.
- Los escenarios de prueba del producto.

