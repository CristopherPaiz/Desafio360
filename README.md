# Proyecto Desafío 360° Backend (NodeJS)

**Este proyecto es el backend de la aplicación 360, el cual se encarga de la gestión de los datos de la aplicación Mi Tiendita Online.**

## Tabla de Contenidos

- [Instrucciones](#instrucciones)
  - [Requisitos](#requisitos)
  - [Dependencias usadas](#dependencias-usadas-en-el-proyecto)
  - [Instalación y configuración](#instalación-y-configuración)
  - [Ejecutar el proyecto](#ejecutar-el-proyecto)
- [Endpoints de la API](#endpoints-de-la-api)
  - [Tabla de resumen de las rutas](#resumen-de-rutas)
  - [Gestión de Productos](#gestión-de-productos)
  - [Gestión de Categorías](#gestión-de-categorías)
  - [Gestión de Estados](#gestión-de-estados)
  - [Gestión de Usuarios](#gestión-de-usuarios)
  - [Gestión de Clientes](#gestión-de-clientes)
  - [Gestión de Órdenes](#gestión-de-órdenes)
  - [Gestión de Reportes (Vistas)](#gestión-de-reportes)
- [WebSockets](#websockets)

# INSTRUCCIONES

## **Reto segunda semana:**

1. **Instalación de herramientas necesarias:**

   - NodeJs, Express, POSTMAN, Repositorio de GitHub

2. **Crear un API-REST para el proyecto final enlazado a la base de datos creada en la primera semana.**

   - **Creación de Endpoints:**
     - CRUD de Productos: Inserción/Actualización
     - CRUD de Categorías de Productos: Inserción/Actualización
     - CRUD de Estados: Inserción/Actualización
     - CRUD de Usuarios: Inserción/Actualización (encriptar contraseña)
     - CRUD de Orden/Detalles: Este es el único CRUD donde se implementa un maestro detalle: Inserción/Actualización (Solo Encabezado)
     - CRUD de Clientes: Inserción/Actualización

3. **Seguridad del API: Agregar autenticación al sistema**

   - Realizarlo mediante JSON Web Token.
   - Agregar gestión de sesiones de usuario.
   - Validar cada transacción que se haga al API con un token válido, expirar los tokens en 24 horas.

4. **Validar los Endpoints utilizando POSTMAN.**

5. **Adjuntar LINK de repositorio público de GITHUB.**

6. **Adjuntar script de la base de datos actualizada con los registros de pruebas realizados.**

## Requisitos

- Node.js
- SQL Server

## Dependencias usadas en el proyecto

- Express
- Sequelize (ORM para Node.js)
- bcrypt (Librería para encriptar contraseñas)
- jsonwebtoken (Librería para manejar tokens de autenticación)
- socket.io (Librería para manejar WebSockets)
- dotenv (Librería para manejar variables de entorno)
- cors (Librería para manejar CORS)
- Multer (Librería para manejar archivos)
- Cloudinary (Librería para subir imágenes a Cloudinary)
- Sharp (Librería para redimensionar imágenes y reducir su peso)

## Instalación y configuración

1. Clonar el repositorio
2. Instalar las dependencias con `npm install`
3. Crear la base de datos en SQL Server con el nombre `GDA00412-OT-CristopherPaiz` (El script de la base de datos se encuentra en la carpeta `db`)
4. Crear un archivo `.env` en la raíz del proyecto con las siguientes variables:

```env
# Configuración del Servidor
PORT=3000

# Configuración de Base de Datos
# Configuración del Servidor
PORT=3000

# Configuración de Base de Datos
DB_HOST=localhost
DB_NOMBRE=GDA00412-OT-CristopherPaiz
DB_PUERTO=1433
DB_USUARIO=sa
DB_CONTRASENA=Administrador_123
JWT_SECRET=password_360_backend
SALT_ROUNDS=10

CLOUDINARY_CLOUD_NAME=drdkb6gjx1
CLOUDINARY_API_KEY=1793119394629481
CLOUDINARY_API_SECRET=pm16O5PHYkFhvb1fHuIOsQ9a1NU1
```

## Ejecutar el proyecto

Para ejecutar el proyecto, se debe correr el siguiente comando:

```bash
npm start
```

Para ejecutar el proyecto en modo desarrollo, se debe correr el siguiente comando:

```bash
npm run dev
```

# Endpoints de la API

### Resumen de Rutas

| Recurso                                                                                                             | Endpoints Disponibles                                      |
| ------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| [Productos](https://github.com/CristopherPaiz/Desafio360?tab=readme-ov-file#gestión-de-productos)                   | GET, POST, (PUT: Update, Soft-Delete)                      |
| [Categorías](https://github.com/CristopherPaiz/Desafio360?tab=readme-ov-file#gestión-de-categorías)                 | GET, POST, (PUT: Update, Soft-Delete)                      |
| [Estados](https://github.com/CristopherPaiz/Desafio360?tab=readme-ov-file#gestión-de-estados)                       | GET, POST, PUT, (DELETE: ⚠Hard Delete⚠)                    |
| [Usuarios](https://github.com/CristopherPaiz/Desafio360?tab=readme-ov-file#gestión-de-usuarios)                     | GET, POST, (PUT: Update, Soft-Delete)                      |
| [Clientes](https://github.com/CristopherPaiz/Desafio360?tab=readme-ov-file#gestión-de-clientes)                     | GET, POST, PUT, (DELETE: ⚠Hard Delete⚠)                    |
| [Órdenes y detalles](https://github.com/CristopherPaiz/Desafio360?tab=readme-ov-file#gestión-de-órdenes)            | GET, POST, PUT, (DELETE: ⚠Hard Delete⚠) (📡 WebSockets 📡) |
| [Gestión de reportes (Vistas)](https://github.com/CristopherPaiz/Desafio360?tab=readme-ov-file#gestión-de-reportes) | GET                                                        |

## Gestión de Productos

#### Obtener Todos los Productos

- **Método:** `GET /productos`
- **Descripción:** Recupera la lista completa de productos
- **URL:** `localhost:3000/productos`
- **Stored Procedure:** `sp_LeerProductos`

#### Filtrar Productos

- **Método:** `GET /productos?params`
- **Descripción:** Permite filtrar productos por nombre, categoría y estado
- **Parámetros:**
  - `nombre`: Filtro por nombre del producto
  - `categoria`: Filtro por categoría
  - `estado`: Filtro por estado
- **Ejemplo:** `localhost:3000/productos?nombre=Laptop&categoria=1&estado=1`
- **Stored Procedure:** `sp_LeerProductosFiltrados`

#### Crear Nuevo Producto

- **Método:** `POST /productos`
- **URL:** `localhost:3000/productos`
- **Stored Procedure:** `sp_InsertarProducto`

**Ejemplo de Solicitud:**

```json
{
  "CategoriaProductos_idCategoriaProductos": 1,
  "usuarios_idusuarios": 1,
  "nombre": "Laptop HP",
  "marca": "HP",
  "codigo": "HP1234",
  "stock": 50,
  "estados_idestados": 1,
  "precio": 500.0,
  "foto": "url-a-la-imagen.jpg"
}
```

#### Crear nuevo Producto con Imagen (TIPO FILE)

- **Método:** `POST /productos/img`
- **URL:** `localhost:3000/productos/img`
- **Stored Procedure:** `sp_InsertarProducto`

**Ejemplo de Solicitud:**

En el body va una propiedad llamada `imagen` que será de tipo file y el resto será normal como en el ejemplo anterior.

```json
{
  "CategoriaProductos_idCategoriaProductos": 1,
  "usuarios_idusuarios": 1,
  "nombre": "Laptop HP",
  "marca": "HP",
  "codigo": "HP1234",
  "stock": 50,
  "estados_idestados": 1,
  "precio": 500.0,
  "imagen": "TIPO FILE" // ATENCIÓN ESTE ARCHIVO CON LA ETIQUETA IMAGEN DEBE SER DE TIPO FILE
}
```

#### Actualizar Producto

- **Método:** `PUT /productos/:id`
- **Descripción:** Actualización parcial o total de un producto
- **URL:** `localhost:3000/productos/1`
- **Stored Procedure:** `sp_ActualizarProducto`

**Ejemplo de Solicitud (Actualización Parcial):**

```json
{
  "nombre": "Laptop HP Editada",
  "stock": 10,
  "precio": 500.0
}
```

**Ejemplo de Solicitud (Actualización Completa):**

```json
{
  "CategoriaProductos_idCategoriaProductos": 1,
  "usuarios_idusuarios": 1,
  "nombre": "Laptop HP Editada",
  "marca": "HP",
  "codigo": "HP1234Edit",
  "stock": 10,
  "precio": 500.0,
  "foto": "url-a-la-imagen.jpg"
}
```

#### Desactivar Producto

- **Método:** `PUT /productos/eliminar/:id`
- **URL:** `localhost:3000/productos/eliminar/1`
- **Stored Procedure:** `sp_CambiarEstadoProducto`
- **Descripción:** Cambia el estado del producto a inactivo

#### Restaurar Producto

- **Método:** `PUT /productos/restaurar/:id`
- **URL:** `localhost:3000/productos/restaurar/1`
- **Stored Procedure:** `sp_CambiarEstadoProducto`
- **Descripción:** Reactiva un producto previamente desactivado

## Gestión de Categorías

#### Obtener Todos las categorías

- **Método:** `GET /categorias`
- **Descripción:** Recupera la lista completa de las categorías
- **URL:** `localhost:3000/categorias`
- **Stored Procedure:** `sp_LeerCategoriaProductos`

#### Filtrar Categorías

- **Método:** `GET /categorias?params`
- **Descripción:** Permite filtrar categorías por nombre, usuario_nombre...
- **Parámetros:**
  - `nombre`: Filtro por nombre de la categoría
  - `usuario_nombre`: Filtro por nombre de usuario
- **Ejemplo:** `localhost:3000/categorias/filtro?nombre=Electrónicos&usuario_nombre=Roberto Martínez`
- **Stored Procedure:** `sp_LeerCategoriaProductosFiltradas`

#### Crear Nueva Categoría

- **Método:** `POST /categorias`
- **URL:** `localhost:3000/categorías`
- **Stored Procedure:** `sp_InsertarCategoriaProductos`

**Ejemplo de Solicitud:**

```json
{
  "usuarios_idusuarios": 1,
  "nombre": "Línea Blanca",
  "estados_idestados": 1
}
```

#### Actualizar Categoría

- **Método:** `PUT /categorías/:id`
- **Descripción:** Actualización parcial o total de una categoría
- **URL:** `localhost:3000/categorías/1`
- **Stored Procedure:** `sp_ActualizarCategoriaProductos`

**Ejemplo de Solicitud (Actualización Parcial o completa):**

```json
{
  "usuarios_idusuarios": 1,
  "nombre": "Línea Blanca",
  "estados_idestados": 1
}
```

#### Desactivar Categoría

- **Método:** `PUT /categorias/eliminar/:id`
- **URL:** `localhost:3000/categorias/eliminar/1`
- **Stored Procedure:** `sp_CambiarEstadoCategoriaProductos`
- **Descripción:** Cambia el estado de la categoría a inactivo

#### Restaurar Categoría

- **Método:** `PUT /categorias/restaurar/:id`
- **URL:** `localhost:3000/categorias/restaurar/1`
- **Stored Procedure:** `sp_CambiarEstadoCategoriaProductos`
- **Descripción:** Reactiva una categoría previamente desactivada

## Gestión de Estados

#### Obtener Todos los estados

- **Método:** `GET /estados`
- **Descripción:** Recupera la lista completa de los estados
- **URL:** `localhost:3000/estados`
- **Stored Procedure:** `sp_LeerEstados`

#### Crear Nuevo Estado

- **Método:** `POST /estados`
- **URL:** `localhost:3000/estados`
- **Stored Procedure:** `sp_InsertarEstado`

**Ejemplo de Solicitud:**

```json
{
  "nombre": "Verificado"
}
```

#### Actualizar Estado

- **Método:** `PUT /estados/:id`
- **Descripción:** Actualización total de un estado, únicamente el nombre
- **URL:** `localhost:3000/estados/7`
- **Stored Procedure:** `sp_ActualizarEstado`

**Ejemplo de Solicitud (Actualización completa y única):**

```json
{
  "nombre": "Ultra Verificado"
}
```

#### Eliminar Estado

- **Método:** `DELETE /estados/:id`
- **URL:** `localhost:3000/estados/7`
- **Stored Procedure:** `sp_EliminarEstado`
- **Descripción:** Elimina un estado de la base de datos ⚠⚠⚠ HARD DELETE ⚠⚠⚠

## Gestión de Usuarios

#### Obtener Todos los Usuarios

- **Método:** `GET /usuarios`
- **Descripción:** Recupera la lista completa de los usuarios
- **URL:** `localhost:3000/usuarios`
- **Stored Procedure:** `sp_LeerUsuarios`

#### Filtrar Usuarios

- **Método:** `GET /usuarios?params`
- **Descripción:** Permite filtrar usuarios por nombre, correo electrónico, rol y estado
- **Parámetros:**
  - `nombre`: Filtro por nombre del usuario
  - `rol`: Filtro por rol
  - `estado`: Filtro por estado
- **Ejemplo:** `localhost:3000/usuarios/filtro?nombre=Ana López&rol=Cliente&estado=Activo`
- **Stored Procedure:** `sp_LeerUsuariosFiltrados`

#### Crear Nuevo Usuario

- **Método:** `POST /usuarios`
- **URL:** `localhost:3000/usuarios`
- **Stored Procedure:** `sp_InsertarUsuario`

**Ejemplo de Solicitud:**

```json
{
  "rol_idrol": 3,
  "estados_idestados": 1,
  "correo_electronico": "operador1@operador1.com",
  "nombre_completo": "operador1",
  "password": "op123",
  "telefono": 55667788,
  "fecha_nacimiento": "2001-10-10",
  "Clientes_idClientes": NULL, // Si es administrador u operador no se pone, sino se pone el id del cliente
}
```

#### Actualizar Usuario

- **Método:** `PUT /usuarios/:id`
- **Descripción:** Actualización parcial o total de un usuario
- **URL:** `localhost:3000/usuarios/1`
- **Stored Procedure:** `sp_ActualizarUsuario`

**Ejemplo de Solicitud (Actualización Total):**

```json
{
  "rol_idrol": 2,
  "estados_idestados": 1,
  "correo_electronico": "operador2@operador1.com",
  "nombre_completo": "operador2",
  "telefono": 55000000,
  "fecha_nacimiento": "2001-10-10",
  "Clientes_idClientes": 1
}
```

#### Eliminar Usuario

- **Método:** `PUT /usuarios/:id`
- **URL:** `localhost:3000/usuarios/eliminar/1`
- **Stored Procedure:** `sp_CambiarEstadoUsuario`
- **Descripción:** Cambia el estado del usuario a inactivo

#### Restaurar Usuario

- **Método:** `PUT /usuarios/:id`
- **URL:** `localhost:3000/usuarios/restaurar/1`
- **Stored Procedure:** `sp_CambiarEstadoUsuario`
- **Descripción:** Reactiva un usuario previamente desactivado

## Gestión de Clientes

#### Obtener Todos los Clientes

- **Método:** `GET /clientes`
- **Descripción:** Recupera la lista completa de los clientes
- **URL:** `localhost:3000/clientes`
- **Stored Procedure:** `sp_LeerClientes`

#### Filtrar Clientes

- **Método:** `GET /clientes?params`
- **Descripción:** Permite filtrar clientes por razon social o correo electrónico
- **Parámetros:**
  - `razon`: Filtro por razón social del cliente
  - `email`: Filtro por correo electrónico del cliente
- **Ejemplo:** `localhost:3000/clientes/filtro?razon=Comercio`
- **Stored Procedure:** `sp_LeerClientesFiltrados`

#### Crear Nuevo Cliente

- **Método:** `POST /clientes`
- **URL:** `localhost:3000/clientes`
- **Stored Procedure:** `sp_InsertarCliente`

**Ejemplo de Solicitud:**

```json
{
  "razon_social": "Comercial Sotz",
  "nombre_comercial": "Comercio El Mero Sotz",
  "direccion_entrega": "Zona 1, Guatemala",
  "telefono": "55554444",
  "email": "info@sotz.com"
}
```

#### Actualizar Cliente

- **Método:** `PUT /clientes/:id`
- **Descripción:** Actualización parcial o total de un cliente
- **URL:** `localhost:3000/clientes/1`
- **Stored Procedure:** `sp_ActualizarCliente`

**Ejemplo de Solicitud (Actualización Total):**

```json
{
  "razon_social": "Comercial Sotz Actualizada",
  "nombre_comercial": "Comercio El Mero Sotz Actualizado",
  "direccion_entrega": "Zona 1, Guatemala",
  "telefono": "55554444",
  "email": "info@sotz.com"
}
```

#### Eliminar Cliente

- **Método:** `DELETE /clientes/:id`
- **URL:** `localhost:3000/clientes/1`
- **Stored Procedure:** `sp_EliminarCliente`
- **Descripción:** Elimina un cliente de la base de datos ⚠⚠⚠ HARD DELETE ⚠⚠⚠

## Gestión de Órdenes

#### Obtener Todas las Órdenes sin Detalles

- **Método:** `GET /ordenes`
- **Descripción:** Recupera la lista completa de las órdenes sin sus detalles
- **URL:** `localhost:3000/ordenes`
- **Stored Procedure:** `sp_LeerOrdenes`

#### Obtener una orden con sus detalles

- **Método:** `GET /ordenes/:id`
- **Descripción:** Recupera una orden con sus detalles
- **URL:** `localhost:3000/ordenes/100`
- **Stored Procedure:** `sp_LeerOrdenPorId`

#### Crear Nueva Orden con Detalles incluídos (Encabezado y Detalles)

- **Método:** `POST /ordenes`
- **Descripción:** Creación de una nueva orden con sus detalles incluídos
- **URL:** `localhost:3000/ordenes`
- **Stored Procedure:** `sp_InsertarOrden` y `sp_InsertarOrdenDetalle`

**Ejemplo de Solicitud:**

```json
{
  "usuarios_idusuarios": 3,
  "estados_idestados": 4,
  "nombre_completo": "Roberto Martínez",
  "direccion": "Calle Falsa 123, Ciudad",
  "telefono": "44440000",
  "correo_electronico": "roberto@ejemplo.com",
  "fecha_entrega": "2024-12-20",
  "total_orden": 150.75,
  "detalles": [
    {
      "Productos_idProductos": 8,
      "cantidad": 2,
      "precio": 50.25
    },
    {
      "Productos_idProductos": 7,
      "cantidad": 1,
      "precio": 50.25
    }
  ]
}
```

#### Añadir detalles a una orden existente

- **Método:** `POST /ordenes/:id/detalles`
- **Descripción:** Añadir detalles a una orden existente
- **URL:** `localhost:3000/ordenes/100/detalles`
- **Stored Procedure:** `sp_InsertarOrdenDetalle`

**Ejemplo de Solicitud:**

```json
{
  "Productos_idProductos": 8,
  "cantidad": 2,
  "precio": 50.25
}
```

#### Actualizar Orden (Encabezado)

- **Método:** `PUT /ordenes/:id`
- **Descripción:** Actualización parcial o total de una orden
- **URL:** `localhost:3000/ordenes/100`
- **Stored Procedure:** `sp_ActualizarOrden`

**Ejemplo de Solicitud (Actualización Total):**

```json
{
  "estados_idestados": 4,
  "nombre_completo": "Juan Pérez Actualizado",
  "direccion": "Calle Falsa 123, Ciudad",
  "telefono": "55664433",
  "correo_electronico": "juan.perez@example.com",
  "fecha_entrega": "2024-12-25",
  "total_orden": 150.75
}
```

#### Cambiar Estado de Orden

- **Método:** `PUT /ordenes/estado/:id`
- **Descripción:** Cambiar el estado de una orden Ej. de Pendiente -> Enviado -> Tránsito -> Entregado
- **URL:** `localhost:3000/ordenes/estado/100`
- **Stored Procedure:** `sp_CambiarEstadoOrden`

```json
{
  "estados_idestados": 5
}
```

#### Eliminar Orden ⚠⚠⚠⚠ HARD DELETE ⚠⚠⚠⚠ (Este método elimina la orden y regresa los productos al stock)

- **Método:** `DELETE /ordenes/:id`
- **Descripción:** Elimina una orden de la base de datos y regresa los productos al stock
- **URL:** `localhost:3000/ordenes/100`
- **Stored Procedure:** `sp_EliminarOrden`

## Gestión de Reportes

#### Reporte: Total de Productos activos que tenga en stock mayor a 0

- **Método:** `GET /reportes/activosConStock`
- **Descripción:** Recupera el total de productos activos que tengan stock mayor a 0
- **URL:** `localhost:3000/reportes/activosConStock`
- **View:** `VistaProductosActivosConStockMayorACero`

#### Reporte: Total de Quetzales en ordenes ingresadas en el mes de Agosto 2024

- **Método:** `GET /reportes/ordenesAgosto`
- **Descripción:** Recupera el total de quetzales en órdenes ingresadas en el mes de Agosto de 2024
- **URL:** `localhost:3000/reportes/ordenesAgosto`
- **View:** `VistaTotalOrdenesAgosto2024`

#### Reporte: Top 10 de clientes con Mayor consumo de ordenes de todo el histórico

- **Método:** `GET /reportes/clientesConsumo`
- **Descripción:** Recupera el top 10 de clientes con mayor consumo de órdenes de todo el histórico
- **URL:** `localhost:3000/reportes/clientesConsumo`
- **View:** `VistaTop10ClientesMayorConsumo`

#### Reporte: Top 10 de productos más vendidos en orden ascendente

- **Método:** `GET /reportes/masVendidos`
- **Descripción:** Recupera el top 10 de productos más vendidos en orden ascendente
- **URL:** `localhost:3000/reportes/masVendidos`
- **View:** `VistaTop10ProductosMasVendidos`

# WebSockets

Para la gestión de las órdenes y sus detalles, se ha implementado un sistema de WebSockets para notificar a los Administradores y operadores cuando una orden cambia de estado, por ejemplo, de Pendiente a Enviado, de Enviado a Tránsito o si se agregan nuevos detalles a una orden. Para esto, se han implementado los siguientes eventos:

- `ordenes:list`: El más básico, se emite para que todos puedan ver la lista de órdenes
- `ordenes:created`: Se emite cuando se crea una nueva orden
- `ordenes:updated`: Se emite cuando se actualiza una orden en el encabezado, se agregan detalles.
- `ordenes:statusChanged`: Se emite cuando se cambia el estado de una orden.
- `ordenes:deleted`: Se emite cuando se elimina una orden.
