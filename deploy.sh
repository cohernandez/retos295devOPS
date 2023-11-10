#!/bin/bash

##### Stage 1 #####

USERID=$(id -u)

# Root user
if [[ "${USERID}" -ne "0" ]]; then
    echo -e "\e[31;1;3mUsuario inválido.\e[m"
    exit 1
fi
echo "  === Updating ==="
apt-get update
echo "  "
echo "  === Server updated ==="
echo "  "

# curl
if ! dpkg -s curl > /dev/null 2>&1; then
    apt install curl -y 2>&1
fi

# Git
if dpkg -s git > /dev/null 2>&1; then
    echo "  *** Git installed ***"
else
    echo "installing Git..."
    apt install git -y > /dev/null 2>&1
    echo "  *** successful Installation ***"
fi
git --version | head -n 1
echo "====================================="
# Mariadb
if dpkg -s mariadb-server > /dev/null 2>&1; then
    echo "  *** mariadb installed ***"
    mariadb -V | head -n 1
else
    echo "installing mariadb..."
    apt install -y mariadb-server > /dev/null 2>&1
    systemctl start mariadb
    systemctl enable mariadb
    echo "  *** successful Installation ***"
    mariadb -V | head -n 1
    # Configuración de la base de datos
    echo "  === Configurating Database ==="
    mysql -e "CREATE DATABASE devopstravel;
    CREATE USER 'codeuser'@'localhost' IDENTIFIED BY 'codepass';
    GRANT ALL PRIVILEGES ON *.* TO 'codeuser'@'localhost';
    FLUSH PRIVILEGES;"
fi

echo "====================================="
# Apache
if dpkg -s apache2 > /dev/null 2>&1; then
    echo "  *** apache installed ***"
else
    echo "installing apache..."
    apt install apache2 -y > /dev/null 2>&1
    sudo systemctl start apache2
    sudo systemctl enable apache2
    mv /var/www/html/index.html /var/www/html/index.html.bkp
    echo "  *** successful Installation ***"
fi
apache2 -v | head -n 1
echo "====================================="
# PHP
if dpkg -s php > /dev/null 2>&1; then
    echo "  ***php installed ***"
else
    echo "installing php..."
    apt install -y php libapache2-mod-php php-mysql php-mbstring php-zip php-gd php-json php-curl > /dev/null 2>&1
    echo "  *** successful Installation ***"
fi
php -v | head -n 1
echo "====================================="

##### Stage 2 #####

MAIN="/root/BootCamp-DevOps-roxsross"
REPO="bootcamp-devops-2023"
BRANCH="clase2-linux-bash"
APP="app-295devops-travel"

# Test de Repo
if test -d "$MAIN/$REPO"; then
    cd $MAIN/$REPO
    git pull
else
    sleep 1
    git clone -b $BRANCH https://github.com/roxsross/$REPO.git
    # Injección de primeros datos
    mysql < /root/$REPO/$APP/database/devopstravel.sql
fi

# Copiando archivos
cd $MAIN
cp -r /$MAIN/$REPO/$APP/* /var/www/html
# Test de codigo
if test -f "/var/www/html/index.php"; then 
    echo "  "
    echo "  === The code was copied ==="
fi
sleep 5
sudo systemctl reload apache2
curl localhost/info.php

##### Stage 3 #####
curl localhost

##### Stage 4 #####
DISCORD="https://discord.com/api/webhooks/1169002249939329156/7MOorDwzym-yBUs3gp0k5q7HyA42M5eYjfjpZgEwmAx1vVVcLgnlSh4TmtqZqCtbupov"

# Obtiene el nombre del repositorio
REPO_NAME=$(basename $(git rev-parse --show-toplevel))
# Obtiene la URL remota del repositorio
REPO_URL="Repositorio: (BootCamp-DevOps-roxsross: $(git remote get-url origin))"
WEB_URL="localhost"
# Realiza una solicitud HTTP GET a la URL
HTTP_STATUS=$(curl -Is "$WEB_URL" | head -n 1)

# Verificación de respuesta 
if [[ "$HTTP_STATUS" == *"200 OK"* ]]; then
  # Obtén información del repositorio
    DEPLOYMENT_INFO2="Despliegue del repositorio $REPO_NAME: "
    DEPLOYMENT_INFO="La página web $WEB_URL está en línea."
    COMMIT="Commit: $(git rev-parse --short HEAD)"
    AUTHOR="Autor: $(git log -1 --pretty=format:'%an')"
    DESCRIPTION="Descripción: $(git log -1 --pretty=format:'%s')"
else
  DEPLOYMENT_INFO="La página web $WEB_URL no está en línea."
fi

# Mensaje
# MESSAGE="$DEPLOYMENT_INFO2\n$DEPLOYMENT_INFO\n$COMMIT\n$AUTHOR\n$REPO_URL\n$DESCRIPTION"

# Discord API
# curl -X POST -H "Content-Type: application/json" \
#     -d '{
#       "content": "'"${MESSAGE}"'"
#     }' "$DISCORD"