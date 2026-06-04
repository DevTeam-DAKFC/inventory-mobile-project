# Project Scope - Sistema de Gestión de Inventario Multiusuario

## 1. Propósito del documento

Este documento define el alcance inicial del proyecto, las funcionalidades incluidas en el MVP, las funcionalidades fuera de alcance, los roles principales, las entidades base y las reglas de negocio que deben guiar el desarrollo.

Su objetivo es alinear al equipo antes de iniciar la implementación, evitando que el proyecto crezca de forma desordenada o que cada integrante interprete la solución de manera distinta.

---

## 2. Contexto del problema

Una pequeña cadena de tiendas locales presenta problemas en el control de inventario entre sus sucursales. Actualmente, el registro de productos, existencias y movimientos se realiza mediante hojas de cálculo o registros manuales.

Esta forma de trabajo provoca:

- Inconsistencias en las existencias disponibles.
- Pérdidas de productos.
- Dificultad para saber quién realizó un movimiento.
- Falta de historial claro sobre entradas y salidas.
- Poca eficiencia para consultar productos y cantidades disponibles.

La administración necesita una aplicación móvil que permita gestionar productos, registrar entradas y salidas de inventario, visualizar existencias disponibles y mantener un historial claro de movimientos realizados dentro del sistema.

---

## 3. Solución propuesta

Se desarrollará una aplicación móvil en Flutter para gestionar el inventario de una pequeña cadena de tiendas locales.

La aplicación permitirá que usuarios autenticados puedan consultar productos, visualizar stock por sucursal, registrar entradas y salidas de inventario, revisar el historial de movimientos y buscar o filtrar información relevante.

El proyecto no busca ser un sistema empresarial completo tipo ERP. El enfoque será construir un MVP funcional y profesional, de alcance controlado, pero con buena calidad técnica, visual y documental.

---

## 4. Objetivo general

Desarrollar una aplicación móvil en Flutter para gestionar el inventario multiusuario de una pequeña cadena de tiendas locales, permitiendo controlar productos, existencias por sucursal, movimientos de inventario e historial de operaciones de forma organizada, usable y técnicamente defendible.

---

## 5. Objetivos específicos

- Implementar autenticación de usuarios.
- Gestionar productos mediante operaciones CRUD.
- Representar sucursales como parte del inventario.
- Visualizar existencias por producto y sucursal.
- Registrar entradas de inventario.
- Registrar salidas de inventario.
- Validar que no se puedan registrar salidas mayores al stock disponible.
- Mantener historial claro de movimientos.
- Permitir búsqueda y filtros sobre productos, stock e historial.
- Asociar imágenes a productos.
- Incorporar almacenamiento local básico para preferencias o datos simples.
- Consumir una API externa para apoyar el registro de productos.
- Permitir registro manual de productos como flujo principal.
- Contemplar importación de productos desde archivo CSV como funcionalidad complementaria.
- Implementar alertas o notificaciones relacionadas con bajo stock.
- Aplicar una arquitectura modular, mantenible y clara.
- Incluir pruebas automatizadas e integración continua.
- Documentar decisiones técnicas, arquitectura, modelo de datos y flujo de trabajo.

---

## 6. Alcance del MVP

El MVP incluirá las funcionalidades necesarias para demostrar el flujo principal de gestión de inventario.

El flujo principal será:

1. Un usuario inicia sesión.
2. El usuario visualiza productos registrados.
3. El usuario selecciona o visualiza una sucursal.
4. El usuario consulta existencias disponibles.
5. El usuario registra una entrada o salida de inventario.
6. El sistema valida los datos ingresados.
7. El sistema actualiza el stock.
8. El movimiento queda registrado en el historial.
9. El usuario puede buscar y filtrar productos o movimientos.

Este alcance permite resolver la problemática principal sin convertir el proyecto en un sistema empresarial demasiado amplio.

---

## 7. Funcionalidades incluidas

### 7.1 Autenticación de usuarios

La aplicación permitirá:

- Registrar usuarios.
- Iniciar sesión.
- Cerrar sesión.
- Mantener sesión activa.
- Diferenciar usuarios según rol.

La autenticación se implementará con Firebase Auth.

---

### 7.2 Roles básicos

El MVP manejará dos roles principales:

- `admin`
- `collaborator`

El rol permitirá diferenciar responsabilidades dentro del sistema sin implementar una matriz compleja de permisos.

---

### 7.3 Gestión de productos

La aplicación permitirá realizar una gestión completa de productos:

- Crear productos.
- Listar productos.
- Consultar detalle de producto.
- Editar productos.
- Desactivar productos.

Cada producto podrá incluir:

- Nombre.
- Código o SKU.
- Código de barras, si aplica.
- Categoría.
- Descripción.
- Imagen.
- Stock mínimo.
- Estado activo o inactivo.
- Fecha de creación.

El producto representa el catálogo general. El stock no se guardará como un campo directo del producto.

Los productos podrán registrarse de tres formas:

1. Registro manual:
   - El usuario ingresa directamente los datos del producto.
   - Este será el flujo principal y obligatorio.

2. Registro asistido por API externa:
   - El usuario ingresa un código de barras o realiza una consulta externa.
   - La app intenta autocompletar datos como nombre, marca, categoría o imagen.
   - El usuario revisa y confirma los datos antes de guardar.

3. Importación desde archivo:
   - Como funcionalidad complementaria, la app podrá permitir importar productos desde un archivo CSV.
   - Este flujo facilitará la carga inicial de inventario cuando la tienda ya tenga registros en hojas de cálculo.

La API externa y la importación de archivos no reemplazan el registro manual. El registro manual deberá estar disponible aunque no exista conexión con la API externa o aunque el producto no sea encontrado.

---

### 7.4 Gestión simple de sucursales

La aplicación considerará las sucursales como parte del dominio del sistema, ya que la problemática se centra en inventario entre tiendas locales.

La sucursal será una entidad ligera. Esto significa que existirá dentro del modelo, pero no se desarrollará como un módulo empresarial complejo.

Cada sucursal podrá incluir:

- Nombre.
- Dirección o descripción.
- Estado activo o inactivo.

El MVP puede iniciar con sucursales precargadas o con una gestión básica, según el tiempo disponible del equipo.

---

### 7.5 Visualización de stock

La aplicación permitirá visualizar existencias disponibles por producto y sucursal.

El stock se manejará como una entidad independiente asociada a:

- Producto.
- Sucursal.
- Cantidad disponible.
- Fecha de última actualización.

El stock no se editará directamente desde el producto. Cualquier cambio de stock deberá originarse mediante un movimiento de inventario.

---

### 7.6 Registro de movimientos de inventario

La aplicación permitirá registrar movimientos de inventario.

Tipos incluidos en el MVP:

- Entrada de inventario.
- Salida de inventario.

Opcionalmente, si el tiempo lo permite, se podrá agregar:

- Ajuste de inventario.

Cada movimiento deberá registrar:

- Producto.
- Sucursal.
- Tipo de movimiento.
- Cantidad.
- Motivo.
- Usuario responsable.
- Fecha y hora.
- Stock resultante.

---

### 7.7 Historial de movimientos

La aplicación permitirá consultar un historial de movimientos.

El historial deberá mostrar:

- Producto afectado.
- Sucursal.
- Tipo de movimiento.
- Cantidad.
- Usuario responsable.
- Fecha y hora.
- Motivo.
- Stock resultante.

Este módulo es central para resolver la falta de trazabilidad de los movimientos realizados por colaboradores.

---

### 7.8 Búsqueda y filtros

La aplicación incluirá búsqueda y filtros para mejorar la consulta de información.

Se aplicarán en:

- Listado de productos.
- Visualización de stock.
- Historial de movimientos.

Filtros posibles:

- Por sucursal.
- Por categoría.
- Por tipo de movimiento.
- Por fecha.
- Por productos con bajo stock.
- Por estado del producto.

---

### 7.9 Imágenes de productos

La aplicación permitirá asociar imágenes a productos.

Las imágenes ayudarán a identificar productos de forma visual, especialmente en listados y pantallas de detalle.

La gestión de imágenes se implementará mediante Firebase Storage.

---

### 7.10 Almacenamiento local

La aplicación usará almacenamiento local de forma limitada para mejorar la experiencia de usuario.

Puede incluir:

- Preferencia de tema.
- Última sucursal seleccionada.
- Filtros recientes.
- Preferencias simples de la aplicación.

No se implementará un modo offline completo en el MVP.

---

### 7.11 Consumo de API externa

La aplicación consumirá una API externa para apoyar el registro de productos.

Uso propuesto:

- Buscar información de producto por código de barras o consulta externa.
- Autocompletar datos como nombre, marca, categoría o imagen cuando la API lo permita.

Esta API externa será un complemento. No será el backend principal de la aplicación y no será la única forma de registrar productos.

Si la API externa no encuentra información o falla, la aplicación deberá permitir continuar con el registro manual.

---

### 7.12 Alertas y notificaciones

La aplicación incluirá alertas o notificaciones relacionadas con bajo stock.

Para el MVP:

- Se mostrará alerta visual o notificación local cuando un producto quede por debajo del stock mínimo.
- Se podrá demostrar recepción de notificación push usando Firebase Cloud Messaging.

El envío automático de push notifications por bajo stock mediante Cloud Functions quedará como mejora futura.

---

### 7.13 Testing e integración continua

El proyecto incluirá pruebas automatizadas y validación mediante GitHub Actions.

Se contemplan:

- Unit tests para validaciones y reglas de inventario.
- Widget tests para formularios y estados visuales.
- Integration tests para flujos principales.
- GitHub Actions para validar pushes y pull requests.

---

### 7.14 Importación de productos desde archivo

La aplicación podrá incluir una funcionalidad de importación de productos desde archivo, especialmente útil para tiendas que ya manejan inventario en hojas de cálculo.

Para el MVP, la opción recomendada es importar archivos CSV, ya que es más simple de implementar y puede generarse desde Excel.

El flujo propuesto será:

1. El usuario selecciona un archivo CSV.
2. La app lee los productos.
3. La app muestra una vista previa.
4. La app valida errores básicos.
5. El usuario confirma la importación.
6. La app crea los productos y, si aplica, el stock inicial.

Columnas sugeridas:

- `name`
- `sku`
- `barcode`
- `category`
- `description`
- `minStock`
- `branchName`
- `initialStock`

Cuando se importe stock inicial, el sistema podrá crear un movimiento de inventario inicial con motivo `Initial import` para mantener trazabilidad desde el primer registro.

La importación Excel `.xlsx` completa queda como mejora futura si el tiempo del equipo lo permite.

---

## 8. Funcionalidades fuera de alcance

Para mantener el proyecto controlado, las siguientes funcionalidades quedan fuera del MVP:

- ERP completo.
- Facturación.
- Gestión de proveedores.
- Compras avanzadas.
- Reportes estadísticos complejos.
- Panel web administrativo.
- Permisos granulares avanzados.
- Auditoría empresarial avanzada.
- Inventario offline completo.
- Transferencias complejas entre sucursales.
- Integración con sistemas contables.
- Gestión financiera.
- Escaneo masivo avanzado de productos.
- Automatización completa de notificaciones mediante Cloud Functions.
- Importación avanzada de archivos Excel `.xlsx` con validaciones complejas.
- Conciliación automática de inventario desde archivos externos.

Estas funcionalidades pueden considerarse mejoras futuras, pero no son necesarias para cumplir el objetivo principal del proyecto.

---

## 9. Roles del sistema

### 9.1 Administrador

El administrador tendrá mayor control sobre la información del sistema.

Podrá:

- Gestionar productos.
- Gestionar sucursales de forma básica.
- Consultar stock por sucursal.
- Registrar entradas y salidas.
- Consultar historial de movimientos.
- Ver alertas de bajo stock.
- Importar productos desde archivo, si esta funcionalidad queda implementada en el MVP.

---

### 9.2 Colaborador

El colaborador representa a un usuario operativo de la tienda.

Podrá:

- Consultar productos.
- Consultar stock disponible.
- Registrar entradas y salidas permitidas.
- Consultar historial de movimientos.

Restricciones:

- No tendrá control sobre configuraciones avanzadas.
- No debería eliminar información crítica.
- No debería modificar directamente el stock sin registrar movimiento.
- No debería realizar importaciones masivas salvo que el equipo decida permitirlo explícitamente.

---

## 10. Entidades principales

### 10.1 User

Representa a un usuario autenticado.

Campos principales:

- `id`
- `name`
- `email`
- `role`
- `branchIds`
- `createdAt`

---

### 10.2 Branch

Representa una tienda o sucursal.

Campos principales:

- `id`
- `name`
- `address`
- `isActive`
- `createdAt`

---

### 10.3 Product

Representa un producto del catálogo general.

Campos principales:

- `id`
- `name`
- `sku`
- `barcode`
- `category`
- `description`
- `imageUrl`
- `minStock`
- `isActive`
- `createdAt`

---

### 10.4 Stock

Representa la cantidad disponible de un producto en una sucursal específica.

Campos principales:

- `id`
- `productId`
- `branchId`
- `availableQuantity`
- `lastMovementAt`
- `updatedAt`

Regla:

No debe existir más de un registro de stock para la misma combinación de producto y sucursal.

---

### 10.5 InventoryMovement

Representa una entrada o salida de inventario.

Campos principales:

- `id`
- `productId`
- `branchId`
- `userId`
- `type`
- `quantity`
- `reason`
- `notes`
- `resultingStock`
- `createdAt`

---

### 10.6 NotificationToken

Representa el token del dispositivo para notificaciones push.

Campos principales:

- `id`
- `userId`
- `token`
- `platform`
- `createdAt`

---

### 10.7 ImportBatch

Representa un proceso de importación de productos desde archivo.

Campos principales:

- `id`
- `fileName`
- `importedBy`
- `status`
- `totalRows`
- `validRows`
- `invalidRows`
- `createdAt`

Esta entidad es opcional para el MVP. Puede utilizarse si el equipo decide registrar historial de importaciones.

---

## 11. Reglas de negocio principales

### 11.1 El stock cambia mediante movimientos

El stock no se debe modificar directamente como un campo libre.

Todo cambio de stock debe estar respaldado por un movimiento de inventario.

---

### 11.2 Las entradas aumentan el stock

Cuando se registra una entrada:

- La cantidad debe ser mayor a cero.
- El producto debe estar activo.
- La sucursal debe estar activa.
- El sistema aumenta el stock disponible.
- El movimiento queda registrado en el historial.

---

### 11.3 Las salidas disminuyen el stock

Cuando se registra una salida:

- La cantidad debe ser mayor a cero.
- El producto debe estar activo.
- La sucursal debe estar activa.
- El sistema valida que exista stock suficiente.
- Si no hay stock suficiente, la salida no se registra.
- Si hay stock suficiente, el sistema disminuye el stock disponible.
- El movimiento queda registrado en el historial.

---

### 11.4 Todo movimiento debe tener trazabilidad

Cada movimiento debe registrar:

- Usuario responsable.
- Producto afectado.
- Sucursal afectada.
- Tipo de movimiento.
- Cantidad.
- Fecha y hora.
- Motivo.
- Stock resultante.

---

### 11.5 Los productos inactivos no deben usarse en nuevos movimientos

Un producto inactivo puede permanecer visible en el historial, pero no debe estar disponible para nuevos movimientos.

---

### 11.6 El bajo stock debe detectarse

Cuando la cantidad disponible de un producto en una sucursal sea menor o igual al stock mínimo definido, el sistema debe mostrar una alerta visual o notificación.

---

### 11.7 Los formularios deben validar datos antes de guardar

Los formularios deben validar:

- Campos obligatorios.
- Formatos válidos.
- Cantidades mayores a cero.
- Stock disponible.
- Valores duplicados cuando aplique.
- Productos y sucursales activos.

---

### 11.8 La API externa no reemplaza la validación interna

Los datos obtenidos desde la API externa deben ser tratados como sugerencias.

Antes de guardar un producto, el usuario debe poder revisar y corregir los datos autocompletados.

---

### 11.9 La importación desde archivo debe validarse antes de guardar

Los productos importados desde archivo deben pasar por una validación previa.

La aplicación deberá detectar, cuando aplique:

- Filas incompletas.
- Stock inicial negativo.
- Productos duplicados por SKU o código de barras.
- Sucursales inexistentes.
- Columnas faltantes.
- Formato inválido.

La importación no debe guardar datos inválidos sin confirmación del usuario.

---

## 12. Decisión técnica general

La aplicación se desarrollará usando Flutter y Dart.

La arquitectura base será:

- MVVM.
- Riverpod para manejo de estado e inyección de dependencias.
- Repository Pattern para separar la UI del acceso a datos.
- Firebase como backend principal.
- Firebase Auth para autenticación.
- Cloud Firestore para persistencia.
- Firebase Storage para imágenes.
- Firebase Cloud Messaging para notificaciones.
- Cliente HTTP, como Dio, solo para API externa de productos.
- Lectura de archivos CSV como funcionalidad complementaria de carga inicial de inventario.

Esta decisión permite cubrir los requerimientos técnicos del proyecto sin construir un backend propio completo, manteniendo el foco en el desarrollo móvil.

---

## 13. Criterios para considerar terminado el MVP

El MVP se considerará terminado cuando:

- Un usuario pueda registrarse e iniciar sesión.
- Existan roles básicos de administrador y colaborador.
- Se puedan crear, listar, consultar, editar y desactivar productos.
- Se pueda registrar un producto manualmente.
- Se pueda autocompletar un producto usando una API externa.
- Se pueda asociar imagen a un producto.
- Existan sucursales dentro del sistema.
- Se pueda visualizar stock por producto y sucursal.
- Se puedan registrar entradas de inventario.
- Se puedan registrar salidas de inventario.
- El sistema impida salidas mayores al stock disponible.
- Cada movimiento quede registrado en el historial.
- El historial permita consultar movimientos realizados.
- Existan búsquedas y filtros funcionales.
- La aplicación maneje estados de carga, vacío y error.
- La aplicación muestre retroalimentación visual al usuario.
- Exista almacenamiento local básico.
- Se consuma al menos una API externa.
- Exista alerta o notificación relacionada con bajo stock.
- Existan pruebas automatizadas relevantes.
- GitHub Actions ejecute validaciones automáticamente.
- La documentación técnica esté completa.
- El equipo pueda explicar la arquitectura, decisiones técnicas y flujos principales.

Criterio complementario si el tiempo lo permite:

- Se puede importar inventario inicial desde archivo CSV con vista previa y validaciones básicas.

---

## 14. Riesgos principales

### 14.1 Exceso de alcance

El proyecto puede crecer demasiado si se agregan funcionalidades empresariales como facturación, proveedores o reportes complejos.

Mitigación:

Mantener el enfoque en productos, stock, movimientos e historial.

---

### 14.2 Construir solo un CRUD de productos

Si el proyecto se limita a productos, no resuelve completamente la problemática de inventario.

Mitigación:

Priorizar stock por sucursal, movimientos e historial.

---

### 14.3 Tratar sucursales como dato opcional

La problemática habla de inventario entre sucursales. Si la sucursal no forma parte real del modelo, la solución queda débil.

Mitigación:

Mantener Branch como entidad y asociar Stock e InventoryMovement con `branchId`.

---

### 14.4 Permitir cambios de stock sin historial

Modificar stock directamente impediría rastrear responsabilidades.

Mitigación:

Actualizar stock únicamente mediante movimientos de inventario.

---

### 14.5 Dejar testing y documentación para el final

El proyecto exige calidad de ingeniería, pruebas y documentación.

Mitigación:

Crear documentación y pruebas durante el desarrollo, no al final.

---

### 14.6 Concentración del trabajo en pocos integrantes

El proyecto requiere trabajo colaborativo.

Mitigación:

Dividir el backlog por módulos y mantener commits distribuidos entre los integrantes.

---

### 14.7 Depender demasiado de la API externa

La API externa puede no encontrar todos los productos o puede fallar.

Mitigación:

Mantener el registro manual como flujo principal y usar la API externa solo como apoyo.

---

### 14.8 Importación de archivos demasiado compleja

La importación desde Excel o archivos complejos puede consumir demasiado tiempo.

Mitigación:

Priorizar CSV simple para el MVP y dejar Excel `.xlsx` avanzado como mejora futura.

---

## 15. Resultado esperado

Al finalizar el MVP, el equipo deberá contar con una aplicación móvil Flutter funcional que permita administrar inventario en una pequeña cadena de tiendas.

La aplicación deberá demostrar:

- Autenticación de usuarios.
- Gestión de productos.
- Registro manual de productos.
- Autocompletado de productos mediante API externa.
- Stock por sucursal.
- Registro de entradas.
- Registro de salidas.
- Validación de stock suficiente.
- Historial de movimientos.
- Búsqueda y filtros.
- Imagen de producto.
- Alerta o notificación de bajo stock.
- Pruebas automatizadas.
- Integración continua.
- Documentación técnica clara.

Si el tiempo lo permite, también podrá demostrar:

- Importación inicial de productos desde archivo CSV.

El resultado debe ser una solución de alcance controlado, pero con suficiente calidad técnica y funcional para presentarse como producto profesional.

