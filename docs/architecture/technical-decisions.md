# Technical Decisions - Sistema de Gestión de Inventario Multiusuario

## 1. Propósito del documento

Este documento registra las decisiones técnicas principales del proyecto. Su objetivo es mantener una guía común para el equipo durante el diseño, implementación, testing, documentación y revisión técnica.

Las decisiones aquí descritas deben mantenerse alineadas con el alcance definido en:

```text
docs/architecture/project-scope.md
```

---

## 2. Resumen de decisiones

| ID | Decisión |
|---|---|
| DT-01 | Usar Flutter y Dart |
| DT-02 | Usar Firebase como backend principal |
| DT-03 | No construir una API REST propia para el MVP |
| DT-04 | Usar Firebase Auth para autenticación |
| DT-05 | Usar Cloud Firestore para persistencia |
| DT-06 | Usar Firebase Storage para imágenes |
| DT-07 | Usar Firebase Cloud Messaging para push notifications |
| DT-08 | Usar una API externa para autocompletar productos |
| DT-09 | Usar Dio solo para consumo de API externa |
| DT-10 | Usar MVVM como patrón de presentación |
| DT-11 | Usar Riverpod para manejo de estado e inyección de dependencias |
| DT-12 | Usar Repository Pattern |
| DT-13 | Usar estructura layer-first simplificada |
| DT-14 | Mantener Branch como entidad obligatoria |
| DT-15 | Manejar stock por `productId + branchId` |
| DT-16 | Cambiar stock únicamente mediante movimientos |
| DT-17 | Usar Firestore transactions para registrar movimientos |
| DT-18 | Manejar dos roles: `admin` y `collaborator` |
| DT-19 | Usar almacenamiento local limitado |
| DT-20 | Permitir registro manual, asistido e importación CSV de productos |
| DT-21 | Implementar estados de UI explícitos |
| DT-22 | Centralizar validaciones |
| DT-23 | Implementar testing automatizado y GitHub Actions |

---

## DT-01: Usar Flutter y Dart

Flutter será el framework principal del proyecto por su capacidad para desarrollar aplicaciones móviles con una sola base de código.

La aplicación se desarrollará con una sola base de código y se enfocará inicialmente en Android, sin descartar compatibilidad futura con otras plataformas soportadas por Flutter.

### Justificación

- Cumple la tecnología asignada.
- Permite construir interfaces móviles consistentes.
- Facilita componentización y reutilización visual.
- Tiene soporte para testing, navegación, estado, integración con Firebase y CI.

---

## DT-02: Usar Firebase como backend principal

Firebase será el backend principal del sistema.

Servicios Firebase utilizados:

| Servicio | Uso |
|---|---|
| Firebase Auth | Autenticación |
| Cloud Firestore | Persistencia de datos |
| Firebase Storage | Imágenes de productos |
| Firebase Cloud Messaging | Notificaciones push |

### Justificación

Firebase permite cubrir autenticación, persistencia, archivos e infraestructura de notificaciones sin construir un backend propio desde cero. Esto mantiene el foco del proyecto en Flutter, arquitectura móvil, UX, validaciones, testing y documentación.

---

## DT-03: No construir una API REST propia para el MVP

El MVP no incluirá una API REST propia desarrollada en .NET, Node.js, Laravel u otra tecnología backend.

La aplicación se comunicará directamente con Firebase mediante los SDKs oficiales y con una API externa específica para autocompletar productos.

### Justificación

Construir una API propia aumentaría significativamente el alcance del proyecto:

- Requeriría endpoints.
- Requeriría autenticación backend.
- Requeriría despliegue.
- Requeriría pruebas adicionales.
- Requeriría documentación OpenAPI completa.
- Desviaría esfuerzo del objetivo móvil del producto.

### Mejora futura

Una API propia podría considerarse en una versión futura si el sistema necesitara reglas empresariales más avanzadas, integraciones externas complejas o administración centralizada del inventario.

---

## DT-04: Usar Firebase Auth para autenticación

La autenticación se implementará con Firebase Auth usando correo y contraseña.

La app permitirá:

- Registro.
- Inicio de sesión.
- Cierre de sesión.
- Persistencia de sesión.
- Identificación del usuario actual.

No se gestionará un JWT propio dentro de la aplicación.

### Justificación

Firebase Auth resuelve la autenticación de forma segura y reduce el trabajo de infraestructura.

---

## DT-05: Usar Cloud Firestore para persistencia

Cloud Firestore será la base de datos principal.

Se almacenarán datos como:

- Usuarios.
- Sucursales.
- Productos.
- Stock.
- Movimientos de inventario.
- Tokens de notificación.
- Información de importación, si aplica.

### Justificación

Firestore permite persistencia en tiempo real, integración directa con Flutter/Firebase, consultas filtradas y estructura flexible para el alcance del proyecto.

---

## DT-06: Usar Firebase Storage para imágenes

Las imágenes de productos se almacenarán en Firebase Storage.

Flujo general:

1. El usuario selecciona una imagen.
2. La app sube la imagen a Firebase Storage.
3. Firebase Storage devuelve una URL de descarga.
4. La URL se guarda en el documento del producto en Firestore.
5. La app usa esa URL para mostrar la imagen en listados y detalles.

### Justificación

Esto permite cumplir el requisito de manejo de imágenes o archivos sin crear un endpoint propio de carga de archivos.

---

## DT-07: Usar Firebase Cloud Messaging para push notifications

Firebase Cloud Messaging se usará para cumplir el requisito de notificaciones push.

Para el MVP:

- La app registrará el token FCM del dispositivo.
- El token se guardará asociado al usuario.
- Se podrá demostrar recepción de una push notification enviada desde Firebase Console.
- La app podrá mostrar alertas locales o in-app cuando un producto quede en bajo stock.

### Limitación del MVP

El envío automático de push notifications por bajo stock no será obligatorio en el MVP, porque requiere un emisor server-side como Cloud Functions.

### Mejora futura

Implementar Cloud Functions para:

- Detectar bajo stock automáticamente.
- Enviar notificaciones push a administradores.
- Centralizar reglas críticas de negocio.

---

## DT-08: Usar una API externa para autocompletar productos

La aplicación consumirá una API externa para apoyar el registro de productos.

Uso propuesto:

- Buscar información por código de barras.
- Obtener sugerencias de nombre, marca, categoría o imagen.
- Presentar los datos al usuario para revisión.
- Guardar el producto en Firestore solo después de confirmación del usuario.

### Justificación

Este flujo cumple el requisito de consumo de APIs externas y aporta valor real al caso de inventario, ya que reduce digitación manual y mejora la calidad del catálogo.

### Regla importante

La API externa no reemplaza el registro manual. Si la API falla o no encuentra información, el usuario podrá crear el producto manualmente.

---

## DT-09: Usar Dio solo para consumo de API externa

Dio se usará únicamente como cliente HTTP para la API externa de productos.

No se usará Dio para comunicarse con Firebase.

### Justificación

Firebase se consume mediante sus SDKs. Dio se reserva para integraciones HTTP externas, manteniendo clara la responsabilidad de cada tecnología.

---

## DT-10: Usar MVVM como patrón de presentación

La app usará MVVM para separar responsabilidades entre UI, estado y acceso a datos.

Flujo esperado:

```text
Screen / Widget
→ ViewModel / Controller
→ Repository
→ Data Source
→ Firebase / API externa / almacenamiento local
```

### Responsabilidades

| Capa | Responsabilidad |
|---|---|
| View | Renderizar UI y capturar acciones |
| ViewModel | Manejar estado, eventos y validaciones de pantalla |
| Repository | Coordinar acceso a datos |
| Data Source | Implementar comunicación con Firebase, API externa o almacenamiento local |
| Domain Model | Representar entidades del sistema |

---

## DT-11: Usar Riverpod para manejo de estado e inyección de dependencias

Riverpod será usado para:

- Estado de pantallas.
- Inyección de repositorios.
- Inyección de servicios.
- Manejo de operaciones asincrónicas.
- Filtros y selección de sucursal.

Tipos de providers esperados:

- Providers de repositorios.
- Providers de servicios.
- Notifiers o AsyncNotifiers para ViewModels.
- Providers de filtros y preferencias.

### Justificación

Riverpod permite manejar estado de forma explícita, testeable y desacoplada del árbol visual.

---

## DT-12: Usar Repository Pattern

Los ViewModels no accederán directamente a Firebase, Firestore, Storage, FCM ni APIs externas.

Toda comunicación pasará por repositorios.

Repositorios previstos:

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

### Justificación

Repository Pattern permite:

- Separar UI de infraestructura.
- Facilitar testing.
- Cambiar implementación interna sin afectar pantallas.
- Mantener una arquitectura defendible.

---

## DT-13: Usar estructura layer-first simplificada

La estructura principal dentro de `lib/` será layer-first simplificada.

Estructura esperada:

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

### Justificación

Esta estructura facilita explicar la arquitectura en revisiones técnicas y mantiene claras las capas del sistema.

### Nota

Aunque la carpeta principal sea layer-first, el backlog y la división del trabajo se organizarán por módulos funcionales:

- Auth.
- Products.
- Branches.
- Stock.
- Movements.
- History.
- Notifications.
- Import.

---

## DT-14: Mantener Branch como entidad obligatoria

La sucursal será una entidad del dominio.

No se tratará como un dato opcional ni decorativo.

### Justificación

La problemática oficial se centra en el control de inventario entre sucursales. Si la sucursal no existe como entidad real, el sistema se reduce a un inventario de una sola tienda.

### Regla

`branchId` será obligatorio en:

- Stock.
- InventoryMovement.
- Filtros de existencias.
- Consultas de historial cuando aplique.

---

## DT-15: Manejar stock por `productId + branchId`

El stock se modelará por combinación de producto y sucursal.

Ejemplo conceptual:

```text
Product
- id
- name
- sku
- category

Stock
- productId
- branchId
- availableQuantity
```

### Regla

El producto no tendrá una cantidad global editable.

La cantidad disponible estará en `Stock`, no en `Product`.

### Justificación

Esto permite que un mismo producto tenga cantidades diferentes en cada sucursal.

---

## DT-16: Cambiar stock únicamente mediante movimientos

El stock solo podrá cambiar mediante movimientos de inventario.

Tipos principales:

- Entrada.
- Salida.

Opcional:

- Ajuste.

### Regla

No se debe editar el stock directamente desde el formulario de producto.

### Justificación

Esto garantiza trazabilidad y permite saber quién realizó cada cambio, cuándo y por qué.

---

## DT-17: Usar Firestore transactions para registrar movimientos

Cuando se registre una entrada o salida, la app usará una transacción de Firestore.

Flujo esperado:

1. Leer el stock actual del producto en la sucursal.
2. Validar cantidad.
3. Si es salida, validar que exista stock suficiente.
4. Calcular nuevo stock.
5. Actualizar documento de stock.
6. Crear documento de movimiento.
7. Guardar stock resultante en el movimiento.

### Justificación

La transacción reduce el riesgo de inconsistencias cuando varios usuarios actualizan el mismo stock.

### Limitación

Para un entorno productivo, esta regla debería moverse a Cloud Functions o a un backend propio. Para el MVP actual, Firestore transactions desde la app son aceptables y mantienen el alcance controlado.

---

## DT-18: Manejar dos roles: `admin` y `collaborator`

El MVP manejará dos roles.

### `admin`

Puede:

- Gestionar productos.
- Gestionar sucursales de forma básica.
- Registrar movimientos.
- Consultar stock.
- Consultar historial.
- Importar productos desde archivo, si la funcionalidad queda implementada.

### `collaborator`

Puede:

- Consultar productos.
- Consultar stock.
- Registrar movimientos permitidos.
- Consultar historial.

### Decisión

El rol se almacenará en el documento del usuario en Firestore.

Ejemplo:

```text
users/{userId}
- name
- email
- role
- branchIds
- createdAt
```

No se usarán custom claims en el MVP para evitar complejidad administrativa adicional.

---

## DT-19: Usar almacenamiento local limitado

El almacenamiento local se usará de forma limitada para preferencias y experiencia de usuario.

Uso previsto:

- Última sucursal seleccionada.
- Preferencia de tema.
- Filtros recientes.
- Configuración simple.

### Decisión

Se puede usar `shared_preferences` para preferencias simples.

Firestore puede encargarse de la persistencia remota y su cache offline propia. No se promete modo offline completo ni resolución de conflictos.

---

## DT-20: Permitir registro manual, asistido e importación CSV de productos

El sistema permitirá tres vías para registrar productos:

1. Registro manual.
2. Registro asistido por API externa.
3. Importación desde archivo CSV como funcionalidad complementaria.

### Registro manual

Será el flujo principal y obligatorio.

### Registro asistido

Usará una API externa para sugerir datos del producto.

### Importación CSV

Permitirá cargar productos desde archivos generados por hojas de cálculo.

### Justificación

Esto refleja mejor el contexto real de una tienda que actualmente usa hojas de cálculo, sin depender exclusivamente de códigos de barras.

### Alcance

La importación CSV será complementaria. La importación avanzada de Excel `.xlsx` queda como mejora futura.

---

## DT-21: Implementar estados de UI explícitos

Las pantallas deberán manejar estados claros:

```text
initial
loading
success
empty
error
```

### Justificación

Esto permite cumplir requisitos de loading states, empty states, manejo de errores y retroalimentación visual.

---

## DT-22: Centralizar validaciones

Las validaciones se organizarán en una capa reutilizable.

Validadores esperados:

```text
AuthValidators
ProductValidators
MovementValidators
ImportValidators
```

Validaciones relevantes:

- Campos obligatorios.
- Email válido.
- Cantidades mayores a cero.
- Stock suficiente.
- Producto activo.
- Sucursal activa.
- Duplicados por SKU o código de barras.
- Formato de archivo CSV.

### Justificación

Centralizar validaciones facilita pruebas unitarias y evita lógica duplicada en pantallas.

---

## DT-23: Implementar testing automatizado y GitHub Actions

El proyecto incluirá pruebas automatizadas.

Tipos de pruebas:

- Unit tests.
- Widget tests.
- Integration tests.

GitHub Actions ejecutará validaciones en pushes y pull requests.

Validaciones mínimas:

```text
flutter analyze
flutter test
```

### Justificación

El proyecto requiere testing automatizado e integración continua, por lo que deben formar parte del flujo desde etapas tempranas.

---

## 3. Decisiones fuera del MVP

Las siguientes decisiones quedan como mejoras futuras:

- API REST propia.
- Backend .NET/Node/Laravel.
- Cloud Functions para lógica crítica.
- Push automática por bajo stock.
- Importación Excel `.xlsx` avanzada.
- Modo offline completo.
- Transferencias complejas entre sucursales.
- Reportes estadísticos avanzados.
- Permisos granulares.
- Panel web administrativo.

---

## 4. Criterio general de arquitectura

El principio guía será:

```text
La UI no debe conocer detalles de Firebase, Firestore, Storage, FCM ni APIs externas.
```

La comunicación debe pasar por:

```text
UI
→ ViewModel
→ Repository
→ Data Source
→ Firebase / API externa / almacenamiento local
```

Esto asegura separación de responsabilidades, mantenibilidad y facilidad para defender el proyecto técnicamente.

---

## 5. Estado del documento

Este documento debe actualizarse cuando el equipo tome una decisión técnica que cambie el alcance o la arquitectura del proyecto.

Las decisiones aquí registradas se consideran la base técnica oficial para los documentos posteriores:

- `docs/architecture/data-model.md`
- `docs/architecture/system-architecture.md`
- `docs/api-contracts/firestore-collections.md`
- `docs/api-contracts/external-product-api.md`
- `README.md`

