#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVER_JAR="${ROOT_DIR}/fabric-server-launch.jar"

# Asignacion de memoria configurable via variables de entorno
RAM_MIN="${MIN_RAM:-2G}"
RAM_MAX="${MAX_RAM:-4G}"

if [[ ! -f "${SERVER_JAR}" ]]; then
    echo "[ERROR] No se encontro ${SERVER_JAR}."
    echo "[INFO] Ejecuta primero el script de instalacion: ./scripts/setup.sh"
    exit 1
fi

echo "[VanullaPlus] Iniciando servidor Fabric..."
echo "[VanullaPlus] Memoria asignada: ${RAM_MIN} (min) / ${RAM_MAX} (max)"

# Aikar's flags optimizados para Garbage Collection en entornos multijugador
JVM_FLAGS=(
    "-Xms${RAM_MIN}"
    "-Xmx${RAM_MAX}"
    "-XX:+UseG1GC"
    "-XX:+ParallelRefProcEnabled"
    "-XX:MaxGCPauseMillis=200"
    "-XX:+UnlockExperimentalVMOptions"
    "-XX:+DisableExplicitGC"
    "-XX:+AlwaysPreTouch"
    "-XX:G1NewSizePercent=30"
    "-XX:G1MaxNewSizePercent=40"
    "-XX:G1ReservePercent=20"
    "-XX:G1HeapWastePercent=5"
    "-XX:G1MixedGCCountTarget=4"
    "-XX:InitiatingHeapOccupancyPercent=15"
    "-XX:G1MixedGCLiveThresholdPercent=90"
    "-XX:G1RSetUpdatingPauseTimePercent=5"
    "-XX:SurvivorRatio=32"
    "-XX:+PerfDisableSharedMem"
    "-XX:MaxTenuringThreshold=1"
    "-Dusing.aikars.flags=https://mcflags.emc.gs"
    "-Daikars.new.flags=true"
)

exec java "${JVM_FLAGS[@]}" -jar "${SERVER_JAR}" nogui
