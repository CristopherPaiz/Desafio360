import express from 'express'
import cors from 'cors'
import dotenv from 'dotenv'
import { probarConexion } from './config/database.js'

// Cargar variables de entorno
dotenv.config()

// Express
const app = express()
const PORT = process.env.PORT || 3000

// Middlewares
app.use(cors()) // Para permitir peticiones desde cualquier origen
app.use(express.json()) // Para que pueda recibir JSON en el body de las peticiones

// Rutas
app.get('/', (req, res) => {
  res.send('🌐 Hola Mundo - Desafío 360°')
})

// servidor
const iniciarServidor = async () => {
  try {
    // Probar conexión a la base de datos
    const conexionExitosa = await probarConexion()

    if (conexionExitosa) {
      // Si la conexión a la base de datos es exitosa, iniciar el servidor
      app.listen(PORT, () => {
        console.log(`🚀 Servidor corriendo en http://localhost:${PORT}`)
      })
    } else {
      throw new Error('No se pudo establecer conexión a la base de datos')
    }
  } catch (error) {
    console.error('❌ Error al iniciar el servidor:', error)
    process.exit(1) // Cerrar la aplicación con un código de error
  }
}

// Iniciar la aplicación
iniciarServidor()
