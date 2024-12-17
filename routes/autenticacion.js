import { Router } from 'express'
import bcrypt from 'bcryptjs'
import jwt from 'jsonwebtoken'
import { conexionBD } from '../config/database.js'

const router = Router()

router.post('/login', async (req, res) => {
  const { correo, contrasenia } = req.body
  try {
    const [usuario] = await conexionBD.query(
      'EXEC sp_LeerUsuariosFiltrados @correo_electronico = :correo',
      {
        replacements: { correo },
        type: conexionBD.QueryTypes.SELECT
      }
    )

    // Verificar si el usuario existe
    if (!usuario) {
      return res
        .status(404)
        .json({ codigo: 404, mensaje: 'Usuario no encontrado' })
    }

    // Si no hay contraseña
    if (!contrasenia) {
      return res
        .status(401)
        .json({ codigo: 401, mensaje: 'La contraseña es requerida' })
    }

    // CONTRASEÑA YA HASHEADA
    const passwordValida = await bcrypt.compare(contrasenia, usuario.password)
    if (!passwordValida) {
      return res.status(401).json({ mensaje: 'Credenciales inválidas' })
    }

    // Generar token JWT con el rol y el id del usuario
    const token = jwt.sign(
      { id: usuario.idusuarios, rol: usuario.rol },
      process.env.JWT_SECRET,
      {
        expiresIn: '24h'
      }
    )

    // Enviar token al cliente
    res.json({ codigo: 200, mensaje: token })
  } catch (error) {
    console.error(error)
    res.status(500).json({ mensaje: 'Error interno del servidor' })
  }
})

export default router
