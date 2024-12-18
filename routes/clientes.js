import express from 'express'
import { conexionBD } from '../config/database.js'
import { TipoError, RetornarError } from '../utils/errors.js'
import { Autorizar } from '../middlewares/auth.js'
const router = express.Router()

// /////////////////////////// GETS /////////////////////////////
// Obtener todos los clientes: sp_LeerClientes
// localhost:3000/clientes
router.get('/', Autorizar(['Administrador', 'Operador']), async (req, res) => {
  try {
    const clientes = await conexionBD.query('sp_LeerClientes', {
      type: conexionBD.QueryTypes.SELECT
    })

    // ERRORES
    if (!clientes.length) {
      throw TipoError('clientes', 'NO_RESOURCES')
    }

    // Respuesta exitosa
    res.json(clientes)
  } catch (error) {
    // Capturar los errores de la BD como los que retorna los SP o del servidor
    const ErrorDelSistema = error?.original?.message
    RetornarError(res, error, ErrorDelSistema)
  }
})

// Leer Clientes Filtrados: sp_LeerClientesFiltrados
// localhost:3000/clientes/filtro?razon=Comercio Global
// localhost:3000/clientes/filtro?email=info@globaltrade.com.gt
// localhost:3000/clientes/filtro?razon=comercio&email=info@globaltrade.com.gt
router.get(
  '/filtro',
  Autorizar(['Administrador', 'Operador']),
  async (req, res) => {
    try {
      // Capturar los filtros de la URL
      const filtros = {
        razon_social: req.query.razon,
        email: req.query.email
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

      // Si no se proporcionan filtros pues le avisamos al usuario que no se proporcionaron
      if (condiciones.length === 0) {
        throw TipoError(
          'No se proporcionaron parámetros válidos de filtro',
          'GENERAL_ERROR'
        )
      }

      // Construimos la query y ejecutamos el SP
      const clientes = await conexionBD.query(
        `EXEC sp_LeerClientesFiltrados ${condiciones.join(', ')}`,
        {
          replacements: params,
          type: conexionBD.QueryTypes.SELECT
        }
      )

      // Si no hay clientes, lanzamos un error
      if (!clientes.length) {
        throw TipoError('clientes', 'NO_RESOURCES')
      }

      // Respuesta exitosa
      res.json(clientes)
    } catch (error) {
      // Capturar los errores de la BD como los que retorna los SP o del servidor
      const ErrorDelSistema = error?.original?.message
      RetornarError(res, error, ErrorDelSistema)
    }
  }
)

// /////////////////////////// POST /////////////////////////////

// Crear un cliente: sp_InsertarCliente
// localhost:3000/clientes
// {
//   "razon_social": "Comercial Sotz",
//   "nombre_comercial": "Comercio El Mero Sotz",
//   "direccion_entrega": "Zona 1, Guatemala",
//   "telefono": "55554444",
//   "email": "info@sotz.com"
// }
router.post('/', Autorizar(['Administrador', 'Operador']), async (req, res) => {
  try {
    // Capturar los datos del body
    const {
      razon_social,
      nombre_comercial,
      direccion_entrega,
      telefono,
      email
    } = req.body

    // Validar que todos los datos requeridos estén presentes
    if (
      !razon_social ||
      !nombre_comercial ||
      !direccion_entrega ||
      !telefono ||
      !email
    ) {
      throw TipoError('Todos', 'REQUIRED_FIELDS')
    }

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

    // Si no se proporcionan parámetros, devolver un error
    if (condiciones.length === 0) {
      throw TipoError(
        'No se proporcionaron parámetros para crear al cliente',
        'GENERAL_ERROR'
      )
    }

    // Construir la consulta SQL para ejecutar el SP
    const consultaSQL = `EXEC sp_InsertarCliente ${condiciones.join(', ')}`

    // Ejecutar el SP con los parámetros
    const cliente = await conexionBD.query(consultaSQL, {
      replacements: parametros,
      type: conexionBD.QueryTypes.SELECT
    })

    // Verificar si se pudo insertar el cliente
    if (!cliente || !cliente.length) {
      throw TipoError('cliente', 'NOT_CREATE')
    }

    // Respuesta exitosa
    res.json(cliente)
  } catch (error) {
    // Capturar los errores de la BD como los que retorna los SP o del servidor
    const ErrorDelSistema = error?.original?.message
    RetornarError(res, error, ErrorDelSistema)
  }
})

// /////////////////////////// PUT /////////////////////////////
// Actualizar un cliente: sp_ActualizarCliente
// localhost:3000/clientes/16
// {
//   "razon_social": "Comercial Putz",
//   "nombre_comercial": "Comercio El Mero Putz",
//   "direccion_entrega": "Zona 1, Guatemala",
//   "telefono": "55554444",
//   "email": "info@putz.com"
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
        idClientes: id
      }
      const condiciones = ['@idClientes = :idClientes']

      // Lista de campos permitidos para actualización
      const camposPermitidos = [
        'razon_social',
        'nombre_comercial',
        'direccion_entrega',
        'telefono',
        'email'
      ]

      // todos los campos son requeridos
      if (
        !req.body.razon_social ||
        !req.body.nombre_comercial ||
        !req.body.direccion_entrega ||
        !req.body.telefono ||
        !req.body.email
      ) {
        throw TipoError('Todos', 'REQUIRED_FIELDS')
      }

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
          'No se proporcionaron parámetros para actualizar el cliente',
          'GENERAL_ERROR'
        )
      }

      // Construir la consulta SQL para ejecutar el SP
      const consultaSQL = `EXEC sp_ActualizarCliente ${condiciones.join(', ')}`

      // Ejecutar el SP con los parámetros
      const cliente = await conexionBD.query(consultaSQL, {
        replacements: parametros,
        type: conexionBD.QueryTypes.SELECT
      })

      // Verificar si se pudo actualizar el cliente
      if (!cliente || !cliente.length) {
        throw TipoError('cliente', 'NOT_UPDATE')
      }

      // Respuesta exitosa
      res.json(cliente)
    } catch (error) {
      // Capturar los errores de la BD como los que retorna los SP o del servidor
      const ErroDelSistema = error?.original?.message
      RetornarError(res, error, ErroDelSistema)
    }
  }
)

// ⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠ DELETE  ⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠
// Eliminar un estado: sp_EliminarCliente
// localhost:3000/clientes/5
router.delete(
  '/:id',
  Autorizar(['Administrador', 'Operador']),
  async (req, res) => {
    try {
      // Capturar el id del cliente
      const { id } = req.params

      // Si el id es requerido
      if (!id) {
        throw TipoError('id', 'REQUIRED_FIELD')
      }

      // Construir la consulta SQL para ejecutar el SP
      const consultaSQL = 'EXEC sp_EliminarCliente @idClientes = :idClientes'

      // Ejecutar el SP con los parámetros
      const cliente = await conexionBD.query(consultaSQL, {
        replacements: { idClientes: id },
        type: conexionBD.QueryTypes.DELETE
      })

      // Verificar si se pudo eliminar el cliente
      if (!cliente || !cliente.length) {
        throw TipoError('cliente', 'NOT_DELETE')
      }

      // Respuesta exitosa
      res.json(cliente)
    } catch (error) {
      // Capturar los errores de la BD como los que retorna los SP o del servidor
      const ErrorDelSistema = error?.original?.message
      RetornarError(res, error, ErrorDelSistema)
    }
  }
)

export default router
