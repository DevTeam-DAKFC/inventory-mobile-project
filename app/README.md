# Aplicación móvil de inventario

Esta carpeta contiene la app Flutter del sistema de gestión de inventario. El backend vive en un repositorio separado (`inventory-backend`); esta app consume endpoints REST mediante Dio y no se conecta directamente a SQL Server.

## Stack y arquitectura

- Flutter / Dart.
- Riverpod para estado e inyección de dependencias.
- GoRouter para navegación.
- Dio para llamadas REST.
- Repository Pattern con data sources REST, DTOs y mappers.
- `flutter_secure_storage` para token de autenticación.
- Firebase Core, Firebase Messaging y notificaciones locales para FCM.

Estructura principal:

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

## Comandos locales

Ejecutar desde `app/`:

```powershell
flutter pub get
flutter analyze
flutter test
flutter run
```

## Configuración del backend

La URL base se resuelve en `lib/core/constants/api_config.dart`.

- Android: `http://10.0.2.2:5225`
- iOS simulator, desktop y tests locales: `http://localhost:5225`
- Override por ejecución: `--dart-define=BACKEND_BASE_URL=<url>`

Ejemplo para emulador Android:

```powershell
flutter run --dart-define=BACKEND_BASE_URL=http://10.0.2.2:5225
```

Ejemplo para dispositivo físico Android usando `adb reverse`:

```powershell
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
& $adb reverse tcp:5225 tcp:5225
flutter run --dart-define=BACKEND_BASE_URL=http://127.0.0.1:5225
```

Un cambio en `--dart-define` requiere reiniciar `flutter run`; hot reload no actualiza ese valor.

## Autenticación

La app implementa:

- Registro.
- Login.
- Logout.
- Restauración de sesión con `/auth/me`.
- Token Bearer guardado en secure storage.
- Interceptor Dio para `Authorization: Bearer <token>`.
- Rutas protegidas.
- Roles mobile `admin` y `collaborator`.

La autorización definitiva debe validarse en el backend. Firebase Auth no se usa.

## Funcionalidad implementada

- Productos: catálogo, búsqueda, filtros, detalle, creación, edición, activar/desactivar, imagen y autocompletado por barcode vía `/product-lookup/{barcode}`.
- Sucursales: listado, filtros, crear, editar, desactivar/reactivar.
- Stock: consulta por sucursal, búsqueda y filtros.
- Movimientos: historial, filtro por tipo, búsqueda local y formulario de entrada/salida.
- Importación CSV: selección de archivo, subida, resultado, errores y últimas importaciones.
- Notificaciones: FCM/local notifications y registro de token contra backend.
- Health check: `/health`.

## Limitaciones conocidas

- `Alertas` es placeholder.
- El dashboard tiene métricas parcialmente reales y elementos demo/pendientes.
- El detalle de producto marca como pendientes "Stock por sucursal" y "Últimos movimientos".
- Stock usa sucursales temporales hardcodeadas en `core/constants/stock_config.dart`.
- Open Food Facts no se consume directamente desde Flutter; la app llama al backend.
- La subida de imágenes usa el backend, no Firebase Storage.
- FCM requiere configuración Firebase válida y soporte server-side para validación end to end.
- No hay carpeta `integration_test/` confirmada en el código actual.
