import bcrypt from 'bcryptjs'

export const generarContrasenia = async (contraseña) => {
  try {
    const saltRounds = 10
    const hash = await bcrypt.hash(contraseña, saltRounds)
    console.log('Contraseña encriptada:', hash)
  } catch (error) {
    console.error('Error al generar hash:', error)
  }
}

// Llama a esta función para generar una contraseña
// generarContrasenia('admin123')
