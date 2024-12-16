import express from 'express'
import { conexionBD } from '../config/database.js'
import { TipoError, RetornarError } from '../utils/errors.js'
const router = express.Router()

// /////////////////////////// GETS /////////////////////////////

// Obtener todos los productos: sp_LeerProductos
// localhost:3000/productos
router.get('/', async (req, res) => {
  try {
    const productos = await conexionBD.query('sp_LeerProductos', {
      type: conexionBD.QueryTypes.SELECT
    })

    // ERRORES
    if (!productos.length) {
      throw TipoError('productos', 'NO_RESOURCES')
    }

    // Respuesta exitosa
    res.json(productos)
  } catch (error) {
    // Capturar los errores de la BD como los que retorna los SP o del servidor
    const ErrorDelSistema = error?.original?.message
    RetornarError(res, error, ErrorDelSistema)
  }
})

// Leer Productos Filtrados: sp_LeerProductosFiltrados
// localhost:3000/productos/filtro?marca=Master
// localhost:3000/productos/filtro?nombre=Laptop
// localhost:3000/productos/filtro?marca=Master&nombre=x5
router.get('/filtro', async (req, res) => {
  try {
    // Capturar los filtros de la URL
    const filtros = {
      nombre: req.query.nombre,
      marca: req.query.marca,
      codigo: req.query.codigo,
      categoria_nombre: req.query.categoria_nombre,
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
    const productos = await conexionBD.query(
      `EXEC sp_LeerProductosFiltrados ${condiciones.join(', ')}`,
      {
        replacements: params,
        type: conexionBD.QueryTypes.SELECT
      }
    )

    // Si no hay productos, lanzamos un error
    if (!productos.length) {
      throw TipoError('productos', 'NO_RESOURCES')
    }

    // Respuesta exitosa
    res.json(productos)
  } catch (error) {
    // Capturar los errores de la BD como los que retorna los SP o del servidor
    const ErrorDelSistema = error?.original?.message
    RetornarError(res, error, ErrorDelSistema)
  }
})

// /////////////////////////// POST /////////////////////////////

// Crear un producto: sp_InsertarProducto
// localhost:3000/productos
// {
//   "CategoriaProductos_idCategoriaProductos": 1,
//   "usuarios_idusuarios": 1,
//   "nombre": "Laptop HP",
//   "marca": "HP",
//   "codigo": "HP1234",
//   "stock": 50,
//   "estados_idestados": 1,
//   "precio": 500.00,
//   "foto": "url-a-la-imagen.jpg"
// }
router.post('/', async (req, res) => {
  try {
    // Capturar los datos del body
    const {
      CategoriaProductos_idCategoriaProductos,
      usuarios_idusuarios,
      nombre,
      marca,
      codigo,
      stock,
      estados_idestados,
      precio,
      foto
    } = req.body

    // Todos lo datos son requeridos
    if (
      !CategoriaProductos_idCategoriaProductos ||
      !usuarios_idusuarios ||
      !nombre ||
      !marca ||
      !codigo ||
      !stock ||
      !estados_idestados ||
      !precio ||
      !foto
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
        'No se proporcionaron parámetros para crear el producto',
        'GENERAL_ERROR'
      )
    }

    // Construir la consulta SQL para ejecutar el SP
    const consultaSQL = `EXEC sp_InsertarProducto ${condiciones.join(', ')}`

    // Ejecutar el SP con los parámetros
    const producto = await conexionBD.query(consultaSQL, {
      replacements: parametros,
      type: conexionBD.QueryTypes.SELECT
    })

    // Verificar si se pudo insertar el producto
    if (!producto || !producto.length) {
      throw TipoError('producto', 'NOT_CREATE')
    }

    // Respuesta exitosa
    res.json(producto)
  } catch (error) {
    // Capturar los errores de la BD como los que retorna los SP o del servidor
    const ErrorDelSistema = error?.original?.message
    RetornarError(res, error, ErrorDelSistema)
  }
})

// /////////////////////////// PUT /////////////////////////////
// Actualizar un producto: sp_ActualizarProducto
// localhost:3000/productos/1
// {
//   "CategoriaProductos_idCategoriaProductos": 1,
//   "usuarios_idusuarios": 1,
//   "nombre": "Laptop HP Editada",
//   "marca": "HP",
//   "codigo": "HP1234Edit",
//   "stock": 10,
//   "precio": 500.00,
//   "foto": "url-a-la-imagen.jpg"
// }
router.put('/:id', async (req, res) => {
  try {
    // Capturar el id del producto
    const { id } = req.params

    // Construir los parámetros dinámicamente
    const parametros = {
      idProductos: id
    }
    const condiciones = ['@idProductos = :idProductos']

    // Lista de campos permitidos para actualización
    const camposPermitidos = [
      'CategoriaProductos_idCategoriaProductos',
      'usuarios_idusuarios',
      'nombre',
      'marca',
      'codigo',
      'stock',
      'estados_idestados',
      'precio',
      'foto'
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
        'No se proporcionaron parámetros para actualizar el producto',
        'GENERAL_ERROR'
      )
    }

    // Construir la consulta SQL para ejecutar el SP
    const consultaSQL = `EXEC sp_ActualizarProducto ${condiciones.join(', ')}`

    // Ejecutar el SP con los parámetros
    const producto = await conexionBD.query(consultaSQL, {
      replacements: parametros,
      type: conexionBD.QueryTypes.SELECT
    })

    // Verificar si se pudo actualizar el producto
    if (!producto || !producto.length) {
      throw TipoError('producto', 'NOT_UPDATE')
    }

    // Respuesta exitosa
    res.json(producto)
  } catch (error) {
    // Capturar los errores de la BD como los que retorna los SP o del servidor
    const ErroDelSistema = error?.original?.message
    RetornarError(res, error, ErroDelSistema)
  }
})

// Eliminar un producto: sp_CambiarEstadoProducto
// localhost:3000/eliminar/1
router.put('/eliminar/:id', async (req, res) => {
  try {
    // Capturar el id del producto
    const { id } = req.params

    // Construir los parámetros dinámicamente
    const parametros = {
      idProductos: id,
      estados_idestados: 2
    }

    // Construir la consulta SQL para ejecutar el SP
    const consultaSQL = `EXEC sp_CambiarEstadoProducto @idProductos = :idProductos, @estados_idestados = :estados_idestados`

    // Ejecutar el SP con los parámetros
    const producto = await conexionBD.query(consultaSQL, {
      replacements: parametros,
      type: conexionBD.QueryTypes.SELECT
    })

    // Verificar si se pudo eliminar el producto
    if (!producto || !producto.length) {
      throw TipoError('producto', 'NOT_DELETE')
    }

    // Respuesta exitosa
    res.json(producto)
  } catch (error) {
    // Capturar los errores de la BD como los que retorna los SP o del servidor
    const ErrorDelSistema = error?.original?.message
    RetornarError(res, error, ErrorDelSistema)
  }
})

// Restaurar un producto: sp_CambiarEstadoProducto
// localhost:3000/restaurar/1
router.put('/restaurar/:id', async (req, res) => {
  try {
    // Capturar el id del producto
    const { id } = req.params

    // Construir los parámetros dinámicamente
    const parametros = {
      idProductos: id,
      estados_idestados: 1
    }

    // Construir la consulta SQL para ejecutar el SP
    const consultaSQL = `EXEC sp_CambiarEstadoProducto @idProductos = :idProductos, @estados_idestados = :estados_idestados`

    // Ejecutar el SP con los parámetros
    const producto = await conexionBD.query(consultaSQL, {
      replacements: parametros,
      type: conexionBD.QueryTypes.SELECT
    })

    // Verificar si se pudo restaurar el producto
    if (!producto || !producto.length) {
      throw TipoError('producto', 'NOT_RESTORE')
    }

    // Respuesta exitosa
    res.json(producto)
  } catch (error) {
    // Capturar los errores de la BD como los que retorna los SP o del servidor
    const ErrorDelSistema = error?.original?.message
    RetornarError(res, error, ErrorDelSistema)
  }
})

export default router
