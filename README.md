# Curvas del Dragón ALTENCOA11-2026

Repositorio para la ponencia **"Curvas del Dragón revisitadas"** presentada en ALTENCOA 11 (2026).  
Exploramos la *palabra del dragón*, la *curva de Heighway* y su tratamiento categórico como coálgebra de un endofuntor, usando herramientas computacionales interactivas.

## 🧠 Contenido de la ponencia

- Construcción recursiva de la **palabra del dragón** sobre un alfabeto binario.
- Propiedades: longitud, conteo de valles/montañas, estabilidad de prefijos, palabra infinita.
- Interpretación geométrica: de la palabra a la **curva del dragón** en el plano complejo.
- Visualización de la propiedad de **no autointersección**, **semillas generadoras** y **teselación**.
- Nociones de teoría de categorías: endofuntores, coálgebras, sistemas ecuacionales y el lema de Lambek.
- Implementación en **Julia** con notebooks interactivos (**Pluto**) y scripts de generación de imágenes.

## 📁 Estructura del repositorio

```
Curvas-de-dragon-ALTENCOA11-2026/
├── assets/
├── docs/
├── notebooks/
│   ├── 00_preliminares.jl
│   ├── 01_DragonCurves.jl
├── scripts/
│   └── generar_curva_dragon.jl
├── src/
│   ├── DragonCurve.jl
├── .gitignore
├── Project.toml
├── Manifest.toml
└── README.md
```

## 🚀 Requisitos

- [Julia](https://julialang.org/downloads/) ≥ 1.10
- Paquetes de Julia (instalados automáticamente con el entorno):
  - `Plots`, `PlutoUI`, `Pluto`, `Images`, `FileIO`
  - Otros según notebooks/scripts

## ⚙️ Instalación y uso
Clona el repositorio:
   
```bash
git clone https://github.com/tu-usuario/Curvas-de-dragon-ALTENCOA11-2026.git
cd Curvas-de-dragon-ALTENCOA11-2026
 ```

Activa el entorno del proyecto e instala las dependencias:

```bash
julia --project=.
```
En el REPL de Julia:

```julia
using Pkg; Pkg.instantiate()
```
Notebooks interactivos
Lanza Pluto y abre los notebooks desde la carpeta notebooks:

```julia
using Pluto; Pluto.run()
```
Scripts de generación de imágenes
Por ejemplo, para generar la curva del dragón en PNG:

```bash
julia --project=. scripts/generar_curva_dragon.jl
```
Las imágenes se guardan en assets/.
