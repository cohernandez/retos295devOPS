#!/bin/bash

# Configura el token de acceso de tu bot de Discord
DISCORD="https://discord.com/api/webhooks/1169002249939329156/7MOorDwzym-yBUs3gp0k5q7HyA42M5eYjfjpZgEwmAx1vVVcLgnlSh4TmtqZqCtbupov"

# Verifica si se proporcionó el argumento del directorio del repositorio
if [ $# -ne 1 ]; then
  echo "Uso: $0 <ruta_al_repositorio>"
  exit 1
fi

# Cambia al directorio del repositorio
cd "$1"

# Obtiene el nombre del repositorio
get_name_repo() {
REPO_NAME=$(basename $(git rev-parse --show-toplevel))
# Obtiene la URL remota del repositorio
REPO_URL=$(git remote get-url origin)
WEB_URL="localhost"
# Realiza una solicitud HTTP GET a la URL
HTTP_STATUS=$(curl -Is "$WEB_URL" | head -n 1)
}

# Verifica si la respuesta es 200 OK 
check_http_status(){
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
}


# Envía el mensaje a Discord utilizando la API de Discord
alert_status_discord() {
# Construye el mensaje
MESSAGE="$DEPLOYMENT_INFO2\n$DEPLOYMENT_INFO\n$COMMIT\n$AUTHOR\n$REPO_URL\n$DESCRIPTION"
curl -X POST -H "Content-Type: application/json" \
     -d '{
       "content": "'"${MESSAGE}"'"
     }' "$DISCORD"
}

get_name_repo
check_http_status
#alert_status_discord