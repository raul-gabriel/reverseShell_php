#!/bin/bash

echo "====================================="
echo "  Shell Remota"
echo "====================================="
echo ""
echo -n "URL del servidor: "
read URL

echo ""
echo "Conectando..."

# Obtener PWD inicial
response=$(curl -s -X POST "$URL" -d "cmd=pwd")
current_pwd=$(echo "$response" | grep -o '"pwd":"[^"]*"' | cut -d'"' -f4)

if [ -z "$current_pwd" ]; then
    echo "Error: No se pudo conectar al servidor"
    exit 1
fi

echo "Conectado!"
echo ""

while true; do
    # Mostrar prompt con el directorio actual
    echo -n "$current_pwd> "
    read -r cmd
    
    # Salir
    if [ "$cmd" = "exit" ] || [ "$cmd" = "quit" ]; then
        echo "Cerrando conexión..."
        break
    fi
    
    # Comando vacío
    if [ -z "$cmd" ]; then
        continue
    fi
    
    # Enviar comando
    response=$(curl -s -X POST "$URL" -d "cmd=$cmd")
    
    # Extraer salida y nuevo PWD
    output=$(echo "$response" | grep -o '"output":"[^"]*"' | sed 's/"output":"//;s/"$//' | sed 's/\\n/\n/g')
    current_pwd=$(echo "$response" | grep -o '"pwd":"[^"]*"' | cut -d'"' -f4)
    
    # Mostrar salida si hay
    if [ -n "$output" ] && [ "$output" != "null" ]; then
        echo "$output"
    fi
done