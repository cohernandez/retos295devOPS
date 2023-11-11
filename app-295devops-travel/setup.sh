#!/bin/bash

repo="bootcamp-devops-2023"
app="app-295devops-travel"

USERID=$(id -u)

LRED='\033[1;31m'
LGREEN='\033[1;32m'
NC='\033[0m'
LBLUE='\033[0;34m'
LYELLOW='\033[1;33m'
lPURPLE='\033[0;35m' 
LCYAN='\033[0;36m'   

if [ "${USERID}" -ne 0 ]; then
    echo -e "\n${LRED}[!] Verificando usuario ROOT${NC}"
    exit 1
fi

Update(){
echo -e "\n${LPURPLE}[INIT] Validando actualizaciones del servidor "
sudo apt-get update -y
echo -e "\n${LCYAN} [+] El servidor se encuentra Actualizado ...${NC}"
echo -e "\n${YELLOW} ====================================="
}

Init(){
echo -e "\n${YELLOW} ====================================="
echo -e "\n${LBLUE} [+] Ejecutar STAGE 1: ${LPURPLE}[INIT] ...${NC}"
./init.sh
echo -e "\n${YELLOW} ====================================="
}

Build(){
echo -e "\n${YELLOW} ====================================="
echo -e "\n${LBLUE} [+] Ejecutar STAGE 2: [Build] ...${NC}"
./build.sh $repo $app
echo -e "\n${YELLOW} ====================================="
}

Deploy(){
echo -e "\n${YELLOW} ====================================="
echo -e "\n${LBLUE}[+] Ejecutar STAGE 3: [Deploy] ...${NC}"
read -p "Ingrese el host de la aplicación: " host_url
# Quita la barra diagonal al final de la URL (si existe)
./discord.sh ~/$repo "${host_url%/}/$app/"
echo -e "\n${YELLOW} ====================================="
}

Update
Init
Build
Deploy