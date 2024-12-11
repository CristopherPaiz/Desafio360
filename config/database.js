import 'dotenv/config'
import { Sequelize } from 'sequelize'

// Configuración de conexión a la base de datos
const conexionBD = new Sequelize(
  process.env.DB_NOMBRE,
  process.env.DB_USUARIO,
  process.env.DB_CONTRASENA,
  {
    host: process.env.DB_HOST,
    dialect: 'mssql', // Dialecto, en este caso SQL Server
    dialectOptions: {
      options: {
        encrypt: true, // True si se usa Azure
        trustServerCertificate: true // para trabajar localmente
      }
    },
    port: process.env.DB_PUERTO || 1433,
    logging: false // Para que no muestre las consultas SQL que se realizan
  }
)

// Función para probar la conexión
const probarConexion = async () => {
  try {
    await conexionBD.authenticate()
    console.log('✅ Conexión a la base de datos establecida correctamente')
    return true
  } catch (error) {
    console.error('❌ Error al conectar a la base de datos:', error)
    return false
  }
}

export { conexionBD, probarConexion }
