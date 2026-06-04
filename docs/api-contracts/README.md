# API Contracts - Sistema de Gestión de Inventario Multiusuario

## 1. Propósito de esta carpeta

Esta carpeta contiene los contratos de datos e integración utilizados por la aplicación móvil Flutter.

El contrato principal es `openapi.inventory-api.yaml`, que define la API REST que deberá implementar el backend ASP.NET Core Web API planificado. La persistencia principal estará detrás del backend y usará SQL Server como capa de datos.

Firebase no será el backend principal ni la capa de persistencia del sistema. Se mantiene para Firebase Cloud Messaging y, si el equipo lo decide, Firebase Storage para imágenes de productos.

Los documentos se dividen en:

- Contrato REST para el backend ASP.NET Core Web API (`openapi.inventory-api.yaml`).
- Contrato de esquema SQL Server planificado para la persistencia detrás del backend (`sqlserver-schema.md`).
- Contrato de integración con la API externa de productos (`external-product-api.md`).
- Datos de prueba o mock data para desarrollo, testing y demostraciones (`mock-data.md`).

---

## 2. Decisión técnica

La dirección técnica planificada es:

```text
Flutter
→ Dio / HttpClient
→ ASP.NET Core Web API
→ SQL Server
```

El backend ASP.NET Core Web API está planificado y todavía no está implementado. La configuración de SQL Server y Docker / Docker Compose también está pendiente.

Decisiones principales:

- ASP.NET Core Web API será el backend principal.
- SQL Server será la capa principal de persistencia detrás del backend.
- Docker / Docker Compose dará soporte a la infraestructura backend, especialmente para SQL Server en desarrollo local.
- OpenAPI define el contrato de endpoints, requests, responses y seguridad.
- `sqlserver-schema.md` define el contrato de esquema SQL Server planificado.
- Firebase se mantiene únicamente para FCM y almacenamiento opcional de imágenes.

---

## 3. Documentos incluidos

### `README.md`

Describe el propósito de esta carpeta, el estado de los documentos incluidos y la relación entre contratos REST, persistencia, datos mock, API externa y servicios Firebase.

---

### `openapi.inventory-api.yaml`

Es el contrato REST principal que deberá implementar el backend ASP.NET Core Web API.

Define:

- Grupos de endpoints: Auth, Users, Branches, Products, Stock, InventoryMovements, ProductLookup, NotificationTokens e ImportBatches.
- Esquemas compartidos para entidades, DTOs y errores.
- Ejemplos de request y response.
- Esquema de seguridad `bearerAuth` (JWT), con excepciones públicas cuando aplique.

Este contrato no implica que el backend ya exista. Define la superficie que la implementación backend deberá respetar.

---

### `sqlserver-schema.md`

Define el contrato de esquema SQL Server planificado para la persistencia detrás del backend ASP.NET Core Web API.

Incluye tablas, columnas, llaves primarias, llaves foráneas, restricciones e índices sugeridos para guiar futuras entidades EF Core, migraciones y repositorios. No implica que la base de datos, las migraciones o el backend ya estén implementados.

---

### `external-product-api.md`

Define la integración con la API externa usada para autocompletar productos.

La API externa seleccionada es:

```text
Open Food Facts API
```

Uso principal:

```text
Usuario ingresa código de barras
→ App consulta API externa
→ API devuelve datos sugeridos
→ Usuario revisa y corrige
→ Producto se guarda mediante la API REST del backend
```

Open Food Facts no reemplaza el registro manual de productos ni funciona como base de datos principal.

---

### `mock-data.md`

Contiene datos de prueba y demostración.

Puede incluir:

- Usuarios demo.
- Sucursales demo.
- Productos demo.
- Stock inicial.
- Movimientos de ejemplo.
- Datos para probar importación CSV.
- Casos de bajo stock.

Este archivo se mantiene útil para desarrollo, pruebas y demos.

---

## 4. Flujo general de datos

El flujo general de la aplicación será:

```text
UI
→ ViewModel
→ Repository
→ RestApiDataSource
→ ASP.NET Core Web API
→ SQL Server
```

La UI no debe acceder directamente al backend, SQL Server, Firebase, APIs externas ni almacenamiento local. Toda comunicación debe pasar por repositorios y data sources.

Servicios complementarios:

- Open Food Facts se usa como fuente externa de búsqueda de productos.
- Firebase Cloud Messaging se usa para notificaciones push.
- Firebase Storage puede usarse para imágenes si se toma esa decisión.
- El almacenamiento local se reserva para preferencias y estado liviano.

---

## 5. Fuentes de datos del sistema

### ASP.NET Core Web API

Será la API backend principal planificada.

Se encargará de exponer endpoints REST para:

- Autenticación y perfil.
- Usuarios y roles.
- Sucursales.
- Productos.
- Stock.
- Movimientos de inventario.
- Tokens de notificación.
- Importación CSV, si se implementa.

---

### SQL Server

Será la capa principal de persistencia detrás del backend.

La aplicación Flutter no se conectará directamente a SQL Server. Toda lectura y escritura de datos de inventario deberá pasar por el backend ASP.NET Core Web API.

El contrato de esquema planificado vive en `sqlserver-schema.md`.

---

### Firebase

Firebase se mantiene para servicios específicos:

- Firebase Cloud Messaging para notificaciones push.
- Firebase Storage como opción para imágenes de productos, pendiente de decisión final.

Firebase no será el backend principal ni la persistencia principal del inventario.

---

### API externa

Open Food Facts se usa solo como apoyo para registrar productos.

Se usa para:

- Buscar producto por código de barras.
- Autocompletar datos sugeridos.
- Obtener nombre, categoría, marca o imagen cuando estén disponibles.

La API externa no guarda datos dentro del sistema. Los datos externos solo se guardan después de que el usuario los revise y confirme.

---

### Almacenamiento local

El almacenamiento local se usará de forma limitada para preferencias simples.

Puede incluir:

- Última sucursal seleccionada.
- Preferencia de tema.
- Filtros recientes.

No se promete modo offline completo en el MVP.

---

## 6. Diferencia entre backend, Firebase y API externa

Para este proyecto:

```text
ASP.NET Core Web API
→ Backend principal planificado

SQL Server
→ Persistencia principal planificada detrás del backend

Open Food Facts API
→ API externa para autocompletar productos

Firebase
→ FCM y almacenamiento opcional de imágenes
```

Esta separación permite mantener el contrato REST del producto en OpenAPI, centralizar la persistencia en SQL Server y conservar Firebase solo para servicios complementarios.

---

## 7. Relación con arquitectura

Estos contratos deben respetar las decisiones definidas en:

```text
docs/architecture/project-scope.md
docs/architecture/technical-decisions.md
docs/architecture/data-model.md
```

Especialmente:

- `Product` no contiene stock directo.
- `Stock` se maneja por combinación `productId + branchId`.
- `InventoryMovement` es la única forma de cambiar stock.
- `Branch` es una entidad obligatoria.
- La API externa no reemplaza el registro manual.
- OpenAPI es el contrato principal del backend planificado.
- SQL Server será la persistencia principal detrás del backend.
- Firebase se limita a FCM y Storage opcional.

---

## 8. Contratos no incluidos o pendientes

Los siguientes elementos están pendientes o no forman parte de esta carpeta:

- Implementación del backend ASP.NET Core Web API.
- Configuración Docker / Docker Compose.
- Flujo final de almacenamiento de imágenes si se decide gestionarlo desde backend.
- Implementación server-side para envío automático de notificaciones push.

El contrato OpenAPI ya documenta la superficie REST esperada y `sqlserver-schema.md` documenta el esquema de persistencia planificado. La implementación backend está pendiente, no excluida.

---

## 9. Criterios de calidad para los contratos

Los documentos dentro de esta carpeta deben cumplir:

- Ser claros.
- Estar alineados con el modelo de datos.
- Evitar contradicciones con el alcance del MVP.
- No presentar como implementados servicios pendientes.
- Incluir ejemplos cuando ayuden a entender el flujo.
- Mantener separación entre backend REST, SQL Server, Firebase, API externa y almacenamiento local.

---

## 10. Estado de la carpeta

Estructura esperada:

```text
docs/api-contracts/
├── README.md
├── openapi.inventory-api.yaml
├── sqlserver-schema.md
├── external-product-api.md
└── mock-data.md
```

Estado actual:

- `openapi.inventory-api.yaml` se mantiene como contrato REST principal.
- `sqlserver-schema.md` se mantiene como contrato de esquema SQL Server planificado.
- `external-product-api.md` se mantiene como contrato de la API externa.
- `mock-data.md` se mantiene para desarrollo, pruebas y demos.

---

## 11. Cobertura de documentación requerida

La documentación de contratos cubre las piezas necesarias para describir cómo la aplicación se integra con sus fuentes de datos.

| Pieza requerida | Archivo | Detalle |
|---|---|---|
| Endpoints | `openapi.inventory-api.yaml` | Contrato REST principal para el backend ASP.NET Core Web API planificado. |
| Contratos | `openapi.inventory-api.yaml` y `sqlserver-schema.md` | OpenAPI define la API; `sqlserver-schema.md` define el esquema SQL Server planificado. |
| Requests / responses | `openapi.inventory-api.yaml` y `external-product-api.md` | Ejemplos de solicitud y respuesta para el contrato REST de la aplicación y para Open Food Facts. |
| Mock data | `mock-data.md` | Datos de demostración para usuarios, sucursales, productos, stock, movimientos, importación CSV y casos de prueba. |

Notas de alcance:

- `openapi.inventory-api.yaml` describe la superficie REST que deberá implementar el backend ASP.NET Core Web API.
- El contrato OpenAPI no implica que el backend ya esté implementado.
- `sqlserver-schema.md` define el esquema de persistencia planificado y no implica que SQL Server o migraciones ya existan.
- Open Food Facts es la API externa HTTP para búsqueda de productos; ese contrato se mantiene en `external-product-api.md`.
- Los ejemplos de `mock-data.md` se utilizan en desarrollo, pruebas y demos del producto.
