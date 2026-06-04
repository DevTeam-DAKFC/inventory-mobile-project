# Inventory Mobile Project

Aplicación móvil desarrollada con **Flutter** para la gestión de inventario multiusuario en una pequeña cadena de tiendas locales.

El sistema busca resolver una problemática de control de inventario entre sucursales, donde actualmente se utilizan registros manuales y hojas de cálculo que generan inconsistencias, pérdidas de productos y poca trazabilidad de movimientos.

---

## 1. Descripción del proyecto

La aplicación permitirá que usuarios autenticados puedan gestionar productos, visualizar existencias por sucursal, registrar entradas y salidas de inventario, consultar historial de movimientos y recibir alertas relacionadas con bajo stock.

El enfoque del proyecto es construir un **MVP funcional y profesional**, de alcance controlado, pero con buena calidad técnica, documentación clara, pruebas automatizadas e integración continua.

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

### Funcionalidades del MVP

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

### Fuera de alcance del MVP

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

---

## 4. Stack técnico

Stack objetivo planificado:

| Área | Tecnología |
|---|---|
| Framework móvil | Flutter |
| Lenguaje | Dart |
| Arquitectura | MVVM |
| Estado / DI | Riverpod |
| Backend principal | ASP.NET Core Web API |
| Base de datos | SQL Server |
| Infraestructura backend | Docker / Docker Compose |
| Cliente HTTP en Flutter | Dio |
| Notificaciones push | Firebase Cloud Messaging |
| Almacenamiento de imágenes | Firebase Storage o almacenamiento de archivos gestionado por backend, decisión pendiente |
| API externa | Open Food Facts API |
| Almacenamiento local | Shared Preferences |
| Testing | Flutter test, widget tests, integration tests |
| CI/CD | GitHub Actions |

---

## 5. Decisiones técnicas principales

- La aplicación Flutter consumirá una API REST usando Dio.
- ASP.NET Core Web API expondrá los endpoints backend planificados.
- SQL Server será la capa principal de persistencia.
- Docker se utilizará para la infraestructura backend planificada.
- Firebase se mantiene para Firebase Cloud Messaging y, opcionalmente, para almacenamiento de imágenes.
- El contrato OpenAPI `docs/api-contracts/openapi.inventory-api.yaml` se mantiene como el contrato backend que deberá implementar la API.
- La API externa se usará únicamente para autocompletar productos por código de barras.
- La sucursal es una entidad obligatoria del dominio.
- El stock se maneja por combinación `productId + branchId`.
- El stock no se edita directamente desde el producto.
- El stock cambia mediante movimientos de inventario.
- Los movimientos son la fuente de trazabilidad.
- Riverpod se usará para estado e inyección de dependencias.
- La UI no accederá directamente al backend, Firebase, APIs externas ni almacenamiento local.
- El acceso a datos pasará por repositorios y data sources.

---

## 6. Arquitectura

La aplicación seguirá una arquitectura por capas con MVVM y Repository Pattern.

Flujo general:

```text
UI
→ ViewModel
→ Repository
→ RestApiDataSource
→ ASP.NET Core Web API
→ SQL Server
```

Principio base:

```text
La UI no debe conocer detalles del backend, SQL Server, Firebase, Storage, FCM, Dio ni almacenamiento local.
```

El almacenamiento local se mantiene para preferencias y estado local liviano. La búsqueda externa de productos seguirá soportada para autocompletar información por código de barras. Firebase se usará para notificaciones push mediante FCM y, si el equipo lo decide, para almacenamiento de imágenes.

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

## 7. Estructura del repositorio

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
| `docs/api-contracts` | Contrato REST backend-compatible (OpenAPI), esquema SQL Server planificado, API externa y mock data. |
| `docs/research` | Informe de investigación sobre Flutter en PDF. |
| `docs/screenshots` | Evidencia visual del proyecto. |
| `docs/video` | Guion o apoyo para video técnico. |
| `docs/workshop` | Guía del workshop y live coding. |
| `tests` | Plan de pruebas y casos manuales. |

---

## 8. Documentación disponible

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
docs/api-contracts/sqlserver-schema.md
docs/api-contracts/external-product-api.md
docs/api-contracts/mock-data.md
```

`openapi.inventory-api.yaml` describe el contrato REST que el backend ASP.NET Core Web API deberá implementar. No implica que dicho backend esté implementado.

`sqlserver-schema.md` describe el contrato de esquema SQL Server planificado para la persistencia detrás del backend. No implica que la base de datos, las migraciones o el backend ya existan.

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

## 9. Instalación del proyecto

> Estado actual: el repositorio incluye el proyecto Flutter inicial dentro de la carpeta `app/`, junto con la documentación base y el contrato OpenAPI. El backend ASP.NET Core Web API, la configuración de SQL Server con Docker Compose y la configuración de FCM aún están pendientes.

### Requisitos

- Git.
- Flutter SDK.
- Android Studio.
- Android SDK.
- Emulador Android o dispositivo físico.
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

---

## 10. Validaciones locales

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

---

## 11. GitHub Actions

El proyecto deberá incluir un workflow para validar pushes y pull requests.

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

## 12. Datos de prueba

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

## 13. API externa

La aplicación consumirá **Open Food Facts API** para buscar información de productos por código de barras.

Uso esperado:

```text
Usuario ingresa código de barras
→ App consulta API externa
→ API devuelve datos sugeridos
→ Usuario revisa y corrige
→ Producto se guarda mediante la API REST backend
```

La API externa no reemplaza el registro manual.

Contrato documentado en:

```text
docs/api-contracts/external-product-api.md
```

---

## 14. Servicios Firebase

Firebase se mantiene como parte del stack para servicios específicos:

- Firebase Cloud Messaging para notificaciones push.
- Firebase Storage como opción de almacenamiento de imágenes, pendiente de decisión final.

Servicios contemplados:

```text
Firebase Cloud Messaging
Firebase Storage
```

La persistencia principal será SQL Server a través del backend ASP.NET Core Web API. La estrategia final de autenticación se definirá dentro del diseño del backend.

---

## 15. Testing

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

## 16. Flujo de trabajo

El equipo trabajará usando GitHub de forma profesional.

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

## 17. Estado actual del proyecto

### Completado

- Estructura base del repositorio.
- Documentación inicial de arquitectura.
- Contrato OpenAPI backend-compatible (`openapi.inventory-api.yaml`).
- Contrato de API externa.
- Mock data.
- Plan de pruebas.
- Proyecto Flutter creado dentro de `app/`, con `flutter pub get`, `flutter analyze` y `flutter test` ejecutándose correctamente sobre el scaffold inicial.

### Pendiente

- Crear el scaffold del backend ASP.NET Core Web API.
- Agregar la configuración de SQL Server con Docker Compose.
- Implementar la persistencia backend con SQL Server.
- Implementar los endpoints backend según `openapi.inventory-api.yaml`.
- Conectar `RestApiDataSource` en Flutter usando Dio.
- Configurar Firebase Cloud Messaging.
- Decidir la estrategia final de almacenamiento de imágenes.
- Agregar el workflow de GitHub Actions.
- Configurar dependencias base del producto en Flutter (Riverpod, go_router, Dio, FCM, entre otras).
- Implementar la estructura de capas descrita en `docs/architecture/layers-explanation.md`.
- Implementar navegación según `docs/architecture/navigation-map.md`.
- Implementar módulos funcionales según el alcance del MVP.
- Completar el documento de investigación en PDF en `docs/research/`.
- Preparar el video técnico.
- Preparar la guía del workshop.

---

## 18. Integrantes

| Integrante | Rol / Responsabilidad |
|---|---|
| Pendiente | Pendiente |
| Pendiente | Pendiente |
| Pendiente | Pendiente |
| Pendiente | Pendiente |

---

## 19. Video técnico

El video técnico deberá explicar:

- Arquitectura del proyecto.
- Decisiones técnicas.
- Flujo funcional.
- Testing.
- Integración continua.
- Problemas encontrados y soluciones.

Enlace pendiente:

```text
Pendiente
```

---

## 20. Workshop técnico

El workshop deberá incluir:

- Explicación del framework.
- Explicación de arquitectura.
- Actividad práctica guiada.
- Live coding.
- Sesión de preguntas.
- Revisión técnica del flujo implementado.

Guía pendiente:

```text
docs/workshop/workshop-guide.md
```

---

## 21. Uso responsable de IA

El uso de IA puede apoyar planificación, documentación, revisión y generación de ideas.

Sin embargo:

- El equipo debe comprender todo el código del sistema.
- Cada integrante debe poder explicar su parte.
- Las decisiones técnicas deben ser justificables.
- El código generado o asistido debe revisarse críticamente.
- La IA no reemplaza el criterio técnico esperado del equipo.

---

## 22. Licencia

Proyecto de gestión de inventario desarrollado como solución móvil profesional.

La licencia formal queda pendiente de definición por el equipo.
