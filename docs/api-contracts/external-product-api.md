# External Product API — Sistema de Gestión de Inventario Multiusuario

## 1. Propósito del documento

Este documento define el contrato de integración con la API externa utilizada por la aplicación para apoyar el registro de productos.

El proyecto usa Firebase como backend principal. Por eso, esta API externa no reemplaza Firestore ni funciona como base de datos del sistema. Su función es ayudar al usuario a autocompletar información de productos, principalmente mediante código de barras.

Este documento complementa:

```text
docs/architecture/project-scope.md
docs/architecture/technical-decisions.md
docs/architecture/data-model.md
docs/contracts/firestore-collections.md
```

---

## 2. Decisión general

La aplicación consumirá una API externa para buscar información de productos por código de barras.

Uso principal:

```text
Crear producto
→ Usuario ingresa código de barras
→ App consulta API externa
→ API devuelve datos sugeridos
→ Usuario revisa y corrige
→ Usuario guarda producto en Firestore
```

La API externa es una ayuda para reducir digitación manual, no una fuente obligatoria ni única para registrar productos.

---

## 3. API seleccionada

La opción principal será:

```text
Open Food Facts API
```

Open Food Facts es una base de datos abierta y colaborativa de productos alimenticios. Permite consultar productos por código de barras y obtener datos como nombre, marcas, categorías e imágenes cuando existen.

### Justificación

Se selecciona esta API porque:

- Es pública.
- Tiene endpoint por código de barras.
- Devuelve respuestas en JSON.
- No requiere construir backend propio.
- Encaja con inventario de productos de tiendas locales.
- Permite cumplir el requisito de consumo de APIs externas.
- Puede usarse como apoyo para autocompletar productos.

### Limitación

Open Food Facts está enfocada principalmente en productos alimenticios. Por eso, no debe ser la única forma de crear productos. El registro manual siempre debe estar disponible.

---

## 4. Endpoint principal

### Get product by barcode

Consulta un producto por código de barras.

```http
GET https://world.openfoodfacts.org/api/v2/product/{barcode}
```

### Parámetro de ruta

| Parámetro | Tipo | Requerido | Descripción |
|---|---|---:|---|
| `barcode` | string | Sí | Código de barras del producto. |

### Ejemplo

```http
GET https://world.openfoodfacts.org/api/v2/product/3017624010701
```

---

## 5. Endpoint recomendado con campos limitados

Para evitar respuestas demasiado grandes, se recomienda solicitar solo los campos necesarios.

```http
GET https://world.openfoodfacts.org/api/v2/product/{barcode}?fields=code,product_name,brands,categories,image_url
```

### Campos solicitados

| Campo | Uso en la app |
|---|---|
| `code` | Código de barras. |
| `product_name` | Nombre sugerido del producto. |
| `brands` | Marca sugerida. |
| `categories` | Categoría sugerida. |
| `image_url` | Imagen sugerida del producto. |

---

## 6. Request contract

### Request

```http
GET /api/v2/product/{barcode}?fields=code,product_name,brands,categories,image_url
Host: world.openfoodfacts.org
Accept: application/json
```

### Headers recomendados

| Header | Valor |
|---|---|
| `Accept` | `application/json` |

---

## 7. Response contract

### Respuesta exitosa con producto encontrado

La API puede responder con un objeto que incluye el estado y el producto.

Ejemplo conceptual:

```json
{
  "code": "3017624010701",
  "status": 1,
  "status_verbose": "product found",
  "product": {
    "code": "3017624010701",
    "product_name": "Nutella",
    "brands": "Ferrero",
    "categories": "Spreads, Hazelnut spreads",
    "image_url": "https://images.openfoodfacts.org/images/products/301/762/401/0701/front_en.400.jpg"
  }
}
```

### Respuesta cuando no se encuentra producto

Ejemplo conceptual:

```json
{
  "code": "0000000000000",
  "status": 0,
  "status_verbose": "product not found"
}
```

---

## 8. Modelo interno de respuesta

La respuesta externa no debe usarse directamente en la UI. Debe mapearse a un modelo interno.

### ExternalProductSuggestion

```text
ExternalProductSuggestion
- barcode
- name
- brand
- category
- imageUrl
- source
```

### Ejemplo

```json
{
  "barcode": "3017624010701",
  "name": "Nutella",
  "brand": "Ferrero",
  "category": "Spreads",
  "imageUrl": "https://images.openfoodfacts.org/images/products/301/762/401/0701/front_en.400.jpg",
  "source": "open_food_facts"
}
```

---

## 9. Mapeo hacia Product

La API externa devuelve sugerencias. El usuario debe confirmar antes de crear el producto.

| API externa | Modelo interno `Product` |
|---|---|
| `code` | `barcode` |
| `product_name` | `name` |
| `brands` | Puede agregarse a `description` o mostrarse como dato auxiliar |
| `categories` | `category` |
| `image_url` | `imageUrl` |

### Nota

El modelo interno actual no incluye un campo `brand`. Si el equipo decide mostrar marca como dato separado, se debe agregar formalmente al modelo de datos antes de implementarlo.

Para mantener el MVP simple, la marca puede tratarse como dato auxiliar o incorporarse dentro de la descripción.

---

## 10. Flujo funcional en la app

### Pantalla

La integración se usará principalmente en:

```text
Product Form Screen
```

### Flujo

```text
1. Usuario abre el formulario de producto.
2. Usuario ingresa un código de barras.
3. Usuario presiona “Buscar producto”.
4. La app muestra estado loading.
5. ProductLookupRepository consulta Open Food Facts.
6. Si existe resultado, la app muestra datos sugeridos.
7. Usuario revisa los campos.
8. Usuario corrige o completa datos faltantes.
9. Usuario guarda el producto.
10. ProductRepository guarda el producto en Firestore.
```

---

## 11. Manejo de errores

La integración debe manejar errores de forma controlada.

### Casos esperados

| Caso | Comportamiento esperado |
|---|---|
| Producto encontrado | Autocompletar campos disponibles. |
| Producto no encontrado | Mostrar mensaje y permitir registro manual. |
| Sin conexión | Mostrar error y permitir registro manual. |
| Timeout | Mostrar error y permitir reintento. |
| Respuesta incompleta | Autocompletar solo campos disponibles. |
| Error de servidor externo | Mostrar error y no bloquear el formulario. |

### Mensajes sugeridos

```text
No se encontró información para este código de barras. Puede registrar el producto manualmente.
```

```text
No fue posible consultar la API externa. Revise su conexión o complete el producto manualmente.
```

```text
Se encontraron datos sugeridos. Revise la información antes de guardar.
```

---

## 12. Validaciones

La API externa no reemplaza las validaciones internas.

Antes de guardar un producto, la app debe validar:

- Nombre requerido.
- SKU requerido.
- Categoría requerida.
- Stock mínimo mayor o igual a cero.
- SKU no duplicado.
- Código de barras no duplicado, si aplica.
- Producto activo al crearse.
- Datos revisados por el usuario.

---

## 13. Responsabilidades por capa

### UI

La UI debe:

- Capturar el código de barras.
- Mostrar loading, éxito, error o empty state.
- Permitir editar los datos sugeridos.
- No llamar directamente a Dio ni a la API externa.

### ViewModel

El ViewModel debe:

- Manejar el estado del formulario.
- Invocar el repositorio de búsqueda externa.
- Mapear estados de respuesta hacia la UI.
- Mantener los datos sugeridos como editables.

### Repository

El repositorio debe:

- Exponer un método de búsqueda.
- Devolver un resultado controlado.
- Ocultar detalles de HTTP y Dio a la capa de UI.

### Data Source

El data source debe:

- Ejecutar la llamada HTTP.
- Manejar timeout.
- Parsear la respuesta.
- Mapear errores técnicos.

---

## 14. Método esperado del repositorio

### ProductLookupRepository

```text
Future<AppResult<ExternalProductSuggestion>> findByBarcode(String barcode)
```

### Respuestas posibles

```text
Success(ExternalProductSuggestion)
Failure(product_not_found)
Failure(network_error)
Failure(timeout)
Failure(unexpected_error)
```

---

## 15. Cliente HTTP

Se usará Dio o un cliente HTTP equivalente.

Dio se usará solo para esta API externa.

No se usará Dio para Firestore, Firebase Auth, Firebase Storage ni Firebase Cloud Messaging.

---

## 16. Timeout recomendado

La consulta externa no debe bloquear el formulario por demasiado tiempo.

Timeout recomendado:

```text
5 segundos
```

Si la API no responde dentro de ese tiempo, se debe mostrar error y permitir registro manual.

---

## 17. Datos externos y persistencia

Los datos de la API externa no se guardan automáticamente.

Flujo correcto:

```text
API externa
→ datos sugeridos
→ usuario revisa
→ usuario confirma
→ Firestore guarda Product
```

El sistema no debe crear productos automáticamente solo porque la API devolvió un resultado.

---

## 18. Privacidad y seguridad

La consulta a la API externa solo enviará el código de barras.

No se enviarán:

- Datos del usuario.
- Tokens de Firebase.
- Información de sesión.
- Información interna de stock.
- Información de sucursales.
- Historial de movimientos.

---

## 19. Limitaciones conocidas

- No todos los productos existirán en Open Food Facts.
- Algunos productos pueden tener datos incompletos.
- Algunos productos pueden tener categorías poco útiles para inventario.
- La API externa puede fallar o estar temporalmente no disponible.
- La cobertura puede variar según país, producto o tipo de comercio.
- La API está más orientada a alimentos que a productos generales.

Por estas razones, el registro manual sigue siendo obligatorio.

---

## 20. Alternativas consideradas

### UPCitemdb

API de búsqueda de productos por UPC/EAN. Puede tener mejor cobertura en algunos productos, pero puede requerir condiciones o límites de uso distintos.

### Barcode Lookup

API comercial de búsqueda de códigos de barras. Puede devolver datos amplios, pero normalmente requiere API key.

### Backend propio

No se selecciona como solución principal porque una API propia no cuenta como API externa y aumentaría el alcance del proyecto.

---

## 21. Criterios de aceptación

La integración con API externa se considera lista cuando:

- El usuario puede ingresar un código de barras.
- La app consulta Open Food Facts.
- La app muestra estado de carga.
- Si el producto existe, se muestran datos sugeridos.
- Si el producto no existe, se permite registro manual.
- Si ocurre un error, se muestra mensaje claro.
- El usuario puede editar los datos sugeridos antes de guardar.
- El producto confirmado se guarda en Firestore.
- Dio o cliente HTTP está aislado en data source/repository.
- La UI no consume la API directamente.

---

## 22. Evidencia esperada

Para demostrar esta funcionalidad, se deberá incluir:

- Captura o video de búsqueda por código de barras.
- Captura de producto encontrado.
- Captura de producto no encontrado o error controlado.
- Evidencia de que el producto se guarda en Firestore después de confirmación.
- Validación de que el registro manual sigue funcionando.

---

## 23. Referencias

- Open Food Facts API documentation: https://openfoodfacts.github.io/openfoodfacts-server/api/
- Open Food Facts API tutorial: https://openfoodfacts.github.io/openfoodfacts-server/api/tutorial-off-api/
- Open Food Facts product endpoint example: https://world.openfoodfacts.org/api/v2/product/3017624010701

