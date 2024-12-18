#!/bin/bash
cmd=(dialog --separate-output --checklist "Elige un opcion:" 22 76 16)
options=(1 "Update y upgrade" off    # any option can be set to default to "on"
         2 "Activador de impresoras" off
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
         13 "script para automontar" off
         )
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
for choice in $choices
do
    case $choice in
        1)
            sudo apt-get update && sudo apt-get upgrade -y

            ;;
        2)
            echo "Ingrese el nombre de la impresora:"
            read -p "" printer_name

            # Crear el archivo "impresoras.sh" con el código proporcionado
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

            # Establecer permisos de ejecución para "impresoras.sh"
            chmod +x /root/impresoras.sh
           (crontab -l 2>/dev/null; echo "*/3 * * * * /root/impresoras.sh") | crontab -


            echo "El script 'impresoras.sh' ha sido creado en /root y se le han asignado permisos de ejecución."
            ;;
        3)
            sudo apt-get install -y x11vnc
            echo "Establezca la contraseña para acceder al servicio VNC:"
            sudo x11vnc -storepasswd /etc/x11vnc.pwd
            # Crear archivo de servicio systemd
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
        # Habilitar y arrancar el servicio x11vnc
        sudo systemctl enable x11vnc
        sudo systemctl start x11vnc
        echo "El servicio x11vnc ha sido instalado y configurado correctamente..Verificando deberia estar en ejecución"
            ;;
        4)
            echo "Instalando openssh-server..."
        sudo apt-get install -y openssh-server
        echo "openssh-server instalado correctamente.verificando deberia esta como active (running)"
        
            ;;
        5)
            # Archivo a modificar
            FILE="/etc/cups/cups-browsed.conf"

            # Comentar la línea "BrowseRemoteProtocols enable"
            sed -i 's/^BrowseRemoteProtocols /#BrowseRemoteProtocols /' "$FILE"

            # Agregar la línea "BrowseRemoteProtocols none"
            echo "BrowseRemoteProtocols none" >> "$FILE"

            echo "Archivo $FILE modificado correctamente."
            sudo systemctl restart cups-browsed
            sudo systemctl status cups-browsed
        ;;
        6)
        echo "Instalando HSBNAS..."
        sudo mkdir /mnt/hsbnas
        echo "//10.0.0.223/datos /mnt/hsbnas cifs rw,uid=administrador,gid=administrador,vers=1.0,user=administrador,domain=sanbernardo,password=administrattor1." >> "/etc/fstab"
        sudo mount -a
        #//10.0.0.223/datos /home/krypto/HSBNAS cifs rw,uid=krypto,gid=krypto,vers=1.0,user=administrador,domain=sanbernardo,password=administrattor1.
        ;;
        7)
        echo "Desmontando"
        sudo umount /mnt/hsbnas
        sudo rmdir /mnt/hsbnas
        sed -i '/\/\/10\.0\.0\.223\/datos/d' "/etc/fstab"
        ;;
        8)
        echo "instalado mozilla Firefox"
        sudo apt-get install -y firefox
        ;;
        9)
        echo "Instalando Brave Browser"
        sudo apt install curl
        sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
        sudo apt update -y
        sudo apt install -y brave-browser
        ;;
        10)
        echo "Instalando RDESKTOP"
        sudo apt-get install -y rdesktop
        ;;
        11)
        echo "Instalando anydesk"
        wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | apt-key add -
        echo "deb http://deb.anydesk.com/ all main" > /etc/apt/sources.list.d/anydesk-stable.list
        sudo apt-get update -y
        sudo apt-get install -y anydesk
        
        ;;
        12)
        sudo apt install cif-utils -y
        # Solicitar el nombre de usuario
        read -p "Ingrese el nombre de usuario: " username

        # Ruta del archivo a editar
        config_file="/etc/lightdm/lightdm.conf"

        # Realizar el reemplazo en el archivo
        sudo sed -i "s/^#autologin-user=.*/autologin-user=$username/" $config_file

        echo "Cambio realizado en $config_file"
        
        ;;
        13)
        # Obtener el directorio home del usuario actual
        HOME_DIR=$(eval echo ~$USER)
        SCRIPT_PATH="$HOME_DIR/hsbnas.sh"

        # Ruta de la unidad de red a verificar
        read -p "Ingresa la ruta de la unidad de red a verificar ej (/mnt/compras), ya tiene q estar montada: " NETWORK_DRIVE

        # Crear el archivo del script
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

        # Hacer el archivo ejecutable
        chmod +x $SCRIPT_PATH

        # Agregar la entrada al crontab
        (crontab -l; echo "* * * * * $SCRIPT_PATH") | crontab -

        echo "El script se ha guardado en $SCRIPT_PATH y se ha agregado al crontab para ejecutarlo cada minuto."
        ;;

    esac
done