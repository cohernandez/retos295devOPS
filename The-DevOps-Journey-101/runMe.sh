#!/bin/bash
### Ejercio 1 The-DevOps-Journey-101 ###
#variables
variableRepo="The-DevOps-Journey-101"
userID=$(id -u)

### colores ###

LRED='\033[1;31m'
LGREEN='\033[1;32m'
NC='\033[0m'
LBLUE='\033[0;34m'
LYELLOW='\033[1;33m'
lPURPLE='\033[0;35m' # Purple
LCYAN='\033[0;36m'   # Cyan

echo -e "\n${LYELLOW}[+] Validando usuario root :${LCYAN} ${userID}"
if [ "${userID}" -ne 0 ];
then
        echo -e "\n${LRED} Ejecutar con usuario ROOT${NC}"
        exit
fi

echo -e "\n${LYELLOW}[!] Validando Actualizaciones" 
apt update -y && apt upgrade -y

echo -e "\n${LYELLOW}[!] Verificando paquete Git"
if dpkg -l | grep -q git;
then
        echo -e "\n${LGREEN}[ok] GIT ya se encuentra instalado"
        echo -e "\n${LYELLOW}[!] Verificando paquete apache"
        if dpkg -l | grep -q apache2;
        then
                echo -e "\n${LGREEN}[ok] El servidor Apache ya se encuentra instalado"
        else
                apt install apache2 -y
                apt install php libapache2-mod-php php-mysql -y
                echo -e "\n${LGREEN}[ok] Servidor Apache instalado con exito"
                systemctl start apache2
                systemctl enable apache2
        fi
else
        echo -e "\n${LRED}[!] GIT no se encuentra instalado"
        apt install git -y
fi

### Base de Datos mariaDB ###
echo -e "\n${LYELLOW}[!] Verificando existencia de mariaDB"
if dpkg -s mariadb-server > /dev/null 2>&1;
then
        echo -e "\n${LGREEN}[+] MariaDB se encuentra instalado"
else
        echo -e "\n${LYELLOW}[!] Instalando MariaDB"
        apt install -y mariadb-server
        systemctl start mariadb
        systemctl enable mariadb
fi
### configurando la db ###
        mysql -e "
        CREATE DATABASE ecomdb;
        CREATE USER 'ecomuser'@'localhost' IDENTIFIED BY 'ecompassword';
        GRANT ALL PRIVILEGES ON *.* TO 'ecomuser'@'localhost';
        FLUSH PRIVILEGES;"
        
### Crear script e insertar datos en las tablas  ###
cat > db-load-script.sql <<-EOF
USE ecomdb;
CREATE TABLE products (id mediumint(8) unsigned NOT NULL auto_increment,Name varchar(255) default NULL,Price varchar(255) default NULL, ImageUrl varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;

INSERT INTO products (Name,Price,ImageUrl) VALUES ("Laptop","100","c-1.png"),("Drone","200","c-2.png"),("VR","300","c-3.png"),("Tablet","50","c-5.png"),("Watch","90","c-6.png"),("Phone Covers","20","c-7.png"),("Phone","80","c-8.png"),("Laptop","150","c-4.png");

EOF
### Ejecutar script ###
        mysql < db-load-script.sql

### Instalar Web ###
echo "[!] Modificando index.html"
if [ -d "$variableRepo" ];
then
        echo "La carpeta $variableRepo existe"       
fi
echo -e "\n${LCYAN}[!] Instalando contedido web"
sleep 1
git clone https://github.com/roxsross/The-DevOps-Journey-101.git
#cp -r $variableRepo/CLASE-02/lamp-app-ecommerce/* /var/www/html/
cp -r The-DevOps-Journey-101/CLASE-02/lamp-app-ecommerce/* /var/www/html/
mv /var/www/html/index.html /var/www/html/index.html.bkp
echo -e "\n${LCYAN}[!] Busca y reemplaza IP del servidor por localhost en el archivo index.php"
sed -i 's/172.20.1.101/localhost/g' /var/www/html/index.php
### reload ###
systemctl reload apache2
echo -e "\n${LCYAN} [ok] Servidor actualizado con exito"
echo -e "\n${LCYAN} [ok] Git "
echo -e "\n${LCYAN} [ok] Apache"
echo -e "\n${LCYAN} [ok] index.html modificado con exito"






