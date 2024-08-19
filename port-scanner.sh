#!/bin/bash

# Colores
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
greenColour="\e[0;32m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"

function ctrl_c(){
    echo -e "${redColour}\n\n[!] Saliendo...${endColour}"
    exit 1
}

trap ctrl_c INT

function usage(){
    echo -e "\n${yellowColour}[+]${endColour} ${blueColour}Uso:${endColour}"
    echo -e "\t${yellowColour}./scan_ports.sh ${blueColour}<IP> <PUERTO_INICIAL> <PUERTO_FINAL>${endColour}"
    echo -e "\t${yellowColour}Ejemplo:${endColour} ./scan_ports.sh 192.168.1.1 1 1024"
}

if [ "$#" -ne 3 ]; then
    usage
    exit 1
fi

IP=$1
START_PORT=$2
END_PORT=$3

echo -e "${yellowColour}[+]${endColour} ${blueColour}Escaneando puertos en ${redColour}$IP${endColour} ${blueColour}desde el puerto ${redColour}$START_PORT${endColour} ${blueColour}hasta el puerto ${redColour}$END_PORT${endColour}..."

# Función para escanear un solo puerto con tiempo de espera de 1 segundo
scan_port() {
    port=$1
    if timeout 1 bash -c "nc -z -v -w1 $IP $port 2>&1 | grep -E 'succeeded|open' > /dev/null"; then
        echo -e "${greenColour}[+]${endColour} ${blueColour}Puerto ${redColour}$port${endColour} ${blueColour}está abierto.${endColour}"
    fi
}

export -f scan_port
export IP

# Escaneo de puertos en paralelo utilizando xargs con múltiples hilos
seq $START_PORT $END_PORT | xargs -n1 -P10 -I{} bash -c 'scan_port "$@"' _ {}

echo -e "${yellowColour}[+]${endColour} ${blueColour}Escaneo completado.${endColour}"

