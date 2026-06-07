# Inventory Mobile Project

Aplicación móvil desarrollada con **Flutter** para la gestión de inventario multiusuario en una pequeña cadena de tiendas locales.

El sistema busca resolver una problemática de control de inventario entre sucursales, donde actualmente se utilizan registros manuales y hojas de cálculo que generan inconsistencias, pérdidas de productos y poca trazabilidad de movimientos.

---

## 1. Descripción del proyecto

La aplicación permite que usuarios autenticados gestionen productos, visualicen existencias por sucursal, registren entradas y salidas de inventario, consulten el historial de movimientos y reciban alertas relacionadas con bajo stock.

El enfoque del proyecto es construir un producto **funcional y profesional**, de alcance controlado, pero con buena calidad técnica, documentación clara, pruebas automatizadas e integración continua.

No se busca construir un sistema ERP completo. El alcance se centra en:

- Productos.
- Sucursales.
- Stock.
- Movimientos de inventario.
- Historial.
- Búsqueda y filtros.
- Autenticación.
- Imágenes.
- API externa.
- Notificaciones.
- Testing.
- CI/CD.

---

## 2. Problemática

Una pequeña cadena de tiendas locales presenta problemas en el control de inventario entre sus sucursales.

Actualmente usan hojas de cálculo y registros manuales, lo que provoca:

- Inconsistencias en existencias.
- Pérdidas de productos.
- Falta de trazabilidad sobre movimientos.
- Dificultad para saber qué colaborador realizó una entrada o salida.
- Baja eficiencia para consultar inventario disponible.

La solución propuesta es una aplicación móvil que permita centralizar y organizar el control de inventario desde dispositivos móviles.

---

## 3. Funcionalidades principales

### Funcionalidades del producto

- Autenticación de usuarios.
- Registro e inicio de sesión.
- Roles básicos: `admin` y `collaborator`.
- Gestión completa de productos.
- Registro manual de productos.
- Autocompletado de productos usando API externa.
- Carga de imagen de producto.
- Gestión simple de sucursales.
- Visualización de stock por sucursal.
- Registro de entradas de inventario.
- Registro de salidas de inventario.
- Validación de stock insuficiente.
- Historial de movimientos.
- Búsqueda y filtros.
- Alertas o notificaciones relacionadas con bajo stock.
- Almacenamiento local básico para preferencias.
- Testing automatizado.
- GitHub Actions.

### Funcionalidades complementarias

- Importación inicial de productos desde archivo CSV.
- Vista previa y validación básica de importación.
- Registro de movimiento inicial cuando se importe stock.

### Fuera de alcance

- Implementación de los endpoints del backend dentro de este repositorio.
- Recuperación de contraseña (forgot password).
- Login social.
- Firebase Auth.
- ERP completo.
- Facturación.
- Gestión de proveedores.
- Reportes estadísticos complejos.
- Panel web administrativo.
- Permisos granulares avanzados.
- Inventario offline completo.
- Transferencias complejas entre sucursales.
- Automatización completa de push notifications mediante Cloud Functions.
- Importación avanzada de Excel `.xlsx`.
- Módulos de productos y movimientos mientras no estén implementados en la app.
- Roles avanzados y soporte multi-sucursal avanzado mientras no estén implementados en la app.

---

## 4. Estado actual de autenticación

La autenticación móvil ya está implementada y operativa en el repositorio. Actualmente la app soporta:

- Registro de usuarios.
- Inicio de sesión.
- Almacenamiento seguro del token (secure storage).
- Adjunto del Bearer token en cada request mediante un cliente Dio autenticado.
- Restauración de sesión usando el endpoint existente `/auth/me`.
- Cierre de sesión (logout).
- Redirecciones automáticas para rutas protegidas.
- Mensajes de validación y de error en español.

Notas importantes sobre el flujo de autenticación:

- **Firebase Auth no se utiliza.** El flujo principal de autenticación no depende de Firebase.
- La app consume la **API de autenticación existente del backend** (`inventory-backend`).
- La implementación de los endpoints de autenticación vive en el repositorio `inventory-backend`, no en este repositorio.

---

## 5. Stack técnico

Stack del repositorio móvil:

| Área | Tecnología |
|---|---|
| Framework móvil | Flutter |
| Lenguaje | Dart |
| Arquitectura | MVVM |
| Estado / DI | Riverpod |
| Backend externo | `inventory-backend` con ASP.NET Core Web API |
| Persistencia backend | SQL Server en el repositorio backend |
| Infraestructura backend | Docker / Docker Compose en `inventory-backend` |
| Cliente HTTP en Flutter | Dio |
| Autenticación móvil | Token Bearer emitido por el backend + almacenamiento seguro local |
| Notificaciones push | Firebase Cloud Messaging |
| Almacenamiento de imágenes | Firebase Storage o almacenamiento de archivos gestionado por backend, decisión pendiente |
| API externa | Open Food Facts API |
| Almacenamiento local | Shared Preferences |
| Testing móvil | Flutter test, widget tests, integration tests |
| CI/CD móvil | GitHub Actions |

---

## 6. Decisiones técnicas principales

- Este repositorio contiene la aplicación Flutter, documentación móvil, pruebas móviles y contratos de API consumidos por la app.
- El backend se mantiene en el repositorio separado `inventory-backend`.
- La aplicación Flutter consume el backend externo mediante Dio.
- SQL Server y Docker Compose pertenecen al repositorio backend.
- Este repositorio no contiene código fuente ASP.NET Core, configuración SQL Server, migraciones EF Core ni pruebas backend.
- La autenticación se resuelve contra el backend existente. Firebase Auth no participa en el flujo.
- Firebase se mantiene para Firebase Cloud Messaging y, opcionalmente, para almacenamiento de imágenes.
- El contrato OpenAPI `docs/api-contracts/openapi.inventory-api.yaml` se mantiene como referencia REST que la app móvil consume desde el backend externo.
- La API externa se usará únicamente para autocompletar productos por código de barras.
- La sucursal es una entidad obligatoria del dominio.
- El stock se maneja por combinación `productId + branchId`.
- El stock no se edita directamente desde el producto.
- El stock cambia mediante movimientos de inventario.
- Los movimientos son la fuente de trazabilidad.
- Riverpod se usa para estado e inyección de dependencias.
- La UI no accede directamente al backend, Firebase, APIs externas ni almacenamiento local.
- El acceso a datos pasa por repositorios y data sources.

---

## 7. Arquitectura

La aplicación sigue una arquitectura por capas con MVVM y Repository Pattern.

Flujo general:

```text
UI
→ ViewModel
→ Repository
→ RestApiDataSource (Dio autenticado)
→ inventory-backend / ASP.NET Core Web API
→ SQL Server en el repositorio backend
```

Principio base:

```text
La UI no debe conocer detalles del backend, SQL Server, Firebase, Storage, FCM, Dio ni almacenamiento local.
```

El almacenamiento local se usa para preferencias, estado liviano y almacenamiento seguro del token de sesión. La búsqueda externa de productos se mantiene soportada para autocompletar información por código de barras. Firebase se usa para notificaciones push mediante FCM y, si el equipo lo decide, para almacenamiento de imágenes.

Estructura esperada dentro de `app/lib`:

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

---

## 8. Estructura del repositorio

```text
inventory-mobile-project/
├── .github/
│   └── workflows/
├── app/
├── docs/
│   ├── api-contracts/
│   ├── architecture/
│   ├── research/
│   ├── screenshots/
│   ├── video/
│   └── workshop/
├── tests/
└── README.md
```

### Carpetas principales

| Carpeta | Propósito |
|---|---|
| `.github/workflows` | Workflows de GitHub Actions. |
| `app` | Proyecto Flutter. |
| `docs/architecture` | Alcance, arquitectura, modelo de datos y navegación. |
| `docs/api-contracts` | Contrato REST consumido por la app, referencia compartida de esquema backend, API externa y mock data. |
| `docs/research` | Informe de investigación sobre Flutter en PDF. |
| `docs/screenshots` | Evidencia visual del proyecto. |
| `docs/video` | Guion o apoyo para video técnico. |
| `docs/workshop` | Guía del workshop y live coding. |
| `tests` | Plan de pruebas y casos manuales. |

---

## 9. Documentación disponible

### Arquitectura

```text
docs/architecture/project-scope.md
docs/architecture/technical-decisions.md
docs/architecture/data-model.md
docs/architecture/system-architecture.md
docs/architecture/navigation-map.md
docs/architecture/layers-explanation.md
```

### API contracts

```text
docs/api-contracts/README.md
docs/api-contracts/openapi.inventory-api.yaml
docs/api-contracts/external-product-api.md
docs/api-contracts/mock-data.md
```

`openapi.inventory-api.yaml` describe el contrato REST que la aplicación móvil consume desde el backend externo `inventory-backend`.

La documentación de esquema SQL Server pertenece al repositorio separado `inventory-backend`. No implica que SQL Server, migraciones, Docker Compose o código backend existan dentro de `inventory-mobile-project`.

`external-product-api.md` describe la integración con Open Food Facts y `mock-data.md` se mantiene útil para desarrollo, pruebas y demos.

### Testing

```text
tests/test-plan.md
```

### Investigación

```text
docs/research/flutter-research.pdf
```

---

## 10. Instalación del proyecto

> Estado actual: este repositorio incluye el proyecto Flutter dentro de `app/`, documentación móvil y contratos de API consumidos por la app. El backend ASP.NET Core Web API, SQL Server, Docker Compose, migraciones y pruebas backend pertenecen al repositorio separado `inventory-backend`.

### Requisitos

- Git.
- Flutter SDK.
- Android Studio.
- Android SDK.
- Emulador Android o dispositivo físico.
- Acceso al backend `inventory-backend` corriendo localmente para probar la autenticación y los endpoints.
- Cuenta y proyecto Firebase disponibles para configurar FCM y, si se decide, Firebase Storage más adelante.

### Verificar Flutter

```powershell
flutter --version
flutter doctor
```

### Entrar al proyecto Flutter

```powershell
cd .\app
```

### Instalar dependencias

```powershell
flutter pub get
```

### Validar el proyecto

```powershell
flutter analyze
flutter test
```

### Ejecutar aplicación

```powershell
flutter run
```

Para que el inicio de sesión y el registro funcionen contra el backend, ver la sección **Conectividad con el backend** y las secciones de ejecución en dispositivo físico o emulador.

---

## 11. Conectividad con el backend

La app móvil necesita que el backend `inventory-backend` esté corriendo de forma separada. La implementación de los endpoints (autenticación, productos, stock, movimientos, etc.) vive en ese repositorio, no en este.

Puntos clave:

- **Repositorio backend:** `inventory-backend`.
- **Puerto local por defecto durante desarrollo:** `5225`.
- **Variable que la app espera:** `BACKEND_BASE_URL`.

`BACKEND_BASE_URL` se pasa a Flutter en tiempo de ejecución mediante `--dart-define`. No se debe commitear como configuración con secretos. Para desarrollo local apuntando al backend en la misma máquina:

```text
BACKEND_BASE_URL=http://127.0.0.1:5225
```

Ejemplo de comando:

```powershell
flutter run --dart-define=BACKEND_BASE_URL=http://127.0.0.1:5225
```

Si `BACKEND_BASE_URL` no se pasa al iniciar la app, los llamados al backend pueden fallar o usar un valor por defecto distinto. Un hot reload **no** es suficiente para tomar un nuevo `--dart-define`: hay que detener y volver a lanzar `flutter run`.

---

## 12. Ejecutar la app en dispositivo Android físico

Para ejecutar la app en un teléfono Android físico apuntando al backend que corre en la PC, se usa `adb reverse` para que el teléfono pueda alcanzar `127.0.0.1:5225` como si fuera local.

Pasos en PowerShell:

```powershell
cd C:\dev\inventory-mobile-project\app

$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
& $adb -s RFCX30ACQNE reverse tcp:5225 tcp:5225
& $adb -s RFCX30ACQNE reverse --list

flutter run -d RFCX30ACQNE --dart-define=BACKEND_BASE_URL=http://127.0.0.1:5225
```

Notas importantes:

- Reemplazar `RFCX30ACQNE` por el ID real del dispositivo. Se puede obtener con:

  ```powershell
  flutter devices
  ```

- `adb reverse tcp:5225 tcp:5225` hace que el teléfono pueda llegar al backend de la PC a través de `127.0.0.1:5225`. Sin este paso el teléfono no podrá alcanzar el backend local.
- Si la app fue lanzada sin `--dart-define=BACKEND_BASE_URL=...`, un hot reload **no es suficiente**. Hay que detener `flutter run` y volver a lanzarlo con el `--dart-define` correcto.
- Si el teléfono se desconecta y se vuelve a conectar (cable USB, cambio de modo, reinicio), puede ser necesario volver a ejecutar `adb reverse`.
- Verificar que el backend `inventory-backend` esté efectivamente escuchando en `http://127.0.0.1:5225` antes de probar el flujo de login/registro.

---

## 13. Ejecutar la app en emulador

En emulador Android, el host de la máquina anfitriona se alcanza típicamente mediante la IP especial `10.0.2.2`, por lo que **no es necesario** ejecutar `adb reverse`.

Si se prefiere emulador sin `adb reverse`:

```powershell
flutter run --dart-define=BACKEND_BASE_URL=http://10.0.2.2:5225
```

Resumen rápido:

- Emulador Android sin `adb reverse`: usar `http://10.0.2.2:5225`.
- Dispositivo Android físico con `adb reverse`: usar `http://127.0.0.1:5225`.

---

## 14. Validaciones locales

Desde la carpeta `app`:

```powershell
flutter pub get
flutter analyze
flutter test
```

Cuando el entorno Android esté configurado:

```powershell
flutter build apk --debug
```

Si se agregan integration tests:

```powershell
flutter test integration_test
```

Notas de validación manual:

- Los cambios visibles de UI deben validarse manualmente en un dispositivo Android físico cuando aplique.
- En los Pull Requests que cambien UI o comportamiento visible se debe adjuntar evidencia: capturas de pantalla y/o video corto.

---

## 15. GitHub Actions

El proyecto incluye un workflow para validar pushes y pull requests.

Archivo esperado:

```text
.github/workflows/flutter-ci.yml
```

Validaciones mínimas:

```text
flutter pub get
flutter analyze
flutter test
```

Validación recomendada:

```text
flutter build apk --debug
```

---

## 16. Datos de prueba

Los datos de prueba están documentados en:

```text
docs/api-contracts/mock-data.md
```

Incluyen:

- Usuarios demo.
- Sucursales demo.
- Productos demo.
- Stock inicial.
- Movimientos de ejemplo.
- Casos de bajo stock.
- Casos de salida con stock insuficiente.
- Ejemplos de CSV válido e inválido.

---

## 17. API externa

La aplicación consume **Open Food Facts API** para buscar información de productos por código de barras.

Uso esperado:

```text
Usuario ingresa código de barras
→ App consulta API externa
→ API devuelve datos sugeridos
→ Usuario revisa y corrige
→ Producto se guarda mediante la API REST del backend externo
```

La API externa no reemplaza el registro manual.

Contrato documentado en:

```text
docs/api-contracts/external-product-api.md
```

---

## 18. Servicios Firebase

Firebase se mantiene como parte del stack únicamente para servicios complementarios:

- **Firebase Cloud Messaging (FCM)** para notificaciones push.
- **Firebase Storage** posiblemente para almacenamiento de imágenes, si el equipo lo decide.

Servicios contemplados:

```text
Firebase Cloud Messaging
Firebase Storage (opcional, pendiente de decisión)
```

Notas importantes:

- **Firebase Auth no se usa** en el flujo de autenticación actual.
- La autenticación principal se maneja contra la **API existente del backend** (`inventory-backend`).
- La persistencia principal se resuelve en el backend externo con SQL Server. La app móvil solo consume endpoints REST.

---

## 19. Testing

El plan de pruebas está documentado en:

```text
tests/test-plan.md
```

Tipos de pruebas contemplados:

- Unit tests.
- Widget tests.
- Integration tests.
- Casos positivos.
- Casos negativos.
- Pruebas manuales documentadas.

---

## 20. Flujo de trabajo

El equipo trabaja usando GitHub de forma profesional.

Se espera:

- Uso de ramas.
- Pull Requests.
- Code Reviews.
- GitHub Projects.
- Issues o tickets.
- Commits distribuidos entre integrantes.
- Evidencia de validación por PR.

Convención sugerida de ramas:

```text
feature/INV-001-short-description
fix/INV-002-short-description
docs/INV-003-short-description
test/INV-004-short-description
```

Convención sugerida de commits:

```text
feat(products): add product form
fix(stock): prevent outgoing movement with insufficient stock
docs(architecture): add data model
test(movements): add stock validation tests
```

---

## 22. Licencia

Proyecto de gestión de inventario desarrollado como solución móvil profesional.

La licencia formal queda pendiente de definición por el equipo.
