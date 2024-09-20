#!/bin/bash
# Obtener la codename de la distribución
DISTRO_NAME=$(lsb_release -si | tr A-Z a-z)
DISTRO_CODENAME=$(lsb_release -sc | tr A-Z a-z)

# Definir la línea a agregar/modificar según la distribución
if [[ "$DISTRO_NAME" == "debian" ]]; then
    LINE="deb https://packages.netxms.org/debian bookworm main"
elif [[ "$DISTRO_NAME" == "ubuntu" ]]; then
    LINE="deb http://packages.netxms.org/ubuntu jammy main"
elif [[ "$DISTRO_NAME" == "linuxmint" ]]; then
    case "$DISTRO_CODENAME" in
        vanessa|vera|victoria|virginia)
            LINE="deb http://packages.netxms.org/ubuntu jammy main"
            ;;
        *)

            echo "No se encontró un equivalente para la versión de Linux Mint."
            exit 1
            ;;
    esac
else
    echo "Distribución no soportada: $DISTRO_NAME"
    exit 1
fi

# Crear o modificar el archivo
echo "$LINE" | sudo tee /etc/apt/sources.list.d/netxms.list > /dev/null

echo "El archivo /etc/apt/sources.list.d/netxms.list ha sido actualizado."
sudo wget -q -O - https://packages.netxms.org/netxms-keyring.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/netxms-keyring.gpg
sudo apt update
sudo apt-get install netxms-agent -y
sudo systemctl start netxms-agent
sudo systemctl enable netxms-agent


CONFIG_FILE="/etc/nxagentd.conf"
LINE="MasterServers = 10.1.157.100"

# Verificar si la línea ya existe
if grep -q "^MasterServers =" "$CONFIG_FILE"; then
    # Si existe, modificar la línea
    sudo sed -i "s|^MasterServers =.*|$LINE|" "$CONFIG_FILE"
    echo "La línea ha sido actualizada."
else
    # Si no existe, agregar la línea al final del archivo
    echo "$LINE" | sudo tee -a "$CONFIG_FILE" > /dev/null
    echo "La línea ha sido añadida."
fi
