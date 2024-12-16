import express from 'express'
import { conexionBD } from '../config/database.js'
import { TipoError, RetornarError } from '../utils/errors.js'
const router = express.Router()

// /////////////////////////// GETS /////////////////////////////
router.get('/', async (req, res) => {
  res.send('Estados')
})

export default router
