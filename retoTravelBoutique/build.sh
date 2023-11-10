#!/bin/bash

repo=""
app=""

LRED='\033[1;31m'
LGREEN='\033[1;32m'
NC='\033[0m'
LBLUE='\033[0;34m'
LYELLOW='\033[1;33m'

clone_repository() {
    if [ ! -d ~/$repo ]; then
        echo -e "\n${LYELLOW}Clonando el repositorio $repo ...${NC}"
        cd ~
        git clone -b clase2-linux-bash https://github.com/dsantafe/$repo
    else
        echo -e "\n${LYELLOW}Actualizando el repositorio $repo ...${NC}"
        cd ~/$repo
        git pull
    fi
}

copy_application() {
    echo "====================================="

    # Testear la existencia del código de la aplicación
    if [ -d /var/www/html/$app ]; then
        echo -e "\n${LGREEN}El código de la aplicación existe. Realizando copia de seguridad ...${NC}"
        backup_dir="$app_$(date +'%Y%m%d_%H%M%S')"
        sudo mkdir /var/www/html/$backup_dir
        sudo mv /var/www/html/$app/* /var/www/html/$backup_dir
    fi

    echo -e "\n${LYELLOW}Copiando el código de la aplicación ...${NC}"
    sudo cp -r ~/$repo/$app /var/www/html
    echo "====================================="
}

configure_mariadb() {

    echo "====================================="
    echo -e "\n${LBLUE}Configurando base de datos ...${NC}"
    local db_password="$1"

    # Comprobar si la base de datos ya existe
    if mysql -e "USE devopstravel;" 2>/dev/null; then
        echo -e "\n${LGREEN}La base de datos 'devopstravel' ya existe ...${NC}"
    else
        # Configura MariaDB (crea la base de datos, el usuario y establece la contraseña)
        mysql -e "
        CREATE DATABASE devopstravel;
        CREATE USER 'codeuser'@'localhost' IDENTIFIED BY '$db_password';
        GRANT ALL PRIVILEGES ON *.* TO 'codeuser'@'localhost';
        FLUSH PRIVILEGES;"

        # Agrega datos a la base de datos desde el archivo SQL
        mysql <~/$repo/$app/database/devopstravel.sql
    fi

    echo "====================================="
}

configure_php() {

    echo "====================================="
    echo -e "\n${LBLUE}Configurando el servidor web ...${NC}"
    # Mover archivos de configuración de Apache
    sudo mv /var/www/html/index.html /var/www/html/index.html.bkp

    # Ajustar la configuración de PHP para admitir archivos dinámicos
    sudo sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php index.html/' /etc/apache2/mods-enabled/dir.conf

    # Actualizar el archivo config.php con la contraseña de la base de datos
    local db_password="$1"
    sudo sed -i "s/\$dbPassword = \".*\";/\$dbPassword = \"$db_password\";/" /var/www/html/$app/config.php

    # Recargar Apache para que los cambios surtan efecto
    sudo systemctl reload apache2

    # Verifica si PHP está funcionando correctamente
    php -v
    echo "====================================="
}

# STAGE 2: [Build]
# Clonar el repositorio de la aplicación
# Validar si el repositorio de la aplicación no existe realizar un git clone. y si existe un git pull
# Mover al directorio donde se guardar los archivos de configuración de apache /var/www/html/
# Testear existencia del codigo de la aplicación
# Ajustar el config de php para que soporte los archivos dinamicos de php agreganfo index.php
# Testear la compatibilidad -> ejemplo http://localhost/info.php
# Si te muestra resultado de una pantalla informativa php , estariamos funcional para la siguiente etapa.

# Verifica si se proporcionó el argumento del directorio del repositorio y de la aplicación
if [ $# -ne 2 ]; then
    echo "Uso: $0 <ruta_al_repositorio> <web_app>"
    exit 1
fi

repo="$1"
app="$2"

# Solicitar al usuario la contraseña de la base de datos en tiempo de despliegue
read -s -p "Ingrese la contraseña de la base de datos: " db_password

# Deploy and Configure Database
# Deploy and Configure Web
clone_repository
copy_application
configure_mariadb "$db_password"
configure_php "$db_password"