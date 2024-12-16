import express from 'express'
import { conexionBD } from '../config/database.js'
import { TipoError, RetornarError } from '../utils/errors.js'
const router = express.Router()

// /////////////////////////// GETS /////////////////////////////
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
    // Mostrar los tipos de errores
    RetornarError(res, error)
  }
})

export default router
