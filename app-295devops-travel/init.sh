#!/bin/bash

### Tareas ###
# STAGE 1: [Init]
# Instalacion de paquetes en el servidor: [apache, php, mariadb, git, curl, etc]
# Validación de existencia de paquetes en servidor
# Habilitacion y Testing de los paquetes instalados


LRED='\033[1;31m'
LGREEN='\033[1;32m'
NC='\033[0m'
LBLUE='\033[0;34m'
LYELLOW='\033[1;33m'
lPURPLE='\033[0;35m' 
LCYAN='\033[0;36m'   

check_status() {
  if [ $1 -eq 0 ]; then
    echo -e "\n${LPURPLE}[ok] Éxito ...${NC}"
  else
    echo -e "\n${LRED} Error: El comando falló. Saliendo del script ...${NC}"
    exit 1
  fi
}

install_packages() {
  packages=("apache2" "php" "libapache2-mod-php" "php-mysql" "mariadb-server" "git" "curl")

  for package in "${packages[@]}"; do
    dpkg -l | grep -q $package
    if [ $? -eq 0 ]; then
      echo -e "\n${LGREEN} $package ya está instalado ...${NC}"
    else
      echo -e "\n${LCYAN}instalando $package ...${NC}"
      apt-get install -y $package
      check_status $?
    fi
  done

  # Servicios
  sudo systemctl enable apache2 && sudo systemctl start apache2
  sudo systemctl enable mariadb && sudo systemctl start mariadb
}

install_packages