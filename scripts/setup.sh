#!/usr/bin/env bash
set -euo pipefail

# VanullaPlus - Automated Server Setup Script
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST_FILE="${ROOT_DIR}/manifest.json"
MODS_DIR="${ROOT_DIR}/mods"

echo "[VanullaPlus] Iniciando configuracion automatizada del servidor..."

# 1. Verificar runtime de Java
if ! command -v java >/dev/null 2>&1; then
    echo "[ERROR] Java no esta instalado o no se encuentra en el PATH."
    echo "[INFO] Por favor instala OpenJDK 21 (ejemplo en Debian/Ubuntu: sudo apt install openjdk-21-jre-headless)."
    exit 1
fi

JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d'.' -f1)
if [[ "${JAVA_VERSION}" -lt 21 ]]; then
    echo "[ERROR] Se requiere Java 21 o superior. Version detectada: ${JAVA_VERSION}."
    exit 1
fi
echo "[OK] Runtime Java detectado: $(java -version 2>&1 | head -n 1)"

# 2. Verificar manifiesto
if [[ ! -f "${MANIFEST_FILE}" ]]; then
    echo "[ERROR] No se encontro el archivo manifest.json en ${MANIFEST_FILE}."
    exit 1
fi

mkdir -p "${MODS_DIR}"

# 3. Descargar ejecutable de Fabric Server
SERVER_JAR_NAME=$(python3 -c "import json; print(json.load(open('${MANIFEST_FILE}'))['server_jar_name'])")
SERVER_JAR_URL=$(python3 -c "import json; print(json.load(open('${MANIFEST_FILE}'))['server_launcher_url'])")
TARGET_SERVER_JAR="${ROOT_DIR}/${SERVER_JAR_NAME}"

echo "[VanullaPlus] Verificando núcleo del servidor (${SERVER_JAR_NAME})..."
if [[ ! -f "${TARGET_SERVER_JAR}" ]]; then
    echo "[INFO] Descargando ${SERVER_JAR_NAME} desde ${SERVER_JAR_URL}..."
    curl -fsSL -o "${TARGET_SERVER_JAR}" "${SERVER_JAR_URL}"
    echo "[OK] Nucleo descargado correctamente."
else
    echo "[OK] Nucleo existente: ${SERVER_JAR_NAME}."
fi

# 4. Descargar mods definidos en el manifiesto
echo "[VanullaPlus] Descargando modulos de servidor declarados..."
python3 - << 'EOF'
import json, urllib.request, os, hashlib, sys

root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..")) if "__file__" in locals() else os.getcwd()
manifest_path = os.path.join(root_dir, "manifest.json")
mods_dir = os.path.join(root_dir, "mods")

with open(manifest_path, "r") as f:
    manifest = json.load(f)

for mod in manifest.get("mods", []):
    filename = mod["filename"]
    url = mod["url"]
    dest_path = os.path.join(mods_dir, filename)

    if os.path.exists(dest_path):
        print(f"  [OMITIDO] {filename} ya existe.")
        continue

    print(f"  [DESCARGANDO] {filename}...")
    req = urllib.request.Request(url, headers={"User-Agent": "VanullaPlus-Installer/1.0"})
    try:
        with urllib.request.urlopen(req) as resp, open(dest_path, "wb") as out:
            out.write(resp.read())
        print(f"  [OK] {filename}")
    except Exception as e:
        print(f"  [ERROR] Fallo al descargar {filename}: {e}", file=sys.stderr)
        sys.exit(1)
EOF

# 5. Generar eula.txt si no existe
EULA_FILE="${ROOT_DIR}/eula.txt"
if [[ ! -f "${EULA_FILE}" ]]; then
    echo "eula=true" > "${EULA_FILE}"
    echo "[OK] EULA aceptado automaticamente (eula=true)."
fi

echo "[VanullaPlus] Despliegue completado con exito. Ejecuta ./scripts/start.sh para iniciar el servidor."
