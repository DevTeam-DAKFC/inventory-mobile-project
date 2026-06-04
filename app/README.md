# Aplicación móvil de inventario

Esta carpeta contiene la aplicación móvil Flutter del sistema de gestión de inventario.

La aplicación consumirá una API REST expuesta por un backend ASP.NET Core Web API usando Dio / HttpClient desde Flutter. La persistencia principal con SQL Server estará detrás del backend, por lo que la aplicación móvil no se conectará directamente a la base de datos.

Firebase no será el backend principal de la aplicación. Se utilizará para Firebase Cloud Messaging en notificaciones push y, si el equipo lo decide, Firebase Storage para imágenes de productos.

## Comandos locales

Ejecutar estos comandos desde la carpeta `app/`:

```powershell
flutter pub get
flutter analyze
flutter test
flutter run
```
