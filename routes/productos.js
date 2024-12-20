import express from 'express'
import { conexionBD } from '../config/database.js'
import { TipoError, RetornarError } from '../utils/errors.js'
import { Autorizar } from '../middlewares/auth.js'
// manejo de las imagenes
import multer from 'multer'
import { subirImagen } from '../utils/subirCloudinary.js'
const router = express.Router()

// /////////////////////////// MULTER /////////////////////////////
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024 // 10 mb maximo que igual lo reducimos más adelante
  },
  fileFilter: (req, file, cb) => {
    // Error si el usaurio sube algo que no sea uina imagen
    if (!file.mimetype.startsWith('image/')) {
      return cb(new Error('Solo se permiten archivos de imagen'), false)
    }
    cb(null, true)
  }
})

// /////////////////////////// GETS /////////////////////////////

// Obtener todos los productos: sp_LeerProductos
// localhost:3000/productos
router.get('/', Autorizar(['Todos']), async (req, res) => {
  try {
    const productos = await conexionBD.query('sp_LeerProductos', {
      type: conexionBD.QueryTypes.SELECT
    })

    // ERRORES
    if (!productos.length) {
      throw TipoError('productos', 'NO_RESOURCES')
    }

    // Respuesta exitosa777
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
router.get('/filtro', Autorizar(['Todos']), async (req, res) => {
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

// Leer productos paginados: sp_LeerProductosPaginados
// localhost:3000/productos/paginado?page=1&size=10
router.get('/paginado', Autorizar(['Todos']), async (req, res) => {
  try {
    // Capturar los parámetros de paginación de la URL
    const pageNumber = parseInt(req.query.page) || 1
    const pageSize = parseInt(req.query.size) || 10

    // Construir los parámetros para el SP
    const parametros = {
      PageNumber: pageNumber,
      PageSize: pageSize
    }

    // Ejecutar el SP
    const result = await conexionBD.query(
      'EXEC sp_LeerProductosPaginados @PageNumber = :PageNumber, @PageSize = :PageSize',
      {
        replacements: parametros,
        type: conexionBD.QueryTypes.SELECT
      }
    )

    // Verificar si hay resultados
    if (!result || result.length === 0) {
      throw TipoError('productos', 'NO_RESOURCES')
    }

    // Separar los productos de la información de paginación
    const productos = result.slice(0, -1) // Todos los elementos excepto el último
    const paginacionInfo = result[result.length - 1] // Último elemento

    // Respuesta exitosa con productos y metadata de paginación
    res.json({
      productos,
      paginacion: paginacionInfo
    })
  } catch (error) {
    // Capturar los errores de la BD como los que retorna los SP o del servidor
    const ErrorDelSistema = error?.original?.message
    RetornarError(res, error, ErrorDelSistema)
  }
})

// Leer productos filtrados y paginados: sp_LeerProductosFiltradosPaginados
// localhost:3000/productos/filtro-paginado?page=1&size=10&nombre=Laptop&categoria_nombre=Electrónicos
router.get('/filtro-paginado', Autorizar(['Todos']), async (req, res) => {
  try {
    // Capturar los parámetros de paginación y filtros de la URL
    const pageNumber = parseInt(req.query.page) || 1
    const pageSize = parseInt(req.query.size) || 10

    // Capturar los filtros
    const filtros = {
      PageNumber: pageNumber,
      PageSize: pageSize,
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
      if (valor !== undefined && valor !== null) {
        params[campo] = valor
        condiciones.push(`@${campo} = :${campo}`)
      }
    }

    // Construir la query y ejecutar el SP
    const result = await conexionBD.query(
      `EXEC sp_LeerProductosFiltradosPaginados ${condiciones.join(', ')}`,
      {
        replacements: params,
        type: conexionBD.QueryTypes.SELECT
      }
    )

    // Verificar si hay resultados
    if (!result || result.length === 0) {
      throw TipoError('productos', 'NO_RESOURCES')
    }

    // Separar los productos de la información de paginación
    const productos = result.slice(0, -1) // Todos los elementos excepto el último
    const paginacionInfo = result[result.length - 1] // Último elemento

    // Respuesta exitosa con productos y metadata de paginación
    res.json({
      productos,
      paginacion: paginacionInfo
    })
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
router.post('/', Autorizar(['Administrador', 'Operador']), async (req, res) => {
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

// Crear un producto: sp_InsertarProducto
// localhost:3000/productos/img
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
router.post(
  '/img',
  Autorizar(['Administrador', 'Operador']),
  upload.single('imagen'), // Nombre del campo en el formulario
  async (req, res) => {
    try {
      // Verificar si se envió una imagen
      if (!req.file) {
        throw TipoError('Imagen', 'REQUIRED_FIELD')
      }

      // Subir la imagen procesada a Cloudinary usando la función subirImagen que creamos
      const resultadoImagen = await subirImagen(req.file)

      // meter la url de la imagen en el body
      const datosProducto = {
        ...req.body,
        foto: resultadoImagen.url
      }

      // Verificar todos los campos requeridos
      const {
        CategoriaProductos_idCategoriaProductos,
        usuarios_idusuarios,
        nombre,
        marca,
        codigo,
        stock,
        estados_idestados,
        precio
      } = datosProducto

      if (
        !CategoriaProductos_idCategoriaProductos ||
        !usuarios_idusuarios ||
        !nombre ||
        !marca ||
        !codigo ||
        !stock ||
        !estados_idestados ||
        !precio
      ) {
        throw TipoError('Todos', 'REQUIRED_FIELDS')
      }

      // Construir los parámetros dinámicamente
      const parametros = {}
      const condiciones = []

      for (const [campo, valor] of Object.entries(datosProducto)) {
        if (valor) {
          parametros[campo] = valor
          condiciones.push(`@${campo} = :${campo}`)
        }
      }

      // Construir y ejecutar la consulta SQL
      const consultaSQL = `EXEC sp_InsertarProducto ${condiciones.join(', ')}`
      const producto = await conexionBD.query(consultaSQL, {
        replacements: parametros,
        type: conexionBD.QueryTypes.SELECT
      })

      // Verificar si se pudo insertar el producto
      if (!producto || !producto.length) {
        throw TipoError('producto', 'NOT_CREATE')
      }

      // Respuesta exitosa
      res.json({ ...producto[0] })
    } catch (error) {
      const ErrorDelSistema = error?.original?.message
      RetornarError(res, error, ErrorDelSistema)
    }
  }
)

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
router.put(
  '/:id',
  Autorizar(['Administrador', 'Operador']),
  async (req, res) => {
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
  }
)

// Eliminar un producto: sp_CambiarEstadoProducto
// localhost:3000/eliminar/1
router.put(
  '/eliminar/:id',
  Autorizar(['Administrador', 'Operador']),
  async (req, res) => {
    try {
      // Capturar el id del producto
      const { id } = req.params

      // Construir los parámetros dinámicamente
      const parametros = {
        idProductos: id,
        estados_idestados: 2
      }

      // Construir la consulta SQL para ejecutar el SP
      const consultaSQL =
        'EXEC sp_CambiarEstadoProducto @idProductos = :idProductos, @estados_idestados = :estados_idestados'

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
  }
)

// Restaurar un producto: sp_CambiarEstadoProducto
// localhost:3000/restaurar/1
router.put(
  '/restaurar/:id',
  Autorizar(['Administrador', 'Operador']),
  async (req, res) => {
    try {
      // Capturar el id del producto
      const { id } = req.params

      // Construir los parámetros dinámicamente
      const parametros = {
        idProductos: id,
        estados_idestados: 1
      }

      // Construir la consulta SQL para ejecutar el SP
      const consultaSQL =
        'EXEC sp_CambiarEstadoProducto @idProductos = :idProductos, @estados_idestados = :estados_idestados'

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
  }
)

export default router
