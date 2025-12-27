# Reverse Shell PHP (REST API) — Ejemplo Educativo

> **Aviso importante:**  
> Este proyecto se proporciona **únicamente con fines educativos y de aprendizaje**.  
> El autor **no se hace responsable del uso indebido** que pueda darse a este material.  
> No debe utilizarse en sistemas sin autorización expresa.

---

## Descripción general

Este repositorio muestra un **ejemplo educativo** de una *reverse shell* implementada en **PHP**, basada en **APIs REST**.  
El flujo general se divide en dos componentes:

- **`servidor.php`**: archivo PHP pensado para alojarse en un servidor web. Actúa como punto de comunicación y control a través de peticiones REST.
- **`cliente.sh`**: script de cliente que se ejecuta localmente y se comunica con el servidor mediante solicitudes HTTP.

El proyecto también puede presentarse como **plugin de WordPress**, bajo el nombre:




---

## Componentes

### servidor.php
- Archivo PHP que se sube al servidor web.
- Expone endpoints REST simples.
- Permite la interacción remota a través de solicitudes HTTP.
- Diseñado para demostrar cómo PHP puede actuar como intermediario en comunicaciones cliente-servidor.

### cliente.sh
- Script de ejemplo para sistemas tipo Unix.
- Debe ejecutarse con permisos adecuados.
- Realiza solicitudes HTTP hacia el servidor.
- Su propósito es **demostrativo**, para entender la comunicación remota mediante REST.

---

## Uso como plugin de WordPress

Este proyecto puede adaptarse como un **plugin de WordPress**:

1. Colocar los archivos dentro de una carpeta llamada:


## wp-performance-optimizer
2. Comprimir la carpeta en un archivo `.zip`.
3. Subir el archivo ZIP desde el panel de administración de WordPress.
4. Activar el plugin desde la sección de plugins.

> Este procedimiento es solo parte del ejemplo académico sobre cómo WordPress carga y ejecuta plugins.

---

## Objetivo educativo

Este proyecto sirve para estudiar:

- Comunicación cliente-servidor mediante HTTP
- Uso de APIs REST en PHP
- Estructura básica de plugins de WordPress
- Interacción entre scripts de shell y servicios web

---

## Descargo de responsabilidad

- Este código **no está destinado a producción**.
- **No debe usarse** para acceder, modificar o controlar sistemas sin permiso.
- El autor **rechaza cualquier responsabilidad** por usos ilegales, poco éticos o no autorizados.

---

## Licencia

Uso libre **solo con fines educativos**.  
Se recomienda adaptar este material para prácticas controladas, laboratorios o entornos de prueba.

---
