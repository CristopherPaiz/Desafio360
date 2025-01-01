-- CRISTOPHER ABRAHAN PAIZ LÓPEZ
-- CLAVE: GDA00412-OT

-- #########################################################################################
-- ################################### CREACION DE LA BD ###################################
-- #########################################################################################

-- Verifico si la base de datos ya existe y, si es así, la elimino
IF DB_ID(N'GDA00412-OT-CristopherPaiz') IS NOT NULL
BEGIN
    -- Terminar conexiones activas forzosamente
    ALTER DATABASE [GDA00412-OT-CristopherPaiz] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [GDA00412-OT-CristopherPaiz];
END

-- Creo la nueva base de datos
CREATE DATABASE [GDA00412-OT-CristopherPaiz];
GO

-- Uso la base de datos recién creada
USE [GDA00412-OT-CristopherPaiz];
GO

-- ##############################################################################################
-- ################################### CREACION DE LAS TABLAS ###################################
-- ##############################################################################################

-- Tabla Estados
CREATE TABLE Estados (
    idestados INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(45) NOT NULL UNIQUE
);
GO

-- Tabla Rol
CREATE TABLE Rol (
    idrol INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(45) NOT NULL UNIQUE
);
GO

-- Tabla Clientes
CREATE TABLE Clientes (
    idClientes INT IDENTITY(1,1) PRIMARY KEY,
    razon_social NVARCHAR(245),
    nombre_comercial NVARCHAR(340),
    direccion_entrega NVARCHAR(45),
    telefono NVARCHAR(45),
    email NVARCHAR(45)
);
GO

-- Tabla Usuarios
CREATE TABLE Usuarios (
    idusuarios INT IDENTITY(1,1) PRIMARY KEY,
    rol_idrol INT NOT NULL,
    estados_idestados INT NOT NULL,
    correo_electronico NVARCHAR(90) UNIQUE,
    nombre_completo NVARCHAR(45),
    password NVARCHAR(255),
    telefono NVARCHAR(15),
    fecha_nacimiento DATE,
    fecha_creacion DATETIME DEFAULT GETDATE(),
    Clientes_idClientes INT,
    FOREIGN KEY (rol_idrol) REFERENCES Rol(idrol),
    FOREIGN KEY (estados_idestados) REFERENCES Estados(idestados),
    FOREIGN KEY (Clientes_idClientes) REFERENCES Clientes(idClientes)
);
GO

-- Tabla CategoriaProductos
CREATE TABLE CategoriaProductos (
    idCategoriaProductos INT IDENTITY(1,1) PRIMARY KEY,
    usuarios_idusuarios INT NOT NULL,
    nombre NVARCHAR(45),
    estados_idestados INT NOT NULL,
    fecha_creacion DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (usuarios_idusuarios) REFERENCES Usuarios(idusuarios),
    FOREIGN KEY (estados_idestados) REFERENCES Estados(idestados)
);
GO

-- Tabla Productos
CREATE TABLE Productos (
    idProductos INT IDENTITY(1,1) PRIMARY KEY,
    CategoriaProductos_idCategoriaProductos INT NOT NULL,
    usuarios_idusuarios INT NOT NULL,
    nombre NVARCHAR(45),
    marca NVARCHAR(45),
    codigo NVARCHAR(45) UNIQUE,
    stock FLOAT CHECK (stock >= 0),
    estados_idestados INT NOT NULL,
    precio FLOAT CHECK (precio >= 0),
    fecha_creacion DATETIME DEFAULT GETDATE(),
    foto NVARCHAR(200),
    FOREIGN KEY (CategoriaProductos_idCategoriaProductos) REFERENCES CategoriaProductos(idCategoriaProductos),
    FOREIGN KEY (usuarios_idusuarios) REFERENCES Usuarios(idusuarios),
    FOREIGN KEY (estados_idestados) REFERENCES Estados(idestados)
);
GO

-- Tabla Orden
CREATE TABLE Orden (
    idOrden INT IDENTITY(1,1) PRIMARY KEY,
    usuarios_idusuarios INT NOT NULL,
    estados_idestados INT NOT NULL,
    fecha_creacion DATETIME DEFAULT GETDATE(),
    nombre_completo NVARCHAR(45),
    direccion NVARCHAR(545),
    telefono NVARCHAR(15),
    correo_electronico NVARCHAR(90),
    fecha_entrega DATE,
    total_orden FLOAT CHECK (total_orden >= 0),
    FOREIGN KEY (usuarios_idusuarios) REFERENCES Usuarios(idusuarios),
    FOREIGN KEY (estados_idestados) REFERENCES Estados(idestados)
);
GO

-- Tabla OrdenDetalles
CREATE TABLE OrdenDetalles (
    idOrdenDetalles INT IDENTITY(1,1) PRIMARY KEY,
    Orden_idOrden INT NOT NULL,
    Productos_idProductos INT NOT NULL,
    cantidad INT CHECK (cantidad > 0),
    precio FLOAT CHECK (precio >= 0),
    subtotal FLOAT CHECK (subtotal >= 0),
    FOREIGN KEY (Orden_idOrden) REFERENCES Orden(idOrden),
    FOREIGN KEY (Productos_idProductos) REFERENCES Productos(idProductos)
);
GO

-- ##################################################################################################################
-- ################################### CREACION DE LOS PROCEDIMIENTOS ALMACENADOS ###################################
-- ##################################################################################################################


-- #######################################################################################################################
-- ###################################################### SP ESTADO ######################################################
-- #######################################################################################################################


-- Insertar Estado
-- EXEC sp_InsertarEstado @nombre = 'Activo'
CREATE PROCEDURE sp_InsertarEstado
    @nombre NVARCHAR(45)
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Estados WHERE nombre = @nombre)
        BEGIN
            RAISERROR('Ya existe un estado con este nombre.', 16, 1);
            RETURN;
        END

        INSERT INTO Estados (nombre)
        VALUES (@nombre);

        SELECT SCOPE_IDENTITY() AS idestados;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Actualizar Estado
-- EXEC sp_ActualizarEstado @idestados = 1, @nombre = 'Inactivo'
CREATE PROCEDURE sp_ActualizarEstado
    @idestados INT,
    @nombre NVARCHAR(45)
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Estados WHERE idestados = @idestados)
        BEGIN
            RAISERROR('El estado no existe.', 16, 1);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM Estados WHERE nombre = @nombre AND idestados != @idestados)
        BEGIN
            RAISERROR('Ya existe otro estado con este nombre.', 16, 1);
            RETURN;
        END

        UPDATE Estados
        SET nombre = @nombre
        WHERE idestados = @idestados;

        SELECT @idestados AS idestados;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Eliminar Estado (Hard Delete) (En teoría nunca se usaría, pero por si acaso lo pongo)
-- EXEC sp_EliminarEstado @idestados = 1
CREATE PROCEDURE sp_EliminarEstado
    @idestados INT
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Estados WHERE idestados = @idestados)
        BEGIN
            RAISERROR('El estado no existe.', 16, 1);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM Usuarios WHERE estados_idestados = @idestados) OR
           EXISTS (SELECT 1 FROM CategoriaProductos WHERE estados_idestados = @idestados) OR
           EXISTS (SELECT 1 FROM Productos WHERE estados_idestados = @idestados) OR
           EXISTS (SELECT 1 FROM Orden WHERE estados_idestados = @idestados)
        BEGIN
            RAISERROR('No se puede eliminar el estado porque está siendo utilizado en otras tablas.', 16, 1);
            RETURN;
        END

        DELETE FROM Estados WHERE idestados = @idestados;

        SELECT @idestados AS idestados;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Leer Estados
-- EXEC sp_LeerEstados
CREATE PROCEDURE sp_LeerEstados
AS
BEGIN
    BEGIN TRY
        SELECT idestados, nombre
        FROM Estados
        ORDER BY nombre;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- #######################################################################################################################
-- ######################################################## SP ROL #######################################################
-- #######################################################################################################################
-- Insertar Rol
-- EXEC sp_InsertarRol @nombre = 'Operador'
CREATE PROCEDURE sp_InsertarRol
    @nombre NVARCHAR(45)
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Rol WHERE nombre = @nombre)
        BEGIN
            RAISERROR('Ya existe un rol con este nombre.', 16, 1);
            RETURN;
        END

        INSERT INTO Rol (nombre)
        VALUES (@nombre);

        SELECT SCOPE_IDENTITY() AS idrol;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Actualizar Rol
-- EXEC sp_ActualizarRol @idrol = 1, @nombre = 'Administrador'
CREATE PROCEDURE sp_ActualizarRol
    @idrol INT,
    @nombre NVARCHAR(45)
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Rol WHERE idrol = @idrol)
        BEGIN
            RAISERROR('El rol no existe.', 16, 1);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM Rol WHERE nombre = @nombre AND idrol != @idrol)
        BEGIN
            RAISERROR('Ya existe otro rol con este nombre.', 16, 1);
            RETURN;
        END

        UPDATE Rol
        SET nombre = @nombre
        WHERE idrol = @idrol;

        SELECT @idrol AS idrol;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Eliminar Rol (Tampoco debería usarse nunca)
-- EXEC sp_EliminarRol @idrol = 1
CREATE PROCEDURE sp_EliminarRol
    @idrol INT
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Rol WHERE idrol = @idrol)
        BEGIN
            RAISERROR('El rol no existe.', 16, 1);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM Usuarios WHERE rol_idrol = @idrol)
        BEGIN
            RAISERROR('No se puede eliminar el rol porque está siendo utilizado por usuarios.', 16, 1);
            RETURN;
        END

        DELETE FROM Rol WHERE idrol = @idrol;

        SELECT @idrol AS idrol;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Leer Roles
-- EXEC sp_LeerRoles
CREATE PROCEDURE sp_LeerRoles
AS
BEGIN
    BEGIN TRY
        SELECT idrol, nombre
        FROM Rol
        ORDER BY nombre;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- #######################################################################################################################
-- ##################################################### SP CLIENTES #####################################################
-- #######################################################################################################################
-- Insertar Cliente
-- EXEC sp_InsertarCliente
--     @razon_social = 'Empresa de Prueba S.A.',
--     @nombre_comercial = 'Prueba Comercial',
--     @direccion_entrega = 'Dirección de Entrega',
--     @telefono = '123456789',
--     @email = 'contacto@empresa.com'
CREATE PROCEDURE sp_InsertarCliente
    @razon_social NVARCHAR(245),
    @nombre_comercial NVARCHAR(340),
    @direccion_entrega NVARCHAR(45),
    @telefono NVARCHAR(45),
    @email NVARCHAR(45)
AS
BEGIN
    BEGIN TRY
        -- Validar que no exista un cliente con el mismo email o razón social
        IF EXISTS (SELECT 1 FROM Clientes
                   WHERE email = @email OR razon_social = @razon_social)
        BEGIN
            RAISERROR('Ya existe un cliente con este correo o razón social.', 16, 1);
            RETURN;
        END

        INSERT INTO Clientes (
            razon_social,
            nombre_comercial,
            direccion_entrega,
            telefono,
            email
        )
        VALUES (
            @razon_social,
            @nombre_comercial,
            @direccion_entrega,
            @telefono,
            @email
        );

        SELECT SCOPE_IDENTITY() AS idClientes;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Actualizar Cliente
-- EXEC sp_ActualizarCliente
--     @idClientes = 1,
--     @razon_social = 'Empresa Actualizada S.A.',
--     @nombre_comercial = 'Nuevo Nombre Comercial',
--     @direccion_entrega = 'Nueva Dirección',
--     @telefono = '987654321',
--     @email = 'nuevo@empresa.com'
CREATE PROCEDURE sp_ActualizarCliente
    @idClientes INT,
    @razon_social NVARCHAR(245),
    @nombre_comercial NVARCHAR(340),
    @direccion_entrega NVARCHAR(45),
    @telefono NVARCHAR(45),
    @email NVARCHAR(45)
AS
BEGIN
    BEGIN TRY
        -- Verificar que el cliente existe
        IF NOT EXISTS (SELECT 1 FROM Clientes WHERE idClientes = @idClientes)
        BEGIN
            RAISERROR('El cliente no existe.', 16, 1);
            RETURN;
        END

        -- Validar que no exista otro cliente con el mismo email o razón social
        IF EXISTS (SELECT 1 FROM Clientes
                   WHERE (email = @email OR razon_social = @razon_social)
                   AND idClientes != @idClientes)
        BEGIN
            RAISERROR('Ya existe otro cliente con este correo o razón social.', 16, 1);
            RETURN;
        END

        UPDATE Clientes
        SET
            razon_social = @razon_social,
            nombre_comercial = @nombre_comercial,
            direccion_entrega = @direccion_entrega,
            telefono = @telefono,
            email = @email
        WHERE idClientes = @idClientes;

        SELECT @idClientes AS idClientes;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Eliminar Cliente (Soft Delete) (Se puede usar pero con cuidado xD)
-- EXEC sp_EliminarCliente @idClientes = 1
CREATE PROCEDURE sp_EliminarCliente
    @idClientes INT
AS
BEGIN
    BEGIN TRY
        -- Verificar que el cliente existe
        IF NOT EXISTS (SELECT 1 FROM Clientes WHERE idClientes = @idClientes)
        BEGIN
            RAISERROR('El cliente no existe.', 16, 1);
            RETURN;
        END

        -- Verificar que no tenga usuarios asociados
        IF EXISTS (SELECT 1 FROM Usuarios WHERE Clientes_idClientes = @idClientes)
        BEGIN
            RAISERROR('No se puede eliminar el cliente porque tiene usuarios asociados.', 16, 1);
            RETURN;
        END

        DELETE FROM Clientes WHERE idClientes = @idClientes;

        SELECT @idClientes AS idClientes;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Leer Clientes
-- EXEC sp_LeerClientes
CREATE PROCEDURE sp_LeerClientes
AS
BEGIN
    BEGIN TRY
        SELECT
            idClientes,
            razon_social,
            nombre_comercial,
            direccion_entrega,
            telefono,
            email
        FROM Clientes
        ORDER BY razon_social;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Leer Clientes Filtrados por empresa, correo y/o ID del cliente
-- EXEC sp_LeerClientesFiltrados @razon_social = 'Empresa'
-- EXEC sp_LeerClientesFiltrados @email = 'contacto'
-- EXEC sp_LeerClientesFiltrados @razon_social = 'Empresa', @email = 'contacto'
-- EXEC sp_LeerClientesFiltrados @idCliente = 1
CREATE PROCEDURE sp_LeerClientesFiltrados
    @razon_social NVARCHAR(245) = NULL,
    @email NVARCHAR(45) = NULL,
    @idCliente INT = NULL
AS
BEGIN
    BEGIN TRY
        SELECT
            idClientes,
            razon_social,
            nombre_comercial,
            direccion_entrega,
            telefono,
            email
        FROM Clientes
        WHERE
            (@razon_social IS NULL OR razon_social LIKE '%' + @razon_social + '%')
            AND (@email IS NULL OR email LIKE '%' + @email + '%')
            AND (@idCliente IS NULL OR idClientes = @idCliente)
        ORDER BY razon_social;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO


-- #######################################################################################################################
-- ##################################################### SP USUARIOS #####################################################
-- #######################################################################################################################
-- Insertar Usuario
-- EXEC sp_InsertarUsuario
--     @rol_idrol = 1,
--     @estados_idestados = 1,
--     @correo_electronico = 'usuario@ejemplo.com',
--     @nombre_completo = 'Juan Pérez',
--     @password = 'contraseñaHasheada',
--     @telefono = '123456789',
--     @fecha_nacimiento = '1990-01-01',
--     @Clientes_idClientes = NULL
CREATE PROCEDURE sp_InsertarUsuario
    @rol_idrol INT,
    @estados_idestados INT,
    @correo_electronico NVARCHAR(90),
    @nombre_completo NVARCHAR(45),
    @password NVARCHAR(255),
    @telefono NVARCHAR(15),
    @fecha_nacimiento DATE,
    @Clientes_idClientes INT = NULL
AS
BEGIN
    BEGIN TRY
        -- Validar que el rol existe
        IF NOT EXISTS (SELECT 1 FROM Rol WHERE idrol = @rol_idrol)
        BEGIN
            RAISERROR('El rol especificado no existe.', 16, 1);
            RETURN;
        END

        -- Validar que el estado existe
        IF NOT EXISTS (SELECT 1 FROM Estados WHERE idestados = @estados_idestados)
        BEGIN
            RAISERROR('El estado especificado no existe.', 16, 1);
            RETURN;
        END

        -- Validar que no exista un usuario con el mismo correo
        IF EXISTS (SELECT 1 FROM Usuarios WHERE correo_electronico = @correo_electronico)
        BEGIN
            RAISERROR('Ya existe un usuario con este correo electrónico.', 16, 1);
            RETURN;
        END

        -- Validar que el cliente exista si se proporciona
        IF @Clientes_idClientes IS NOT NULL AND
           NOT EXISTS (SELECT 1 FROM Clientes WHERE idClientes = @Clientes_idClientes)
        BEGIN
            RAISERROR('El cliente especificado no existe.', 16, 1);
            RETURN;
        END

        INSERT INTO Usuarios (
            rol_idrol,
            estados_idestados,
            correo_electronico,
            nombre_completo,
            password,
            telefono,
            fecha_nacimiento,
            Clientes_idClientes
        )
        VALUES (
            @rol_idrol,
            @estados_idestados,
            @correo_electronico,
            @nombre_completo,
            @password,
            @telefono,
            @fecha_nacimiento,
            @Clientes_idClientes
        );

        SELECT SCOPE_IDENTITY() AS idusuarios;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Actualizar Usuario
-- EXEC sp_ActualizarUsuario
--     @idusuarios = 1,
--     @rol_idrol = 2,
--     @estados_idestados = 2,
--     @correo_electronico = 'nuevo.correo@ejemplo.com',
--     @nombre_completo = 'Juan Pérez Actualizado',
--     @telefono = '987654321',
--     @fecha_nacimiento = '1990-01-01',
--     @Clientes_idClientes = NULL
CREATE PROCEDURE sp_ActualizarUsuario
    @idusuarios INT,
    @rol_idrol INT,
    @estados_idestados INT,
    @correo_electronico NVARCHAR(90),
    @nombre_completo NVARCHAR(45),
    @telefono NVARCHAR(15),
    @fecha_nacimiento DATE,
    @Clientes_idClientes INT = NULL
AS
BEGIN
    BEGIN TRY
        -- Verificar que el usuario existe
        IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE idusuarios = @idusuarios)
        BEGIN
            RAISERROR('El usuario no existe.', 16, 1);
            RETURN;
        END

        -- Validar que el rol existe
        IF NOT EXISTS (SELECT 1 FROM Rol WHERE idrol = @rol_idrol)
        BEGIN
            RAISERROR('El rol especificado no existe.', 16, 1);
            RETURN;
        END

        -- Validar que el estado existe
        IF NOT EXISTS (SELECT 1 FROM Estados WHERE idestados = @estados_idestados)
        BEGIN
            RAISERROR('El estado especificado no existe.', 16, 1);
            RETURN;
        END

        -- Validar que no exista otro usuario con el mismo correo
        IF EXISTS (SELECT 1 FROM Usuarios
                   WHERE correo_electronico = @correo_electronico
                   AND idusuarios != @idusuarios)
        BEGIN
            RAISERROR('Ya existe otro usuario con este correo electrónico.', 16, 1);
            RETURN;
        END

        -- Validar que el cliente exista si se proporciona
        IF @Clientes_idClientes IS NOT NULL AND
           NOT EXISTS (SELECT 1 FROM Clientes WHERE idClientes = @Clientes_idClientes)
        BEGIN
            RAISERROR('El cliente especificado no existe.', 16, 1);
            RETURN;
        END

        UPDATE Usuarios
        SET
            rol_idrol = @rol_idrol,
            estados_idestados = @estados_idestados,
            correo_electronico = @correo_electronico,
            nombre_completo = @nombre_completo,
            telefono = @telefono,
            fecha_nacimiento = @fecha_nacimiento,
            Clientes_idClientes = @Clientes_idClientes
        WHERE idusuarios = @idusuarios;

        SELECT @idusuarios AS idusuarios;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Eliminar / Cambiar Estado de Usuario (Soft Delete)
-- Para desactivar un usuario (cambiar a estado Inactivo)
-- EXEC sp_CambiarEstadoUsuario
--     @idusuarios = 1,
--     @estados_idestados = 2  -- Suponiendo que 2 es el ID de "Inactivo"
CREATE PROCEDURE sp_CambiarEstadoUsuario
    @idusuarios INT,
    @estados_idestados INT
AS
BEGIN
    BEGIN TRY
        -- Verificar que el usuario existe
        IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE idusuarios = @idusuarios)
        BEGIN
            RAISERROR('El usuario no existe.', 16, 1);
            RETURN;
        END

        -- Validar que el estado existe
        IF NOT EXISTS (SELECT 1 FROM Estados WHERE idestados = @estados_idestados)
        BEGIN
            RAISERROR('El estado especificado no existe.', 16, 1);
            RETURN;
        END

        UPDATE Usuarios
        SET estados_idestados = @estados_idestados
        WHERE idusuarios = @idusuarios;

        SELECT @idusuarios AS idusuarios, @estados_idestados AS nuevo_estado;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Leer Usuarios
-- EXEC sp_LeerUsuarios
-- SELECT * from Usuarios
CREATE PROCEDURE sp_LeerUsuarios
AS
BEGIN
    BEGIN TRY
        SELECT
            u.idusuarios,
            u.correo_electronico,
            u.nombre_completo,
            u.telefono,
            u.fecha_nacimiento,
            r.nombre AS rol,
            e.nombre AS estado,
            c.razon_social AS cliente
        FROM Usuarios u
        INNER JOIN Rol r ON u.rol_idrol = r.idrol
        INNER JOIN Estados e ON u.estados_idestados = e.idestados
        LEFT JOIN Clientes c ON u.Clientes_idClientes = c.idClientes
        ORDER BY u.nombre_completo;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Leer un Usuario por ID
-- EXEC sp_LeerUsuarioPorID @UsuarioID = 1
CREATE PROCEDURE sp_LeerUsuarioPorID
    @UsuarioID INT
AS
BEGIN
    BEGIN TRY
        SELECT
            u.idusuarios,
            u.correo_electronico,
            u.nombre_completo,
            u.telefono,
            u.fecha_nacimiento,
            e.nombre AS estado,
            c.razon_social AS cliente
        FROM Usuarios u
        INNER JOIN Estados e ON u.estados_idestados = e.idestados
        LEFT JOIN Clientes c ON u.Clientes_idClientes = c.idClientes
        WHERE u.idusuarios = @UsuarioID -- Filtro por ID del usuario
        ORDER BY u.nombre_completo;
    END TRY
    BEGIN CATCH
        -- Captura y lanza errores
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO


-- Leer Usuarios Filtrados
-- EXEC sp_LeerUsuariosFiltrados @nombre_completo = 'Juan'
-- EXEC sp_LeerUsuariosFiltrados @correo_electronico = 'admin1@admin1.com'
-- EXEC sp_LeerUsuariosFiltrados @rol_nombre = 'Administrador'
-- EXEC sp_LeerUsuariosFiltrados @estado_nombre = 'Activo'
-- EXEC sp_LeerUsuariosFiltrados
--     @nombre_completo = 'Juan',
--     @correo_electronico = 'ejemplo',
--     @rol_nombre = 'Administrador',
--     @estado_nombre = 'Activo'
CREATE PROCEDURE sp_LeerUsuariosFiltrados
    @nombre_completo NVARCHAR(45) = NULL,
    @correo_electronico NVARCHAR(90) = NULL,
    @rol_nombre NVARCHAR(45) = NULL,
    @estado_nombre NVARCHAR(45) = NULL
AS
BEGIN
    BEGIN TRY
        SELECT
            u.idusuarios,
            u.correo_electronico,
            u.nombre_completo,
            u.telefono,
            u.fecha_nacimiento,
            r.nombre AS rol,
            e.nombre AS estado,
            c.razon_social AS cliente
        FROM Usuarios u
        INNER JOIN Rol r ON u.rol_idrol = r.idrol
        INNER JOIN Estados e ON u.estados_idestados = e.idestados
        LEFT JOIN Clientes c ON u.Clientes_idClientes = c.idClientes
        WHERE
            (@nombre_completo IS NULL OR u.nombre_completo LIKE '%' + @nombre_completo + '%')
            AND (@correo_electronico IS NULL OR u.correo_electronico LIKE '%' + @correo_electronico + '%')
            AND (@rol_nombre IS NULL OR r.nombre = @rol_nombre)
            AND (@estado_nombre IS NULL OR e.nombre = @estado_nombre)
        ORDER BY u.nombre_completo;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Leer Usuario para Login
-- EXEC sp_ObtenerDatosLogin @correo_electronico = 'admin1@admin1.com'
-- UPDATE Usuarios SET password = '$2a$10$Qrq5pN1.zlScIUGTCDMW0uuit/8MQPGvEd0p2igZiBqDns1PULydi' WHERE idusuarios = 7;  // contraseña hasheada para admin123
CREATE PROCEDURE sp_ObtenerDatosLogin
    @correo_electronico NVARCHAR(90)
AS
BEGIN
    BEGIN TRY
        -- Traer solo los datos necesarios para el inicio de sesión
        SELECT
            u.idusuarios AS id,
            u.correo_electronico AS usuario,
            u.password AS contraseña,
            r.nombre AS rol
        FROM Usuarios u
        INNER JOIN Rol r ON u.rol_idrol = r.idrol
        WHERE u.correo_electronico = @correo_electronico;
    END TRY
    BEGIN CATCH
        -- Manejo de errores
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO


-- #######################################################################################################################
-- ############################################### SP CategoríaProducto ##################################################
-- #######################################################################################################################
-- Insertar Categoría de Productos
-- EXEC sp_InsertarCategoriaProductos
--     @usuarios_idusuarios = 1,
--     @nombre = 'Electrónica',
--     @estados_idestados = 1
CREATE PROCEDURE sp_InsertarCategoriaProductos
    @usuarios_idusuarios INT,
    @nombre NVARCHAR(45),
    @estados_idestados INT
AS
BEGIN
    BEGIN TRY
        -- Validar que el usuario existe
        IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE idusuarios = @usuarios_idusuarios)
        BEGIN
            RAISERROR('El usuario especificado no existe.', 16, 1);
            RETURN;
        END

        -- Validar que el estado existe
        IF NOT EXISTS (SELECT 1 FROM Estados WHERE idestados = @estados_idestados)
        BEGIN
            RAISERROR('El estado especificado no existe.', 16, 1);
            RETURN;
        END

        -- Validar que no exista una categoría con el mismo nombre para este usuario
        IF EXISTS (SELECT 1 FROM CategoriaProductos
                   WHERE nombre = @nombre AND usuarios_idusuarios = @usuarios_idusuarios)
        BEGIN
            RAISERROR('Ya existe una categoría con este nombre para este usuario.', 16, 1);
            RETURN;
        END

        INSERT INTO CategoriaProductos (
            usuarios_idusuarios,
            nombre,
            estados_idestados
        )
        VALUES (
            @usuarios_idusuarios,
            @nombre,
            @estados_idestados
        );

        SELECT SCOPE_IDENTITY() AS idCategoriaProductos;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Actualizar Categoría de Productos
-- EXEC sp_ActualizarCategoriaProductos
--     @idCategoriaProductos = 1,
--     @usuarios_idusuarios = 1,
--     @nombre = 'Electrónica Actualizada',
--     @estados_idestados = 1
CREATE PROCEDURE sp_ActualizarCategoriaProductos
    @idCategoriaProductos INT,
    @usuarios_idusuarios INT,
    @nombre NVARCHAR(45),
    @estados_idestados INT
AS
BEGIN
    BEGIN TRY
        -- Verificar que la categoría existe
        IF NOT EXISTS (SELECT 1 FROM CategoriaProductos WHERE idCategoriaProductos = @idCategoriaProductos)
        BEGIN
            RAISERROR('La categoría de productos no existe.', 16, 1);
            RETURN;
        END

        -- Validar que el usuario existe
        IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE idusuarios = @usuarios_idusuarios)
        BEGIN
            RAISERROR('El usuario especificado no existe.', 16, 1);
            RETURN;
        END

        -- Validar que el estado existe
        IF NOT EXISTS (SELECT 1 FROM Estados WHERE idestados = @estados_idestados)
        BEGIN
            RAISERROR('El estado especificado no existe.', 16, 1);
            RETURN;
        END

        -- Validar que no exista otra categoría con el mismo nombre para este usuario
        IF EXISTS (SELECT 1 FROM CategoriaProductos
                   WHERE nombre = @nombre
                   AND usuarios_idusuarios = @usuarios_idusuarios
                   AND idCategoriaProductos != @idCategoriaProductos)
        BEGIN
            RAISERROR('Ya existe otra categoría con este nombre para este usuario.', 16, 1);
            RETURN;
        END

        UPDATE CategoriaProductos
        SET
            usuarios_idusuarios = @usuarios_idusuarios,
            nombre = @nombre,
            estados_idestados = @estados_idestados
        WHERE idCategoriaProductos = @idCategoriaProductos;

        SELECT @idCategoriaProductos AS idCategoriaProductos;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Eliminar / Cambiar Estado de Categoría de Productos
-- EXEC sp_CambiarEstadoCategoriaProductos
--     @idCategoriaProductos = 1,
--     @estados_idestados = 2  -- Suponiendo que 2 es el ID de "Inactivo"
CREATE PROCEDURE sp_CambiarEstadoCategoriaProductos
    @idCategoriaProductos INT,
    @estados_idestados INT
AS
BEGIN
    BEGIN TRY
        -- Verificar que la categoría existe
        IF NOT EXISTS (SELECT 1 FROM CategoriaProductos WHERE idCategoriaProductos = @idCategoriaProductos)
        BEGIN
            RAISERROR('La categoría de productos no existe.', 16, 1);
            RETURN;
        END

        -- Validar que el estado existe
        IF NOT EXISTS (SELECT 1 FROM Estados WHERE idestados = @estados_idestados)
        BEGIN
            RAISERROR('El estado especificado no existe.', 16, 1);
            RETURN;
        END

        -- Verificar si hay productos asociados a esta categoría
        IF EXISTS (SELECT 1 FROM Productos
                   WHERE CategoriaProductos_idCategoriaProductos = @idCategoriaProductos)
        BEGIN
            RAISERROR('No se puede cambiar el estado de la categoría porque tiene productos asociados.', 16, 1);
            RETURN;
        END

        UPDATE CategoriaProductos
        SET estados_idestados = @estados_idestados
        WHERE idCategoriaProductos = @idCategoriaProductos;

        SELECT @idCategoriaProductos AS idCategoriaProductos, @estados_idestados AS nuevo_estado;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Leer Categorías de Productos
-- EXEC sp_LeerCategoriaProductos
CREATE PROCEDURE sp_LeerCategoriaProductos
AS
BEGIN
    BEGIN TRY
        SELECT
            cp.idCategoriaProductos,
            cp.nombre,
            u.nombre_completo AS usuario,
            e.nombre AS estado,
            cp.fecha_creacion
        FROM CategoriaProductos cp
        INNER JOIN Usuarios u ON cp.usuarios_idusuarios = u.idusuarios
        INNER JOIN Estados e ON cp.estados_idestados = e.idestados
        ORDER BY cp.nombre;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Leer Categorías de Productos Activos (Para el Público)
-- EXEC sp_LeerCategoriaProductosActivos
CREATE PROCEDURE sp_LeerCategoriaProductosActivos
AS
BEGIN
    BEGIN TRY
        SELECT
            cp.idCategoriaProductos,
            cp.nombre
        FROM CategoriaProductos cp
        INNER JOIN Estados e ON cp.estados_idestados = e.idestados
        WHERE e.nombre = 'Activo' -- Asegúrate de que "Activo" sea el valor correcto en tu tabla
        ORDER BY cp.nombre;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Leer Categorías de Productos Filtradas
-- EXEC sp_LeerCategoriaProductosFiltradas @nombre = 'Electrónicos'
-- EXEC sp_LeerCategoriaProductosFiltradas @usuario_nombre = 'Roberto Martínez'
-- EXEC sp_LeerCategoriaProductosFiltradas @estado_nombre = 'Activo'
-- EXEC sp_LeerCategoriaProductosFiltradas
--     @nombre = 'Electrónicos',
--     @usuario_nombre = 'Roberto Martínez',
--     @estado_nombre = 'Activo'
CREATE PROCEDURE sp_LeerCategoriaProductosFiltradas
    @nombre NVARCHAR(45) = NULL,
    @usuario_nombre NVARCHAR(45) = NULL,
    @estado_nombre NVARCHAR(45) = NULL
AS
BEGIN
    BEGIN TRY
        SELECT
            cp.idCategoriaProductos,
            cp.nombre,
            u.nombre_completo AS usuario,
            e.nombre AS estado,
            cp.fecha_creacion
        FROM CategoriaProductos cp
        INNER JOIN Usuarios u ON cp.usuarios_idusuarios = u.idusuarios
        INNER JOIN Estados e ON cp.estados_idestados = e.idestados
        WHERE
            (@nombre IS NULL OR cp.nombre LIKE '%' + @nombre + '%')
            AND (@usuario_nombre IS NULL OR u.nombre_completo LIKE '%' + @usuario_nombre + '%')
            AND (@estado_nombre IS NULL OR e.nombre = @estado_nombre)
        ORDER BY cp.nombre;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- #######################################################################################################################
-- ################################################### SP Productos ######################################################
-- #######################################################################################################################

-- Insertar Producto
-- EXEC sp_InsertarProducto
--     @CategoriaProductos_idCategoriaProductos = 1,
--     @usuarios_idusuarios = 1,
--     @nombre = 'Laptop',
--     @marca = 'Dell',
--     @codigo = 'DELL-XPS-15',
--     @stock = 10,
--     @estados_idestados = 1,
--     @precio = 1500.00,
--     @foto = 'path/to/image.jpg'
CREATE PROCEDURE sp_InsertarProducto
    @CategoriaProductos_idCategoriaProductos INT,
    @usuarios_idusuarios INT,
    @nombre NVARCHAR(45),
    @marca NVARCHAR(45),
    @codigo NVARCHAR(45),
    @stock FLOAT,
    @estados_idestados INT,
    @precio FLOAT,
    @foto NVARCHAR(200) = NULL
AS
BEGIN
    BEGIN TRY
        -- Validar que la categoría existe
        IF NOT EXISTS (SELECT 1 FROM CategoriaProductos WHERE idCategoriaProductos = @CategoriaProductos_idCategoriaProductos)
        BEGIN
            RAISERROR('La categoría de producto especificada no existe.', 16, 1);
            RETURN;
        END

        -- Validar que el usuario existe
        IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE idusuarios = @usuarios_idusuarios)
        BEGIN
            RAISERROR('El usuario especificado no existe.', 16, 1);
            RETURN;
        END

        -- Validar que el estado existe
        IF NOT EXISTS (SELECT 1 FROM Estados WHERE idestados = @estados_idestados)
        BEGIN
            RAISERROR('El estado especificado no existe.', 16, 1);
            RETURN;
        END

        -- Validar que no exista un producto con el mismo código
        IF EXISTS (SELECT 1 FROM Productos WHERE codigo = @codigo)
        BEGIN
            RAISERROR('Ya existe un producto con este código.', 16, 1);
            RETURN;
        END

        INSERT INTO Productos (
            CategoriaProductos_idCategoriaProductos,
            usuarios_idusuarios,
            nombre,
            marca,
            codigo,
            stock,
            estados_idestados,
            precio,
            foto
        )
        VALUES (
            @CategoriaProductos_idCategoriaProductos,
            @usuarios_idusuarios,
            @nombre,
            @marca,
            @codigo,
            @stock,
            @estados_idestados,
            @precio,
            @foto
        );

        SELECT SCOPE_IDENTITY() AS idProductos;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Actualizar Producto
-- EXEC sp_ActualizarProducto
--     @idProductos = 1,
--     @CategoriaProductos_idCategoriaProductos = 1,
--     @usuarios_idusuarios = 1,
--     @nombre = 'Laptop Actualizada',
--     @marca = 'Dell',
--     @codigo = 'DELL-XPS-15-V2',
--     @stock = 15,
--     @estados_idestados = 1,
--     @precio = 1600.00,
--     @foto = 'path/to/new/image.jpg'
CREATE PROCEDURE sp_ActualizarProducto
    @idProductos INT,
    @CategoriaProductos_idCategoriaProductos INT = NULL,
    @usuarios_idusuarios INT = NULL,
    @nombre NVARCHAR(45) = NULL,
    @marca NVARCHAR(45) = NULL,
    @codigo NVARCHAR(45) = NULL,
    @stock FLOAT = NULL,
    @precio FLOAT = NULL,
    @foto NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones iniciales
    IF NOT EXISTS (SELECT 1 FROM Productos WHERE idProductos = @idProductos)
    BEGIN
        RAISERROR('El producto no existe.', 16, 1);
        RETURN;
    END

    -- Verificaciones condicionales para referencias
    IF @CategoriaProductos_idCategoriaProductos IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM CategoriaProductos WHERE idCategoriaProductos = @CategoriaProductos_idCategoriaProductos)
    BEGIN
        RAISERROR('La categoría de producto especificada no existe.', 16, 1);
        RETURN;
    END

    IF @usuarios_idusuarios IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM Usuarios WHERE idusuarios = @usuarios_idusuarios)
    BEGIN
        RAISERROR('El usuario especificado no existe.', 16, 1);
        RETURN;
    END

    -- Validar código único
    IF @codigo IS NOT NULL
       AND EXISTS (SELECT 1 FROM Productos
                   WHERE codigo = @codigo AND idProductos != @idProductos)
    BEGIN
        RAISERROR('Ya existe otro producto con este código.', 16, 1);
        RETURN;
    END

    -- Actualización dinámica
    UPDATE Productos
    SET
        CategoriaProductos_idCategoriaProductos = COALESCE(@CategoriaProductos_idCategoriaProductos, CategoriaProductos_idCategoriaProductos),
        usuarios_idusuarios = COALESCE(@usuarios_idusuarios, usuarios_idusuarios),
        nombre = COALESCE(@nombre, nombre),
        marca = COALESCE(@marca, marca),
        codigo = COALESCE(@codigo, codigo),
        stock = COALESCE(@stock, stock),
        precio = COALESCE(@precio, precio),
        foto = COALESCE(@foto, foto)
    WHERE idProductos = @idProductos;

    -- Devolver el ID del producto
    SELECT @idProductos AS idProductos;
END
GO

-- Cambiar Estado de Producto
-- EXEC sp_CambiarEstadoProducto
--     @idProductos = 1,
--     @estados_idestados = 2  -- Suponiendo que 2 es el ID de "Inactivo"
CREATE PROCEDURE sp_CambiarEstadoProducto
    @idProductos INT,
    @estados_idestados INT
AS
BEGIN
    BEGIN TRY
        -- Verificar que el producto existe
        IF NOT EXISTS (SELECT 1 FROM Productos WHERE idProductos = @idProductos)
        BEGIN
            RAISERROR('El producto no existe.', 16, 1);
            RETURN;
        END

        -- Validar que el estado existe
        IF NOT EXISTS (SELECT 1 FROM Estados WHERE idestados = @estados_idestados)
        BEGIN
            RAISERROR('El estado especificado no existe.', 16, 1);
            RETURN;
        END

        UPDATE Productos
        SET estados_idestados = @estados_idestados
        WHERE idProductos = @idProductos;

        SELECT @idProductos AS idProductos, @estados_idestados AS nuevo_estado;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Leer Productos
-- EXEC sp_LeerProductos //stock 500
-- EXEC sp_LeerOrdenDetalles @Orden_idOrden = 20
-- EXEC sp_LeerOrdenPorId @idOrden = 20
CREATE PROCEDURE sp_LeerProductos
AS
BEGIN
    BEGIN TRY
        SELECT
            p.idProductos,
            p.nombre,
            p.marca,
            p.codigo,
            p.stock,
            p.precio,
            p.foto,
            cp.nombre AS categoria,
            e.nombre AS estado,
            u.nombre_completo AS usuario
        FROM Productos p
        INNER JOIN CategoriaProductos cp ON p.CategoriaProductos_idCategoriaProductos = cp.idCategoriaProductos
        INNER JOIN Estados e ON p.estados_idestados = e.idestados
        INNER JOIN Usuarios u ON p.usuarios_idusuarios = u.idusuarios
        ORDER BY p.nombre;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Leer Productos Filtrados
-- EXEC sp_LeerProductosFiltrados @nombre = 'Laptop'
-- EXEC sp_LeerProductosFiltrados @marca = 'Dell'
-- EXEC sp_LeerProductosFiltrados @codigo = 'DELL'
-- EXEC sp_LeerProductosFiltrados @categoria_nombre = 'Electrónicos'
-- EXEC sp_LeerProductosFiltrados @estado_nombre = 'Activo'
-- EXEC sp_LeerProductosFiltrados
--     @nombre = 'Laptop',
--     @marca = 'Dell',
--     @categoria_nombre = 'Electrónicos'
CREATE PROCEDURE sp_LeerProductosFiltrados
    @nombre NVARCHAR(45) = NULL,
    @marca NVARCHAR(45) = NULL,
    @codigo NVARCHAR(45) = NULL,
    @categoria_nombre NVARCHAR(45) = NULL,
    @estado_nombre NVARCHAR(45) = NULL
AS
BEGIN
    BEGIN TRY
        SELECT
            p.idProductos,
            p.nombre,
            p.marca,
            p.codigo,
            p.stock,
            p.precio,
            p.foto,
            cp.nombre AS categoria,
            e.nombre AS estado,
            u.nombre_completo AS usuario
        FROM Productos p
        INNER JOIN CategoriaProductos cp ON p.CategoriaProductos_idCategoriaProductos = cp.idCategoriaProductos
        INNER JOIN Estados e ON p.estados_idestados = e.idestados
        INNER JOIN Usuarios u ON p.usuarios_idusuarios = u.idusuarios
        WHERE
            (@nombre IS NULL OR p.nombre LIKE '%' + @nombre + '%')
            AND (@marca IS NULL OR p.marca LIKE '%' + @marca + '%')
            AND (@codigo IS NULL OR p.codigo LIKE '%' + @codigo + '%')
            AND (@categoria_nombre IS NULL OR cp.nombre = @categoria_nombre)
            AND (@estado_nombre IS NULL OR e.nombre = @estado_nombre)
        ORDER BY p.nombre;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO


-- Leer productos paginados
-- EXEC sp_LeerProductosPaginados @PageNumber = 1, @PageSize = 10
CREATE PROCEDURE sp_LeerProductosPaginados
    @PageNumber INT = 1,
    @PageSize INT = 10
AS
BEGIN
    BEGIN TRY
        -- Declarar variables para el conteo total
        DECLARE @TotalRows INT
        DECLARE @TotalPages INT

        -- Obtener el número total de registros
        SELECT @TotalRows = COUNT(*)
        FROM Productos p

        -- Calcular el total de páginas
        SET @TotalPages = CEILING(CAST(@TotalRows AS FLOAT) / @PageSize)

        -- Asegurar que el número de página sea válido
        IF @PageNumber < 1
            SET @PageNumber = 1
        IF @PageNumber > @TotalPages
            SET @PageNumber = @TotalPages

        -- Seleccionar los productos de la página actual
        SELECT
            p.idProductos,
            p.nombre,
            p.marca,
            p.codigo,
            p.stock,
            p.precio,
            p.foto,
            cp.nombre AS categoria,
            e.nombre AS estado,
            u.nombre_completo AS usuario
        FROM Productos p
        INNER JOIN CategoriaProductos cp ON p.CategoriaProductos_idCategoriaProductos = cp.idCategoriaProductos
        INNER JOIN Estados e ON p.estados_idestados = e.idestados
        INNER JOIN Usuarios u ON p.usuarios_idusuarios = u.idusuarios
        ORDER BY p.nombre
        OFFSET (@PageNumber - 1) * @PageSize ROWS
        FETCH NEXT @PageSize ROWS ONLY;

        -- Devolver información de paginación
        SELECT
            @PageNumber AS CurrentPage,
            @PageSize AS PageSize,
            @TotalPages AS TotalPages,
            @TotalRows AS TotalRecords;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Leer productos filtrados y paginados
-- EXEC sp_LeerProductosFiltradosPaginados
--     @PageNumber = 2,
--     @PageSize = 10,
--     @nombre = 'Laptop',
--     @categoria_nombre = 'Electrónicos'
CREATE PROCEDURE sp_LeerProductosFiltradosPaginados
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @nombre NVARCHAR(45) = NULL,
    @marca NVARCHAR(45) = NULL,
    @codigo NVARCHAR(45) = NULL,
    @categoria_nombre NVARCHAR(45) = NULL,
    @estado_nombre NVARCHAR(45) = NULL
AS
BEGIN
    BEGIN TRY
        -- Declarar variables para el conteo total
        DECLARE @TotalRows INT
        DECLARE @TotalPages INT

        -- Obtener el número total de registros con filtros
        SELECT @TotalRows = COUNT(*)
        FROM Productos p
        INNER JOIN CategoriaProductos cp ON p.CategoriaProductos_idCategoriaProductos = cp.idCategoriaProductos
        INNER JOIN Estados e ON p.estados_idestados = e.idestados
        WHERE
            (@nombre IS NULL OR p.nombre LIKE '%' + @nombre + '%')
            AND (@marca IS NULL OR p.marca LIKE '%' + @marca + '%')
            AND (@codigo IS NULL OR p.codigo LIKE '%' + @codigo + '%')
            AND (@categoria_nombre IS NULL OR cp.nombre = @categoria_nombre)
            AND (@estado_nombre IS NULL OR e.nombre = @estado_nombre);

        -- Calcular el total de páginas
        SET @TotalPages = CEILING(CAST(@TotalRows AS FLOAT) / @PageSize)

        -- Asegurar que el número de página sea válido
        IF @PageNumber < 1
            SET @PageNumber = 1
        IF @PageNumber > @TotalPages AND @TotalPages > 0
            SET @PageNumber = @TotalPages

        -- Seleccionar los productos filtrados de la página actual
        SELECT
            p.idProductos,
            p.nombre,
            p.marca,
            p.codigo,
            p.stock,
            p.precio,
            p.foto,
            cp.nombre AS categoria,
            e.nombre AS estado,
            u.nombre_completo AS usuario
        FROM Productos p
        INNER JOIN CategoriaProductos cp ON p.CategoriaProductos_idCategoriaProductos = cp.idCategoriaProductos
        INNER JOIN Estados e ON p.estados_idestados = e.idestados
        INNER JOIN Usuarios u ON p.usuarios_idusuarios = u.idusuarios
        WHERE
            (@nombre IS NULL OR p.nombre LIKE '%' + @nombre + '%')
            AND (@marca IS NULL OR p.marca LIKE '%' + @marca + '%')
            AND (@codigo IS NULL OR p.codigo LIKE '%' + @codigo + '%')
            AND (@categoria_nombre IS NULL OR cp.nombre = @categoria_nombre)
            AND (@estado_nombre IS NULL OR e.nombre = @estado_nombre)
        ORDER BY p.nombre
        OFFSET (@PageNumber - 1) * @PageSize ROWS
        FETCH NEXT @PageSize ROWS ONLY;

        -- Devolver información de paginación
        SELECT
            @PageNumber AS CurrentPage,
            @PageSize AS PageSize,
            @TotalPages AS TotalPages,
            @TotalRows AS TotalRecords;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Leer Productos por ID
-- EXEC sp_LeerProductosPorID @idProducto = 1
CREATE PROCEDURE sp_LeerProductosPorID
    @idProducto INT
AS
BEGIN
    BEGIN TRY
        SELECT
            p.idProductos,
            p.nombre,
            p.marca,
            p.codigo,
            p.stock,
            p.precio,
            p.foto,
            cp.nombre AS categoria,
            e.nombre AS estado
        FROM Productos p
        INNER JOIN CategoriaProductos cp ON p.CategoriaProductos_idCategoriaProductos = cp.idCategoriaProductos
        INNER JOIN Estados e ON p.estados_idestados = e.idestados
        WHERE p.idProductos = @idProducto
        ORDER BY p.nombre;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- #######################################################################################################################
-- ###################################################### SP ORDEN #######################################################
-- #######################################################################################################################

-- Insertar Orden
-- EXEC sp_InsertarOrden
--     @usuarios_idusuarios = 1,
--     @estados_idestados = 1,
--     @nombre_completo = 'Juan Pérez',
--     @direccion = 'Calle Principal 123',
--     @telefono = '55551234',
--     @correo_electronico = 'juan.perez@ejemplo.com',
--     @fecha_entrega = '2024-02-15',
--     @total_orden = 2500.50
CREATE PROCEDURE sp_InsertarOrden
    @usuarios_idusuarios INT,
    @estados_idestados INT,
    @nombre_completo NVARCHAR(45),
    @direccion NVARCHAR(545),
    @telefono NVARCHAR(15),
    @correo_electronico NVARCHAR(90),
    @fecha_entrega DATE,
    @total_orden FLOAT
AS
BEGIN
    BEGIN TRY
        -- Validar que el usuario existe
        IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE idusuarios = @usuarios_idusuarios)
        BEGIN
            RAISERROR('El usuario especificado no existe.', 16, 1);
            RETURN;
        END

        -- Validar que el estado existe
        IF NOT EXISTS (SELECT 1 FROM Estados WHERE idestados = @estados_idestados)
        BEGIN
            RAISERROR('El estado especificado no existe.', 16, 1);
            RETURN;
        END

        -- Insertar la orden
        INSERT INTO Orden (
            usuarios_idusuarios,
            estados_idestados,
            nombre_completo,
            direccion,
            telefono,
            correo_electronico,
            fecha_entrega,
            total_orden
        )
        VALUES (
            @usuarios_idusuarios,
            @estados_idestados,
            @nombre_completo,
            @direccion,
            @telefono,
            @correo_electronico,
            @fecha_entrega,
            @total_orden
        );

        -- Devolver el ID de la orden recién creada
        SELECT SCOPE_IDENTITY() AS idOrden;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Actualizar Orden
-- EXEC sp_ActualizarOrden
--     @idOrden = 1,
--     @estados_idestados = 2,
--     @nombre_completo = 'Juan Pérez Actualizado',
--     @direccion = 'Nueva Dirección 456',
--     @telefono = '55505678',
--     @correo_electronico = 'juan.perez.nuevo@ejemplo.com',
--     @fecha_entrega = '2024-02-20',
--     @total_orden = 2750.75
CREATE PROCEDURE sp_ActualizarOrden
    @idOrden INT,
    @estados_idestados INT,
    @nombre_completo NVARCHAR(45),
    @direccion NVARCHAR(545),
    @telefono NVARCHAR(15),
    @correo_electronico NVARCHAR(90),
    @fecha_entrega DATE,
    @total_orden FLOAT
AS
BEGIN
    BEGIN TRY
        -- Verificar que la orden existe
        IF NOT EXISTS (SELECT 1 FROM Orden WHERE idOrden = @idOrden)
        BEGIN
            RAISERROR('La orden no existe.', 16, 1);
            RETURN;
        END

        -- Validar que el estado existe
        IF NOT EXISTS (SELECT 1 FROM Estados WHERE idestados = @estados_idestados)
        BEGIN
            RAISERROR('El estado especificado no existe.', 16, 1);
            RETURN;
        END

        UPDATE Orden
        SET
            estados_idestados = @estados_idestados,
            nombre_completo = @nombre_completo,
            direccion = @direccion,
            telefono = @telefono,
            correo_electronico = @correo_electronico,
            fecha_entrega = @fecha_entrega,
            total_orden = @total_orden
        WHERE idOrden = @idOrden;

        SELECT @idOrden AS idOrden;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Cambiar Estado de Orden
-- EXEC sp_CambiarEstadoOrden
--     @idOrden = 1,
--     @estados_idestados = 2  -- Suponiendo que 2 es el ID de "En Proceso"
CREATE PROCEDURE sp_CambiarEstadoOrden
    @idOrden INT,
    @estados_idestados INT
AS
BEGIN
    BEGIN TRY
        -- Verificar que la orden existe
        IF NOT EXISTS (SELECT 1 FROM Orden WHERE idOrden = @idOrden)
        BEGIN
            RAISERROR('La orden no existe.', 16, 1);
            RETURN;
        END

        -- Validar que el estado existe
        IF NOT EXISTS (SELECT 1 FROM Estados WHERE idestados = @estados_idestados)
        BEGIN
            RAISERROR('El estado especificado no existe.', 16, 1);
            RETURN;
        END

        UPDATE Orden
        SET estados_idestados = @estados_idestados
        WHERE idOrden = @idOrden;

        SELECT @idOrden AS idOrden, @estados_idestados AS nuevo_estado;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Leer Ordenes
-- EXEC sp_LeerOrdenes
CREATE PROCEDURE sp_LeerOrdenes
AS
BEGIN
    BEGIN TRY
        SELECT
            o.idOrden,
            o.nombre_completo,
            o.direccion,
            o.telefono,
            o.correo_electronico,
            o.fecha_creacion,
            o.fecha_entrega,
            o.total_orden,
            u.nombre_completo AS usuario,
            e.nombre AS estado
        FROM Orden o
        INNER JOIN Usuarios u ON o.usuarios_idusuarios = u.idusuarios
        INNER JOIN Estados e ON o.estados_idestados = e.idestados
        ORDER BY o.fecha_creacion DESC;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Leer Orden por ID
-- EXEC sp_LeerOrdenPorId @idOrden = 1
CREATE PROCEDURE sp_LeerOrdenPorId
    @idOrden INT
AS
BEGIN
    BEGIN TRY
        SELECT
            o.idOrden,
            o.nombre_completo,
            o.direccion,
            o.telefono,
            o.correo_electronico,
            o.fecha_creacion,
            o.fecha_entrega,
            o.total_orden,
            u.nombre_completo AS usuario,
            e.nombre AS estado
        FROM Orden o
        INNER JOIN Usuarios u ON o.usuarios_idusuarios = u.idusuarios
        INNER JOIN Estados e ON o.estados_idestados = e.idestados
        WHERE o.idOrden = @idOrden;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Eliminar Orden por ID
-- EXEC sp_EliminarOrden @idOrden = 1
CREATE PROCEDURE sp_EliminarOrden
    @idOrden INT
AS
BEGIN
    BEGIN TRY
        -- Verificar que la orden existe
        IF NOT EXISTS (SELECT 1 FROM Orden WHERE idOrden = @idOrden)
        BEGIN
            RAISERROR('La orden no existe.', 16, 1);
            RETURN;
        END

        -- Eliminar la orden
        DELETE FROM Orden WHERE idOrden = @idOrden;

        SELECT @idOrden AS idOrden;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- #######################################################################################################################
-- ################################################# SP ORDEN DETALLES #################################################
-- #######################################################################################################################

-- Insertar OrdenDetalle
-- EXEC sp_InsertarOrdenDetalle
--     @Orden_idOrden = 1,
--     @Productos_idProductos = 1,
--     @cantidad = 5,
--     @precio = 100.00
CREATE PROCEDURE sp_InsertarOrdenDetalle
    @Orden_idOrden INT,
    @Productos_idProductos INT,
    @cantidad INT,
    @precio FLOAT
AS
BEGIN
    BEGIN TRY
        -- Validar que la orden existe
        IF NOT EXISTS (SELECT 1 FROM Orden WHERE idOrden = @Orden_idOrden)
        BEGIN
            RAISERROR('La orden especificada no existe.', 16, 1);
            RETURN;
        END

        -- Validar que el producto existe
        IF NOT EXISTS (SELECT 1 FROM Productos WHERE idProductos = @Productos_idProductos)
        BEGIN
            RAISERROR('El producto especificado no existe.', 16, 1);
            RETURN;
        END

        -- Validar que hay suficiente stock
        DECLARE @stock_disponible FLOAT
        SELECT @stock_disponible = stock
        FROM Productos
        WHERE idProductos = @Productos_idProductos

        IF @stock_disponible < @cantidad
        BEGIN
            RAISERROR('No hay suficiente stock disponible.', 16, 1);
            RETURN;
        END

        -- Calcular subtotal
        DECLARE @subtotal FLOAT = @cantidad * @precio

        INSERT INTO OrdenDetalles (
            Orden_idOrden,
            Productos_idProductos,
            cantidad,
            precio,
            subtotal
        )
        VALUES (
            @Orden_idOrden,
            @Productos_idProductos,
            @cantidad,
            @precio,
            @subtotal
        );

        -- Actualizar el stock del producto
        UPDATE Productos
        SET stock = stock - @cantidad
        WHERE idProductos = @Productos_idProductos;

        -- Actualizar el total de la orden
        UPDATE Orden
        SET total_orden = (
            SELECT SUM(subtotal)
            FROM OrdenDetalles
            WHERE Orden_idOrden = @Orden_idOrden
        )
        WHERE idOrden = @Orden_idOrden;

        SELECT SCOPE_IDENTITY() AS idOrdenDetalles;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Actualizar OrdenDetalle
-- EXEC sp_ActualizarOrdenDetalle
--     @idOrdenDetalles = 1,
--     @cantidad = 3,
--     @precio = 120.00
CREATE PROCEDURE sp_ActualizarOrdenDetalle
    @idOrdenDetalles INT,
    @cantidad INT,
    @precio FLOAT
AS
BEGIN
    BEGIN TRY
        -- Verificar que el detalle de orden existe
        IF NOT EXISTS (SELECT 1 FROM OrdenDetalles WHERE idOrdenDetalles = @idOrdenDetalles)
        BEGIN
            RAISERROR('El detalle de orden no existe.', 16, 1);
            RETURN;
        END

        -- Obtener la cantidad anterior y el producto
        DECLARE @cantidad_anterior INT
        DECLARE @Productos_idProductos INT
        DECLARE @Orden_idOrden INT

        SELECT
            @cantidad_anterior = cantidad,
            @Productos_idProductos = Productos_idProductos,
            @Orden_idOrden = Orden_idOrden
        FROM OrdenDetalles
        WHERE idOrdenDetalles = @idOrdenDetalles

        -- Validar stock disponible para el nuevo cambio
        DECLARE @diferencia_cantidad INT = @cantidad - @cantidad_anterior
        DECLARE @stock_disponible FLOAT

        SELECT @stock_disponible = stock
        FROM Productos
        WHERE idProductos = @Productos_idProductos

        IF @stock_disponible < @diferencia_cantidad
        BEGIN
            RAISERROR('No hay suficiente stock disponible para el cambio.', 16, 1);
            RETURN;
        END

        -- Calcular nuevo subtotal
        DECLARE @subtotal FLOAT = @cantidad * @precio

        UPDATE OrdenDetalles
        SET
            cantidad = @cantidad,
            precio = @precio,
            subtotal = @subtotal
        WHERE idOrdenDetalles = @idOrdenDetalles;

        -- Actualizar el stock del producto
        UPDATE Productos
        SET stock = stock - @diferencia_cantidad
        WHERE idProductos = @Productos_idProductos;

        -- Actualizar el total de la orden
        UPDATE Orden
        SET total_orden = (
            SELECT SUM(subtotal)
            FROM OrdenDetalles
            WHERE Orden_idOrden = @Orden_idOrden
        )
        WHERE idOrden = @Orden_idOrden;

        SELECT @idOrdenDetalles AS idOrdenDetalles;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Eliminar OrdenDetalle
-- EXEC sp_EliminarOrdenDetalle @idOrdenDetalles = 1
CREATE PROCEDURE sp_EliminarOrdenDetalle
    @idOrdenDetalles INT
AS
BEGIN
    BEGIN TRY
        -- Verificar que el detalle de orden existe
        IF NOT EXISTS (SELECT 1 FROM OrdenDetalles WHERE idOrdenDetalles = @idOrdenDetalles)
        BEGIN
            RAISERROR('El detalle de orden no existe.', 16, 1);
            RETURN;
        END

        -- Obtener información necesaria antes de eliminar
        DECLARE @cantidad INT
        DECLARE @Productos_idProductos INT
        DECLARE @Orden_idOrden INT

        SELECT
            @cantidad = cantidad,
            @Productos_idProductos = Productos_idProductos,
            @Orden_idOrden = Orden_idOrden
        FROM OrdenDetalles
        WHERE idOrdenDetalles = @idOrdenDetalles

        -- Devolver el stock al producto
        UPDATE Productos
        SET stock = stock + @cantidad
        WHERE idProductos = @Productos_idProductos;

        -- Eliminar el detalle
        DELETE FROM OrdenDetalles
        WHERE idOrdenDetalles = @idOrdenDetalles;

        -- Actualizar el total de la orden
        UPDATE Orden
        SET total_orden = (
            SELECT ISNULL(SUM(subtotal), 0)
            FROM OrdenDetalles
            WHERE Orden_idOrden = @Orden_idOrden
        )
        WHERE idOrden = @Orden_idOrden;

        SELECT @idOrdenDetalles AS idOrdenDetalles;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Leer OrdenDetalles por Orden
-- EXEC sp_LeerOrdenDetalles @Orden_idOrden = 20
CREATE PROCEDURE sp_LeerOrdenDetalles
    @Orden_idOrden INT
AS
BEGIN
    BEGIN TRY
        SELECT
            od.idOrdenDetalles,
            od.Orden_idOrden,
            od.Productos_idProductos,
            p.nombre AS nombre_producto,
            p.codigo AS codigo_producto,
            od.cantidad,
            od.precio,
            od.subtotal,
            o.total_orden
        FROM OrdenDetalles od
        INNER JOIN Productos p ON od.Productos_idProductos = p.idProductos
        INNER JOIN Orden o ON od.Orden_idOrden = o.idOrden
        WHERE od.Orden_idOrden = @Orden_idOrden
        ORDER BY od.idOrdenDetalles;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- ##############################################################################################
-- ################################### CREACION DE LAS VISTAS ###################################
-- ##############################################################################################

-- a. Total de productos activos con stock mayor a 0
CREATE VIEW VistaProductosActivosConStockMayorACero AS
SELECT
    P.nombre AS NombreProducto,
    P.stock AS StockMayorACero
FROM Productos P
WHERE P.estados_idestados = (SELECT idestados FROM Estados WHERE nombre = 'Activo')
  AND P.stock > 0;
GO

-- b. Total de Quetzales en órdenes ingresadas en agosto de 2024
CREATE VIEW VistaTotalOrdenesAgosto2024 AS
SELECT SUM(total_orden) AS TotalQuetzalesAgosto2024
FROM Orden
WHERE DATEPART(MONTH, fecha_creacion) = 8
  AND DATEPART(YEAR, fecha_creacion) = 2024;
GO

-- c. Top 10 clientes con mayor consumo de órdenes
CREATE VIEW VistaTop10ClientesMayorConsumo AS
SELECT TOP 10
    C.idClientes,
    C.razon_social,
    C.nombre_comercial,
    SUM(O.total_orden) AS TotalConsumoDesc
FROM Orden O
JOIN Usuarios U ON O.usuarios_idusuarios = U.idusuarios
JOIN Clientes C ON U.Clientes_idClientes = C.idClientes
GROUP BY C.idClientes, C.razon_social, C.nombre_comercial
ORDER BY TotalConsumoDesc DESC;
GO

-- d. Top 10 productos más vendidos en orden ascendente
CREATE VIEW VistaTop10ProductosMasVendidos AS
SELECT TOP 10
    P.idProductos,
    P.nombre,
    SUM(OD.cantidad) AS TotalVendidosAsc
FROM OrdenDetalles OD
JOIN Productos P ON OD.Productos_idProductos = P.idProductos
GROUP BY P.idProductos, P.nombre
ORDER BY TotalVendidosAsc ASC;
GO

-- ######################################################################################################
-- ################################### INSERTS PARA LLENAR LAS TABLAS ###################################
-- ######################################################################################################

-- INSERCIÓN DE ESTADOS
INSERT INTO Estados (nombre) VALUES
('Activo'),
('Inactivo'),
('Suspendido'),
('Pendiente'),
('Aprobado'),
('Tránsito');

-- INSERCIÓN DE ROLES
INSERT INTO Rol (nombre) VALUES
('Administrador'),
('Operador'),
('Cliente');

-- INSERCIÓN DE CLIENTES
INSERT INTO Clientes (razon_social, nombre_comercial, direccion_entrega, telefono, email) VALUES
('Distribuidora El Sol SA', 'El Sol', 'Zone 10 Ciudad de Guatemala', '22334455', 'info@elsol.com.gt'),
('Comercializadora La Luna', 'La Luna', '4ta Avenida zona 1', '22556677', 'ventas@laluna.com.gt'),
('Mayoreo Express SA', 'MayoreoExpress', 'Mixco Guatemala', '22222233', 'contacto@mayoreoexpress.com.gt'),
('Importaciones Gallo', 'ImportGallo', 'Zona 4 Ciudad', '55667788', 'ventas@importgallo.com.gt'),
('Tienda Universal', 'UniStore', 'Zona 9 Ciudad', '22334456', 'info@unistore.com.gt'),
('Supermercados Delta', 'Delta Market', 'Zona 11 Ciudad', '22556678', 'ventas@delta.com.gt'),
('Comercializadora San Jose', 'SanJose', 'Zona 4 Guatemala', '22334457', 'info@sanjose.com.gt'),
('Distribuidora Las Flores', 'LasFLores', 'Zona 5 Ciudad', '22556679', 'ventas@lasflores.com.gt'),
('Tienda Express', 'ExpressStore', 'Mixco', '22222234', 'contacto@expressstore.com.gt'),
('Importaciones Central', 'CentralImport', 'Zona 7 Ciudad', '55667789', 'ventas@centralimport.com.gt'),
('Supermercados El Progreso', 'ProgresoMarket', 'Zona 12 Ciudad', '22334458', 'info@progresomarket.com.gt'),
('Mayoreo Rápido', 'QuickWholesale', 'Zona 6 Ciudad', '22556680', 'ventas@quickwholesale.com.gt'),
('Comercio Global', 'GlobalTrade', 'Zona 8 Ciudad', '55667790', 'info@globaltrade.com.gt'),
('Tienda Moderna', 'ModernStore', 'Zona 10 Ciudad', '22334459', 'ventas@modernstore.com.gt'),
('Distribuidora Nacional', 'NationalDist', 'Zona 13 Ciudad', '22556681', 'contacto@nationaldist.com.gt');

-- INSERCIÓN DE USUARIOS
INSERT INTO Usuarios (rol_idrol, estados_idestados, correo_electronico, nombre_completo, password, telefono, fecha_nacimiento, fecha_creacion, Clientes_idClientes)
VALUES
-- Administradores
(1, 1, 'admin1@admin1.com', 'Carlos Rodríguez', '$2a$10$Qrq5pN1.zlScIUGTCDMW0uuit/8MQPGvEd0p2igZiBqDns1PULydi', '55112233', '1985-05-15', GETDATE(), NULL),
(1, 1, 'admin2@admin2.com', 'María González', 'admin123', '55445566', '1990-08-22', GETDATE(), NULL),

-- Operadores
(2, 1, 'operador1@operador1.com', 'Roberto Martínez', '$2a$10$Qrq5pN1.zlScIUGTCDMW0uuit/8MQPGvEd0p2igZiBqDns1PULydi', '33112233', '1975-07-20', GETDATE(), 1),
(2, 1, 'operador2@operador2.com', 'Sofía Ramírez', 'operador123', '33445566', '1980-12-30', GETDATE(), 2),
(2, 1, 'operador3@operador3.com', 'Juan Pérez', 'operador123', '33112234', '1982-03-25', GETDATE(), 5),
(2, 1, 'operador4@operador4.com', 'Ana López', 'operador123', '33445567', '1988-11-15', GETDATE(), 6),

-- Clientes
(3, 1, 'cliente1@cliente1.com', 'Luis Hernández', '$2a$10$Qrq5pN1.zlScIUGTCDMW0uuit/8MQPGvEd0p2igZiBqDns1PULydi', '33112235', '1983-06-10', GETDATE(), 7),
(3, 1, 'cliente2@cliente2.com', 'María Sánchez', 'cliente123', '33445568', '1979-09-25', GETDATE(), 8),
(3, 1, 'cliente3@cliente3.com', 'Pedro Ruiz', 'cliente123', '33112236', '1987-04-15', GETDATE(), 9),
(3, 1, 'cliente4@cliente4.com', 'Carmen Morales', 'cliente123', '33445569', '1981-11-05', GETDATE(), 10),
(3, 1, 'cliente5@cliente5.com', 'Jorge Mendoza', 'cliente123', '33112237', '1986-08-30', GETDATE(), 11),
(3, 1, 'cliente6@cliente6.com', 'Andrea Guzmán', 'cliente123', '33445570', '1984-02-20', GETDATE(), 12),
(3, 1, 'cliente7@cliente7.com', 'Ricardo Flores', 'cliente123', '33112238', '1980-07-12', GETDATE(), 13),
(3, 1, 'cliente8@cliente8.com', 'Lucia Torres', 'cliente123', '33445571', '1989-03-18', GETDATE(), 14),
(3, 1, 'cliente9@cliente9.com', 'Miguel Castillo', 'cliente123', '33112239', '1982-10-05', GETDATE(), 15);


-- INSERCIÓN DE CATEGORÍAS DE PRODUCTOS
INSERT INTO CategoriaProductos (
    usuarios_idusuarios, nombre, estados_idestados, fecha_creacion
) VALUES
(3, 'Electrónicos', 1, GETDATE()),
(3, 'Hogar y Cocina', 1, GETDATE()),
(4, 'Papelería', 1, GETDATE()),
(3, 'Ferretería', 1, GETDATE());

-- INSERCIÓN DE PRODUCTOS
INSERT INTO Productos (
    CategoriaProductos_idCategoriaProductos,
    usuarios_idusuarios,
    nombre,
    marca,
    codigo,
    stock,
    estados_idestados,
    precio,
    fecha_creacion,
    foto
) VALUES
-- Electrónicos
(1, 3, 'Smartphone X1', 'TechBrand', 'ELEC001', 50, 1, 2500.50, GETDATE(), 'https://technostore.es/wp-content/uploads/smartphone_v3_1.jpg'),
(1, 3, 'Laptop Pro', 'ComputerCorp', 'ELEC002', 30, 1, 8999.99, GETDATE(), 'https://m.media-amazon.com/images/I/815Su-0wUDL._AC_SL1500_.jpg'),

-- Hogar y Cocina
(2, 3, 'Licuadora MultiUsos', 'KitchenMaster', 'HOGAR001', 100, 1, 599.99, GETDATE(), 'https://m.media-amazon.com/images/I/71X5Q6bcfgL.__AC_SX300_SY300_QL70_FMwebp_.jpg'),
(2, 3, 'Juego de Ollas', 'ChefPro', 'HOGAR002', 75, 1, 1299.50, GETDATE(), 'https://www.mundodeportivo.com/elrecomendador/comparativas/wp-content/uploads/2023/04/B00V6GF7UU.jpg'),

-- Papelería
(3, 4, 'Cuaderno Profesional', 'PaperMax', 'PAPEL001', 200, 1, 45.75, GETDATE(), 'https://http2.mlstatic.com/D_NQ_NP_688290-MLU72549815159_102023-O.webp'),
(3, 4, 'Bolígrafo Pack x5', 'WriteMaster', 'PAPEL002', 500, 1, 35.25, GETDATE(), 'https://cdn4.volusion.store/xyndy-woqrt/v/vspfiles/photos/PEN24DC-SP-3.jpg'),

-- Ferretería
(4, 3, 'Taladro Inalámbrico', 'ToolPro', 'FERR001', 40, 1, 1799.99, GETDATE(), 'https://cemacogt.vtexassets.com/arquivos/ids/306172/969559_1.jpg'),
(4, 3, 'Juego de Destornilladores', 'MechanicKit', 'FERR002', 80, 1, 299.50, GETDATE(), 'https://gt.epaenlinea.com/media/catalog/product/cache/3f8a07f91ed96197ac7613a4e8859f2d/0/f/0fc087bf-a530-419f-9039-7898b8927696.jpg');

-- INSERCIÓN DE ÓRDENES
INSERT INTO Orden (
    usuarios_idusuarios,
    estados_idestados,
    fecha_creacion,
    nombre_completo,
    direccion,
    telefono,
    correo_electronico,
    fecha_entrega,
    total_orden
) VALUES
-- Ordenes para Agosto de 2024
(3, 1, '2024-08-01', 'Roberto Martínez', 'Zone 10 Ciudad de Guatemala', '33112233', 'cliente1@elsol.com', DATEADD(day, 5, '2024-08-01'), 5600.99),
(4, 1, '2024-08-05', 'Sofía Ramírez', '4ta Avenida zona 1', '33445566', 'cliente2@laluna.com', DATEADD(day, 3, '2024-08-05'), 3200.50),
(5, 1, '2024-08-10', 'Juan Pérez', 'Zona 9 Ciudad', '33112234', 'cliente3@unistore.com', DATEADD(day, 5, '2024-08-10'), 4500.75),
(6, 1, '2024-08-15', 'Ana López', 'Zona 11 Ciudad', '33445567', 'cliente4@delta.com', DATEADD(day, 3, '2024-08-15'), 3750.25),
(7, 1, '2024-08-20', 'Luis Hernández', 'Zona 4 Guatemala', '33112235', 'cliente7@sanjose.com', DATEADD(day, 4, '2024-08-20'), 6200.50),
(8, 1, '2024-08-22', 'María Sánchez', 'Zona 5 Ciudad', '33445568', 'cliente8@lasflores.com', DATEADD(day, 3, '2024-08-22'), 2800.75),
(9, 1, '2024-08-25', 'Pedro Ruiz', 'Mixco', '33112236', 'cliente9@expressstore.com', DATEADD(day, 5, '2024-08-25'), 4100.25),
(10, 1, '2024-08-27', 'Carmen Morales', 'Zona 7 Ciudad', '33445569', 'cliente10@centralimport.com', DATEADD(day, 3, '2024-08-27'), 5500.99),
(11, 1, '2024-08-28', 'Jorge Mendoza', 'Zona 12 Ciudad', '33112237', 'cliente11@progresomarket.com', DATEADD(day, 4, '2024-08-28'), 3950.50),
(12, 1, '2024-08-30', 'Andrea Guzmán', 'Zona 6 Ciudad', '33445570', 'cliente12@quickwholesale.com', DATEADD(day, 5, '2024-08-30'), 4750.25),

-- Otras ordenes por si acaso
(13, 1, '2024-01-15', 'Ricardo Flores', 'Zona 8 Ciudad', '33112238', 'cliente13@globaltrade.com', DATEADD(day, 3, '2024-01-15'), 3600.75),
(14, 1, '2024-02-20', 'Lucia Torres', 'Zona 10 Ciudad', '33445571', 'cliente14@modernstore.com', DATEADD(day, 4, '2024-02-20'), 5200.50),
(15, 1, '2024-03-10', 'Miguel Castillo', 'Zona 13 Ciudad', '33112239', 'cliente15@nationaldist.com', DATEADD(day, 5, '2024-03-10'), 4300.25),
(3, 1, '2024-04-05', 'Roberto Martínez', 'Zone 10 Ciudad de Guatemala', '33112233', 'cliente1@elsol.com', DATEADD(day, 3, '2024-04-05'), 2800.99),
(4, 1, '2024-05-12', 'Sofía Ramírez', '4ta Avenida zona 1', '33445566', 'cliente2@laluna.com', DATEADD(day, 4, '2024-05-12'), 6100.50),
(5, 1, '2024-06-18', 'Juan Pérez', 'Zona 9 Ciudad', '33112234', 'cliente3@unistore.com', DATEADD(day, 5, '2024-06-18'), 3950.75),
(6, 1, '2024-07-22', 'Ana López', 'Zona 11 Ciudad', '33445567', 'cliente4@delta.com', DATEADD(day, 3, '2024-07-22'), 4500.25),
(7, 1, '2024-09-05', 'Luis Hernández', 'Zona 4 Guatemala', '33112235', 'cliente7@sanjose.com', DATEADD(day, 4, '2024-09-05'), 5700.50),
(8, 1, '2024-10-15', 'María Sánchez', 'Zona 5 Ciudad', '33445568', 'cliente8@lasflores.com', DATEADD(day, 5, '2024-10-15'), 3200.75),
(9, 1, '2024-11-20', 'Pedro Ruiz', 'Mixco', '33112236', 'cliente9@expressstore.com', DATEADD(day, 3, '2024-11-20'), 4800.25);

-- INSERCIÓN DE DETALLES DE ÓRDENES
INSERT INTO OrdenDetalles (
    Orden_idOrden,
    Productos_idProductos,
    cantidad,
    precio,
    subtotal
) VALUES
-- Detalles para órdendes de agosto
(1, 1, 2, 2500.50, 5001.00),
(1, 3, 1, 599.99, 599.99),
(2, 4, 2, 1299.50, 2599.00),
(2, 6, 3, 35.25, 105.75),
(3, 2, 1, 8999.99, 8999.99),
(3, 5, 10, 45.75, 457.50),
(4, 7, 2, 1799.99, 3599.98),
(4, 8, 5, 299.50, 1497.50),
(5, 1, 1, 2500.50, 2500.50),
(5, 4, 3, 1299.50, 3898.50),
(6, 3, 2, 599.99, 1199.98),
(6, 6, 5, 35.25, 176.25),
(7, 2, 1, 8999.99, 8999.99),
(7, 5, 15, 45.75, 686.25),
(8, 7, 3, 1799.99, 5399.97),
(8, 8, 7, 299.50, 2096.50),
(9, 1, 2, 2500.50, 5001.00),
(9, 4, 1, 1299.50, 1299.50),
(10, 3, 4, 599.99, 2399.96),
(10, 6, 6, 35.25, 211.50),

-- Detalles para otras ordenes por si acaso
(11, 1, 1, 2500.50, 2500.50),
(12, 2, 1, 8999.99, 8999.99),
(13, 4, 2, 1299.50, 2599.00),
(14, 5, 10, 45.75, 457.50),
(15, 7, 2, 1799.99, 3599.98),
(16, 8, 5, 299.50, 1497.50),
(17, 1, 3, 2500.50, 7501.50),
(18, 3, 2, 599.99, 1199.98),
(19, 2, 1, 8999.99, 8999.99),
(20, 6, 10, 35.25, 352.50);

-- /////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////// EJEMPLOS DE USO //////////////////////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////////////////////////////////////


-- #####################################################################################
-- ################################### USO DE VISTAS ###################################
-- #####################################################################################

-- a. Total de Productos activos que tenga en stock mayor a 0
SELECT * FROM VistaProductosActivosConStockMayorACero;

-- b. Total de Quetzales en ordenes ingresadas en el mes de Agosto 2024
SELECT * FROM VistaTotalOrdenesAgosto2024;

-- c. Top 10 de clientes con Mayor consumo de ordenes de todo el histórico
SELECT * FROM VistaTop10ClientesMayorConsumo;

-- d. Top 10 de productos más vendidos en orden ascendente
SELECT * FROM VistaTop10ProductosMasVendidos;

-- #####################################################################################
-- ##################################### USO DE SP #####################################
-- #####################################################################################

-- //////////////////////////////// ESTADOS ////////////////////////////////
-- Insertar Estado
-- EXEC sp_InsertarEstado @nombre = 'Activo'

-- Actualizar Estado
-- EXEC sp_ActualizarEstado @idestados = 1, @nombre = 'Inactivo'

-- Eliminar Estado (Soft Delete) (En teoría nunca se usaría, pero por si acaso lo pongo)
-- EXEC sp_EliminarEstado @idestados = 1

-- Leer Estados
-- EXEC sp_LeerEstados

-- //////////////////////////////// ROL ////////////////////////////////
-- Insertar Rol
-- EXEC sp_InsertarRol @nombre = 'Administrador'

-- Actualizar Rol
-- EXEC sp_ActualizarRol @idrol = 1, @nombre = 'Administrador'

-- Eliminar Rol (Tampoco debería usarse nunca)
-- EXEC sp_EliminarRol @idrol = 1

-- Leer Roles
-- EXEC sp_LeerRoles

-- //////////////////////////////// CLIENTES ////////////////////////////////
-- Insertar Cliente
-- EXEC sp_InsertarCliente
--     @razon_social = 'Empresa de Prueba S.A.',
--     @nombre_comercial = 'Prueba Comercial',
--     @direccion_entrega = 'Dirección de Entrega',
--     @telefono = '123456789',
--     @email = 'contacto@empresa.com'

-- Actualizar Cliente
-- EXEC sp_ActualizarCliente
--     @idClientes = 1,
--     @razon_social = 'Empresa Actualizada S.A.',
--     @nombre_comercial = 'Nuevo Nombre Comercial',
--     @direccion_entrega = 'Nueva Dirección',
--     @telefono = '987654321',
--     @email = 'nuevo@empresa.com'

-- Eliminar Cliente (Soft Delete) (Se puede usar pero con cuidado xD)
-- EXEC sp_EliminarCliente @idClientes = 1

-- Leer Clientes
-- EXEC sp_LeerClientes

-- Leer Clientes Filtrados por empresa y/o correo
-- EXEC sp_LeerClientesFiltrados @razon_social = 'Empresa'
-- EXEC sp_LeerClientesFiltrados @email = 'contacto'
-- EXEC sp_LeerClientesFiltrados @razon_social = 'Empresa', @email = 'contacto'

-- //////////////////////////////// USUARIOS ////////////////////////////////
-- Insertar Usuario
-- EXEC sp_InsertarUsuario
--     @rol_idrol = 1,
--     @estados_idestados = 1,
--     @correo_electronico = 'usuario@ejemplo.com',
--     @nombre_completo = 'Juan Pérez',
--     @password = 'contraseñaHasheada',
--     @telefono = '123456789',
--     @fecha_nacimiento = '1990-01-01',
--     @Clientes_idClientes = NULL

-- Actualizar Usuario
-- EXEC sp_ActualizarUsuario
--     @idusuarios = 1,
--     @rol_idrol = 2,
--     @estados_idestados = 2,
--     @correo_electronico = 'nuevo.correo@ejemplo.com',
--     @nombre_completo = 'Juan Pérez Actualizado',
--     @telefono = '987654321',
--     @fecha_nacimiento = '1990-01-01',
--     @Clientes_idClientes = NULL

-- Eliminar / Cambiar Estado de Usuario (Soft Delete)
-- Para desactivar un usuario (cambiar a estado Inactivo)
-- EXEC sp_CambiarEstadoUsuario
--     @idusuarios = 1,
--     @estados_idestados = 2  -- Suponiendo que 2 es el ID de "Inactivo"

-- Leer Usuarios
-- EXEC sp_LeerUsuarios

-- Leer Usuarios Filtrados
-- EXEC sp_LeerUsuariosFiltrados @nombre_completo = 'Juan'
-- EXEC sp_LeerUsuariosFiltrados @correo_electronico = 'ejemplo'
-- EXEC sp_LeerUsuariosFiltrados @rol_nombre = 'Administrador'
-- EXEC sp_LeerUsuariosFiltrados @estado_nombre = 'Activo'
-- EXEC sp_LeerUsuariosFiltrados
--     @nombre_completo = 'Juan',
--     @correo_electronico = 'ejemplo',
--     @rol_nombre = 'Administrador',
--     @estado_nombre = 'Activo'

-- //////////////////////////////// CATEGORIA PRODUCTOS ////////////////////////////////
-- Insertar Categoría de Productos
-- EXEC sp_InsertarCategoriaProductos
--     @usuarios_idusuarios = 1,
--     @nombre = 'Electrónica',
--     @estados_idestados = 1

-- Actualizar Categoría de Productos
-- EXEC sp_ActualizarCategoriaProductos
--     @idCategoriaProductos = 1,
--     @usuarios_idusuarios = 1,
--     @nombre = 'Electrónica Actualizada',
--     @estados_idestados = 1

-- Eliminar / Cambiar Estado de Categoría de Productos
-- EXEC sp_CambiarEstadoCategoriaProductos
--     @idCategoriaProductos = 1,
--     @estados_idestados = 2  -- Suponiendo que 2 es el ID de "Inactivo"

-- Leer Categorías de Productos
-- EXEC sp_LeerCategoriaProductos

-- Leer Categorías de Productos Filtradas
-- EXEC sp_LeerCategoriaProductosFiltradas @nombre = 'Electrónica'
-- EXEC sp_LeerCategoriaProductosFiltradas @usuario_nombre = 'Juan'
-- EXEC sp_LeerCategoriaProductosFiltradas @estado_nombre = 'Activo'
-- EXEC sp_LeerCategoriaProductosFiltradas
--     @nombre = 'Electrónica',
--     @usuario_nombre = 'Juan',
--     @estado_nombre = 'Activo'

-- //////////////////////////////// PRODUCTOS ////////////////////////////////
-- Insertar Producto
-- EXEC sp_InsertarProducto
--     @CategoriaProductos_idCategoriaProductos = 1,
--     @usuarios_idusuarios = 1,
--     @nombre = 'Laptop',
--     @marca = 'Dell',
--     @codigo = 'DELL-XPS-15',
--     @stock = 10,
--     @estados_idestados = 1,
--     @precio = 1500.00,
--     @foto = 'ruta/a/imagen.jpg'

-- Actualizar Producto
-- EXEC sp_ActualizarProducto
--     @idProductos = 1,
--     @CategoriaProductos_idCategoriaProductos = 1,
--     @usuarios_idusuarios = 1,
--     @nombre = 'Laptop Actualizada',
--     @marca = 'Dell',
--     @codigo = 'DELL-XPS-15-V2',
--     @stock = 15,
--     @estados_idestados = 1,
--     @precio = 1600.00,
--     @foto = 'ruta/a/nueva/imagen.jpg'

-- Cambiar Estado de Producto
-- EXEC sp_CambiarEstadoProducto
--     @idProductos = 1,
--     @estados_idestados = 2  -- Suponiendo que 2 es el ID de "Inactivo"

-- Leer Productos
-- EXEC sp_LeerProductos

-- Leer Productos Filtrados
-- EXEC sp_LeerProductosFiltrados @nombre = 'Laptop'
-- EXEC sp_LeerProductosFiltrados @marca = 'Dell'
-- EXEC sp_LeerProductosFiltrados @codigo = 'DELL'
-- EXEC sp_LeerProductosFiltrados @categoria_nombre = 'Electrónicos'
-- EXEC sp_LeerProductosFiltrados @estado_nombre = 'Activo'
-- EXEC sp_LeerProductosFiltrados
--     @nombre = 'Laptop',
--     @marca = 'Dell',
--     @categoria_nombre = 'Electrónicos'

-- //////////////////////////////// ORDEN ////////////////////////////////
-- Insertar Orden
-- EXEC sp_InsertarOrden
--     @usuarios_idusuarios = 1,
--     @estados_idestados = 1,
--     @nombre_completo = 'Juan Pérez',
--     @direccion = 'Calle Principal 123',
--     @telefono = '55551234',
--     @correo_electronico = 'juan.perez@ejemplo.com',
--     @fecha_entrega = '2024-02-15',
--     @total_orden = 2500.50

-- Actualizar Orden
-- EXEC sp_ActualizarOrden
--     @idOrden = 1,
--     @estados_idestados = 2,
--     @nombre_completo = 'Juan Pérez Actualizado',
--     @direccion = 'Nueva Dirección 456',
--     @telefono = '55505678',
--     @correo_electronico = 'juan.perez.nuevo@ejemplo.com',
--     @fecha_entrega = '2024-02-20',
--     @total_orden = 2750.75

-- Cambiar Estado de Orden
-- EXEC sp_CambiarEstadoOrden
--     @idOrden = 1,
--     @estados_idestados = 2  -- Suponiendo que 2 es el ID de "En Proceso"

-- Leer Ordenes
-- EXEC sp_LeerOrdenes

-- Leer Orden por ID
-- EXEC sp_LeerOrdenPorId @idOrden = 1

-- //////////////////////////////// ORDEN DETALLES ////////////////////////////////
-- Insertar OrdenDetalle
-- EXEC sp_InsertarOrdenDetalle
--     @Orden_idOrden = 1,
--     @Productos_idProductos = 1,
--     @cantidad = 5,
--     @precio = 100.00

-- Actualizar OrdenDetalle
-- EXEC sp_ActualizarOrdenDetalle
--     @idOrdenDetalles = 1,
--     @cantidad = 3,
--     @precio = 120.00

-- Eliminar OrdenDetalle
-- EXEC sp_EliminarOrdenDetalle @idOrdenDetalles = 1

-- Leer OrdenDetalles por Orden
-- EXEC sp_LeerOrdenDetalles @Orden_idOrden = 1