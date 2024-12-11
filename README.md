# Proyecto Desafío 360° Backend (NodeJS)

Este proyecto es el backend de la aplicación 360, el cual se encarga de la gestión de los datos de la aplicación Mi Tiendita Online.

## Requisitos

- Node.js
- SQL Server

## INSTRUCCIONES

Reto segunda semana:

1. Instalación de NodeJs,Express, POSTMAN, Repositorio de GitHub
2. Crear un API-REST para el proyecto final enlazado a la base de datos creada en la primera semana.
   2.1. Creación de Enpoints
   - CRUD de Productos: Inserción/Actualización
   - CRUD de Categorias de Productos: Inserción/Actualización
   - CRUD de Estados: Inserción/Actualización
   - CRUD de Usuarios: Inserción/Actualización (encriptar contraseña)
   - CRUD de Orden/Detalles, este es el unico CRUD donde se implementa un maestro detalle: Inserción/Actualización (Solo Encabezado)
   - CRUD de Clientes: Inserción/Actualización
3. Seguridad del API: Agregar autenticación al sistema
   - realizarlo mediante JSON web token
   - agregar gestión de sesiones de usuario
   - validar cada transacción que se haga al API con un token valido, expirar los tokens en 24 horas
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
