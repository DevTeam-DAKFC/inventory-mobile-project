# Inventory Mobile Project

Aplicación móvil desarrollada con **Flutter** para la gestión de inventario multiusuario en una pequeña cadena de tiendas locales.

El proyecto forma parte del curso **Diseño y Programación de Plataformas Móviles** y busca resolver una problemática de control de inventario entre sucursales, donde actualmente se utilizan registros manuales y hojas de cálculo que generan inconsistencias, pérdidas de productos y poca trazabilidad de movimientos.

---

## 1. Descripción del proyecto

La aplicación permitirá que usuarios autenticados puedan gestionar productos, visualizar existencias por sucursal, registrar entradas y salidas de inventario, consultar historial de movimientos y recibir alertas relacionadas con bajo stock.

El enfoque del proyecto es construir un **MVP académico-profesional**, de alcance controlado, pero con buena calidad técnica, documentación clara, pruebas automatizadas e integración continua.

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

| Área | Tecnología |
|---|---|
| Framework móvil | Flutter |
| Lenguaje | Dart |
| Arquitectura | MVVM |
| Estado / DI | Riverpod |
| Backend principal | Firebase |
| Autenticación | Firebase Auth |
| Base de datos | Cloud Firestore |
| Imágenes | Firebase Storage |
| Notificaciones | Firebase Cloud Messaging |
| API externa | Open Food Facts API |
| HTTP client | Dio |
| Almacenamiento local | Shared Preferences |
| Testing | Flutter test, widget tests, integration tests |
| CI/CD | GitHub Actions |

---

## 5. Decisiones técnicas principales

- Firebase será el backend principal.
- No se construirá una API REST propia para el MVP.
- La API externa se usará únicamente para autocompletar productos por código de barras.
- La sucursal es una entidad obligatoria del dominio.
- El stock se maneja por combinación `productId + branchId`.
- El stock no se edita directamente desde el producto.
- El stock cambia mediante movimientos de inventario.
- Los movimientos son la fuente de trazabilidad.
- Riverpod se usará para estado e inyección de dependencias.
- La UI no accederá directamente a Firebase ni a APIs externas.
- El acceso a datos pasará por repositorios y data sources.

---

## 6. Arquitectura

La aplicación seguirá una arquitectura por capas con MVVM y Repository Pattern.

Flujo general:

```text
UI
→ ViewModel
→ Repository
→ Data Source
→ Firebase / API externa / almacenamiento local
```

Principio base:

```text
La UI no debe conocer detalles de Firebase, Firestore, Storage, FCM, Dio ni almacenamiento local.
```

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
| `docs/contracts` | Contratos de Firestore, API externa y mock data. |
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
docs/contracts/README.md
docs/contracts/firestore-collections.md
docs/contracts/external-product-api.md
docs/contracts/mock-data.md
```

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

> Estado actual: el repositorio contiene la estructura base y documentación inicial. El proyecto Flutter debe crearse dentro de la carpeta `app`.

### Requisitos

- Git.
- Flutter SDK.
- Android Studio.
- Android SDK.
- Emulador Android o dispositivo físico.
- Firebase project configurado.

### Verificar Flutter

```powershell
flutter --version
flutter doctor
```

### Crear proyecto Flutter dentro de `/app`

Desde la raíz del repositorio:

```powershell
cd C:\dev\inventory-mobile-project

flutter create --project-name inventory_mobile app
```

### Entrar al proyecto Flutter

```powershell
cd .\app
```

### Instalar dependencias

```powershell
flutter pub get
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
docs/contracts/mock-data.md
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
→ Producto se guarda en Firestore
```

La API externa no reemplaza el registro manual.

Contrato documentado en:

```text
docs/contracts/external-product-api.md
```

---

## 14. Firebase

Firebase se utilizará para:

- Autenticación.
- Persistencia.
- Imágenes.
- Notificaciones.

Servicios esperados:

```text
Firebase Auth
Cloud Firestore
Firebase Storage
Firebase Cloud Messaging
```

La configuración específica de Firebase se agregará durante la implementación del proyecto Flutter.

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
- Contratos de Firestore.
- Contrato de API externa.
- Mock data.
- Plan de pruebas.

### Pendiente

- Crear proyecto Flutter dentro de `app`.
- Configurar Firebase.
- Configurar dependencias Flutter.
- Implementar arquitectura base.
- Implementar navegación.
- Implementar módulos funcionales.
- Crear GitHub Actions.
- Completar informe de investigación en PDF.
- Preparar video técnico.
- Preparar workshop.

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
- Participación de la clase.
- Defensa técnica individual.

Guía pendiente:

```text
docs/workshop/workshop-guide.md
```

---

## 21. Uso responsable de IA

El uso de IA puede apoyar planificación, documentación, revisión y generación de ideas.

Sin embargo:

- El equipo debe comprender todo el código entregado.
- Cada integrante debe poder explicar su parte.
- Las decisiones técnicas deben ser justificables.
- El código generado o asistido debe revisarse críticamente.
- La IA no reemplaza el dominio técnico esperado del curso.

---

## 22. Licencia

Proyecto académico desarrollado para el curso Diseño y Programación de Plataformas Móviles.

La licencia formal queda pendiente de definición por el equipo.

