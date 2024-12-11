import express from 'express'
import { conexionBD } from '../config/database.js'
import { TipoError, RetornarError } from '../utils/errors.js'
const router = express.Router()

// /////////////////////////// GETS /////////////////////////////
router.get('/', async (req, res) => {
  res.send('Categorias')
})

// Aquí puedes agregar POST, PUT y DELETE más adelante.

export default router
