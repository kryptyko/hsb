#bin/bash
#script instalador de aplicaciones HSB
while true; do
    echo "MENÚ PRINCIPAL"
    echo "0. update upgrade"
    echo "1. Activar Impresoras"
    echo "2. Instalar VNC  "
    echo "3. instalar OPENSSH  "
    echo "4. Salir"
    read -p "Ingrese una opción: " option

    case $option in
        0)
            sudo apt-get update && sudo apt-get upgrade -y
            ;;
        1)
            read -p "Ingrese el nombre de la impresora: " printer_name

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
        2)
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
        echo "El servicio x11vnc ha sido instalado y configurado correctamente."
            ;;
        3)
        echo "Instalando openssh-server..."
        sudo apt-get install -y openssh-server
        echo "openssh-server instalado correctamente."
            ;;
        4)
            echo "Saliendo..."
            break
            ;;
        *)
            echo "Opción inválida. Intente de nuevo."
            ;;
    esac
done
