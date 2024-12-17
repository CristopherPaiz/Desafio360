import express from 'express'
import { conexionBD } from '../config/database.js'
import { TipoError, RetornarError } from '../utils/errors.js'
import { Autorizar } from '../middlewares/auth.js'
import bcrypt from 'bcryptjs'
import dotenv from 'dotenv'
dotenv.config()
const router = express.Router()

// /////////////////////////// CONSTANTES /////////////////////////////
const ADMIN_ID = 1
const CLIENTE_ID = 2
const OPERADOR_ID = 3

// /////////////////////////// GETS /////////////////////////////
// Obtener todos los usuarios: sp_LeerUsuarios
// localhost:3000/usuarios
router.get('/', Autorizar(['Administrador', 'Operador']), async (req, res) => {
  try {
    const usuarios = await conexionBD.query('sp_LeerUsuarios', {
      type: conexionBD.QueryTypes.SELECT
    })

    // ERRORES
    if (!usuarios.length) {
      throw TipoError('usuarios', 'NO_RESOURCES')
    }

    // Respuesta exitosa
    res.json(usuarios)
  } catch (error) {
    // Capturar los errores de la BD como los que retorna los SP o del servidor
    const ErrorDelSistema = error?.original?.message
    RetornarError(res, error, ErrorDelSistema)
  }
})

// Leer Clientes Filtrados: sp_LeerUsuariosFiltrados
// localhost:3000/usuarios/filtro?nombre=Ana López
// localhost:3000/usuarios/filtro?rol=Cliente
// localhost:3000/usuarios/filtro?estado=Activo
// localhost:3000/usuarios/filtro?nombre=Ana López&rol=Cliente&estado=Activo
router.get(
  '/filtro',
  Autorizar(['Administrador', 'Operador']),
  async (req, res) => {
    try {
      // Capturar los filtros de la URL
      const filtros = {
        nombre_completo: req.query.nombre,
        rol_nombre: req.query.rol,
        estado_nombre: req.query.estado
      }

      const params = {}
      const condiciones = []

      // Recorrer los filtros y agregarlos a la consulta
      for (const [campo, valor] of Object.entries(filtros)) {
        if (valor) {
          params[campo] = valor
          condiciones.push(`@${campo} = :${campo}`)
        }
      }
      console.log('condiciones', condiciones)
      // Si no se proporcionan filtros pues le avisamos al usuario que no se proporcionaron
      if (condiciones.length === 0) {
        throw TipoError(
          'No se proporcionaron parámetros válidos de filtro',
          'GENERAL_ERROR'
        )
      }

      // Construimos la query y ejecutamos el SP
      const usuarios = await conexionBD.query(
        `EXEC sp_LeerUsuariosFiltrados ${condiciones.join(', ')}`,
        {
          replacements: params,
          type: conexionBD.QueryTypes.SELECT
        }
      )

      // Si no hay usuarios, lanzamos un error
      if (!usuarios.length) {
        throw TipoError('usuarios', 'NO_RESOURCES')
      }

      // Respuesta exitosa
      res.json(usuarios)
    } catch (error) {
      // Capturar los errores de la BD como los que retorna los SP o del servidor
      const ErrorDelSistema = error?.original?.message
      RetornarError(res, error, ErrorDelSistema)
    }
  }
)

// /////////////////////////// POST /////////////////////////////

// Crear un usuario: sp_InsertarUsuario
// localhost:3000/usuarios
// {
//   "rol_idrol": 3,
//   "estados_idestados": 1,
//   "correo_electronico": "operador1@operador1.com",
//   "nombre_completo": "operador1",
//   "password": "op123",
//   "telefono": 55667788,
//   "fecha_nacimiento": "2001-10-10",
//   "Clientes_idClientes": NULL, // Si es administrador u operador no se pone, sino se pone el id del cliente
// }
router.post('/', Autorizar(['Administrador', 'Operador']), async (req, res) => {
  try {
    // Capturar los datos del body
    const {
      rol_idrol,
      estados_idestados,
      correo_electronico,
      nombre_completo,
      password,
      telefono,
      fecha_nacimiento,
      Clientes_idClientes
    } = req.body

    // Validar que todos los datos requeridos estén presentes
    if (
      !rol_idrol ||
      !estados_idestados ||
      !correo_electronico ||
      !nombre_completo ||
      !password ||
      !telefono ||
      !fecha_nacimiento
    ) {
      throw TipoError('Todos', 'REQUIRED_FIELDS')
    }

    // Hasheamos la contraseña
    const saltRounds = parseInt(process.env.SALT_ROUNDS) || 10
    const hashedPassword = await bcrypt.hash(password, saltRounds)

    // Construir los parámetros dinámicamente
    const parametros = {}
    const condiciones = []

    // Recorrer los datos del body y agregarlos a los parámetros
    for (const [campo, valor] of Object.entries(req.body)) {
      if (valor) {
        parametros[campo] = valor
        condiciones.push(`@${campo} = :${campo}`)
      }
    }

    // Reemplazamos la contraseña por la hasheada dentro del objeto de los parametros
    parametros.password = hashedPassword

    // Si es un cliente, se debe proporcionar el id del cliente
    if (rol_idrol === CLIENTE_ID && !Clientes_idClientes) {
      throw TipoError('ID Cliente', 'REQUIRED_FIELD')
    }

    // Si es un administrador u operador, se pone NULL en el id del cliente
    if (rol_idrol === ADMIN_ID || rol_idrol === OPERADOR_ID) {
      parametros.Clientes_idClientes = null
      condiciones.push('@Clientes_idClientes = :Clientes_idClientes')
    }

    // Si no se proporcionan parámetros, devolver un error
    if (condiciones.length === 0) {
      throw TipoError(
        'No se proporcionaron parámetros para crear al usuario',
        'GENERAL_ERROR'
      )
    }

    // Construir la consulta SQL para ejecutar el SP
    const consultaSQL = `EXEC sp_InsertarUsuario ${condiciones.join(', ')}`

    // Ejecutar el SP con los parámetros
    const usuario = await conexionBD.query(consultaSQL, {
      replacements: parametros,
      type: conexionBD.QueryTypes.SELECT
    })

    // Verificar si se pudo insertar el usuario
    if (!usuario || !usuario.length) {
      throw TipoError('usuario', 'NOT_CREATE')
    }

    // Respuesta exitosa
    res.json(usuario)
  } catch (error) {
    // Capturar los errores de la BD como los que retorna los SP o del servidor
    const ErrorDelSistema = error?.original?.message
    RetornarError(res, error, ErrorDelSistema)
  }
})

// /////////////////////////// PUT /////////////////////////////
// Actualizar un usuario: sp_ActualizarUsuario
// localhost:3000/usuarios/16
// {
//   "rol_idrol": 2,
//   "estados_idestados": 1,
//   "correo_electronico": "operador2@operador1.com",
//   "nombre_completo": "operador2",
//   "telefono": 55000000,
//   "fecha_nacimiento": "2001-10-10",
//   "Clientes_idClientes": 1
// }
router.put(
  '/:id',
  Autorizar(['Administrador', 'Operador']),
  async (req, res) => {
    try {
      // Capturar el id del usuario
      const { id } = req.params

      // Construir los parámetros dinámicamente
      const parametros = {
        idusuarios: id
      }
      const condiciones = ['@idusuarios = :idusuarios']

      // Lista de campos permitidos para actualización
      const camposPermitidos = [
        'rol_idrol',
        'estados_idestados',
        'correo_electronico',
        'nombre_completo',
        'telefono',
        'fecha_nacimiento',
        'Clientes_idClientes'
      ]

      // Recorrer los datos del body y agregarlos a los parámetros
      for (const [campo, valor] of Object.entries(req.body)) {
        if (camposPermitidos.includes(campo) && valor !== undefined) {
          parametros[campo] = valor
          condiciones.push(`@${campo} = :${campo}`)
        }
      }

      // Si no se proporcionan parámetros para actualizar, devolver un error
      if (condiciones.length === 1) {
        throw TipoError(
          'No se proporcionaron parámetros para actualizar el usuario',
          'GENERAL_ERROR'
        )
      }

      // Construir la consulta SQL para ejecutar el SP
      const consultaSQL = `EXEC sp_ActualizarUsuario ${condiciones.join(', ')}`

      // Ejecutar el SP con los parámetros
      const usuario = await conexionBD.query(consultaSQL, {
        replacements: parametros,
        type: conexionBD.QueryTypes.SELECT
      })

      // Verificar si se pudo actualizar el usuario
      if (!usuario || !usuario.length) {
        throw TipoError('usuario', 'NOT_UPDATE')
      }

      // Respuesta exitosa
      res.json(usuario)
    } catch (error) {
      // Capturar los errores de la BD como los que retorna los SP o del servidor
      const ErroDelSistema = error?.original?.message
      RetornarError(res, error, ErroDelSistema)
    }
  }
)

// Eliminar un producto: sp_CambiarEstadoUsuario
// localhost:3000/usuarios/eliminar/16
router.put(
  '/eliminar/:id',
  Autorizar(['Administrador', 'Operador']),
  async (req, res) => {
    try {
      // Capturar el id del usuario
      const { id } = req.params

      // Construir los parámetros dinámicamente
      const parametros = {
        idusuarios: id,
        estados_idestados: 2
      }

      // Construir la consulta SQL para ejecutar el SP
      const consultaSQL =
        'EXEC sp_CambiarEstadoUsuario @idusuarios = :idusuarios, @estados_idestados = :estados_idestados'

      // Ejecutar el SP con los parámetros
      const usuario = await conexionBD.query(consultaSQL, {
        replacements: parametros,
        type: conexionBD.QueryTypes.SELECT
      })

      // Verificar si se pudo eliminar el usuario
      if (!usuario || !usuario.length) {
        throw TipoError('usuario', 'NOT_DELETE')
      }

      // Respuesta exitosa
      res.json(usuario)
    } catch (error) {
      // Capturar los errores de la BD como los que retorna los SP o del servidor
      const ErrorDelSistema = error?.original?.message
      RetornarError(res, error, ErrorDelSistema)
    }
  }
)

// Restaurar un producto: sp_CambiarEstadoUsuario
// localhost:3000/restaurar/16
router.put(
  '/restaurar/:id',
  Autorizar(['Administrador', 'Operador']),
  async (req, res) => {
    try {
      // Capturar el id del producto
      const { id } = req.params

      // Construir los parámetros dinámicamente
      const parametros = {
        idusuarios: id,
        estados_idestados: 1
      }

      // Construir la consulta SQL para ejecutar el SP
      const consultaSQL =
        'EXEC sp_CambiarEstadoUsuario @idusuarios = :idusuarios, @estados_idestados = :estados_idestados'

      // Ejecutar el SP con los parámetros
      const usuario = await conexionBD.query(consultaSQL, {
        replacements: parametros,
        type: conexionBD.QueryTypes.SELECT
      })

      // Verificar si se pudo restaurar el usuario
      if (!usuario || !usuario.length) {
        throw TipoError('usuario', 'NOT_RESTORE')
      }

      // Respuesta exitosa
      res.json(usuario)
    } catch (error) {
      // Capturar los errores de la BD como los que retorna los SP o del servidor
      const ErrorDelSistema = error?.original?.message
      RetornarError(res, error, ErrorDelSistema)
    }
  }
)

export default router
