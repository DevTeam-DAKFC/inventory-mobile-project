# Aplicación móvil de inventario

Esta carpeta contiene la aplicación móvil Flutter del sistema de gestión de inventario.

El backend vive fuera de esta carpeta y fuera de este repositorio móvil, en el repositorio separado `inventory-backend`. La aplicación consumirá la API REST externa expuesta por ASP.NET Core Web API usando Dio / HttpClient desde Flutter.

La persistencia principal con SQL Server pertenece al backend externo, por lo que la aplicación móvil no se conectará directamente a la base de datos. Esta carpeta no contiene estructura backend inicial, configuración Docker Compose, migraciones EF Core ni pruebas backend.

Firebase no será el backend principal de la aplicación. Se utilizará para Firebase Cloud Messaging en notificaciones push y, si el equipo lo decide, Firebase Storage para imágenes de productos.

## Comandos locales

Ejecutar estos comandos desde la carpeta `app/`:

```powershell
flutter pub get
flutter analyze
flutter test
flutter run
```

## Configuración del backend móvil

La URL base de Dio se resuelve en `lib/core/constants/api_config.dart` y se inyecta mediante `apiConfigProvider`.

- Android emulator: `http://10.0.2.2:5225`
- iOS simulator, desktop y pruebas locales: `http://localhost:5225`
- Override para demos o dispositivos físicos:

```powershell
flutter run --dart-define=BACKEND_BASE_URL=http://<host>:5225
```

El valor se normaliza sin `/` final para que los data sources puedan usar rutas relativas como `/products` y `/stock`.

## Autenticación y requests protegidos

La app contiene pantallas de login/logout, almacenamiento seguro de token y un interceptor Dio que adjunta `Authorization: Bearer <token>` cuando existe una sesión guardada. Los providers de productos, stock, movimientos, sucursales, imports y notificaciones usan el Dio autenticado.

Para pruebas manuales sin login real se puede pasar un token de desarrollo con:

```powershell
flutter run --dart-define=DEV_ACCESS_TOKEN=<token>
```

Si el backend usado en la demostración final no expone autenticación ni autorización por rol, validar login/logout, roles y requests protegidos como alcance no aplicable del backend final. No agregar flujos nuevos de autenticación para esta entrega.

## Limitaciones conocidas para la validación final

- El backend vive en el repositorio separado `inventory-backend`; esta app solo consume la API REST.
- La configuración local asume el puerto `5225` salvo que se use `BACKEND_BASE_URL`.
- Las secciones de stock por sucursal y últimos movimientos dentro del detalle de producto se muestran como pendientes de integración; el listado de productos y la pantalla principal de stock sí forman parte del demo móvil actual.
