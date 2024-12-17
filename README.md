# Proyecto Desafío 360° Backend (NodeJS)

Este proyecto es el backend de la aplicación 360, el cual se encarga de la gestión de los datos de la aplicación Mi Tiendita Online.

## Requisitos

- Node.js
- SQL Server

## INSTRUCCIONES

Reto segunda semana:

1. Instalación de NodeJs,Express, POSTMAN, Repositorio de GitHub
2. Crear un API-REST para el proyecto final enlazado a la base de datos creada en la primera semana.
   - Creación de Enpoints
   1. CRUD de Productos: Inserción/Actualización
   2. CRUD de Categorias de Productos: Inserción/Actualización
   3. CRUD de Estados: Inserción/Actualización
   4. CRUD de Usuarios: Inserción/Actualización (encriptar contraseña)
   5. CRUD de Orden/Detalles, este es el unico CRUD donde se implementa un maestro detalle: Inserción/Actualización (Solo Encabezado)
   6. CRUD de Clientes: Inserción/Actualización
3. Seguridad del API: Agregar autenticación al sistema
   1. realizarlo mediante JSON web token
   2. agregar gestión de sesiones de usuario
   3. validar cada transacción que se haga al API con un token valido, expirar los tokens en 24 horas
4. Validar los endpoint utilizando POSTMAN
5. Adjuntar LINK de repositorio publico de GITHUB
6. Adjuntar script de la base de datos actualizada con los registros de pruebas realizados.

## Dependencias usadas en el proyecto

- Express
- Sequelize (ORM para Node.js)
- bcrypt (Librería para encriptar contraseñas)
- jsonwebtoken (Librería para manejar tokens de autenticación)
- socket.io (Librería para manejar WebSockets)
- dotenv (Librería para manejar variables de entorno)
- cors (Librería para manejar CORS)

## Instalación y configuración

1. Clonar el repositorio
2. Instalar las dependencias con `npm install`
3. Crear un archivo `.env` en la raíz del proyecto con las siguientes variables:

```env
# Configuración del Servidor
PORT=3000

# Configuración de Base de Datos
DB_HOST=localhost
DB_NOMBRE=GDA00412-OT-CristopherPaiz
DB_PUERTO=1433
DB_USUARIO=sa
DB_CONTRASENA=Administrador_123
```

4. Crear la base de datos en SQL Server con el nombre `GDA00412-OT-CristopherPaiz`

## Ejecutar el proyecto

Para ejecutar el proyecto, se debe correr el siguiente comando:

```bash
npm start
```

Para ejecutar el proyecto en modo desarrollo, se debe correr el siguiente comando:

```bash
npm run dev
```

## Endpoints de la API

### Resumen de Rutas

| Recurso                                                                                             | Endpoints Disponibles                     |
| --------------------------------------------------------------------------------------------------- | ----------------------------------------- |
| [Productos](https://github.com/CristopherPaiz/Desafio360?tab=readme-ov-file#gestión-de-productos)   | GET, POST, (PUT: Update, Soft-Delete)     |
| [Categorías](https://github.com/CristopherPaiz/Desafio360?tab=readme-ov-file#gestión-de-categorías) | GET, POST, (PUT: Update, Soft-Delete)     |
| [Estados](https://github.com/CristopherPaiz/Desafio360?tab=readme-ov-file#gestión-de-estados)       | GET, POST, PUT, (DELETE: ⚠ Hard Delete ⚠) |
| [Usuarios](https://github.com/CristopherPaiz/Desafio360?tab=readme-ov-file#gestión-de-usuarios)     | GET, POST, (PUT: Update, Soft-Delete)     |
| Clientes                                                                                            | GET, POST, PUT, DELETE                    |
| Órdenes                                                                                             | GET, POST, PUT, DELETE                    |

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

## Gestion de Estados

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
- **Descripción:** Elimina un estado de la base de datos ⚠⚠ HARD DELETE ⚠⚠

## Gestion de Usuarios

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
