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
