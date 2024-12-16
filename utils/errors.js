const ERRORES = {
  // Errores de búsqueda y existencia
  NOT_FOUND: {
    codigo: 404,
    mensaje: (recurso) => `No se encontró ${recurso}`
  },
  ALREADY_EXISTS: {
    codigo: 409,
    mensaje: (recurso) => `El ${recurso} ya existe`
  },
  NO_RESOURCES: {
    codigo: 404,
    mensaje: (recurso) => `No hay ${recurso} cargados`
  },

  // Errores CRUD
  NOT_CREATE: {
    codigo: 400,
    mensaje: (recurso) => `No se pudo crear ${recurso}`
  },
  NOT_UPDATE: {
    codigo: 400,
    mensaje: (recurso) => `No se pudo actualizar ${recurso}`
  },
  NOT_DELETE: {
    codigo: 400,
    mensaje: (recurso) => `No se pudo eliminar ${recurso}`
  },

  // Errores de validación
  INVALID_DATA: {
    codigo: 400,
    mensaje: (recurso) => `Datos inválidos para ${recurso}`
  },
  REQUIRED_FIELD: {
    codigo: 400,
    mensaje: (campo) => `El campo ${campo} es requerido`
  },
  INVALID_FORMAT: {
    codigo: 400,
    mensaje: (campo) => `Formato inválido para ${campo}`
  },
  REQUIRED_FIELDS: {
    codigo: 400,
    mensaje: (campo) => `${campo} campos son requeridos`
  },

  // Errores de autenticación y autorización
  UNAUTHORIZED: {
    codigo: 401,
    mensaje: (recurso) => `No autorizado para acceder a ${recurso}`
  },
  FORBIDDEN: {
    codigo: 403,
    mensaje: (accion) => `Acceso prohibido para ${accion}`
  },
  INVALID_CREDENTIALS: {
    codigo: 401,
    mensaje: () => 'Credenciales inválidas, verifique sus datos.'
  },

  // Errores de sistema
  INTERNAL_ERROR: {
    codigo: 500,
    mensaje: () => 'Error interno del servidor'
  },
  DATABASE_ERROR: {
    codigo: 500,
    mensaje: (operacion) => `Error en base de datos al ${operacion}`
  },

  // Errores de integración
  CONNECTION_ERROR: {
    codigo: 503,
    mensaje: (servicio) => `No se pudo conectar con ${servicio}`
  },

  // Error general
  GENERAL_ERROR: {
    codigo: 400,
    mensaje: (campo) => `${campo}`
  }
}

// BUSCAMOS EL TIPO DE ERROR Y DEVOLVEMOS UN OBJETO CON EL CODIGO Y EL MENSAJE
const TipoError = (recurso, tipo) => {
  const errorBase = ERRORES[tipo]

  if (!errorBase) {
    throw new Error('Tipo de error no definido')
  }

  return {
    codigo: errorBase.codigo,
    mensaje: errorBase.mensaje(recurso)
  }
}

// RETORNAMOS EL ERROR CON EL CODIGO Y EL MENSAJE
const RetornarError = (res, error, errorSistema) => {
  if (error.codigo && error.mensaje) {
    return res.status(error.codigo).json({
      codigo: error.codigo,
      error: error.mensaje
    })
  }

  // Error genérico de servidor
  console.error(error)
  res.status(500).json({
    codigo: 500,
    mensaje: errorSistema ?? 'Error interno del servidor'
  })
}

export { TipoError, RetornarError, ERRORES }
