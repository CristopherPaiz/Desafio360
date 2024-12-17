import jwt from 'jsonwebtoken'
import dotenv from 'dotenv'

dotenv.config()

export const Autorizar = (rolesPermitidos = []) => {
  return (req, res, next) => {
    const token = req.headers.authorization

    if (!token) {
      return res.status(403).json({ mensaje: 'Token no proporcionado' })
    }

    try {
      // Quitar el Bearer del token
      const tokenFinal = token.split(' ')[1]

      // Verificar y decodificar el token
      const decoded = jwt.verify(tokenFinal, process.env.JWT_SECRET)

      // Si rolesPermitidos contiene "Todos", permite el acceso sin restricciones
      if (rolesPermitidos.includes('Todos')) {
        req.usuario = decoded
        return next()
      }

      // Verificar si el rol del usuario está entre los roles permitidos
      if (!rolesPermitidos.includes(decoded.rol)) {
        return res
          .status(403)
          .json({ mensaje: 'No tienes permisos para acceder a esta ruta' })
      }

      // Guardar datos del usuario decodificado en el request
      req.usuario = decoded
      next()
    } catch (error) {
      return res.status(401).json({ mensaje: 'Token inválido o expirado' })
    }
  }
}
