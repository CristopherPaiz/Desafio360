import express from 'express'
import { conexionBD } from '../config/database.js'
import { TipoError, RetornarError } from '../utils/errors.js'
import { Autorizar } from '../middlewares/auth.js'
const router = express.Router()

// /////////////////////////// GETS /////////////////////////////
// Obtener todos los estados: sp_LeerEstados
// localhost:3000/estados
router.get('/', Autorizar(['Administrador', 'Operador']), async (req, res) => {
  try {
    const estados = await conexionBD.query('sp_LeerEstados', {
      type: conexionBD.QueryTypes.SELECT
    })

    // ERRORES
    if (!estados.length) {
      throw TipoError('estados', 'NO_RESOURCES')
    }

    // Respuesta exitosa
    res.json(estados)
  } catch (error) {
    // Capturar los errores de la BD como los que retorna los SP o del servidor
    const ErrorDelSistema = error?.original?.message
    RetornarError(res, error, ErrorDelSistema)
  }
})

// /////////////////////////// POST /////////////////////////////

// Crear una nuevo estado: sp_InsertarEstado
// localhost:3000/estados
// {
//   "nombre": "Verificado"
// }
router.post('/', Autorizar(['Administrador', 'Operador']), async (req, res) => {
  try {
    // Capturar los datos del body
    const { nombre } = req.body

    // El nombre es requerido
    if (!nombre) {
      throw TipoError('nombre', 'REQUIRED_FIELD')
    }

    // Construir la consulta SQL para ejecutar el SP
    const consultaSQL = 'EXEC sp_InsertarEstado @nombre = :nombre'

    // Ejecutar el SP con los parámetros
    const estado = await conexionBD.query(consultaSQL, {
      replacements: { nombre },
      type: conexionBD.QueryTypes.SELECT
    })

    // Verificar si se pudo insertar el estado
    if (!estado || !estado.length) {
      throw TipoError('estado', 'NOT_CREATE')
    }

    // Respuesta exitosa
    res.json(estado)
  } catch (error) {
    // Capturar los errores de la BD como los que retorna los SP o del servidor
    const ErrorDelSistema = error?.original?.message
    RetornarError(res, error, ErrorDelSistema)
  }
})

// /////////////////////////// PUT /////////////////////////////
// Actualizar un estado: sp_ActualizarEstado
// localhost:3000/estados/7
// {
//   "nombre" : "Semi Verificado"
// }
router.put(
  '/:id',
  Autorizar(['Administrador', 'Operador']),
  async (req, res) => {
    try {
      // Capturar el id del producto
      const { id } = req.params

      // Capturar los datos del body
      const { nombre } = req.body

      // El nombre es requerido
      if (!nombre) {
        throw TipoError('nombre', 'REQUIRED_FIELD')
      }

      // Construir los parámetros dinámicamente

      const parametros = {
        idEstado: id,
        nombre
      }

      // Construir la consulta SQL para ejecutar el SP
      const consultaSQL =
        'EXEC sp_ActualizarEstado @idestados = :idEstado, @nombre = :nombre'

      // Ejecutar el SP con los parámetros
      const estado = await conexionBD.query(consultaSQL, {
        replacements: parametros,
        type: conexionBD.QueryTypes.SELECT
      })

      // Verificar si se pudo actualizar el estado
      if (!estado || !estado.length) {
        throw TipoError('estado', 'NOT_UPDATE')
      }

      // Respuesta exitosa
      res.json(estado)
    } catch (error) {
      // Capturar los errores de la BD como los que retorna los SP o del servidor
      const ErroDelSistema = error?.original?.message
      RetornarError(res, error, ErroDelSistema)
    }
  }
)

// ⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠ DELETE  ⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠
// Eliminar un estado: sp_EliminarEstado
// localhost:3000/estados/5
router.delete(
  '/:id',
  Autorizar(['Administrador', 'Operador']),
  async (req, res) => {
    try {
      // Capturar el id del producto
      const { id } = req.params

      // Si el id es requerido
      if (!id) {
        throw TipoError('id', 'REQUIRED_FIELD')
      }

      // Construir la consulta SQL para ejecutar el SP
      const consultaSQL = 'EXEC sp_EliminarEstado @idestados = :idEstado'

      // Ejecutar el SP con los parámetros
      const estado = await conexionBD.query(consultaSQL, {
        replacements: { idEstado: id },
        type: conexionBD.QueryTypes.SELECT
      })

      // Verificar si se pudo eliminar el producto
      if (!estado || !estado.length) {
        throw TipoError('estado', 'NOT_DELETE')
      }

      // Respuesta exitosa
      res.json(estado)
    } catch (error) {
      // Capturar los errores de la BD como los que retorna los SP o del servidor
      const ErrorDelSistema = error?.original?.message
      RetornarError(res, error, ErrorDelSistema)
    }
  }
)
export default router
