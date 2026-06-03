# Layers Explanation - Sistema de Gestión de Inventario Multiusuario

## 1. Propósito del documento

Este documento explica las capas internas de la aplicación Flutter y la responsabilidad de cada una.

Su objetivo es que el equipo mantenga una estructura consistente durante el desarrollo, evitando que la lógica de negocio, la UI, Firebase, la API externa y el almacenamiento local queden mezclados.

Este documento complementa:

```text
docs/architecture/project-scope.md
docs/architecture/technical-decisions.md
docs/architecture/system-architecture.md
docs/architecture/data-model.md
docs/architecture/navigation-map.md
```

---

## 2. Principio base

La aplicación debe mantener separación clara de responsabilidades.

El flujo general será:

```text
UI
→ ViewModel
→ Repository
→ Data Source
→ Firebase / API externa / almacenamiento local
```

Regla principal:

```text
La UI no debe acceder directamente a Firebase, Firestore, Firebase Storage, FCM, Dio ni almacenamiento local.
```

---

## 3. Estructura general de capas

La app usará una estructura `layer-first` simplificada:

```text
lib/
├── app/
├── core/
├── data/
├── domain/
├── navigation/
├── notifications/
└── ui/
```

Esta estructura permite explicar claramente dónde vive cada responsabilidad.

---

## 4. app/

## 4.1 Propósito

La capa `app/` contiene la configuración inicial de la aplicación.

## 4.2 Responsabilidades

- Inicializar Firebase.
- Configurar providers globales.
- Configurar tema visual.
- Configurar navegación principal.
- Exponer el widget raíz de la aplicación.

## 4.3 Archivos sugeridos

```text
app/
├── app.dart
├── bootstrap.dart
└── theme.dart
```

## 4.4 Qué sí debe contener

- Configuración global.
- Inicialización de servicios.
- Configuración de `MaterialApp`.
- Configuración del router.
- Configuración del tema.

## 4.5 Qué no debe contener

- Lógica de negocio.
- Lógica de productos.
- Lógica de movimientos.
- Consultas directas a Firestore.
- Código específico de pantallas complejas.

---

## 5. core/

## 5.1 Propósito

La capa `core/` contiene elementos compartidos por toda la aplicación.

Debe incluir utilidades, validadores, errores, resultados, widgets reutilizables y helpers comunes.

## 5.2 Responsabilidades

- Definir errores comunes.
- Definir resultado estándar de operaciones.
- Centralizar validaciones reutilizables.
- Incluir widgets genéricos.
- Manejar preferencias locales simples.
- Incluir constantes globales.

## 5.3 Estructura sugerida

```text
core/
├── constants/
├── errors/
├── result/
├── storage/
├── validation/
├── utils/
└── widgets/
```

---

## 6. core/result/

## 6.1 Propósito

Define una forma estándar de representar éxito o fallo en operaciones.

## 6.2 Ejemplo conceptual

```text
AppResult<T>
├── Success<T>
└── Failure
```

## 6.3 Uso esperado

Los repositorios deben devolver resultados controlados.

Ejemplos:

```text
Success(Product)
Failure(stock_insufficient)
Failure(network_error)
Failure(product_not_found)
```

## 6.4 Beneficio

Evita que la UI dependa directamente de excepciones técnicas de Firebase, Dio u otros servicios.

---

## 7. core/errors/

## 7.1 Propósito

Centraliza errores comunes de la aplicación.

## 7.2 Errores esperados

```text
AuthError
ValidationError
NetworkError
FirestoreError
StorageError
StockError
ImportError
ExternalApiError
```

## 7.3 Uso esperado

Los errores técnicos deben mapearse a mensajes comprensibles para el usuario.

Ejemplo:

```text
Firestore permission-denied
→ No tiene permisos para realizar esta acción.
```

---

## 8. core/validation/

## 8.1 Propósito

Contiene validaciones reutilizables.

## 8.2 Validadores esperados

```text
AuthValidators
ProductValidators
MovementValidators
ImportValidators
BranchValidators
```

## 8.3 Ejemplos de validaciones

### AuthValidators

- Email requerido.
- Email con formato válido.
- Contraseña requerida.
- Longitud mínima de contraseña.

### ProductValidators

- Nombre requerido.
- SKU requerido.
- Categoría requerida.
- Stock mínimo mayor o igual a cero.
- Código de barras válido, si aplica.

### MovementValidators

- Producto requerido.
- Sucursal requerida.
- Cantidad mayor a cero.
- Motivo requerido.
- Stock suficiente para salidas.

### ImportValidators

- Archivo requerido.
- Formato CSV válido.
- Columnas requeridas.
- Stock inicial no negativo.
- Sucursal existente.
- SKU no duplicado.

## 8.4 Beneficio

Permite probar reglas con unit tests y evita duplicar lógica en formularios.

---

## 9. core/widgets/

## 9.1 Propósito

Contiene widgets reutilizables que no pertenecen a un módulo específico.

## 9.2 Widgets esperados

```text
AppButton
AppTextField
LoadingStateView
EmptyStateView
ErrorStateView
ConfirmDialog
SectionHeader
SearchField
FilterChips
```

## 9.3 Regla

Los widgets compartidos no deben contener lógica de negocio.

Ejemplo correcto:

```text
EmptyStateView(title, message, actionLabel, onAction)
```

Ejemplo incorrecto:

```text
EmptyProductsView que consulta Firestore directamente.
```

---

## 10. domain/

## 10.1 Propósito

La capa `domain/` representa el núcleo conceptual de la aplicación.

Debe estar libre de detalles técnicos de Firebase, Dio, Storage, FCM o Flutter UI.

## 10.2 Responsabilidades

- Definir modelos del dominio.
- Definir contratos de repositorios.
- Definir casos de uso si el flujo lo requiere.
- Mantener conceptos del sistema independientes de infraestructura.

## 10.3 Estructura sugerida

```text
domain/
├── models/
├── repositories/
└── usecases/
```

---

## 11. domain/models/

## 11.1 Propósito

Define las entidades principales del sistema.

## 11.2 Modelos esperados

```text
User
Branch
Product
Stock
InventoryMovement
NotificationToken
ImportBatch
ExternalProductSuggestion
```

## 11.3 Regla

Los modelos de dominio no deben depender de Firestore ni de DTOs externos.

Ejemplo correcto:

```text
Product
- id
- name
- sku
- barcode
- category
- imageUrl
- minStock
- isActive
```

Ejemplo incorrecto:

```text
Product que importa DocumentSnapshot de Firestore.
```

---

## 12. domain/repositories/

## 12.1 Propósito

Define contratos abstractos de acceso a datos.

## 12.2 Repositorios esperados

```text
AuthRepository
UserRepository
BranchRepository
ProductRepository
StockRepository
InventoryMovementRepository
NotificationRepository
ProductLookupRepository
ImportRepository
```

## 12.3 Regla

Los contratos no deben decir cómo se obtiene la información. Solo definen qué operación necesita la app.

Ejemplo:

```text
ProductRepository
- getProducts()
- getProductById(productId)
- createProduct(product)
- updateProduct(product)
- deactivateProduct(productId)
```

No debe incluir detalles como:

```text
FirebaseFirestore.instance.collection(...)
```

---

## 13. domain/usecases/

## 13.1 Propósito

Contiene operaciones de negocio que coordinan más de un repositorio o encapsulan reglas importantes.

## 13.2 Casos de uso posibles

```text
RegisterInventoryMovementUseCase
CheckLowStockUseCase
ImportProductsFromCsvUseCase
SearchProductByBarcodeUseCase
```

## 13.3 Nota

Para el MVP, no todos los flujos necesitan use cases. Se deben usar cuando ayuden a mantener limpia la lógica.

---

## 14. data/

## 14.1 Propósito

La capa `data/` contiene implementaciones concretas de acceso a datos.

Aquí viven Firebase, clientes HTTP REST, APIs externas, almacenamiento local, mock data sources, DTOs, mappers e implementaciones de repositorios.

Los data sources son intercambiables. Para una misma operación de dominio puede existir una implementación basada en Firebase, una basada en un backend REST compatible con `docs/api-contracts/openapi.inventory-api.yaml`, una basada en almacenamiento local y una basada en mock data, sin que los ViewModels ni la UI cambien.

## 14.2 Responsabilidades

- Implementar contratos de `domain/repositories`.
- Comunicarse con Firebase, según la implementación actual del MVP.
- Consumir un backend REST compatible con `docs/api-contracts/openapi.inventory-api.yaml`, cuando exista.
- Consumir la API externa de productos.
- Leer y escribir preferencias locales.
- Proveer mock data sources para pruebas y demostraciones.
- Convertir documentos Firestore, respuestas REST o respuestas externas a modelos de dominio.
- Manejar errores técnicos.

## 14.3 Estructura sugerida

```text
data/
├── datasources/
│   ├── firebase/
│   ├── rest/
│   ├── external/
│   ├── local/
│   └── mock/
├── dto/
├── mappers/
└── repositories/
```

---

## 15. data/datasources/firebase/

## 15.1 Propósito

Contiene data sources que se comunican con Firebase.

## 15.2 Data sources esperados

```text
FirebaseAuthDataSource
FirebaseUserDataSource
FirebaseBranchDataSource
FirebaseProductDataSource
FirebaseStockDataSource
FirebaseInventoryMovementDataSource
FirebaseStorageDataSource
FirebaseNotificationTokenDataSource
```

## 15.3 Responsabilidades

- Leer y escribir documentos Firestore.
- Ejecutar transacciones de movimientos.
- Subir imágenes a Firebase Storage.
- Obtener usuario autenticado.
- Registrar tokens FCM.

## 15.4 Regla

Los data sources pueden conocer Firebase. Las capas superiores no.

---

## 15A. data/datasources/rest/

## 15A.1 Propósito

Contiene data sources que consumen un backend REST compatible con `docs/api-contracts/openapi.inventory-api.yaml`.

Esta capa es opcional para el MVP. Existirá cuando se decida operar la aplicación contra un backend REST en lugar de, o además de, Firebase.

## 15A.2 Data sources esperados

```text
RestApiAuthDataSource
RestApiUserDataSource
RestApiBranchDataSource
RestApiProductDataSource
RestApiStockDataSource
RestApiInventoryMovementDataSource
RestApiProductLookupDataSource
RestApiNotificationTokenDataSource
RestApiImportBatchDataSource
```

## 15A.3 Responsabilidades

- Ejecutar requests HTTP definidos en el contrato OpenAPI.
- Adjuntar el token bearer requerido por `bearerAuth`.
- Parsear respuestas JSON hacia DTOs REST.
- Mapear códigos de estado y `error.code` a errores controlados de la aplicación.
- Respetar timeouts y políticas de reintentos definidos por la app.
- Retornar resultados consumibles por los repositorios.

## 15A.4 Cliente HTTP

Se usará Dio o un cliente HTTP equivalente, alineado con DT-09.

Dio no debe usarse para Firebase.

## 15A.5 Regla

Los data sources REST pueden conocer Dio, los DTOs REST y el contrato OpenAPI. Las capas superiores no.

---

## 16. data/datasources/external/

## 16.1 Propósito

Contiene data sources para APIs externas.

## 16.2 Data source esperado

```text
OpenFoodFactsDataSource
```

## 16.3 Responsabilidades

- Ejecutar request HTTP.
- Manejar timeout.
- Parsear JSON externo.
- Retornar DTO o modelo intermedio.
- Mapear errores de red.

## 16.4 Regla

Dio o el cliente HTTP solo debe usarse aquí.

No debe usarse Dio para Firestore ni Firebase.

---

## 17. data/datasources/local/

## 17.1 Propósito

Contiene data sources para almacenamiento local limitado.

## 17.2 Data source esperado

```text
LocalPreferencesDataSource
```

## 17.3 Responsabilidades

- Guardar última sucursal seleccionada.
- Guardar preferencia de tema.
- Guardar filtros recientes.
- Leer preferencias al iniciar la app.

## 17.4 Regla

No se debe prometer modo offline completo en el MVP.

---

## 17A. data/datasources/mock/

## 17A.1 Propósito

Contiene implementaciones fake o en memoria de los data sources.

Se utiliza para desarrollo temprano de UI, widget tests, pruebas de ViewModels y demostraciones cuando todavía no se cuenta con backend real o cuando no conviene depender de Firebase.

## 17A.2 Data sources esperados

```text
MockAuthDataSource
MockUserDataSource
MockBranchDataSource
MockProductDataSource
MockStockDataSource
MockInventoryMovementDataSource
MockProductLookupDataSource
MockNotificationTokenDataSource
MockImportBatchDataSource
```

## 17A.3 Responsabilidades

- Implementar los mismos contratos que los data sources reales (Firebase o REST).
- Cargar datos iniciales alineados con `docs/api-contracts/mock-data.md`.
- Mantener un estado en memoria consistente con las reglas del dominio.
- Responder de forma determinista y rápida para tests y demos.
- Permitir simular errores controlados como `insufficient_stock` o `product_not_found`.

## 17A.4 Regla

Los mock data sources deben respetar las reglas del dominio: una salida no puede dejar stock negativo, un producto inactivo no se puede usar en nuevos movimientos, los SKUs deben ser únicos.

No deben filtrarse hacia producción; su empaquetado debe permanecer aislado del flujo de release.

---

## 18. data/dto/

## 18.1 Propósito

Contiene objetos usados para representar datos externos o remotos.

## 18.2 DTOs esperados

```text
ProductFirestoreDto
StockFirestoreDto
InventoryMovementFirestoreDto
ProductRestDto
StockRestDto
InventoryMovementRestDto
UserRestDto
BranchRestDto
OpenFoodFactsProductDto
ImportRowDto
```

## 18.3 Regla

Los DTOs pueden adaptarse al formato de Firebase o APIs externas.

Los modelos de dominio deben mantenerse limpios.

---

## 19. data/mappers/

## 19.1 Propósito

Convierte DTOs o documentos remotos hacia modelos de dominio y viceversa.

## 19.2 Mappers esperados

```text
ProductMapper
StockMapper
InventoryMovementMapper
UserMapper
BranchMapper
ExternalProductMapper
ImportMapper
```

## 19.3 Ejemplo conceptual

```text
OpenFoodFactsProductDto
→ ExternalProductSuggestion
→ Product form suggestion
```

```text
Firestore Product document
→ Product
```

---

## 20. data/repositories/

## 20.1 Propósito

Contiene las implementaciones concretas de los contratos definidos en `domain/repositories`.

## 20.2 Repositorios esperados

```text
AuthRepositoryImpl
ProductRepositoryImpl
StockRepositoryImpl
InventoryMovementRepositoryImpl
BranchRepositoryImpl
NotificationRepositoryImpl
ProductLookupRepositoryImpl
ImportRepositoryImpl
```

## 20.3 Responsabilidades

- Coordinar data sources.
- Mapear errores técnicos a `AppResult`.
- Aplicar reglas simples de coordinación.
- Ocultar detalles de infraestructura al ViewModel.

---

## 21. ui/

## 21.1 Propósito

Contiene pantallas, ViewModels y componentes específicos de cada módulo visual.

## 21.2 Estructura sugerida

```text
ui/
├── auth/
├── branches/
├── products/
├── stock/
├── movements/
├── history/
├── import/
├── notifications/
└── settings/
```

---

## 22. ui/auth/

## 22.1 Responsabilidades

- Login.
- Registro.
- Logout.
- Estado de autenticación.

## 22.2 Archivos esperados

```text
login_screen.dart
register_screen.dart
auth_view_model.dart
auth_state.dart
```

---

## 23. ui/products/

## 23.1 Responsabilidades

- Listar productos.
- Crear producto.
- Editar producto.
- Ver detalle.
- Buscar por código de barras.
- Asociar imagen.
- Acceder a importación CSV.

## 23.2 Archivos esperados

```text
products_screen.dart
product_detail_screen.dart
product_form_screen.dart
product_lookup_section.dart
product_view_model.dart
product_form_view_model.dart
product_state.dart
```

---

## 24. ui/stock/

## 24.1 Responsabilidades

- Mostrar stock por sucursal.
- Mostrar productos bajo stock.
- Filtrar existencias.
- Abrir detalle de producto.
- Registrar movimiento.

## 24.2 Archivos esperados

```text
stock_screen.dart
stock_view_model.dart
stock_state.dart
low_stock_card.dart
```

---

## 25. ui/movements/

## 25.1 Responsabilidades

- Registrar entradas.
- Registrar salidas.
- Validar cantidad y stock suficiente.
- Mostrar resultado del movimiento.
- Activar alerta de bajo stock si aplica.

## 25.2 Archivos esperados

```text
movement_form_screen.dart
movement_view_model.dart
movement_state.dart
movement_type_selector.dart
```

---

## 26. ui/history/

## 26.1 Responsabilidades

- Listar movimientos.
- Filtrar por producto, sucursal, tipo, fecha o usuario.
- Mostrar detalle de movimiento.

## 26.2 Archivos esperados

```text
history_screen.dart
movement_detail_screen.dart
history_view_model.dart
history_filters.dart
movement_card.dart
```

---

## 27. ui/import/

## 27.1 Responsabilidades

- Seleccionar archivo CSV.
- Parsear archivo.
- Mostrar vista previa.
- Mostrar errores.
- Confirmar importación.

## 27.2 Archivos esperados

```text
import_products_screen.dart
import_view_model.dart
import_state.dart
import_preview_table.dart
import_error_list.dart
```

## 27.3 Nota

La importación CSV es complementaria. Si el tiempo no alcanza, puede quedar documentada como mejora posterior.

---

## 28. navigation/

## 28.1 Propósito

Centraliza la navegación de la app.

## 28.2 Responsabilidades

- Definir rutas.
- Proteger rutas privadas.
- Redirigir según estado de autenticación.
- Aplicar restricciones por rol cuando corresponda.

## 28.3 Archivos esperados

```text
app_router.dart
routes.dart
route_guard.dart
```

---

## 29. notifications/

## 29.1 Propósito

Contiene servicios de notificaciones.

## 29.2 Responsabilidades

- Solicitar permisos.
- Obtener FCM token.
- Guardar token en Firestore.
- Manejar mensajes entrantes.
- Mostrar notificaciones locales o alertas in-app.

## 29.3 Archivos esperados

```text
fcm_service.dart
notification_service.dart
local_notification_service.dart
```

---

## 30. Dependencias permitidas por capa

## 30.1 UI puede depender de

```text
domain
core
navigation
Riverpod
Flutter widgets
```

No debe depender directamente de:

```text
cloud_firestore
firebase_auth
firebase_storage
dio
```

---

## 30.2 Domain puede depender de

```text
Dart core
```

No debe depender de:

```text
Flutter UI
Firebase
Dio
Firestore
Storage
FCM
```

---

## 30.3 Data puede depender de

```text
domain
core
firebase_auth
cloud_firestore
firebase_storage
firebase_messaging
dio o un cliente HTTP equivalente
shared_preferences
mock o fake data helpers para tests
```

---

## 30.4 Core puede depender de

```text
Dart core
Flutter widgets para widgets compartidos
```

Debe evitar depender de módulos específicos de negocio.

---

## 31. Flujo de dependencia esperado

```text
ui
↓
domain
↑
data
```

Otra forma de verlo:

```text
UI → Domain contracts
Data → Domain contracts
```

Los repositorios en `data/` implementan contratos definidos en `domain/`.

---

## 32. Ejemplo de flujo completo: registrar salida

El flujo siempre cruza el repositorio. La implementación concreta del data source puede variar sin afectar la UI ni los ViewModels.

```text
MovementFormScreen
→ MovementViewModel
→ InventoryMovementRepository
→ <data source concreto>
→ persistencia y validación de stock
→ AppResult success/failure
→ UI muestra resultado
```

El `<data source concreto>` puede ser, según el entorno:

- `FirebaseInventoryMovementDataSource` — ejecuta una transacción de Firestore. Implementación actual del MVP.
- `RestApiInventoryMovementDataSource` — ejecuta `POST /inventory-movements` según `docs/api-contracts/openapi.inventory-api.yaml`. Implementación futura cuando exista un backend REST compatible.
- `MockInventoryMovementDataSource` — actualiza estado en memoria para pruebas y demostraciones.

Responsabilidades:

| Capa | Responsabilidad |
|---|---|
| UI | Captura datos y muestra estado. |
| ViewModel | Valida formulario y coordina operación. |
| Repository | Ejecuta operación de dominio sobre un data source intercambiable. |
| Data Source | Ejecuta la persistencia concreta (Firestore, REST o mock). |
| Backend / Mock | Persiste stock y movimiento, o simula la persistencia para pruebas. |

---

## 33. Criterios de aceptación de capas

La estructura de capas se considera correcta si:

- La UI no llama directamente a Firebase.
- La UI no llama directamente a Dio.
- Los ViewModels no conocen detalles de Firestore.
- Los repositorios devuelven resultados controlados.
- Los data sources encapsulan infraestructura.
- Los modelos de dominio no importan paquetes de Firebase.
- Las validaciones reutilizables están fuera de las pantallas.
- La navegación está centralizada.
- Los widgets compartidos no contienen lógica de negocio.
- El sistema puede probar reglas sin depender de UI.

---

## 34. Riesgos de incumplimiento

### 34.1 UI conectada directamente a Firebase

Riesgo:

- Difícil de testear.
- Difícil de mantener.
- Mezcla responsabilidades.

Mitigación:

- Usar repositorios y data sources.

---

### 34.2 Lógica duplicada en pantallas

Riesgo:

- Validaciones inconsistentes.
- Más errores.
- Mayor dificultad de cambios.

Mitigación:

- Centralizar validadores en `core/validation`.

---

### 34.3 Modelos mezclados con DTOs

Riesgo:

- El dominio queda acoplado a Firestore.
- Cambiar estructura de datos afecta toda la app.

Mitigación:

- Usar DTOs y mappers.

---

### 34.4 Módulos sin patrón común

Riesgo:

- Cada integrante implementa diferente.
- La app se vuelve difícil de integrar.

Mitigación:

- Seguir estructura común por módulo.

---

## 35. Estado del documento

Este documento debe actualizarse si cambian:

- La estructura de carpetas.
- El patrón de arquitectura.
- La estrategia de repositorios.
- La forma de consumir Firebase.
- La integración con API externa.
- La estructura de UI por módulos.

