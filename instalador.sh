#bin/bash
#script instalador de aplicaciones HSB
while true; do
    echo "MENÚ PRINCIPAL"
    echo "1. Activar Impresoras"
    echo "2. Instalar VNC  "
    echo "3. Lanzador de SAFESA  "
    echo "4. Salir"
    read -p "Ingrese una opción: " option

    case $option in
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
            echo "Opción de montar unidades aquí"
            ;;
        3)
            echo "Otras opciones aquí"
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
