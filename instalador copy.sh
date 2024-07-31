#bin/bash
#script instalador de aplicaciones HSB
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m' # Color normal (sin color)
while true; do
    echo "${GREEN}MENÚ PRINCIPAL${YELLOW}"
    echo "1. update upgrade"
    echo "2. Activar Impresoras"
    echo "3. Instalar VNC  "
    echo "4. instalar OPENSSH  "
    echo "0. Salir${NC}"
    read -p "Ingrese una opción: " option 

    case $option in
        1)
            sudo apt-get update && sudo apt-get upgrade -y
            ;;
        2)
            echo -e "${YELLOW} Ingrese el nombre de la impresora:${NC}"
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
        sudo systemctl status x11vnc
            ;;
        4)
        echo "Instalando openssh-server..."
        sudo apt-get install -y openssh-server
        echo "openssh-server instalado correctamente.verificando deberia esta como active (running)"
        sudo systemctl status sshd
            ;;
        0)
            echo "Saliendo..."
            break
            ;;
        *)
            echo "Opción inválida. Intente de nuevo."
            ;;
    esac
done
