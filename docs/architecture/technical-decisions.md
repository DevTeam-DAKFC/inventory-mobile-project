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
| DT-02 | Usar ASP.NET Core Web API como backend principal |
| DT-03 | Implementar un backend REST para el MVP |
| DT-04 | Manejar autenticación desde el backend con JWT |
| DT-05 | Usar SQL Server como persistencia principal |
| DT-06 | Definir almacenamiento de imágenes entre Firebase Storage o flujo backend |
| DT-07 | Usar Firebase Cloud Messaging para push notifications |
| DT-08 | Usar una API externa para autocompletar productos |
| DT-09 | Usar Dio para comunicación HTTP con backend y APIs externas |
| DT-10 | Usar MVVM como patrón de presentación |
| DT-11 | Usar Riverpod para manejo de estado e inyección de dependencias |
| DT-12 | Usar Repository Pattern |
| DT-13 | Usar estructura layer-first simplificada |
| DT-14 | Mantener Branch como entidad obligatoria |
| DT-15 | Manejar stock por `productId + branchId` |
| DT-16 | Cambiar stock únicamente mediante movimientos |
| DT-17 | Manejar cambios de stock con transacciones en el backend |
| DT-18 | Manejar dos roles: `admin` y `collaborator` |
| DT-19 | Usar almacenamiento local limitado |
| DT-20 | Permitir registro manual, asistido e importación CSV de productos |
| DT-21 | Implementar estados de UI explícitos |
| DT-22 | Centralizar validaciones |
| DT-23 | Implementar testing automatizado y GitHub Actions |
| DT-24 | Contrato OpenAPI para el backend ASP.NET Core |
| DT-25 | Usar infraestructura backend basada en Docker |

---

## DT-01: Usar Flutter y Dart

Flutter será el framework principal del proyecto por su capacidad para desarrollar aplicaciones móviles con una sola base de código.

La aplicación se desarrollará con una sola base de código y se enfocará inicialmente en Android, sin descartar compatibilidad futura con otras plataformas soportadas por Flutter.

### Justificación

- Permite construir interfaces móviles consistentes.
- Facilita componentización y reutilización visual.
- Tiene soporte para testing, navegación, estado, integración con servicios Firebase específicos y CI.

---

## DT-02: Usar ASP.NET Core Web API como backend principal

ASP.NET Core Web API será el backend principal planificado del sistema.

El backend expondrá endpoints REST que serán consumidos por la aplicación Flutter mediante Dio / HttpClient.

Responsabilidades previstas:

| Capa backend | Responsabilidad |
|---|---|
| Controllers | Recibir solicitudes HTTP, validar entrada básica y devolver respuestas REST. |
| Services | Contener reglas de negocio, validaciones de dominio y coordinación de casos de uso. |
| Repositories | Gestionar acceso a persistencia. |
| SQL Server | Almacenar los datos principales del sistema a través del backend. |

El backend está planificado y todavía no está implementado.

### Justificación

Centralizar las reglas de negocio y la persistencia en un backend REST permite separar la aplicación móvil de la base de datos, controlar autenticación y autorización desde el servidor, y mantener una arquitectura más escalable para el producto.

---

## DT-03: Implementar un backend REST para el MVP

El MVP tendrá como dirección técnica implementar un backend REST con ASP.NET Core Web API.

La aplicación Flutter consumirá endpoints del backend mediante Dio / HttpClient. El contrato OpenAPI existente seguirá siendo la referencia esperada para esa API.

Contrato esperado:

```text
docs/api-contracts/openapi.inventory-api.yaml
```

La implementación del backend está pendiente. Esta decisión no implica que el backend ya exista.

### Justificación

Un backend REST permite que Flutter no dependa directamente de la persistencia, facilita pruebas por contrato, centraliza reglas críticas de inventario y habilita una integración clara con SQL Server.

---

## DT-04: Manejar autenticación desde el backend con JWT

La autenticación será manejada por el backend ASP.NET Core Web API.

Dirección planificada:

- El backend expondrá endpoints de autenticación.
- El backend emitirá y validará tokens JWT.
- Flutter consumirá los endpoints de autenticación mediante Dio.
- Firebase Auth no será el proveedor principal de autenticación.

La implementación de autenticación está pendiente y deberá alinearse con el contrato REST.

### Justificación

Manejar autenticación desde el backend permite controlar usuarios, roles, permisos y tokens dentro de la misma capa que protege los endpoints del sistema.

---

## DT-05: Usar SQL Server como persistencia principal

SQL Server será la capa principal de persistencia del sistema.

Se almacenarán datos como:

- Usuarios.
- Sucursales.
- Productos.
- Stock.
- Movimientos de inventario.
- Tokens de notificación.
- Lotes de importación, si se implementan.

Firestore ya no será la capa de persistencia del MVP. La configuración de SQL Server está pendiente y deberá realizarse detrás del backend ASP.NET Core Web API.

### Justificación

SQL Server permite manejar relaciones, consistencia transaccional, consultas estructuradas y reglas de integridad adecuadas para inventario multiusuario.

---

## DT-06: Definir almacenamiento de imágenes entre Firebase Storage o flujo backend

El manejo de imágenes de productos sigue siendo requerido, pero la implementación final queda pendiente.

Opciones válidas:

- Usar Firebase Storage para subir y servir imágenes.
- Usar un flujo gestionado por el backend para carga, almacenamiento y acceso a archivos.

En ambos casos, `Product.imageUrl` se mantiene como la referencia persistida para mostrar la imagen en listados y detalles.

### Justificación

Mantener abierta la decisión permite elegir la opción más conveniente cuando se implemente el backend y se definan costos, seguridad, simplicidad operativa y responsabilidad de almacenamiento.

---

## DT-07: Usar Firebase Cloud Messaging para push notifications

Firebase Cloud Messaging se usará para cumplir el requisito de notificaciones push.

Para el MVP:

- La app registrará el token FCM del dispositivo.
- El backend ASP.NET Core podrá guardar tokens de dispositivo asociados al usuario.
- El backend podrá disparar notificaciones push cuando se implemente el emisor server-side.
- Se podrá demostrar recepción de una push notification enviada desde Firebase Console.
- Flutter recibirá notificaciones mediante Firebase Messaging.
- La app podrá mostrar alertas locales o in-app cuando un producto quede en bajo stock.

### Limitación del MVP

El envío automático de push notifications por bajo stock dependerá de implementar el emisor server-side desde el backend u otro servicio compatible.

### Mejora futura

Implementar un flujo server-side para:

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
- Guardar el producto mediante la API REST del backend solo después de confirmación del usuario.

### Justificación

Este flujo cumple el requisito de consumo de APIs externas y aporta valor real al caso de inventario, ya que reduce digitación manual y mejora la calidad del catálogo.

### Regla importante

La API externa no reemplaza el registro manual. Si la API falla o no encuentra información, el usuario podrá crear el producto manualmente.

---

## DT-09: Usar Dio para integraciones HTTP

Dio será el cliente HTTP de la aplicación para integraciones REST.

Uso planificado en el MVP:

- Consumir la API REST del backend ASP.NET Core desde `RestApiDataSource`.
- Consumir la API externa de productos si se llama directamente desde Flutter, por ejemplo desde `OpenFoodFactsDataSource`.

Dio no se usará para conectar directamente con SQL Server. La base de datos se consumirá únicamente a través del backend.

Firebase no será el backend principal de datos. Los SDKs oficiales de Firebase se usarán solo para servicios Firebase que lo requieran, como Firebase Messaging y, si se decide, Firebase Storage.

### Justificación

Mantener un cliente HTTP central para integraciones REST simplifica configuración, manejo de errores, timeout, interceptores, tokens JWT y testing.

---

## DT-10: Usar MVVM como patrón de presentación

La app usará MVVM para separar responsabilidades entre UI, estado y acceso a datos.

Flujo esperado:

```text
Screen / Widget
→ ViewModel / Controller
→ Repository
→ Data Source
→ ASP.NET Core Web API / API externa / almacenamiento local
```

### Responsabilidades

| Capa | Responsabilidad |
|---|---|
| View | Renderizar UI y capturar acciones |
| ViewModel | Manejar estado, eventos y validaciones de pantalla |
| Repository | Coordinar acceso a datos |
| Data Source | Implementar comunicación con backend REST, API externa, Firebase Services o almacenamiento local |
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

Los ViewModels no accederán directamente al backend, SQL Server, Firebase, Storage, FCM ni APIs externas.

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

Los contratos de repositorios son agnósticos del backend. Cada repositorio coordina una o varias implementaciones intercambiables de data source:

- `RestApiDataSource` — familia principal de data sources para datos del MVP, consumiendo el backend ASP.NET Core mediante Dio.
- `MockDataSource` — implementación usada en pruebas, prototipos y demostraciones, alineada con los datos descritos en `docs/api-contracts/mock-data.md`.
- `FirebaseDataSource` — implementación limitada a servicios Firebase, como FCM y almacenamiento opcional de imágenes; no se usará para persistencia de inventario.

La UI y los ViewModels no deben cambiar cuando se intercambia la implementación del data source.

### Justificación

Repository Pattern permite:

- Separar UI de infraestructura.
- Facilitar testing mediante data sources mock.
- Cambiar implementación interna sin afectar pantallas.
- Permitir que el mismo contrato funcional sea servido por el backend REST o por una capa de mock data.
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

## DT-17: Manejar cambios de stock con transacciones en el backend

Cuando se registre una entrada o salida, el backend deberá manejar el cambio de stock de forma transaccional.

Flujo esperado:

1. Leer el stock actual del producto en la sucursal.
2. Validar cantidad.
3. Si es salida, validar que exista stock suficiente.
4. Calcular nuevo stock.
5. Actualizar `Stock`.
6. Crear `InventoryMovement`.
7. Confirmar ambas operaciones de forma atómica.

### Justificación

Una transacción de SQL Server o EF Core debe garantizar que el stock y el movimiento de inventario permanezcan consistentes cuando varios usuarios actualicen inventario.

### Limitación

La implementación de esta regla está pendiente junto con el backend y la persistencia SQL Server.

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

Los roles se almacenarán en SQL Server a través del backend.

Ejemplo:

```text
Users
- Id
- Name
- Email
- Role
- BranchIds
- CreatedAt
```

Flutter recibirá el rol y permisos del usuario mediante endpoints de autenticación o perfil.

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

La persistencia remota será responsabilidad del backend. No se promete modo offline completo ni resolución de conflictos.

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

## DT-24: Contrato OpenAPI para el backend ASP.NET Core

El sistema documenta un contrato REST formal que el backend ASP.NET Core Web API deberá implementar. Ese contrato vive en:

```text
docs/api-contracts/openapi.inventory-api.yaml
```

Relación con la documentación de contratos:

| Documento | Rol |
|---|---|
| `docs/api-contracts/openapi.inventory-api.yaml` | Contrato REST que deberá implementar el backend ASP.NET Core Web API. |
| `docs/api-contracts/firestore-collections.md` | Ya no es el contrato activo de persistencia y será reformulado o reemplazado en un bloque posterior. |
| `docs/api-contracts/external-product-api.md` | Documenta la integración directa con la API externa de productos (Open Food Facts). |
| `docs/api-contracts/mock-data.md` | Aporta datos de demostración para desarrollo, pruebas y demostraciones del producto. |

### Reglas

- Firebase no será la implementación principal de persistencia del MVP.
- El contrato OpenAPI define lo que el backend deberá implementar.
- El contrato OpenAPI no implica que el backend ya esté implementado.
- Los repositorios definidos en DT-12 deben permitir usar `RestApiDataSource` y `MockDataSource` sin cambios en la UI ni en los ViewModels.
- Las pantallas y ViewModels no dependen del proveedor de backend.

### Justificación

Documentar el contrato esperado mantiene alineada la implementación móvil con el backend planificado. También permite usar mock data sources en pruebas y demos sin cambiar el dominio.

---

## DT-25: Usar infraestructura backend basada en Docker

Docker / Docker Compose se usará para la infraestructura backend planificada en desarrollo local, especialmente para SQL Server.

Dirección planificada:

- Ejecutar SQL Server en Docker para desarrollo local.
- Mantener la configuración reproducible mediante Docker Compose.
- Evaluar la contenedorización del backend ASP.NET Core en una etapa posterior.

El archivo `docker-compose.yml` todavía no ha sido creado y la infraestructura Docker no está configurada.

### Justificación

Docker permite definir una base de datos local reproducible, reducir diferencias entre entornos y facilitar que el backend se ejecute con dependencias consistentes.

---

## 3. Decisiones fuera del MVP

Las siguientes decisiones quedan como mejoras futuras:

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
La UI no debe conocer detalles del backend, SQL Server, Firebase, Storage, FCM ni APIs externas.
```

La comunicación debe pasar por:

```text
UI
→ ViewModel
→ Repository
→ RestApiDataSource
→ ASP.NET Core Web API
→ SQL Server
```

Firebase Services, APIs externas y almacenamiento local se consumen mediante data sources específicos cuando aplique.

Esto asegura separación de responsabilidades, mantenibilidad y facilidad para defender el proyecto técnicamente.

---

## 5. Estado del documento

Este documento debe actualizarse cuando el equipo tome una decisión técnica que cambie el alcance o la arquitectura del proyecto.

Las decisiones aquí registradas se consideran la base técnica oficial para los documentos posteriores:

- `docs/architecture/data-model.md`
- `docs/architecture/system-architecture.md`
- `docs/api-contracts/openapi.inventory-api.yaml`
- `docs/api-contracts/firestore-collections.md`
- `docs/api-contracts/external-product-api.md`
- `README.md`

