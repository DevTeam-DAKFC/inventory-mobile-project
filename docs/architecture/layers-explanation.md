# Layers Explanation - Sistema de Gestion de Inventario Multiusuario

## 1. Proposito del documento

Este documento explica las capas internas de la aplicacion Flutter y la responsabilidad de cada una.

Su objetivo es mantener una estructura consistente durante el desarrollo, evitando que la logica de negocio, la UI, el backend REST, Firebase, la API externa y el almacenamiento local queden mezclados.

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

La aplicacion debe mantener separacion clara de responsabilidades.

El flujo principal de datos de aplicacion sera:

```text
UI
→ ViewModel / State
→ Repository
→ RestApiDataSource
→ ASP.NET Core Web API
→ SQL Server
```

El backend ASP.NET Core Web API, SQL Server y la configuracion Docker / Docker Compose estan planificados y pendientes. Flutter no debe conectarse directamente a SQL Server.

Regla principal:

```text
La UI no debe acceder directamente al backend, SQL Server, Firebase, Storage, FCM, Dio ni almacenamiento local.
```

---

## 3. Estructura general de capas

La app usara una estructura `layer-first` simplificada:

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

Esta estructura permite explicar claramente donde vive cada responsabilidad.

---

## 4. app/

## 4.1 Proposito

La capa `app/` contiene la configuracion inicial de la aplicacion.

## 4.2 Responsabilidades

- Inicializar servicios requeridos.
- Configurar providers globales.
- Configurar tema visual.
- Configurar navegacion principal.
- Exponer el widget raiz de la aplicacion.

## 4.3 Archivos sugeridos

```text
app/
├── app.dart
├── bootstrap.dart
└── theme.dart
```

## 4.4 Que si debe contener

- Configuracion global.
- Inicializacion de servicios.
- Configuracion de `MaterialApp`.
- Configuracion del router.
- Configuracion del tema.

## 4.5 Que no debe contener

- Logica de negocio.
- Logica de productos.
- Logica de movimientos.
- Consultas directas al backend o a SQL Server.
- Codigo especifico de pantallas complejas.

---

## 5. core/

## 5.1 Proposito

La capa `core/` contiene elementos compartidos por toda la aplicacion.

Debe incluir utilidades, validadores, errores, resultados, widgets reutilizables y helpers comunes.

## 5.2 Responsabilidades

- Definir errores comunes.
- Definir resultado estandar de operaciones.
- Centralizar validaciones reutilizables.
- Incluir widgets genericos.
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

## 6.1 Proposito

Define una forma estandar de representar exito o fallo en operaciones.

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

Evita que la UI dependa directamente de excepciones tecnicas del backend, Dio, Firebase u otros servicios.

---

## 7. core/errors/

## 7.1 Proposito

Centraliza errores comunes de la aplicacion.

## 7.2 Errores esperados

```text
AuthError
ValidationError
NetworkError
BackendError
StorageError
StockError
ImportError
ExternalApiError
```

## 7.3 Uso esperado

Los errores tecnicos deben mapearse a mensajes comprensibles para el usuario.

Ejemplo:

```text
Backend error insufficient_stock
→ No hay stock suficiente para realizar esta accion.
```

---

## 8. core/validation/

## 8.1 Proposito

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
- Email con formato valido.
- Contrasena requerida.
- Longitud minima de contrasena.

### ProductValidators

- Nombre requerido.
- SKU requerido.
- Categoria requerida.
- Stock minimo mayor o igual a cero.
- Codigo de barras valido, si aplica.

### MovementValidators

- Producto requerido.
- Sucursal requerida.
- Cantidad mayor a cero.
- Motivo requerido.
- Stock suficiente para salidas.

### ImportValidators

- Archivo requerido.
- Formato CSV valido.
- Columnas requeridas.
- Stock inicial no negativo.
- Sucursal existente.
- SKU no duplicado.

## 8.4 Beneficio

Permite probar reglas con unit tests y evita duplicar logica en formularios.

---

## 9. core/widgets/

## 9.1 Proposito

Contiene widgets reutilizables que no pertenecen a un modulo especifico.

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

Los widgets compartidos no deben contener logica de negocio.

Ejemplo correcto:

```text
EmptyStateView(title, message, actionLabel, onAction)
```

Ejemplo incorrecto:

```text
EmptyProductsView que llama a ProductRepository directamente.
```

---

## 10. domain/

## 10.1 Proposito

La capa `domain/` representa el nucleo conceptual de la aplicacion.

Debe estar libre de detalles tecnicos del backend, SQL Server, Dio, Firebase, Storage, FCM o Flutter UI.

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

## 11.1 Proposito

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

Los modelos de dominio no deben depender de DTOs REST, DTOs externos ni paquetes de infraestructura.

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
Product que importa Response, JsonDocument, DocumentSnapshot u objetos de UI.
```

---

## 12. domain/repositories/

## 12.1 Proposito

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

Los contratos no deben decir como se obtiene la informacion. Solo definen que operacion necesita la app.

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
Dio().get('/products')
```

---

## 13. domain/usecases/

## 13.1 Proposito

Contiene operaciones de negocio que coordinan mas de un repositorio o encapsulan reglas importantes.

## 13.2 Casos de uso posibles

```text
RegisterInventoryMovementUseCase
CheckLowStockUseCase
ImportProductsFromCsvUseCase
SearchProductByBarcodeUseCase
```

## 13.3 Nota

Para el MVP, no todos los flujos necesitan use cases. Se deben usar cuando ayuden a mantener limpia la logica.

---

## 14. data/

## 14.1 Proposito

La capa `data/` contiene implementaciones concretas de acceso a datos.

Aqui viven clientes HTTP REST, data sources externos, almacenamiento local, integraciones Firebase especificas, mock data sources, DTOs, mappers e implementaciones de repositorios.

`RestApiDataSource` sera la familia principal de data sources para datos de aplicacion del MVP. Consume el backend ASP.NET Core Web API usando Dio / HttpClient y el contrato `docs/api-contracts/openapi.inventory-api.yaml`.

SQL Server esta detras del backend. Flutter no debe acceder directamente a SQL Server ni usar paquetes cliente de SQL Server.

## 14.2 Responsabilidades

- Implementar contratos de `domain/repositories`.
- Consumir el backend ASP.NET Core Web API mediante `RestApiDataSource`.
- Usar Dio / HttpClient para integraciones HTTP.
- Consumir la API externa de productos si se decide consumo directo desde Flutter.
- Leer y escribir preferencias locales.
- Proveer `MockDataSource` para pruebas, demos y trabajo temprano de UI.
- Integrarse con Firebase solo para servicios especificos, como FCM o Storage opcional.
- Convertir DTOs REST, respuestas externas o datos locales a modelos de dominio.
- Manejar errores tecnicos.
- Convertir respuestas de error del backend en `AppException` o fallos de `AppResult`.

## 14.3 Estructura sugerida

```text
data/
├── datasources/
│   ├── rest/
│   ├── mock/
│   ├── external/
│   ├── local/
│   └── firebase/
├── dto/
├── mappers/
└── repositories/
```

---

## 15. data/datasources/rest/

## 15.1 Proposito

Contiene la familia principal de data sources para datos de aplicacion del MVP.

Consume el backend ASP.NET Core Web API mediante Dio / HttpClient y sigue el contrato definido en:

```text
docs/api-contracts/openapi.inventory-api.yaml
```

## 15.2 Data sources esperados

```text
RestApiAuthDataSource
RestApiProductDataSource
RestApiBranchDataSource
RestApiStockDataSource
RestApiInventoryMovementDataSource
RestApiProductLookupDataSource
RestApiNotificationTokenDataSource
RestApiImportBatchDataSource
```

## 15.3 Responsabilidades

- Ejecutar requests HTTP definidos en el contrato OpenAPI.
- Adjuntar el token bearer requerido cuando aplique.
- Parsear respuestas JSON hacia DTOs REST.
- Mapear DTOs REST hacia modelos de dominio.
- Convertir codigos de estado y errores del backend a `AppException` o fallos de `AppResult`.
- Respetar timeouts y politicas de reintentos definidos por la app.
- Retornar resultados consumibles por los repositorios.
- Ocultar detalles HTTP a ViewModels y UI.

## 15.4 Cliente HTTP

Se usara Dio o un cliente HTTP equivalente, alineado con la decision tecnica del proyecto.

Dio no debe usarse para conectar directamente a SQL Server.

## 15.5 Regla

Los data sources REST pueden conocer Dio, DTOs REST y el contrato OpenAPI. Las capas superiores no.

---

## 16. data/datasources/mock/

## 16.1 Proposito

Contiene implementaciones fake o en memoria de los data sources.

Se utiliza para desarrollo temprano de UI, widget tests, pruebas de ViewModels y demos cuando todavia no se cuenta con backend real o cuando no conviene depender de la red.

## 16.2 Data sources esperados

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

## 16.3 Responsabilidades

- Implementar los mismos contratos que los data sources reales.
- Cargar datos iniciales alineados con `docs/api-contracts/mock-data.md`.
- Mantener un estado en memoria consistente con las reglas del dominio.
- Responder de forma determinista y rapida para tests y demos.
- Permitir simular errores controlados como `insufficient_stock` o `product_not_found`.

## 16.4 Regla

Los mock data sources deben respetar las reglas del dominio: una salida no puede dejar stock negativo, un producto inactivo no se puede usar en nuevos movimientos y los SKUs deben ser unicos.

No deben filtrarse hacia produccion; su empaquetado debe permanecer aislado del flujo de release.

---

## 17. data/datasources/external/

## 17.1 Proposito

Contiene data sources para APIs externas.

## 17.2 Data source esperado

```text
OpenFoodFactsDataSource
```

## 17.3 Responsabilidades

- Ejecutar request HTTP contra Open Food Facts si se decide consumo directo desde Flutter.
- Manejar timeout.
- Parsear JSON externo.
- Retornar DTO o modelo intermedio.
- Mapear errores de red.

## 17.4 Regla

Open Food Facts puede consumirse directamente desde Flutter o mediante proxy backend. Si se consume directo, esta carpeta no se convierte en persistencia de inventario.

---

## 18. data/datasources/local/

## 18.1 Proposito

Contiene data sources para almacenamiento local limitado.

## 18.2 Data source esperado

```text
LocalPreferencesDataSource
```

## 18.3 Responsabilidades

- Guardar ultima sucursal seleccionada.
- Guardar preferencia de tema.
- Guardar filtros recientes.
- Leer preferencias al iniciar la app.

## 18.4 Regla

No se debe prometer modo offline completo en el MVP.

---

## 19. data/datasources/firebase/

## 19.1 Proposito

Contiene data sources para integraciones Firebase especificas.

No representa la persistencia de inventario del MVP.

## 19.2 Data sources esperados

```text
FirebaseMessagingDataSource
FirebaseStorageDataSource
```

## 19.3 Responsabilidades

- Obtener token FCM.
- Recibir notificaciones push mediante Firebase Messaging.
- Integrarse con Firebase Storage si se decide usarlo para imagenes de productos.
- Devolver referencias o URLs de imagen para que se persistan mediante el backend.

## 19.4 Regla

FirebaseDataSource solo debe cubrir FCM y Storage opcional. No debe describirse ni implementarse como persistencia de inventario.

---

## 20. data/dto/

## 20.1 Proposito

Contiene objetos usados para representar datos externos o remotos.

## 20.2 DTOs esperados

```text
AuthSessionRestDto
UserRestDto
BranchRestDto
ProductRestDto
StockRestDto
InventoryMovementRestDto
NotificationTokenRestDto
ImportBatchRestDto
ExternalProductSuggestionRestDto
OpenFoodFactsProductDto
ImportRowDto
```

## 20.3 Regla

Los DTOs REST son la familia principal para datos de aplicacion consumidos por Flutter.

Los DTOs de Open Food Facts se mantienen para la API externa.

Flutter no consume DTOs de SQL Server. SQL Server queda detras del backend; Flutter consume respuestas de API.

Los modelos de dominio deben mantenerse limpios.

---

## 21. data/mappers/

## 21.1 Proposito

Convierte DTOs o datos remotos hacia modelos de dominio y viceversa.

## 21.2 Mappers esperados

```text
AuthMapper
ProductMapper
StockMapper
InventoryMovementMapper
UserMapper
BranchMapper
ExternalProductMapper
ImportMapper
```

## 21.3 Ejemplo conceptual

```text
ProductRestDto
→ Product
```

```text
OpenFoodFactsProductDto
→ ExternalProductSuggestion
→ Product form suggestion
```

---

## 22. data/repositories/

## 22.1 Proposito

Contiene las implementaciones concretas de los contratos definidos en `domain/repositories`.

## 22.2 Repositorios esperados

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

## 22.3 Responsabilidades

- Exponer operaciones orientadas al dominio.
- Coordinar data sources.
- Depender de `RestApiDataSource` para datos principales del MVP.
- Permitir inyectar `MockDataSource` para pruebas y demos.
- Ocultar servicios Firebase detras de repositorios o servicios dedicados cuando se usen FCM o Storage.
- Mapear errores tecnicos a `AppResult`.
- Ocultar detalles de infraestructura al ViewModel.

## 22.4 Regla

Los repositorios no deben filtrar DTOs REST, detalles HTTP, errores crudos de Dio ni referencias Firebase hacia UI o ViewModels.

---

## 23. ui/

## 23.1 Proposito

Contiene pantallas, ViewModels y componentes especificos de cada modulo visual.

## 23.2 Estructura sugerida

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

## 24. ui/auth/

## 24.1 Responsabilidades

- Login.
- Registro.
- Logout.
- Estado de autenticacion.

## 24.2 Archivos esperados

```text
login_screen.dart
register_screen.dart
auth_view_model.dart
auth_state.dart
```

---

## 25. ui/products/

## 25.1 Responsabilidades

- Listar productos.
- Crear producto.
- Editar producto.
- Ver detalle.
- Buscar por codigo de barras.
- Asociar imagen.
- Acceder a importacion CSV.

## 25.2 Archivos esperados

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

## 26. ui/stock/

## 26.1 Responsabilidades

- Mostrar stock por sucursal.
- Mostrar productos bajo stock.
- Filtrar existencias.
- Abrir detalle de producto.
- Registrar movimiento.

## 26.2 Archivos esperados

```text
stock_screen.dart
stock_view_model.dart
stock_state.dart
low_stock_card.dart
```

---

## 27. ui/movements/

## 27.1 Responsabilidades

- Registrar entradas.
- Registrar salidas.
- Validar cantidad y stock suficiente.
- Mostrar resultado del movimiento.
- Activar alerta de bajo stock si aplica.

## 27.2 Archivos esperados

```text
movement_form_screen.dart
movement_view_model.dart
movement_state.dart
movement_type_selector.dart
```

---

## 28. ui/history/

## 28.1 Responsabilidades

- Listar movimientos.
- Filtrar por producto, sucursal, tipo, fecha o usuario.
- Mostrar detalle de movimiento.

## 28.2 Archivos esperados

```text
history_screen.dart
movement_detail_screen.dart
history_view_model.dart
history_filters.dart
movement_card.dart
```

---

## 29. ui/import/

## 29.1 Responsabilidades

- Seleccionar archivo CSV.
- Parsear archivo.
- Mostrar vista previa.
- Mostrar errores.
- Confirmar importacion.

## 29.2 Archivos esperados

```text
import_products_screen.dart
import_view_model.dart
import_state.dart
import_preview_table.dart
import_error_list.dart
```

## 29.3 Nota

La importacion CSV es complementaria. Si el tiempo no alcanza, puede quedar documentada como mejora posterior.

---

## 30. navigation/

## 30.1 Proposito

Centraliza la navegacion de la app.

## 30.2 Responsabilidades

- Definir rutas.
- Proteger rutas privadas.
- Redirigir segun estado de autenticacion.
- Aplicar restricciones por rol cuando corresponda.

## 30.3 Archivos esperados

```text
app_router.dart
routes.dart
route_guard.dart
```

---

## 31. notifications/

## 31.1 Proposito

Contiene servicios de notificaciones.

## 31.2 Responsabilidades

- Solicitar permisos.
- Obtener FCM token.
- Enviar token al backend ASP.NET Core Web API mediante Dio.
- Permitir que el backend almacene el token en SQL Server cuando exista el endpoint.
- Recibir push mediante Firebase Messaging.
- Mostrar notificaciones locales o alertas in-app.

## 31.3 Flujo esperado

```text
Flutter obtiene FCM token
→ NotificationRepository
→ RestApiNotificationTokenDataSource
→ POST /notification-tokens
→ ASP.NET Core Web API
→ SQL Server
→ Backend puede usar FCM para enviar notificaciones
→ Flutter recibe push mediante Firebase Messaging
```

## 31.4 Archivos esperados

```text
fcm_service.dart
notification_service.dart
local_notification_service.dart
```

---

## 32. Dependencias permitidas por capa

## 32.1 UI puede depender de

```text
domain
core
navigation
Riverpod
Flutter widgets
```

No debe depender directamente de:

```text
dio
firebase_messaging
firebase_storage
SQL Server client packages
```

---

## 32.2 Domain puede depender de

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
SQL Server
```

---

## 32.3 Data puede depender de

```text
domain
core
Dio o un cliente HTTP equivalente
shared_preferences
firebase_messaging para FCM
firebase_storage si se decide Storage
mock o fake data helpers para tests
```

No debe depender de:

```text
Flutter UI widgets
Screens
SQL Server client packages desde Flutter
```

---

## 32.4 Core puede depender de

```text
Dart core
Flutter widgets para widgets compartidos
```

Debe evitar depender de modulos especificos de negocio.

---

## 33. Flujo de dependencia esperado

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

## 34. Ejemplo de flujo completo: registrar salida

El flujo siempre cruza el repositorio. La implementacion concreta del data source puede variar sin afectar la UI ni los ViewModels.

```text
MovementFormScreen
→ MovementViewModel
→ InventoryMovementRepository
→ RestApiInventoryMovementDataSource
→ POST /inventory-movements
→ ASP.NET Core Web API
→ SQL Server transaction
→ Movement + updated stock state
→ AppResult success/failure
→ UI muestra resultado
```

Responsabilidades:

| Capa | Responsabilidad |
|---|---|
| UI | Captura datos y muestra estado. |
| ViewModel | Valida formulario y coordina operacion. |
| Repository | Ejecuta operacion de dominio sobre `RestApiInventoryMovementDataSource` o un mock en pruebas. |
| RestApiDataSource | Envia `POST /inventory-movements`, mapea respuesta y convierte errores backend. |
| ASP.NET Core Web API | Ejecuta reglas de negocio y coordina la transaccion. |
| SQL Server | Persiste stock y movimiento de forma transaccional. |

---

## 35. Criterios de aceptacion de capas

La estructura de capas se considera correcta si:

- La UI no llama directamente al backend.
- La UI no llama directamente a Dio.
- La UI no accede directamente a Firebase.
- Los ViewModels no conocen detalles HTTP, SQL Server, FCM ni Storage.
- Los repositorios devuelven resultados controlados.
- Los repositorios dependen de data sources y no de detalles de UI.
- `RestApiDataSource` es el camino principal para datos de aplicacion.
- `MockDataSource` permite pruebas y demos.
- `FirebaseDataSource` queda limitado a FCM y Storage opcional.
- Los data sources encapsulan infraestructura.
- Los modelos de dominio no importan paquetes de infraestructura.
- Las validaciones reutilizables estan fuera de las pantallas.
- La navegacion esta centralizada.
- Los widgets compartidos no contienen logica de negocio.
- El sistema puede probar reglas sin depender de UI ni de un backend real.

---

## 36. Riesgos de incumplimiento

### 36.1 UI conectada directamente a infraestructura

Riesgo:

- Dificil de testear.
- Dificil de mantener.
- Mezcla responsabilidades.

Mitigacion:

- Usar repositorios y data sources.

---

### 36.2 Logica duplicada en pantallas

Riesgo:

- Validaciones inconsistentes.
- Mas errores.
- Mayor dificultad de cambios.

Mitigacion:

- Centralizar validadores en `core/validation`.

---

### 36.3 Modelos mezclados con DTOs

Riesgo:

- El dominio queda acoplado al contrato remoto.
- Cambiar estructura de datos afecta toda la app.

Mitigacion:

- Usar DTOs y mappers.

---

### 36.4 Modulos sin patron comun

Riesgo:

- Cada integrante implementa diferente.
- La app se vuelve dificil de integrar.

Mitigacion:

- Seguir estructura comun por modulo.

---

## 37. Estado del documento

Pendiente de implementacion:

- Scaffold del backend ASP.NET Core Web API.
- Configuracion SQL Server con Docker Compose.
- Endpoints backend segun `docs/api-contracts/openapi.inventory-api.yaml`.
- Conexion de Flutter con `RestApiDataSource` mediante Dio.
- Configuracion FCM.
- Decision final de almacenamiento de imagenes.

Este documento debe actualizarse si cambian:

- La estructura de carpetas.
- El patron de arquitectura.
- La estrategia de repositorios.
- La forma de consumir el backend.
- El enfoque de Firebase.
- La integracion con API externa.
- La estructura de UI por modulos.
