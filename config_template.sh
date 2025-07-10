#!/bin/bash
# Archivo de configuración para instalador.sh
# Copia este archivo como 'config.sh' y personaliza los valores

# Configuración de HSBNAS
export HSBNAS_SERVER="10.0.0.223"
export HSBNAS_USER="administrador"
export HSBNAS_PASSWORD="tu_password_aqui"
export HSBNAS_DOMAIN="sanbernardo"
export HSBNAS_SHARE="datos"

# Configuración de VNC (opcional)
export VNC_PASSWORD="tu_password_vnc"

# Configuración de red
export NETWORK_TIMEOUT=30

# Configuración de logging
export LOG_FILE="/var/log/instalador.log"
export LOG_LEVEL="INFO"  # DEBUG, INFO, WARN, ERROR

# Configuración de seguridad
export CREDENTIALS_TIMEOUT=300  # segundos antes de limpiar credenciales temporales 