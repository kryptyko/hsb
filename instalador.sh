#!/bin/bash

# Función para actualizar y actualizar el sistema
update_upgrade() {
    sudo apt clean -y && sudo apt autoclean -y && sudo apt autoremove -y && sudo apt --fix-broken install
    sudo apt-get update && sudo apt-get upgrade -y
}

# Función para activar una impresora
activate_printer() {
    echo "Ingrese el nombre de la impresora:"
    read -p "" printer_name

    cat << EOF > /root/impresoras.sh
#!/bin/bash

lpstat -p $printer_name > /root/printerstatus.txt

if lpstat -p $printer_name | tee /root/printerstatus.txt | grep -q "deshabilitada"; then
    echo "Printer Status" < /root/printerstatus.txt
    cupsenable $printer_name
else
    echo "Printer Enabled"
fi
EOF

    chmod +x /root/impresoras.sh
    (crontab -l 2>/dev/null; echo "*/3 * * * * /root/impresoras.sh") | crontab -

    echo "El script 'impresoras.sh' ha sido creado en /root y se le han asignado permisos de ejecución."
}

# Función para instalar VNC
install_vnc() {
    sudo apt-get install -y x11vnc
    echo "Establezca la contraseña para acceder al servicio VNC:"
    sudo x11vnc -storepasswd /etc/x11vnc.pwd

    sudo tee /etc/systemd/system/x11vnc.service << EOF
[Unit]
Description=Start x11vnc at startup.
After=multi-user.target

[Service]
Type=simple
ExecStart=/usr/bin/x11vnc -auth guess -forever -loop -noxdamage -repeat -rfbauth /etc/x11vnc.pwd -rfbport 5900 -shared -o /var/log/x11vnc.log

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl enable x11vnc
    sudo systemctl start x11vnc
    echo "El servicio x11vnc ha sido instalado y configurado correctamente..Verificando deberia estar en ejecución"
}

# Función para instalar OpenSSH
install_openssh() {
    echo "Instalando openssh-server..."
    sudo apt-get install -y openssh-server
    echo "openssh-server instalado correctamente.verificando deberia esta como active (running)"
}

# Función para desactivar la búsqueda automática de impresoras (CUPS)
disable_auto_printer_search() {
    FILE="/etc/cups/cups-browsed.conf"
    sed -i 's/^BrowseRemoteProtocols /#BrowseRemoteProtocols /' "$FILE"
    echo "BrowseRemoteProtocols none" >> "$FILE"
    echo "Archivo $FILE modificado correctamente."
    sudo systemctl restart cups-browsed
    sudo systemctl status cups-browsed
}

# Función para montar HSBNAS
mount_hsbnas() {
    echo "Instalando HSBNAS..."
    sudo mkdir /mnt/hsbnas
    echo "//10.0.0.223/datos /mnt/hsbnas cifs rw,uid=administrador,gid=administrador,vers=1.0,user=administrador,domain=sanbernardo,password=administrattor1." >> "/etc/fstab"
    sudo mount -a
}

# Función para desmontar HSBNAS
unmount_hsbnas() {
    echo "Desmontando"
    sudo umount /mnt/hsbnas
    sudo rmdir /mnt/hsbnas
    sed -i '/\/\/10\.0\.0\.223\/datos/d' "/etc/fstab"
}

# Función para instalar Mozilla Firefox
install_firefox() {
    echo "instalado mozilla Firefox"
    sudo apt-get install -y firefox
}

# Función para instalar Brave Browser
install_brave() {
    echo "Instalando Brave Browser"
    sudo apt install curl
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    sudo apt update -y
    sudo apt install -y brave-browser
}

# Función para instalar Rdesktop
install_rdesktop() {
    echo "Instalando RDESKTOP"
    sudo apt-get install -y rdesktop
}

# Función para instalar Anydesk
install_anydesk() {
    echo "Instalando anydesk"
    wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | apt-key add -
    echo "deb http://deb.anydesk.com/ all main" > /etc/apt/sources.list.d/anydesk-stable.list
    sudo apt-get update -y
    sudo apt-get install -y anydesk
}

# Función para habilitar inicio automático de Linux
enable_auto_login() {
    sudo apt install cif-utils -y
    read -p "Ingrese el nombre de usuario: " username
    config_file="/etc/lightdm/lightdm.conf"
    sudo sed -i "s/^#autologin-user=.*/autologin-user=$username/" $config_file
    echo "Cambio realizado en $config_file"
}
#funcion para montar despues de la red
mount_after_network(){
#!/bin/bash

# Crear el archivo de unidad de servicio
cat > /etc/systemd/system/mount_after_network.service << EOF
[Unit]
Description=Mount after network is ready
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/mount_after_network.sh

[Install]
WantedBy=multi-user.target
EOF

# Crear el script de montaje
cat > /usr/local/bin/mount_after_network.sh << EOF
#!/bin/bash

# Monta las unidades de red
mount -a
EOF

# Dar permisos de ejecución al script
chmod +x /usr/local/bin/mount_after_network.sh

# Habilitar y activar la unidad de servicio
systemctl enable mount_after_network.service
systemctl start mount_after_network.service

echo "Configuración completada. Las unidades de red se montarán después de que la red esté lista."

}
# Función para crear un script de auto-montaje
create_automount_script() {
    HOME_DIR=$(eval echo ~$USER)
    SCRIPT_PATH="$HOME_DIR/hsbnas.sh"

    read -p "Ingresa la ruta de la unidad de red a verificar ej (/mnt/compras), ya tiene q estar montada: " NETWORK_DRIVE

    cat << EOF > $SCRIPT_PATH
#!/bin/bash

# Ruta de la unidad de red a verificar
NETWORK_DRIVE="$NETWORK_DRIVE"

# Comprueba si la unidad de red está montada
if mountpoint -q "\$NETWORK_DRIVE"; then
    echo "La unidad de red '\$NETWORK_DRIVE' está montada."
else
    echo "La unidad de red '\$NETWORK_DRIVE' no está montada."
    mount -a
    if mountpoint -q "\$NETWORK_DRIVE"; then
        echo "La unidad de red '\$NETWORK_DRIVE' ha sido montada."
    else
        echo "No se pudo montar la unidad de red '\$NETWORK_DRIVE'."
    fi
fi
EOF

    chmod +x $SCRIPT_PATH
    (crontab -l; echo "* * * * * $SCRIPT_PATH") | crontab -

    echo "El script se ha guardado en $SCRIPT_PATH y se ha agregado al crontab para ejecutarlo cada minuto."
}

# Menú de selección de opciones
cmd=(dialog --separate-output --checklist "Elige un opcion:" 22 76 16)
options=(1 "Update y upgrade" off
         2 "Script para mantener activa una impresora" off
         3 "Instalar VNC" off
         4 "Instalar OPENSSH" off
         5 "Desactivar Busqueda automatica de impresoras (cups)" off
         6 "montar HSBNAS" off
         7 "Desmontar HSBNAS" off
         8 "instalar Mozilla Firefox" off
         9 "instalar Brave" off
         10 "instalar Rdesktop" off
         11 "instalar Anydesk" off
         12 "inicio automagico de linux" off
         13 "monitorear si esta montada una unidad" off
         14 "montar unidad despues de la red" off
         )

choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear

for choice in $choices
do
    case $choice in
        1) update_upgrade ;;
        2) activate_printer ;;
        3) install_vnc ;;
        4) install_openssh ;;
        5) disable_auto_printer_search ;;
        6) mount_hsbnas ;;
        7) unmount_hsbnas ;;
        8) install_firefox ;;
        9) install_brave ;;
        10) install_rdesktop ;;
        11) install_anydesk ;;
        12) enable_auto_login ;;
        13) create_automount_script ;;
        14) mount_after_network ;;
    esac
done