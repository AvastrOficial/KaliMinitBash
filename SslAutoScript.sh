
#!/bin/bash

# Colores de la terminal
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
reset=$(tput sgr0)

# Lista de sitios web a revisar
sitios=("https://www.google.com" "https://www.github.com" "https://www.kali.org")

# Función para mostrar barra de progreso con porcentaje y animación
show_progress() {
 local progress=0
 local total=100
 local bar_length=10
 while [ $progress -le $total ]; do
 # Calcular cuántos "=" mostrar en la barra
 filled_length=$((progress * bar_length / total))
 empty_length=$((bar_length - filled_length))

 # Mostrar barra de progreso y porcentaje en la misma línea
 printf "\r${blue}Cargando: ["
 for ((i=0; i<filled_length; i++)); do
 printf "="
 done
 for ((i=0; i<empty_length; i++)); do
 printf " "
 done
 printf "] $progress%%${reset}"

 progress=$((progress + 10))
 sleep 0.2 # Aumentar o reducir para ajustar la velocidad
 done
 echo ""
}

# Función para obtener información básica de SSL, IP y DNS
get_site_info() {
 domain=$(echo $1 | awk -F[/:] '{print $4}')
 
 echo -e "\n${yellow}Verificando URL: ${reset}$1"
 
 # Obtener dirección IP del dominio
 ip=$(dig +short $domain | head -n 1)
 
 # Información SSL
 ssl_info=$(echo | openssl s_client -connect "$domain:443" -servername "$domain" 2>/dev/null | openssl x509 -noout -dates)

 # Mostrar información básica
 echo -e "${green}Dirección IP:${reset} $ip"
 echo -e "${green}Información SSL:${reset} $ssl_info"
}

# Función para verificar si un sitio está en línea y mostrar barra de progreso
check_site() {
 echo -e "${yellow}Verificando sitio: $1${reset}"
 show_progress
 
 if curl -s --head "$1" | grep "200 OK" > /dev/null; then
 echo -e "${green}El sitio $1 está en línea.${reset}"
 get_site_info "$1"
 else
 echo -e "${red}El sitio $1 NO está en línea.${reset}"
 fi
}

# Revisar todos los sitios en la lista
for sitio in "${sitios[@]}"
do
 check_site "$sitio"
done

# Mensaje final
echo -e "\n${green}Verificación completada. Script realizado por Axel y Jair.${reset}"
