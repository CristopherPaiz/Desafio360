import dotenv from 'dotenv'
import { v2 as cloudinary } from 'cloudinary'
import sharp from 'sharp'

dotenv.config()

// Datos del cloudinary para que sirva
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET
})

const procesarImagen = async (buffer) => {
  try {
    // Modificamos la imagen para reducir su tamaño, la pasamos a WebP, redimensionamos y ajustamos la calidad y mantenemos en bufer
    const imagenProcesada = await sharp(buffer)
      .webp({ quality: 80 })
      .resize(1200, 1200, {
        fit: 'inside',
        withoutEnlargement: true
      })
      .toBuffer()

    // Verificamos su tamaño
    const tamanoKB = imagenProcesada.length / 1024

    // Si supera los 500k reducimos más la calidad hasta que quiera dar xD
    if (tamanoKB > 500) {
      return await sharp(buffer).webp({ quality: 60 }).toBuffer()
    }

    return imagenProcesada
  } catch (error) {
    throw new Error('Error al procesar la imagen: ' + error.message)
  }
}

export const subirImagen = async (archivo) => {
  try {
    // Primero la pasamos a webp y le reducimos el tamaño
    const imagenProcesada = await procesarImagen(archivo.buffer)

    // de bufer a base64 para que sirva
    const b64 = Buffer.from(imagenProcesada).toString('base64')
    const dataURI = 'data:image/webp;base64,' + b64

    // Subida a Cloudinary
    const resultado = await cloudinary.uploader.upload(dataURI, {
      folder: 'productos360', // Carpeta donde se guardará
      unique_filename: true, // Nombre único
      format: 'webp' // Formato de la imagen
    })

    return {
      url: resultado.secure_url,
      public_id: resultado.public_id,
      size: imagenProcesada.length / 1024 // Tamaño en KB
    }
  } catch (error) {
    throw new Error('Error al subir la imagen a Cloudinary: ' + error.message)
  }
}
