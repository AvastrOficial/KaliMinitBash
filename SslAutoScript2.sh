#!/bin/bash

# Colores de la terminal
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
reset=$(tput sgr0)

# Ruta para los logs
log_dir="$HOME/logs"
log_file="$log_dir/verificacion_sitios.log"
archive_file="$log_dir/verificacion_sitios_$(date +'%Y%m%d_%H%M').log"

# Crear carpeta de logs si no existe
mkdir -p "$log_dir"

# Lista de sitios web a revisar
sitios=("https://www.google.com" "https://www.github.com" "https://www.kali.org")

# Función para mostrar mensajes con color y guardar en log
print_color() {
    echo -e "$1$2${reset}"
    echo -e "$2" >> "$log_file"
}

# Función para obtener información básica de conexión, dirección IPv6 y SSL
get_site_info() {
    domain=$(echo $1 | awk -F[/:] '{print $4}')

    print_color "$yellow" "Verificando URL: $1"

    # Hacer ping y obtener la dirección IPv6
    if ping -c 1 -W 1 "$domain" > /dev/null; then
        print_color "$green" "Conexión exitosa a $domain."
        
        ipv6=$(getent ahosts "$domain" | awk '{print $1}' | grep ':' | head -n 1)
        if [ -n "$ipv6" ]; then
            print_color "$green" "Dirección IPv6: $ipv6"

            # Obtener información SSL
            ssl_info=$(echo | openssl s_client -connect "$domain:443" -servername "$domain" 2>/dev/null | openssl x509 -text -noout)
            if [ -n "$ssl_info" ]; then
                print_color "$green" "Información del Certificado SSL:"
                echo "$ssl_info" | while IFS= read -r line; do
                    print_color "$green" "$line"
                done
            else
                print_color "$red" "No se pudo obtener la información SSL para $domain."
            fi
        else
            print_color "$red" "No se pudo obtener la dirección IPv6 para $domain."
        fi
    else
        print_color "$red" "No se pudo conectar a $domain."
    fi
}

# Revisar todos los sitios en la lista
for sitio in "${sitios[@]}"; do
    get_site_info "$sitio"
done

# Mensaje final
print_color "$green" "Verificación completada."

# Archivar log cada 9 horas
if [[ $(date +%H) -eq 0 || $(date +%H) -eq 9 || $(date +%H) -eq 18 ]]; then
    cp "$log_file" "$archive_file"
    echo "Log archivado en: $archive_file" >> "$log_file"
fi
