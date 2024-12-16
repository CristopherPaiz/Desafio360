import express from 'express'
import { conexionBD } from '../config/database.js'
import { TipoError, RetornarError } from '../utils/errors.js'
const router = express.Router()

// /////////////////////////// GETS /////////////////////////////
// Obtener todos los productos: sp_LeerCategoriaProductos
// localhost:3000/categorias
router.get('/', async (req, res) => {
  try {
    const productos = await conexionBD.query('sp_LeerCategoriaProductos', {
      type: conexionBD.QueryTypes.SELECT
    })

    // ERRORES
    if (!productos.length) {
      throw TipoError('categorías', 'NO_RESOURCES')
    }

    // Respuesta exitosa
    res.json(productos)
  } catch (error) {
    // Capturar los errores de la BD como los que retorna los SP o del servidor
    const ErrorDelSistema = error?.original?.message
    RetornarError(res, error, ErrorDelSistema)
  }
})

// Leer categorias Filtradas: sp_LeerCategoriaProductosFiltradas
// localhost:3000/categorias/filtro?nombre=Electrónicos
// localhost:3000/categorias/filtro?usuario_nombre=Roberto Martínez
// localhost:3000/categorias/filtro?nombre=Electrónicos&usuario_nombre=Roberto Martínez
router.get('/filtro', async (req, res) => {
  try {
    // Capturar los filtros de la URL
    const filtros = {
      nombre: req.query.nombre,
      usuario_nombre: req.query.usuario_nombre,
      estado_nombre: req.query.estado_nombre
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
    const categorias = await conexionBD.query(
      `EXEC sp_LeerCategoriaProductosFiltradas ${condiciones.join(', ')}`,
      {
        replacements: params,
        type: conexionBD.QueryTypes.SELECT
      }
    )

    // Si no hay categorías, lanzamos un error
    if (!categorias.length) {
      throw TipoError('categorías', 'NO_RESOURCES')
    }

    // Respuesta exitosa
    res.json(categorias)
  } catch (error) {
    // Capturar los errores de la BD como los que retorna los SP o del servidor
    const ErrorDelSistema = error?.original?.message
    RetornarError(res, error, ErrorDelSistema)
  }
})

// /////////////////////////// POST /////////////////////////////

// Crear un producto: sp_InsertarCategoriaProductos
// localhost:3000/categorias
// {
//   "usuarios_idusuarios": 1,
//   "nombre": "Línea Blanca",
//   "estados_idestados": 1
// }
router.post('/', async (req, res) => {
  try {
    // Capturar los datos del body
    const { usuarios_idusuarios, nombre, estados_idestados } = req.body

    // Todos lo datos son requeridos
    if (!usuarios_idusuarios || !nombre || !estados_idestados) {
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
        'No se proporcionaron parámetros para crear la categoría',
        'GENERAL_ERROR'
      )
    }

    // Construir la consulta SQL para ejecutar el SP
    const consultaSQL = `EXEC sp_InsertarCategoriaProductos ${condiciones.join(
      ', '
    )}`

    // Ejecutar el SP con los parámetros
    const categoria = await conexionBD.query(consultaSQL, {
      replacements: parametros,
      type: conexionBD.QueryTypes.SELECT
    })

    // Verificar si se pudo insertar el categoria
    if (!categoria || !categoria.length) {
      throw TipoError('categoría', 'NOT_CREATE')
    }

    // Respuesta exitosa
    res.json(categoria)
  } catch (error) {
    // Capturar los errores de la BD como los que retorna los SP o del servidor
    const ErrorDelSistema = error?.original?.message
    RetornarError(res, error, ErrorDelSistema)
  }
})

// /////////////////////////// PUT /////////////////////////////
// Actualizar una categoria: sp_ActualizarCategoriaProductos
// localhost:3000/categorias/5
// {
//   "usuarios_idusuarios": 1,
//   "nombre" : "Línea Blanca",
//   "estados_idestados": 1
// }
router.put('/:id', async (req, res) => {
  try {
    // Capturar el id del producto
    const { id } = req.params

    // Construir los parámetros dinámicamente
    const parametros = {
      idCategoria: id
    }
    const condiciones = ['@idCategoriaProductos = :idCategoria']

    // Lista de campos permitidos para actualización
    const camposPermitidos = [
      'usuarios_idusuarios',
      'nombre',
      'estados_idestados'
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
        'No se proporcionaron parámetros para actualizar la categoría',
        'GENERAL_ERROR'
      )
    }

    // Construir la consulta SQL para ejecutar el SP
    const consultaSQL = `EXEC sp_ActualizarCategoriaProductos ${condiciones.join(
      ', '
    )}`

    // Ejecutar el SP con los parámetros
    const categoria = await conexionBD.query(consultaSQL, {
      replacements: parametros,
      type: conexionBD.QueryTypes.SELECT
    })

    // Verificar si se pudo actualizar el categoria
    if (!categoria || !categoria.length) {
      throw TipoError('categoría', 'NOT_UPDATE')
    }

    // Respuesta exitosa
    res.json(categoria)
  } catch (error) {
    // Capturar los errores de la BD como los que retorna los SP o del servidor
    const ErroDelSistema = error?.original?.message
    RetornarError(res, error, ErroDelSistema)
  }
})

// Eliminar una categoria: sp_CambiarEstadoCategoriaProductos
// localhost:3000/categorias/eliminar/5
router.put('/eliminar/:id', async (req, res) => {
  try {
    // Capturar el id del producto
    const { id } = req.params

    // Construir los parámetros dinámicamente
    const parametros = {
      idCategoria: id,
      estados_idestados: 2
    }

    // Construir la consulta SQL para ejecutar el SP
    const consultaSQL =
      'EXEC sp_CambiarEstadoCategoriaProductos @idCategoriaProductos = :idCategoria, @estados_idestados = :estados_idestados'

    // Ejecutar el SP con los parámetros
    const categoria = await conexionBD.query(consultaSQL, {
      replacements: parametros,
      type: conexionBD.QueryTypes.SELECT
    })
    // Verificar si se pudo eliminar el producto
    if (!categoria || !categoria.length) {
      throw TipoError('categoría', 'NOT_DELETE')
    }

    // Respuesta exitosa
    res.json(categoria)
  } catch (error) {
    // Capturar los errores de la BD como los que retorna los SP o del servidor
    const ErrorDelSistema = error?.original?.message
    RetornarError(res, error, ErrorDelSistema)
  }
})

// Restaurar un categoria: sp_CambiarEstadoCategoriaProductos
// localhost:3000/categorias/restaurar/1
router.put('/restaurar/:id', async (req, res) => {
  try {
    // Capturar el id del producto
    const { id } = req.params

    // Construir los parámetros dinámicamente
    const parametros = {
      idCategoria: id,
      estados_idestados: 1
    }

    // Construir la consulta SQL para ejecutar el SP
    const consultaSQL =
      'EXEC sp_CambiarEstadoCategoriaProductos @idCategoriaProductos = :idCategoria, @estados_idestados = :estados_idestados'

    // Ejecutar el SP con los parámetros
    const categoria = await conexionBD.query(consultaSQL, {
      replacements: parametros,
      type: conexionBD.QueryTypes.SELECT
    })

    // Verificar si se pudo restaurar el producto
    if (!categoria || !categoria.length) {
      throw TipoError('categoría', 'NOT_RESTORE')
    }

    // Respuesta exitosa
    res.json(categoria)
  } catch (error) {
    // Capturar los errores de la BD como los que retorna los SP o del servidor
    const ErrorDelSistema = error?.original?.message
    RetornarError(res, error, ErrorDelSistema)
  }
})

export default router
