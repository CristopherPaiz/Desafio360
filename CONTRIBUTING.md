# Documentación de Endpoints

## 1. Middleware auth / token

- **OK** - Login (POST)

## 2. Productos

- **OK** - Insertar (POST - Body)
- **OK** - Actualizar (PUT - Body)
- **OK** - Eliminar (PUT - Body)
- **OK** - Restaurar (PUT - Body)
- **OK** - Leer (GET)
- **OK** - Leer Filtrado (GET - Params)

## 3. Categorías

- **OK** - Insertar (POST - Body)
- **OK** - Actualizar (PUT - Body)
- **OK** - Eliminar (PUT - Body)
- **OK** - Leer (GET)
- **OK** - Leer Filtrado (GET - Params)

## 4. Estados

- **OK** - Insertar (POST - Body)
- **OK** - Actualizar (PUT - Body)
- **OK** - Eliminar (DELETE - param)
- **OK** - Leer (GET)

## 5. Usuarios

- **OK** - Insertar (POST - Body)
- **OK** - Actualizar (PUT - Body)
- **OK** - Eliminar (PUT - Body)
- **OK** - Restaurar (PUT - Body)
- **OK** - Leer (GET)
- **OK** - Leer Filtrado (GET)

## 6. Clientes

- **OK** - Insertar (POST - Body)
- **OK** - Actualizar (PUT - Body)
- **OK** - Eliminar (PUT - Params)
- **OK** - Leer (GET)
- **OK** - Leer Filtrado (GET - Params)

## 7. Orden / Detalles

- **OK** - Insertar [Transaction] (WebSocket / POST - Body)
- **OK** - Actualizar [Transaction] (WebSocket / PUT - Body)
- **OK** - Eliminar [Transaction] (WebSocket / PUT - Body)
- **OK** - Leer (WebSocket / GET)
- **OK** - Leer Filtrado (WebSocket / GET)

## 8. Reportes

- **OK** - activosConStock (GET)
- **OK** - ordenesAgosto (GET)
- **OK** - clientesConsumo (GET)
- **OK** - masVendidos (GET)

## 9. Gestión de imágenes (Cloudinary)

- **OK** - Hacer fetch para Cloudinary y subir la imagen.
- **OK** - Obtener la URL y guardarla en la base de datos.
- **OK** - Crear un endpoint para subir la imagen.
- **OK** - Meter la URL en el body del producto.
- **OK** - Guardar el producto.
- **OK** - Limpiar codigo y documentar
