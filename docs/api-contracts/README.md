# API Contracts - Sistema de Gestión de Inventario Multiusuario

## 1. Propósito de esta carpeta

Esta carpeta contiene los contratos de datos e integración utilizados por la aplicación móvil Flutter.

Aunque la carpeta se llama `api-contracts`, este proyecto no utiliza una API REST propia como backend principal. La aplicación usa Firebase como backend principal y consume una API externa únicamente para apoyar el registro de productos.

Por eso, los contratos documentados aquí se dividen en:

- Contratos de colecciones de Cloud Firestore.
- Contrato de integración con API externa de productos.
- Datos de prueba o mock data para desarrollo, testing y demostración.

---

## 2. Decisión técnica

El backend principal del sistema será Firebase.

Servicios utilizados:

| Servicio | Uso |
|---|---|
| Firebase Auth | Autenticación de usuarios |
| Cloud Firestore | Persistencia de productos, sucursales, stock, movimientos y usuarios |
| Firebase Storage | Almacenamiento de imágenes de productos |
| Firebase Cloud Messaging | Notificaciones push |

La aplicación no tendrá endpoints propios como:

```text
POST /auth/login
GET /products
POST /inventory/movements
```

En su lugar, la app se comunicará con Firebase mediante sus SDKs oficiales y organizará ese acceso mediante repositorios y data sources.

---

## 3. Documentos incluidos

### `firestore-collections.md`

Define el contrato de datos principal del sistema.

Incluye:

- Colecciones de Firestore.
- Estructura de documentos.
- Campos requeridos.
- Ejemplos JSON.
- Operaciones esperadas.
- Reglas de negocio relacionadas.
- Consultas principales.
- Índices recomendados.
- Consideraciones de seguridad.

Colecciones documentadas:

```text
users
branches
products
stocks
inventory_movements
notification_tokens
import_batches
```

---

### `external-product-api.md`

Define la integración con la API externa usada para autocompletar productos.

La API externa seleccionada es:

```text
Open Food Facts API
```

Uso principal:

```text
Usuario ingresa código de barras
→ App consulta API externa
→ API devuelve datos sugeridos
→ Usuario revisa y corrige
→ Producto se guarda en Firestore
```

Esta API externa cumple el requisito de consumo de APIs externas, pero no reemplaza el registro manual de productos ni funciona como base de datos principal.

---

### `mock-data.md`

Documento previsto para datos de prueba y demostración.

Puede incluir:

- Usuarios demo.
- Sucursales demo.
- Productos demo.
- Stock inicial.
- Movimientos de ejemplo.
- Datos para probar importación CSV.
- Casos de bajo stock.

Este archivo se usará para mantener consistencia entre desarrollo, pruebas, video técnico y workshop.

---

## 4. Flujo general de datos

El flujo general de la aplicación será:

```text
UI
→ ViewModel
→ Repository
→ Data Source
→ Firebase / API externa / almacenamiento local
```

La UI no debe acceder directamente a Firebase ni a la API externa.

---

## 5. Fuentes de datos del sistema

### Firebase

Firebase es la fuente principal de datos persistentes.

Se usa para:

- Usuarios.
- Roles.
- Sucursales.
- Productos.
- Stock.
- Movimientos.
- Tokens de notificación.
- Imágenes de productos.

---

### API externa

La API externa se usa solo como apoyo para registrar productos.

Se usa para:

- Buscar producto por código de barras.
- Autocompletar datos sugeridos.
- Obtener nombre, categoría, marca o imagen cuando estén disponibles.

La API externa no guarda datos dentro del sistema. Los datos externos solo se guardan después de que el usuario los revise y confirme.

---

### Almacenamiento local

El almacenamiento local se usará de forma limitada para preferencias simples.

Puede incluir:

- Última sucursal seleccionada.
- Preferencia de tema.
- Filtros recientes.

No se promete modo offline completo en el MVP.

---

## 6. Diferencia entre Firebase y API externa

Firebase no se cuenta como API externa dentro del alcance del proyecto.

Para este proyecto:

```text
Firebase
→ Backend principal del sistema

Open Food Facts API
→ API externa para autocompletar productos
```

Esta separación permite cumplir el requisito de consumo de APIs externas sin construir una API REST propia.

---

## 7. Relación con arquitectura

Estos contratos deben respetar las decisiones definidas en:

```text
docs/architecture/project-scope.md
docs/architecture/technical-decisions.md
docs/architecture/data-model.md
```

Especialmente:

- `Product` no contiene stock directo.
- `Stock` se maneja por combinación `productId + branchId`.
- `InventoryMovement` es la única forma de cambiar stock.
- `Branch` es una entidad obligatoria.
- La API externa no reemplaza el registro manual.
- Firebase es el backend principal.

---

## 8. Contratos que no se incluyen

Este proyecto no incluirá en el MVP:

- OpenAPI completo para backend REST propio.
- Swagger de endpoints internos.
- Contratos de API .NET, Node.js o Laravel.
- Endpoints personalizados de autenticación.
- Endpoints personalizados de carga de imágenes.
- Endpoints personalizados de notificaciones push.

Estas decisiones se deben a que el sistema usa Firebase como backend principal.

---

## 9. Criterios de calidad para los contratos

Los documentos dentro de esta carpeta deben cumplir:

- Ser claros.
- Estar alineados con el modelo de datos.
- Evitar contradicciones con el alcance del MVP.
- No documentar servicios que no se van a implementar.
- Incluir ejemplos cuando ayuden a entender el flujo.
- Mantener separación entre Firebase, API externa y almacenamiento local.

---

## 10. Estado de la carpeta

Estructura esperada:

```text
docs/api-contracts/
├── README.md
├── firestore-collections.md
├── external-product-api.md
└── mock-data.md
```

El archivo `mock-data.md` puede crearse después de definir los datos de demostración para pruebas, video y workshop.

