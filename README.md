# Inventory Mobile Project

Aplicación móvil Flutter para gestión de inventario multiusuario. Este repositorio contiene la app mobile, documentación técnica, contratos REST de referencia y pruebas mobile. El backend no vive en este repositorio.

Estado verificado contra el código actual: la app implementa arquitectura por capas con Riverpod, Dio, repositorios, data sources REST y pantallas funcionales para autenticación, productos, sucursales, stock, movimientos, importación CSV y registro de tokens de notificación. Algunas vistas siguen siendo parciales o placeholders y dependen del backend externo para funcionar end to end.

---

## 1. Alcance Actual

### Implementado en `app/`

- Proyecto Flutter/Dart.
- Arquitectura MVVM por capas con Repository Pattern.
- Estado e inyección de dependencias con Riverpod.
- Navegación con GoRouter y rutas protegidas por sesión.
- Cliente HTTP Dio con `Authorization: Bearer <token>`.
- Registro, login, logout y restauración de sesión con `/auth/me`.
- Almacenamiento seguro del token con `flutter_secure_storage`.
- Catálogo de productos con búsqueda, filtros, paginación y detalle.
- Crear/editar productos, activar/desactivar y cargar imagen.
- Autocompletado de productos por código de barras vía endpoint backend `/product-lookup/{barcode}`.
- Gestión de sucursales con listado, filtros, creación, edición, desactivación y reactivación.
- Pantalla de stock por sucursal con búsqueda y filtros.
- Historial de movimientos, filtros por tipo y creación de entradas/salidas.
- Importación CSV de productos y consulta de importaciones recientes.
- Firebase Core, Firebase Messaging y notificaciones locales.
- Registro/eliminación de tokens FCM contra el backend.
- Health check contra `/health`.
- Unit tests y widget tests en `app/test`.
- GitHub Actions para `flutter pub get`, `flutter analyze` y `flutter test`.

### Parcial, demo o pendiente de integración

- La pantalla `Alertas` existe, pero es un placeholder.
- El dashboard mezcla datos reales parciales con tarjetas demo/pendientes. Actualmente consulta métricas de productos activos y bajo stock, pero disponibilidad, agotados, movimientos de hoy y últimos movimientos no están completamente conectados.
- El detalle de producto muestra explícitamente como pendientes las secciones "Stock por sucursal" y "Últimos movimientos".
- La pantalla de stock usa una lista temporal de sucursales de desarrollo en `app/lib/core/constants/stock_config.dart`; no usa todavía el selector real de sucursales del módulo Branches.
- La importación CSV está implementada como flujo de subida/resultado contra endpoints del backend, no como parser local completo.
- FCM está integrado en la app, pero la entrega real de push notifications requiere configuración Firebase válida y soporte server-side en el backend. No se confirmó en este repositorio un envío automático de notificaciones.
- Firebase Storage está mencionado como opción, pero no hay implementación confirmada de subida a Firebase Storage en la app. La subida de imágenes usa el endpoint backend `/products/{id}/image`.
- No hay `integration_test/` confirmado en el código actual.

### Fuera de este repositorio

- Implementación del backend ASP.NET Core Web API.
- SQL Server, migraciones, EF Core, Docker Compose y pruebas backend.
- Envío automático server-side de push notifications.
- Login social, Firebase Auth y recuperación de contraseña.
- ERP, facturación, proveedores, reportes avanzados y panel web administrativo.

---

## 2. Stack Técnico Verificado

| Área | Tecnología / estado |
|---|---|
| Framework mobile | Flutter |
| Lenguaje | Dart |
| Arquitectura | MVVM por capas + Repository Pattern |
| Estado / DI | Riverpod |
| Navegación | GoRouter |
| HTTP client | Dio |
| Auth mobile | Bearer token del backend + `flutter_secure_storage` |
| Backend esperado | `inventory-backend` externo |
| Contrato REST | `docs/api-contracts/openapi.inventory-api.yaml` |
| Firebase | Firebase Core, Firebase Messaging, notificaciones locales |
| Imágenes | `image_picker` + upload al backend |
| CSV | `file_picker`; subida del archivo al backend |
| Almacenamiento local | `flutter_secure_storage`; `shared_preferences` está en dependencias, pero no se confirmó uso funcional en `lib/` |
| Testing | `flutter_test`, `mocktail`, tests unit/widget |
| CI | `.github/workflows/flutter-ci.yml` |

---

## 3. Arquitectura Mobile

La estructura real de `app/lib` está alineada con una arquitectura por capas:

```text
app/lib/
├── app/                 # App root y tema
├── core/                # Configuración, errores, result, storage, validaciones
├── data/                # DTOs, mappers, REST data sources, providers, repos impl
├── domain/              # Modelos, repositorios abstractos, servicios de dominio
├── navigation/          # GoRouter, rutas, sesión, restauración de sesión
├── notifications/       # FCM, notificaciones locales, coordinadores
└── ui/                  # Pantallas y view models/controllers por módulo
```

Flujo general:

```text
UI
→ Controller / ViewModel / Provider
→ Repository
→ RestApiDataSource
→ Dio autenticado
→ inventory-backend
```

La UI no accede directamente al backend. El acceso a datos pasa por repositorios y data sources REST.

---

## 4. Módulos y Pantallas

| Módulo | Estado actual |
|---|---|
| Auth | Login, registro, logout, restauración de sesión y rutas protegidas implementadas. |
| Home | Dashboard implementado con métricas parciales; varios indicadores siguen pendientes/demo. |
| Products | Listado, búsqueda, filtros, detalle, crear, editar, activar/desactivar, imagen y lookup por barcode implementados. |
| Branches | Listado, filtros, selección, crear, editar, desactivar/reactivar implementados. |
| Stock | Vista de existencias por sucursal implementada, pero usa sucursales temporales hardcodeadas. |
| Movements | Historial, filtro por tipo, búsqueda local y formulario de entrada/salida implementados. |
| Imports | Selección y subida de CSV, resultado, errores y últimas importaciones implementados contra backend. |
| Alerts | Placeholder; no hay listado real de alertas en la UI actual. |
| Notifications | FCM/local notifications y registro de token implementados; requiere backend/Firebase configurados para validación end to end. |

---

## 5. Backend y Endpoints Usados

La app consume un backend externo llamado `inventory-backend`. La implementación de endpoints no está en este repositorio.

La URL base se configura en `app/lib/core/constants/api_config.dart`.

- Android: `http://10.0.2.2:5225`
- iOS simulator, desktop y tests locales: `http://localhost:5225`
- Override: `--dart-define=BACKEND_BASE_URL=<url>`

Ejemplo:

```powershell
cd .\app
flutter run --dart-define=BACKEND_BASE_URL=http://10.0.2.2:5225
```

Endpoints usados por el código mobile:

```text
GET  /health
POST /auth/register
POST /auth/login
GET  /auth/me
POST /auth/logout
GET  /products
POST /products
GET  /products/{productId}
PATCH /products/{productId}
PATCH /products/{productId}/deactivate
PATCH /products/{productId}/activate
POST /products/{productId}/image
GET  /product-lookup/{barcode}
GET  /branches
POST /branches
PATCH /branches/{branchId}
PATCH /branches/{branchId}/deactivate
PATCH /branches/{branchId}/activate
GET  /stock?branchId={branchId}
GET  /inventory-movements
POST /inventory-movements
GET  /inventory-movements/{movementId}
GET  /import-batches
POST /import-batches/products
GET  /import-batches/{batchId}
GET  /import-batches/{batchId}/errors
POST /notification-tokens
DELETE /notification-tokens/{tokenId}
```

Open Food Facts no se consume directamente desde la app actual. La app llama al backend en `/product-lookup/{barcode}`; el backend es quien debería resolver la integración externa.

---

## 6. Autenticación y Roles

La autenticación mobile implementada espera respuestas del backend para:

- Registro.
- Login.
- Usuario actual (`/auth/me`).
- Logout.

El token se guarda en secure storage y el interceptor agrega:

```text
Authorization: Bearer <token>
```

Los roles soportados por el modelo mobile son:

```text
admin
collaborator
```

El rol `admin` habilita acciones administrativas visibles, como importación de productos y acciones administrativas sobre sucursales. La autorización real debe validarse en el backend.

Nota: `DEV_ACCESS_TOKEN` existe en `core/auth/access_token_provider.dart`, pero los providers actuales usan principalmente el almacenamiento seguro y el interceptor de auth. Su uso en ejecución normal no está confirmado como flujo principal.

---

## 7. Instalación y Ejecución

Requisitos:

- Git.
- Flutter SDK compatible con Dart `^3.12.1`.
- Android Studio / Android SDK para Android.
- Emulador o dispositivo físico.
- Backend `inventory-backend` corriendo si se quieren probar flujos reales.
- Configuración Firebase válida para validar FCM en dispositivo.

Comandos desde la raíz:

```powershell
cd .\app
flutter pub get
flutter run
```

Con backend local en emulador Android:

```powershell
flutter run --dart-define=BACKEND_BASE_URL=http://10.0.2.2:5225
```

Con dispositivo Android físico y backend local en la PC:

```powershell
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
& $adb reverse tcp:5225 tcp:5225
flutter run --dart-define=BACKEND_BASE_URL=http://127.0.0.1:5225
```

Un cambio en `--dart-define` requiere detener y volver a lanzar la app; hot reload no alcanza.

---

## 8. Validación Local

Desde `app/`:

```powershell
flutter pub get
flutter analyze
flutter test
```

Build Android debug:

```powershell
flutter build apk --debug
```

Integration tests:

```powershell
flutter test integration_test
```

Nota: no se confirmó una carpeta `app/integration_test/` en el código actual, por lo que ese comando aplica solo si se agregan integration tests.

---

## 9. Tests Existentes

La carpeta `app/test` contiene cobertura para:

- Validadores de auth, productos y movimientos.
- Modelos de dominio.
- DTOs y mappers.
- Data sources REST.
- Repositorios.
- Providers.
- Auth token storage y notification registration storage.
- Configuración de API.
- Navegación y restauración de sesión.
- Pantallas y controllers de auth.
- Pantallas/controllers de productos.
- Sucursales.
- Stock.
- Movimientos.
- Importación.
- Notificaciones.
- Health screen.

El plan de pruebas vive en:

```text
tests/test-plan.md
```

Ese plan incluye algunos escenarios deseados que pueden ser más amplios que el estado actual de implementación. Para evidencia real, usar los tests existentes en `app/test`.

---

## 10. GitHub Actions

Workflow confirmado:

```text
.github/workflows/flutter-ci.yml
```

Ejecuta en `main` y `dev`:

```text
flutter pub get
flutter analyze
flutter test
```

No ejecuta actualmente `flutter build apk --debug`.

---

## 11. Documentación Disponible

```text
docs/architecture/project-scope.md
docs/architecture/technical-decisions.md
docs/architecture/data-model.md
docs/architecture/system-architecture.md
docs/architecture/navigation-map.md
docs/architecture/layers-explanation.md
docs/api-contracts/README.md
docs/api-contracts/openapi.inventory-api.yaml
docs/api-contracts/external-product-api.md
docs/api-contracts/mock-data.md
tests/test-plan.md
app/README.md
```

Algunos documentos usan lenguaje de planificación. El estado más confiable para implementación mobile actual es este README, `app/README.md` y el código en `app/lib` + `app/test`.

---

## 12. Limitaciones Conocidas

- El backend debe existir y respetar los contratos esperados; este repo no puede validar reglas backend ni persistencia SQL Server.
- La app no implementa modo offline completo.
- La selección de sucursal en Stock todavía es temporal y hardcodeada.
- Alertas no está implementada como módulo funcional.
- Push notifications requieren Firebase y backend server-side para validación real.
- La carga de imágenes depende del endpoint backend, no de Firebase Storage.
- Open Food Facts está abstraído detrás del backend; no hay llamada directa desde Flutter.
- No se confirmó integración end to end con un backend real durante esta revisión.
- No se confirmó carpeta de integration tests.
- Variables o secretos de backend/Firebase no deben commitearse. Usar `--dart-define` para `BACKEND_BASE_URL`.

---

