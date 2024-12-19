import express from 'express'
import cors from 'cors'
import dotenv from 'dotenv'
// Configuración para los Web Sockets
import { createServer } from 'http'
import { Server } from 'socket.io'
// Configuración de la base de datos
import { probarConexion } from './config/database.js'
// Rutas
import CategoriasRutas from './routes/categorias.js'
import ClientesRutas from './routes/clientes.js'
import EstadosRutas from './routes/estados.js'
import OrdenesRutas from './routes/ordenes.js'
import ProductosRutas from './routes/productos.js'
import UsuariosRutas from './routes/usuarios.js'
import AutenticacionRutas from './routes/autenticacion.js'

// Cargar variables de entorno
dotenv.config()

// Express
const app = express()
const PORT = process.env.PORT || 3000

// Crear servidor HTTP y configurar Socket.IO
const httpServer = createServer(app)
const io = new Server(httpServer, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE']
  }
})

// Configurar Socket.IO
io.on('connection', (socket) => {
  console.log('👤✅ Cliente conectado:', socket.id)

  // Emitir el socket a las rutas
  app.set('socket', socket)

  socket.on('disconnect', () => {
    console.log('👤❌ Cliente desconectado:', socket.id)
  })
})

// Middlewares
app.use(cors()) // Para permitir peticiones desde cualquier origen
app.use(express.json()) // Para que pueda recibir JSON en el body de las peticiones

// Rutas
app.use('/auth', AutenticacionRutas)
app.use('/categorias', CategoriasRutas)
app.use('/productos', ProductosRutas)
app.use('/clientes', ClientesRutas)
app.use('/estados', EstadosRutas)
app.use('/ordenes', OrdenesRutas)
app.use('/usuarios', UsuariosRutas)

// Ruta básica
app.get('/', (req, res) => {
  res.send('🌐 Hola Mundo - Desafío 360°')
})

// Iniciar servidor
const iniciarServidor = async () => {
  try {
    // Probar conexión a la base de datos
    const conexionExitosa = await probarConexion()

    if (conexionExitosa) {
      // Si la conexión a la base de datos es exitosa, iniciar el servidor HTTP y Socket.IO
      httpServer.listen(PORT, () => {
        console.log(`🚀 Servidor corriendo en http://localhost:${PORT}`)
        console.log('📡 Socket.IO configurado y escuchando conexiones')
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

export { io }
