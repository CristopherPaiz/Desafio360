import express from 'express'
import { conexionBD } from '../config/database.js'
import { TipoError, RetornarError } from '../utils/errors.js'
import { Autorizar } from '../middlewares/auth.js'
import { io } from '../index.js'

const router = express.Router()

// /////////////////////////// GETS /////////////////////////////
// Obtener todos las ordenes: sp_LeerOrdenes
// localhost:3000/ordenes
router.get('/', Autorizar(['Administrador', 'Operador']), async (req, res) => {
  try {
    const ordenes = await conexionBD.query('sp_LeerOrdenes', {
      type: conexionBD.QueryTypes.SELECT
    })

    if (!ordenes.length) {
      throw TipoError('ordenes', 'NO_RESOURCES')
    }

    // Emitir WebSocket
    io.emit('ordenes:list', ordenes)

    res.json(ordenes)
  } catch (error) {
    const ErrorDelSistema = error?.original?.message
    RetornarError(res, error, ErrorDelSistema)
  }
})

// Obtener todas las órdenes de un usuario: sp_LeerOrdenesPorUsuario
// localhost:3000/ordenes/user/7
router.get('/user/:id', Autorizar(['Todos']), async (req, res) => {
  try {
    // Obtener el ID del usuario desde los parámetros de la URL
    const { id } = req.params

    if (!id) {
      throw TipoError(
        'idUsuario',
        'BAD_REQUEST',
        'El ID del usuario es obligatorio'
      )
    }

    // Llamada al procedimiento almacenado con el ID del usuario
    const ordenes = await conexionBD.query(
      'EXEC sp_LeerOrdenesPorUsuario @idUsuario = :idUsuario',
      {
        type: conexionBD.QueryTypes.SELECT,
        replacements: { idUsuario: id } // Reemplazo seguro del parámetro
      }
    )

    // Validación de recursos encontrados
    if (!ordenes.length) {
      throw TipoError(
        'ordenes',
        'NO_RESOURCES',
        'No se encontraron órdenes para este usuario'
      )
    }

    // Respuesta exitosa
    res.json(ordenes)
  } catch (error) {
    // Manejo de errores
    const ErrorDelSistema = error?.original?.message
    RetornarError(res, error, ErrorDelSistema)
  }
})

// Obtener todos las ordenes: sp_LeerOrdenPorId
// localhost:3000/ordenes/23
router.get('/:id', Autorizar(['Todos']), async (req, res) => {
  try {
    const { id } = req.params

    const orden = await conexionBD.query(
      'EXEC sp_LeerOrdenPorId @idOrden = :id',
      {
        replacements: { id },
        type: conexionBD.QueryTypes.SELECT
      }
    )

    if (!orden.length) {
      throw TipoError('orden', 'NOT_FOUND')
    }

    // Obtener detalles de la orden
    const detalles = await conexionBD.query(
      'EXEC sp_LeerOrdenDetalles @Orden_idOrden = :id',
      {
        replacements: { id },
        type: conexionBD.QueryTypes.SELECT
      }
    )

    const ordenCompleta = {
      ...orden[0],
      detalles
    }

    res.json(ordenCompleta)
  } catch (error) {
    const ErrorDelSistema = error?.original?.message
    RetornarError(res, error, ErrorDelSistema)
  }
})

// /////////////////////////// POST /////////////////////////////

// Crear una nuea orden: sp_InsertarOrden
// Crear una nueva orden con sus detalles: sp_InsertarOrdenDetalle
// localhost:3000/ordenes
// {
//   "usuarios_idusuarios": 3,
//   "estados_idestados": 4,
//   "nombre_completo": "Roberto Martínez",
//   "direccion": "Calle Falsa 123, Ciudad",
//   "telefono": "44440000",
//   "correo_electronico": "roberto@ejemplo.com",
//   "fecha_entrega": "2024-12-20",
//   "total_orden": 150.75,
//   "detalles": [
//     {
//       "Productos_idProductos": 8,
//       "cantidad": 2,
//       "precio": 50.25
//     },
//     {
//       "Productos_idProductos": 7,
//       "cantidad": 1,
//       "precio": 50.25
//     }
//   ]
// }
router.post('/', Autorizar(['Todos']), async (req, res) => {
  const transaccion = await conexionBD.transaction()

  try {
    const {
      usuarios_idusuarios,
      estados_idestados,
      nombre_completo,
      direccion,
      telefono,
      correo_electronico,
      fecha_entrega,
      total_orden,
      detalles
    } = req.body

    // Insertar orden
    const consultaOrden = `
      EXEC sp_InsertarOrden
      @usuarios_idusuarios = :usuarios_idusuarios,
      @estados_idestados = :estados_idestados,
      @nombre_completo = :nombre_completo,
      @direccion = :direccion,
      @telefono = :telefono,
      @correo_electronico = :correo_electronico,
      @fecha_entrega = :fecha_entrega,
      @total_orden = :total_orden
    `

    const orden = await conexionBD.query(consultaOrden, {
      replacements: {
        usuarios_idusuarios,
        estados_idestados,
        nombre_completo,
        direccion,
        telefono,
        correo_electronico,
        fecha_entrega,
        total_orden
      },
      type: conexionBD.QueryTypes.SELECT,
      transaction: transaccion
    })

    // Verificar si se creó la orden
    if (!orden || !orden.length) {
      throw TipoError('orden', 'NOT_CREATE')
    }

    const idOrden = orden[0].idOrden

    // Insertar detalles
    for (const detalle of detalles) {
      const consultaDetalle = `
        EXEC sp_InsertarOrdenDetalle
        @Orden_idOrden = :idOrden,
        @Productos_idProductos = :idProducto,
        @cantidad = :cantidad,
        @precio = :precio
      `

      await conexionBD.query(consultaDetalle, {
        replacements: {
          idOrden,
          idProducto: detalle.Productos_idProductos,
          cantidad: detalle.cantidad,
          precio: detalle.precio
        },
        type: conexionBD.QueryTypes.SELECT,
        transaction: transaccion
      })
    }

    await transaccion.commit()

    // Obtener la orden completa con sus detalles
    const ordenCompleta = await conexionBD.query(
      'EXEC sp_LeerOrdenPorId @idOrden = :idOrden',
      {
        replacements: { idOrden },
        type: conexionBD.QueryTypes.SELECT
      }
    )

    // Obtener lista actualizada de órdenes
    const ordenesActualizadas = await conexionBD.query('sp_LeerOrdenes', {
      type: conexionBD.QueryTypes.SELECT
    })

    // Emitir WbeSocket
    io.emit('ordenes:created', ordenCompleta[0]) // Emitir la orden creada
    io.emit('ordenes:list', ordenesActualizadas) // Emitir lista actualizada

    res.json(ordenCompleta[0])
  } catch (error) {
    await transaccion.rollback()
    const ErrorDelSistema = error?.original?.message
    RetornarError(res, error, ErrorDelSistema)
  }
})

// Agregar un detalle a una orden: sp_InsertarOrdenDetalle
// localhost:3000/ordenes/3/detalles
// {
//   "Productos_idProductos": 8,
//   "cantidad": 2,
//   "precio": 50.25
// }
router.post(
  '/:id/detalles',
  Autorizar(['Administrador', 'Operador']),
  async (req, res) => {
    const transaccion = await conexionBD.transaction()

    try {
      const { id } = req.params
      const { Productos_idProductos, cantidad, precio } = req.body

      // Si no hay id de orden, lanzar error
      if (!id) {
        throw TipoError('ID', 'REQUIRED_FIELD')
      }

      // Si no hay ID de producto, cantidad o precio, lanzar error
      if (!Productos_idProductos || !cantidad || !precio) {
        throw TipoError('Todos', 'REQUIRED_FIELDS')
      }

      const detalle = await conexionBD.query(
        'EXEC sp_InsertarOrdenDetalle @Orden_idOrden = :id, @Productos_idProductos = :Productos_idProductos, @cantidad = :cantidad, @precio = :precio',
        {
          replacements: {
            id,
            Productos_idProductos,
            cantidad,
            precio
          },
          type: conexionBD.QueryTypes.SELECT,
          transaction: transaccion
        }
      )

      await transaccion.commit()

      // Obtener orden actualizada
      const ordenActualizada = await conexionBD.query(
        'EXEC sp_LeerOrdenPorId @idOrden = :id',
        {
          replacements: { id },
          type: conexionBD.QueryTypes.SELECT
        }
      )

      io.emit('ordenes:updated', ordenActualizada[0])

      res.json(detalle[0])
    } catch (error) {
      await transaccion.rollback()
      const ErrorDelSistema = error?.original?.message
      RetornarError(res, error, ErrorDelSistema)
    }
  }
)

// /////////////////////////// PUT /////////////////////////////

// Actualizar una orden: sp_ActualizarOrden
// localhost:3000/ordenes/23
// {
//   "estados_idestados": 4,
//   "nombre_completo": "Juan Pérez Actualizado",
//   "direccion": "Calle Falsa 123, Ciudad",
//   "telefono": "55664433",
//   "correo_electronico": "juan.perez@example.com",
//   "fecha_entrega": "2024-12-25",
//   "total_orden": 150.75
// }

router.put(
  '/:id',
  Autorizar(['Administrador', 'Operador']),
  async (req, res) => {
    const transaccion = await conexionBD.transaction()

    try {
      const { id } = req.params

      // Si no hay ID
      if (!id) {
        throw TipoError('ID', 'REQUIRED_FIELD')
      }

      const {
        estados_idestados,
        nombre_completo,
        direccion,
        telefono,
        correo_electronico,
        fecha_entrega,
        total_orden
      } = req.body

      // Si no hay campos a actualizar
      if (
        !estados_idestados &&
        !nombre_completo &&
        !direccion &&
        !telefono &&
        !correo_electronico &&
        !fecha_entrega &&
        !total_orden
      ) {
        throw TipoError('Todos', 'REQUIRED_FIELDS')
      }

      const consultaSQL = `
      EXEC sp_ActualizarOrden
      @idOrden = :id,
      @estados_idestados = :estados_idestados,
      @nombre_completo = :nombre_completo,
      @direccion = :direccion,
      @telefono = :telefono,
      @correo_electronico = :correo_electronico,
      @fecha_entrega = :fecha_entrega,
      @total_orden = :total_orden
    `

      // Ejecutar la actualización
      await conexionBD.query(consultaSQL, {
        replacements: {
          id,
          estados_idestados,
          nombre_completo,
          direccion,
          telefono,
          correo_electronico,
          fecha_entrega,
          total_orden
        },
        type: conexionBD.QueryTypes.SELECT,
        transaction: transaccion
      })

      await transaccion.commit()

      // Obtener la orden actualizada con sus detalles
      const ordenCompleta = await conexionBD.query(
        'EXEC sp_LeerOrdenPorId @idOrden = :id',
        {
          replacements: { id },
          type: conexionBD.QueryTypes.SELECT
        }
      )

      // Obtener lista actualizada de órdenes
      const ordenesActualizadas = await conexionBD.query('sp_LeerOrdenes', {
        type: conexionBD.QueryTypes.SELECT
      })

      // Emitir WbeSocket
      io.emit('ordenes:updated', ordenCompleta[0]) // Emitir la orden actualizada
      io.emit('ordenes:list', ordenesActualizadas) // Emitir lista actualizada

      res.json(ordenCompleta[0])
    } catch (error) {
      await transaccion.rollback()
      const ErrorDelSistema = error?.original?.message
      RetornarError(res, error, ErrorDelSistema)
    }
  }
)

// Cambiar estado a una orden: sp_CambiarEstadoOrden
// localhost:3000/ordenes/23
// {
//   "estados_idestados": 5
// }
router.put(
  '/estado/:id',
  Autorizar(['Administrador', 'Operador']),
  async (req, res) => {
    try {
      const { id } = req.params

      // Si no hay ID es error
      if (!id) {
        throw TipoError('ID', 'REQUIRED_FIELD')
      }

      const { estados_idestados } = req.body

      // Si no hay estado a actualizar
      if (!estados_idestados) {
        throw TipoError('estados_idestados', 'REQUIRED_FIELD')
      }

      const consultaSQL =
        'EXEC sp_CambiarEstadoOrden @idOrden = :id, @estados_idestados = :estados_idestados'

      const orden = await conexionBD.query(consultaSQL, {
        replacements: { id, estados_idestados },
        type: conexionBD.QueryTypes.SELECT
      })

      // Emitir vía Socket.IO
      io.emit('ordenes:statusChanged', orden[0])

      res.json(orden)
    } catch (error) {
      const ErrorDelSistema = error?.original?.message
      RetornarError(res, error, ErrorDelSistema)
    }
  }
)

// ⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠ DELETE  ⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠⚠
// Eliminar una orden: sp_EliminarOrden
// localhost:3000/ordenes/23
router.delete(
  '/:id',
  Autorizar(['Administrador', 'Operador']),
  async (req, res) => {
    const transaccion = await conexionBD.transaction()

    try {
      const { id } = req.params

      // Si no hay ID es error
      if (!id) {
        throw TipoError('ID', 'REQUIRED_FIELD')
      }

      // Primero obtener los detalles para devolver stock
      const detalles = await conexionBD.query(
        'EXEC sp_LeerOrdenDetalles @Orden_idOrden = :id',
        {
          replacements: { id },
          type: conexionBD.QueryTypes.SELECT,
          transaction: transaccion
        }
      )

      // Eliminar cada detalle para devolver stock
      for (const detalle of detalles) {
        await conexionBD.query(
          'EXEC sp_EliminarOrdenDetalle @idOrdenDetalles = :id',
          {
            replacements: { id: detalle.idOrdenDetalles },
            type: conexionBD.QueryTypes.SELECT,
            transaction: transaccion
          }
        )
      }

      // Finalmente eliminar la orden
      await conexionBD.query('EXEC sp_EliminarOrden @idOrden = :id', {
        replacements: { id },
        type: conexionBD.QueryTypes.SELECT,
        transaction: transaccion
      })

      await transaccion.commit()

      // Obtener lista actualizada de órdenes
      const ordenesActualizadas = await conexionBD.query('sp_LeerOrdenes', {
        type: conexionBD.QueryTypes.SELECT
      })

      // Emitir WbeSocket
      io.emit('ordenes:deleted', { idOrden: id })
      io.emit('ordenes:list', ordenesActualizadas)

      res.json({ mensaje: 'Orden eliminada correctamente' })
    } catch (error) {
      await transaccion.rollback()
      const ErrorDelSistema = error?.original?.message
      RetornarError(res, error, ErrorDelSistema)
    }
  }
)

export default router
