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

| Recurso                                                                           | Endpoints Disponibles                  |
| --------------------------------------------------------------------------------- | -------------------------------------- |
| [Productos](/CristopherPaiz/Desafio360?tab=readme-ov-file#gestión-de-productos)   | GET, POST, PUT (Actualizar, Eliminar)  |
| [Categorías](/CristopherPaiz/Desafio360?tab=readme-ov-file#gestión-de-categorías) | GET, POST, PUT, (Actualizar, Eliminar) |
| Estados                                                                           | GET, POST, PUT, DELETE                 |
| Usuarios                                                                          | GET, POST, PUT, DELETE                 |
| Clientes                                                                          | GET, POST, PUT, DELETE                 |
| Órdenes                                                                           | GET, POST, PUT, DELETE                 |

## Gestión de Productos

### Consulta de Productos

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

### Creación de Productos

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

### Actualización de Productos

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

### Gestión de Estado de Productos

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

### Consulta de Categorías

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

### Creación de una Categoría

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

### Actualización de un Categoría

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

### Gestión de Estado de una Categoría

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
