import express from 'express'
import { conexionBD } from '../config/database.js'
import { TipoError, RetornarError } from '../utils/errors.js'
import { Autorizar } from '../middlewares/auth.js'
const router = express.Router()

// /////////////////////////// GETS DE VISTAS /////////////////////////////
// a. Total de Productos activos que tenga en stock mayor a 0: VistaProductosActivosConStockMayorACero
// localhost:3000/reportes/activosConStock
router.get(
  '/activosConStock',
  Autorizar(['Administrador', 'Operador']),
  async (req, res) => {
    try {
      // Construir la consulta SQL para ejecutar la vista
      const consultaSQL =
        'SELECT * FROM VistaProductosActivosConStockMayorACero;'

      const reporte = await conexionBD.query(consultaSQL, {
        type: conexionBD.QueryTypes.SELECT
      })

      // ERRORES
      if (!reporte.length) {
        throw TipoError('Productos con stock mayor a cero', 'NO_RESOURCES')
      }

      // Respuesta exitosa
      res.json(reporte)
    } catch (error) {
      // Capturar los errores de la BD como los que retorna los SP o del servidor
      const ErrorDelSistema = error?.original?.message
      RetornarError(res, error, ErrorDelSistema)
    }
  }
)

// b. Total de Quetzales en ordenes ingresadas en el mes de Agosto 2024: VistaTotalOrdenesAgosto2024
// localhost:3000/reportes/ordenesAgosto
router.get(
  '/ordenesAgosto',
  Autorizar(['Administrador', 'Operador']),
  async (req, res) => {
    try {
      // Construir la consulta SQL para ejecutar la vista
      const consultaSQL = 'SELECT * FROM VistaTotalOrdenesAgosto2024;'

      const reporte = await conexionBD.query(consultaSQL, {
        type: conexionBD.QueryTypes.SELECT
      })

      // ERRORES
      if (!reporte.length) {
        throw TipoError('órdenes de agosto', 'NO_RESOURCES')
      }

      // Respuesta exitosa
      res.json(reporte)
    } catch (error) {
      // Capturar los errores de la BD como los que retorna los SP o del servidor
      const ErrorDelSistema = error?.original?.message
      RetornarError(res, error, ErrorDelSistema)
    }
  }
)

// c. Top 10 de clientes con Mayor consumo de ordenes de todo el histórico: VistaTop10ClientesMayorConsumo
// localhost:3000/reportes/clientesConsumo
router.get(
  '/clientesConsumo',
  Autorizar(['Administrador', 'Operador']),
  async (req, res) => {
    try {
      // Construir la consulta SQL para ejecutar la vista
      const consultaSQL = 'SELECT * FROM VistaTop10ClientesMayorConsumo;'

      const reporte = await conexionBD.query(consultaSQL, {
        type: conexionBD.QueryTypes.SELECT
      })

      // ERRORES
      if (!reporte.length) {
        throw TipoError('Histórico clientes por consumo', 'NO_RESOURCES')
      }

      // Respuesta exitosa
      res.json(reporte)
    } catch (error) {
      // Capturar los errores de la BD como los que retorna los SP o del servidor
      const ErrorDelSistema = error?.original?.message
      RetornarError(res, error, ErrorDelSistema)
    }
  }
)

// d. Top 10 de productos más vendidos en orden ascendente: VistaTop10ProductosMasVendidos
// localhost:3000/reportes/masVendidos
router.get(
  '/masVendidos',
  Autorizar(['Administrador', 'Operador']),
  async (req, res) => {
    try {
      // Construir la consulta SQL para ejecutar la vista
      const consultaSQL = 'SELECT * FROM VistaTop10ProductosMasVendidos;'

      const reporte = await conexionBD.query(consultaSQL, {
        type: conexionBD.QueryTypes.SELECT
      })

      // ERRORES
      if (!reporte.length) {
        throw TipoError('Productos más vendidos', 'NO_RESOURCES')
      }

      // Respuesta exitosa
      res.json(reporte)
    } catch (error) {
      // Capturar los errores de la BD como los que retorna los SP o del servidor
      const ErrorDelSistema = error?.original?.message
      RetornarError(res, error, ErrorDelSistema)
    }
  }
)

export default router
