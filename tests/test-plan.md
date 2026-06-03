# Test Plan - Sistema de Gestión de Inventario Multiusuario

## 1. Propósito del documento

Este documento define el plan de pruebas del proyecto móvil desarrollado con Flutter.

Su objetivo es establecer qué se debe probar, cómo se deben organizar las pruebas, qué tipos de pruebas se implementarán y qué evidencia se espera generar para validar la calidad del sistema.

Este plan se alinea con los requerimientos del proyecto:

- Unit tests.
- Integration tests.
- Casos positivos.
- Casos negativos.
- Ejecución local.
- Ejecución automática mediante GitHub Actions.

---

## 2. Alcance del plan de pruebas

El plan de pruebas cubre los módulos principales del MVP:

- Autenticación.
- Productos.
- Sucursales.
- Stock.
- Movimientos de inventario.
- Historial.
- Búsqueda y filtros.
- API externa de productos.
- Imágenes de productos.
- Notificaciones.
- Importación CSV, si se implementa.
- Estados visuales.
- Validaciones.
- Integración continua.

---

## 3. Objetivos de testing

Los objetivos principales son:

- Verificar que las reglas críticas de inventario funcionen correctamente.
- Validar que los formularios impidan datos inválidos.
- Confirmar que el stock no pueda quedar negativo.
- Validar que las entradas aumenten stock.
- Validar que las salidas disminuyan stock.
- Confirmar que los movimientos queden registrados en historial.
- Probar estados de carga, vacío, éxito y error.
- Validar que la API externa no bloquee el registro manual.
- Confirmar que las pruebas se puedan ejecutar localmente y en GitHub Actions.

---

## 4. Estrategia general

Se utilizarán tres niveles de pruebas:

```text
Unit tests
Widget tests
Integration tests
```

Además, se documentarán casos de prueba manuales en:

```text
tests/manual-test-cases.md
```

---

## 5. Unit tests

## 5.1 Propósito

Los unit tests validan funciones, reglas y clases aisladas sin depender de UI ni servicios reales.

Deben ser rápidos, repetibles y ejecutarse en CI.

## 5.2 Componentes a probar

### Validadores

```text
AuthValidators
ProductValidators
MovementValidators
ImportValidators
```

### Reglas de negocio

```text
Stock calculation
Low stock detection
Outgoing movement validation
Product active validation
Branch active validation
CSV row validation
```

### Mappers

```text
ProductMapper
StockMapper
InventoryMovementMapper
ExternalProductMapper
ImportMapper
```

### Repositories con mocks

```text
ProductRepository
StockRepository
InventoryMovementRepository
ProductLookupRepository
```

---

## 6. Unit tests requeridos

## 6.1 AuthValidators

### Casos positivos

- Email válido.
- Contraseña válida.
- Nombre válido para registro.

### Casos negativos

- Email vacío.
- Email con formato inválido.
- Contraseña vacía.
- Contraseña demasiado corta.
- Nombre vacío.

---

## 6.2 ProductValidators

### Casos positivos

- Producto con nombre, SKU, categoría y stock mínimo válido.
- Producto con código de barras opcional vacío.
- Producto con imagen opcional vacía.

### Casos negativos

- Nombre vacío.
- SKU vacío.
- Categoría vacía.
- Stock mínimo negativo.
- SKU duplicado.
- Código de barras duplicado, si aplica.

---

## 6.3 MovementValidators

### Casos positivos

- Entrada con cantidad mayor a cero.
- Salida con stock suficiente.
- Movimiento con producto, sucursal y motivo válidos.

### Casos negativos

- Cantidad igual a cero.
- Cantidad negativa.
- Producto vacío.
- Sucursal vacía.
- Motivo vacío.
- Salida mayor al stock disponible.
- Producto inactivo.
- Sucursal inactiva.

---

## 6.4 Stock rules

### Casos positivos

Entrada:

```text
previousStock = 10
quantity = 5
resultingStock = 15
```

Salida:

```text
previousStock = 10
quantity = 4
resultingStock = 6
```

Bajo stock:

```text
availableQuantity = 4
minStock = 5
isLowStock = true
```

### Casos negativos

Salida inválida:

```text
previousStock = 4
quantity = 10
operation rejected
```

Stock negativo:

```text
availableQuantity < 0
invalid state
```

---

## 6.5 ExternalProductMapper

### Casos positivos

- Mapea `product_name` hacia `name`.
- Mapea `code` hacia `barcode`.
- Mapea `categories` hacia `category`.
- Mapea `image_url` hacia `imageUrl`.

### Casos negativos

- Producto no encontrado.
- Respuesta sin `product`.
- Respuesta con campos incompletos.
- Respuesta inesperada.

---

## 6.6 ImportValidators

### Casos positivos

- CSV con columnas requeridas.
- Fila con datos válidos.
- Stock inicial mayor o igual a cero.
- Sucursal existente.

### Casos negativos

- CSV sin columnas requeridas.
- Nombre vacío.
- SKU vacío.
- Stock inicial negativo.
- Sucursal inexistente.
- SKU duplicado.
- Archivo vacío.

---

## 7. Widget tests

## 7.1 Propósito

Los widget tests validan que los componentes y pantallas reaccionen correctamente ante distintos estados.

No deben depender de Firebase real. Se deben usar mocks o providers falsos.

## 7.2 Pantallas prioritarias

```text
LoginScreen
RegisterScreen
ProductsScreen
ProductFormScreen
StockScreen
MovementFormScreen
HistoryScreen
ImportProductsScreen
```

---

## 8. Widget tests requeridos

## 8.1 LoginScreen

### Casos positivos

- Muestra campos de email y contraseña.
- Muestra botón de login.
- Permite enviar formulario válido.

### Casos negativos

- Muestra error cuando el email está vacío.
- Muestra error cuando el email tiene formato inválido.
- Muestra error cuando la contraseña está vacía.
- Muestra estado de carga durante login.
- Muestra mensaje si login falla.

---

## 8.2 ProductsScreen

### Casos positivos

- Muestra listado de productos.
- Muestra campo de búsqueda.
- Muestra filtros.
- Muestra botón para crear producto.

### Casos negativos

- Muestra empty state cuando no hay productos.
- Muestra error state si falla la carga.
- Muestra loading state mientras carga.
- No muestra productos inactivos como activos.

---

## 8.3 ProductFormScreen

### Casos positivos

- Permite crear producto con datos válidos.
- Permite registrar producto manualmente.
- Permite cargar imagen si la funcionalidad está disponible.
- Permite usar datos sugeridos por API externa.

### Casos negativos

- Muestra error con nombre vacío.
- Muestra error con SKU vacío.
- Muestra error con categoría vacía.
- Muestra error con stock mínimo negativo.
- Permite continuar manualmente si la API externa falla.

---

## 8.4 StockScreen

### Casos positivos

- Muestra stock por sucursal.
- Permite cambiar sucursal.
- Muestra productos bajo stock.
- Permite navegar al detalle del producto.

### Casos negativos

- Muestra empty state si la sucursal no tiene stock.
- Muestra error state si falla la carga.
- Muestra loading state mientras consulta datos.

---

## 8.5 MovementFormScreen

### Casos positivos

- Permite seleccionar producto.
- Permite seleccionar sucursal.
- Permite seleccionar tipo de movimiento.
- Permite registrar entrada válida.
- Permite registrar salida válida con stock suficiente.

### Casos negativos

- Muestra error si falta producto.
- Muestra error si falta sucursal.
- Muestra error si cantidad es cero.
- Muestra error si cantidad es negativa.
- Muestra error si motivo está vacío.
- Muestra error si salida supera stock disponible.

---

## 8.6 HistoryScreen

### Casos positivos

- Muestra movimientos.
- Permite filtrar por sucursal.
- Permite filtrar por producto.
- Permite filtrar por tipo.
- Permite abrir detalle de movimiento.

### Casos negativos

- Muestra empty state si no hay movimientos.
- Muestra error state si falla la carga.
- Muestra mensaje cuando un filtro no retorna resultados.

---

## 8.7 ImportProductsScreen

Esta pantalla es complementaria si se implementa importación CSV.

### Casos positivos

- Permite seleccionar archivo CSV.
- Muestra vista previa.
- Muestra filas válidas.
- Permite confirmar importación.

### Casos negativos

- Muestra errores de filas inválidas.
- Bloquea importación si no hay filas válidas.
- Muestra error si faltan columnas requeridas.
- Muestra error si hay stock inicial negativo.

---

## 9. Integration tests

## 9.1 Propósito

Los integration tests validan flujos completos o semi-completos de la aplicación.

Deben enfocarse en los flujos principales del MVP.

## 9.2 Flujos prioritarios

```text
Authentication flow
Create product flow
External product lookup flow
Register incoming movement flow
Register outgoing movement flow
Insufficient stock flow
History flow
```

---

## 10. Integration tests requeridos

## 10.1 Login exitoso

### Dado

Un usuario registrado.

### Cuando

Ingresa credenciales válidas.

### Entonces

La app navega a `HomeScreen`.

---

## 10.2 Login inválido

### Dado

Un usuario no registrado o credenciales inválidas.

### Cuando

Intenta iniciar sesión.

### Entonces

La app muestra mensaje de error y permanece en `LoginScreen`.

---

## 10.3 Crear producto manualmente

### Dado

Un usuario autenticado con permisos.

### Cuando

Completa el formulario de producto y guarda.

### Entonces

El producto aparece en el listado de productos.

---

## 10.4 Buscar producto por API externa

### Dado

Un usuario autenticado en el formulario de producto.

### Cuando

Ingresa un código de barras válido y presiona buscar.

### Entonces

La app muestra datos sugeridos y permite editarlos antes de guardar.

---

## 10.5 API externa sin resultado

### Dado

Un usuario autenticado en el formulario de producto.

### Cuando

Ingresa un código de barras no encontrado.

### Entonces

La app informa que no encontró datos y permite continuar manualmente.

---

## 10.6 Registrar entrada de inventario

### Dado

Un producto y una sucursal existentes.

### Cuando

El usuario registra una entrada de 10 unidades.

### Entonces

El stock aumenta en 10 y se crea un movimiento en historial.

---

## 10.7 Registrar salida de inventario

### Dado

Un producto con stock disponible.

### Cuando

El usuario registra una salida menor o igual al stock.

### Entonces

El stock disminuye y el movimiento aparece en historial.

---

## 10.8 Salida con stock insuficiente

### Dado

Un producto con 4 unidades disponibles.

### Cuando

El usuario intenta registrar salida de 10 unidades.

### Entonces

La salida se rechaza, el stock no cambia y no se crea movimiento.

---

## 10.9 Consultar historial

### Dado

Existen movimientos registrados.

### Cuando

El usuario abre HistoryScreen.

### Entonces

La app muestra los movimientos con producto, sucursal, tipo, cantidad, usuario y fecha.

---

## 10.10 Filtrar historial

### Dado

Existen movimientos de diferentes tipos y sucursales.

### Cuando

El usuario aplica filtros.

### Entonces

La app muestra solo los movimientos que coinciden con el filtro.

---

## 11. Casos positivos mínimos

Estos casos deben estar cubiertos por unit, widget, integration o pruebas manuales:

| ID | Caso |
|---|---|
| TP-01 | Login exitoso |
| TP-02 | Crear producto válido |
| TP-03 | Buscar producto por API externa |
| TP-04 | Registrar entrada |
| TP-05 | Registrar salida válida |
| TP-06 | Consultar historial |
| TP-07 | Filtrar productos |
| TP-08 | Detectar bajo stock |
| TP-09 | Asociar imagen a producto |
| TP-10 | Registrar token FCM |

---

## 12. Casos negativos mínimos

Estos casos deben estar cubiertos por unit, widget, integration o pruebas manuales:

| ID | Caso |
|---|---|
| TN-01 | Login con credenciales inválidas |
| TN-02 | Producto con campos obligatorios vacíos |
| TN-03 | Producto con stock mínimo negativo |
| TN-04 | Salida con stock insuficiente |
| TN-05 | API externa sin resultado |
| TN-06 | Error de red en API externa |
| TN-07 | CSV con columnas faltantes |
| TN-08 | CSV con stock inicial negativo |
| TN-09 | Producto inactivo en movimiento |
| TN-10 | Sucursal inactiva en movimiento |

---

## 13. Pruebas por módulo

## 13.1 Auth

| Tipo | Prueba |
|---|---|
| Unit | Validar email |
| Unit | Validar contraseña |
| Widget | Login form |
| Widget | Register form |
| Integration | Login exitoso |
| Integration | Login inválido |

---

## 13.2 Products

| Tipo | Prueba |
|---|---|
| Unit | ProductValidators |
| Unit | ProductMapper |
| Widget | ProductFormScreen |
| Widget | ProductsScreen empty state |
| Integration | Crear producto manual |
| Integration | Autocompletar desde API externa |

---

## 13.3 Stock

| Tipo | Prueba |
|---|---|
| Unit | Calcular entrada |
| Unit | Calcular salida |
| Unit | Detectar bajo stock |
| Widget | StockScreen loading/empty/error |
| Integration | Ver stock por sucursal |

---

## 13.4 Movements

| Tipo | Prueba |
|---|---|
| Unit | Validar cantidad |
| Unit | Validar salida con stock suficiente |
| Widget | MovementFormScreen |
| Integration | Registrar entrada |
| Integration | Registrar salida |
| Integration | Salida insuficiente |

---

## 13.5 History

| Tipo | Prueba |
|---|---|
| Widget | HistoryScreen con datos |
| Widget | HistoryScreen empty state |
| Integration | Consultar historial |
| Integration | Filtrar historial |

---

## 13.6 API externa

| Tipo | Prueba |
|---|---|
| Unit | Mapear respuesta exitosa |
| Unit | Mapear producto no encontrado |
| Unit | Mapear respuesta incompleta |
| Integration/manual | Buscar producto por código de barras |

---

## 13.7 Import CSV

| Tipo | Prueba |
|---|---|
| Unit | Validar columnas requeridas |
| Unit | Validar fila válida |
| Unit | Validar stock inicial negativo |
| Widget | Vista previa de importación |
| Manual/Integration | Importar CSV válido |

---

## 14. Datos de prueba

Los datos de prueba principales están documentados en:

```text
docs/contracts/mock-data.md
```

Se deben utilizar para:

- Pruebas manuales.
- Video técnico.
- Workshop.
- Demo de bajo stock.
- Demo de salida insuficiente.
- Demo de filtros.

---

## 15. Comandos de validación local

Los comandos mínimos para validar localmente serán:

```bash
flutter pub get
flutter analyze
flutter test
```

Cuando la app ya tenga configuración completa de Android:

```bash
flutter build apk --debug
```

Si se agregan integration tests:

```bash
flutter test integration_test
```

---

## 16. GitHub Actions

GitHub Actions debe ejecutar validaciones en pushes y pull requests.

Validaciones mínimas:

```text
flutter pub get
flutter analyze
flutter test
```

Validaciones recomendadas:

```text
flutter build apk --debug
```

El workflow estará en:

```text
.github/workflows/flutter-ci.yml
```

---

## 17. Evidencia esperada

Para el video técnico, PRs y defensa, se debe conservar evidencia de:

- Comandos ejecutados.
- Resultados exitosos de tests.
- Ejecución de GitHub Actions.
- Capturas de pruebas manuales.
- Capturas de estados de error.
- Capturas de casos positivos.
- Capturas de casos negativos.

Evidencia recomendada:

```text
docs/screenshots/testing/
docs/screenshots/github-actions/
docs/screenshots/manual-tests/
```

---

## 18. Criterios de aceptación del plan de pruebas

El plan se considera cumplido si:

- Existen unit tests para validaciones principales.
- Existen unit tests para reglas de stock.
- Existen widget tests para formularios críticos.
- Existen integration tests para al menos un flujo principal.
- Hay casos positivos y negativos documentados.
- GitHub Actions ejecuta pruebas automáticamente.
- El equipo puede demostrar evidencia de validación.
- Las pruebas pueden ejecutarse localmente.
- Los fallos principales muestran mensajes claros en la app.

---

## 19. Riesgos de testing

### 19.1 Dejar pruebas para el final

Riesgo:

- Falta de tiempo.
- Pruebas superficiales.
- CI incompleto.

Mitigación:

- Crear pruebas por módulo mientras se implementa.

---

### 19.2 Depender de Firebase real en todas las pruebas

Riesgo:

- Pruebas lentas.
- Pruebas frágiles.
- Fallos por red o configuración.

Mitigación:

- Usar mocks para unit y widget tests.
- Reservar Firebase real para validaciones manuales o integration tests específicos.

---

### 19.3 No probar casos negativos

Riesgo:

- La app funciona solo en condiciones ideales.
- Formularios permiten datos inválidos.
- No se detecta stock insuficiente.

Mitigación:

- Incluir casos negativos mínimos obligatorios.

---

### 19.4 No probar estados visuales

Riesgo:

- UI rota en loading, empty o error.
- Mala experiencia de usuario.

Mitigación:

- Crear widget tests para estados visuales.

---

## 20. Estado del documento

Este documento debe actualizarse cuando:

- Cambien los módulos.
- Cambien las reglas de negocio.
- Se agreguen nuevas pantallas.
- Se agreguen nuevos flujos.
- Se definan pruebas reales.
- Se agregue GitHub Actions.
- Se modifique el alcance del MVP.

