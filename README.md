# VanullaPlus Server

Repositorio de configuracion y despliegue declarativo para el servidor de Minecraft VanullaPlus, basado en Fabric 1.21.11.

## Descripcion

El proyecto implementa un entorno survival vanilla expandido centrado en:
- Generacion de terreno monumental y biomas enriquecidos (Terralith, Tectonic, Incendium, Nullscape).
- Estructuras integradas y exploracion contextual (Repurposed Structures, Moog's Voyager Structures).
- Mecanicas de supervivencia y alimentacion (Farmer's Delight Refabricated, Comforts).
- Optimizacion multihilo y estabilidad de ticking (Lithium, FerriteCore, C2ME, Alternate Current, Krypton, Chunky).

## Requisitos previos

- Sistema operativo compatible con POSIX (Linux, macOS) o Windows con WSL.
- OpenJDK 21 o superior instalado y disponible en PATH.
- Acceso a internet para la descarga inicial de binarios y dependencias.
- Python 3 y curl disponibles para la ejecucion del script de aprovisionamiento.

## Estructura del repositorio

```
.
├── manifest.json       # Definicion declarativa de versiones y URLs de mods
├── scripts/
│   ├── setup.sh        # Aprovisionamiento automatizado de binarios y mods
│   └── start.sh        # Script de arranque con flags JVM Aikar optimizados
├── server.properties   # Configuracion base del servidor
├── .gitignore          # Aislamiento de binarios, logs y estados del mundo
└── README.md           # Documentacion tecnica
```

## Puesta en marcha

1. Clonar el repositorio en la maquina host:
```bash
git clone https://github.com/FakeCxbas/VanullaPlus.git
cd VanullaPlus
```

2. Otorgar permisos de ejecucion a los scripts:
```bash
chmod +x scripts/*.sh
```

3. Ejecutar el aprovisionamiento automatizado:
```bash
./scripts/setup.sh
```
El script verificara la version de Java, descargara el lanzador oficial de Fabric Server y obtendra los modulos declarados en `manifest.json`.

4. Iniciar el servidor:
```bash
./scripts/start.sh
```

### Configuracion de memoria

Por defecto, `start.sh` asigna un minimo de 2 GB y un maximo de 4 GB de memoria RAM. Es posible ajustar estos valores mediante variables de entorno antes de la ejecucion:

```bash
MIN_RAM=4G MAX_RAM=8G ./scripts/start.sh
```

## Precarga de Chunks (Recomendado)

Para evitar latencias durante la exploracion inicial de los jugadores debido a la generacion de Terralith y Tectonic, se recomienda utilizar el mod Chunky desde la consola del servidor:

```
chunky radius 3000
chunky start
```