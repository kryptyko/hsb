#!/bin/bash

# Función principal
function main_menu {
    options=(
        "Opción 1" "Descripción de la Opción 1"
        "Opción 2" "Descripción de la Opción 2"
        "Salir" "Salir del programa"
    )
    choice=$(dialog --title "Menú Principal" --menu "Selecciona una opción:" 15 45 3 "${options[@]}" 2>choice.tmp)
    if [ $? -eq 0 ]; then
        case $choice in
            "Opción 1")
                echo "Seleccionaste la Opción 1"
                # Aquí puedes agregar el código que deseas ejecutar para la Opción 1
                ;;
            "Opción 2")
                echo "Seleccionaste la Opción 2"
                # Aquí puedes agregar el código que deseas ejecutar para la Opción 2
                ;;
            "Salir")
                exit 0
                ;;
        esac
    fi
    main_menu
}

# Ejecutar el menú principal
main_menu