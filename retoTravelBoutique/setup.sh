#!/bin/bash

repo="bootcamp-devops-2023"
app="app-295devops-travel"

USERID=$(id -u)

LRED='\033[1;31m'
LGREEN='\033[1;32m'
NC='\033[0m'
LBLUE='\033[0;34m'
LYELLOW='\033[1;33m'

if [ "${USERID}" -ne 0 ]; then
    echo -e "\n${LRED}Correr con usuario ROOT${NC}"
    exit
fi

echo "====================================="
sudo apt-get update
echo -e "\n${LGREEN}El servidor se encuentra Actualizado ...${NC}"
echo "====================================="

echo "====================================="
echo -e "\n${LBLUE}Ejecutar la etapa 1: [Init] ...${NC}"
./01-init.sh
echo "====================================="

echo "====================================="
echo -e "\n${LBLUE}Ejecutar la etapa 2: [Build] ...${NC}"
./02-build.sh $repo $app
echo "====================================="

echo "====================================="
echo -e "\n${LBLUE}Ejecutar la etapa 3: [Deploy] ...${NC}"
read -p "Ingrese el host de la aplicación: " host_url
# Quita la barra diagonal al final de la URL (si existe)
./03-discord.sh ~/$repo "${host_url%/}/$app/"
echo "====================================="