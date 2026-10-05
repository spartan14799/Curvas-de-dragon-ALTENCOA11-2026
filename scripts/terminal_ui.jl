# ==============================================================================
# terminal_ui.jl — Estándar de terminal para los scripts del proyecto
# ==============================================================================
# Módulo SIN dependencias externas (solo biblioteca estándar de Julia).
# Todos los scripts de `scripts/` lo cargan al inicio con:
#
#     include(joinpath(@__DIR__, "terminal_ui.jl"))
#     using .TerminalUI
#
# Convenciones visuales (no cambiar sin actualizar todos los scripts):
#   - Banner de apertura con el nombre del script (línea doble `=`).
#   - Secciones con `> Título` y línea simple `-`.
#   - Mensajes etiquetados: [INFO] [ OK ] [WARN] [FAIL] (6 caracteres).
#   - Parámetros alineados en columna (`parametros`).
#   - Ayuda (-h / --help) con el mismo formato en todos los scripts.
#   - Los colores se desactivan solos si la salida no es una terminal
#     o si existe la variable de entorno NO_COLOR.
# ==============================================================================

module TerminalUI

export ANCHO, RAIZ,
       banner, seccion, parametro, parametros, paso,
       msg_info, msg_ok, msg_aviso, msg_error, salir_con_error,
       leer_texto, leer_si_no, parsear_bool, a_entero, a_real,
       parsear_banderas, pide_ayuda, mostrar_ayuda,
       muestra_color, linea_catalogo, ruta_assets, msg_resultado

# ------------------------------------------------------------------------------
# Constantes
# ------------------------------------------------------------------------------

const ANCHO = 67                  # ancho de las líneas separadoras
const RAIZ  = dirname(@__DIR__)   # raíz del repositorio (carpeta padre de scripts/)

const CODIGOS = Dict(
    :reset    => "\e[0m",
    :negrita  => "\e[1m",
    :tenue    => "\e[2m",
    :rojo     => "\e[31m",
    :verde    => "\e[32m",
    :amarillo => "\e[33m",
    :azul     => "\e[34m",
    :magenta  => "\e[35m",
    :cian     => "\e[36m",
)

# ------------------------------------------------------------------------------
# Estilos básicos
# ------------------------------------------------------------------------------

usa_color() = get(ENV, "NO_COLOR", "") == "" && stdout isa Base.TTY

function estilo(texto, estilos::Symbol...)
    usa_color() || return string(texto)
    return string(join(CODIGOS[s] for s in estilos), texto, CODIGOS[:reset])
end

linea_doble()  = estilo("="^ANCHO, :cian)
linea_simple() = estilo("-"^ANCHO, :tenue)

# ------------------------------------------------------------------------------
# Estructura de la salida
# ------------------------------------------------------------------------------

"""
    banner(titulo; subtitulo="")

Encabezado del script. Se imprime una sola vez al inicio.
"""
function banner(titulo::AbstractString; subtitulo::AbstractString="")
    println()
    println(linea_doble())
    println(estilo(uppercase(titulo), :negrita, :cian))
    isempty(subtitulo) || println(estilo(subtitulo, :tenue))
    println(linea_doble())
end

"""
    seccion(titulo)

Título de bloque dentro de la salida (Parámetros, Generación, Resultado...).
"""
function seccion(titulo::AbstractString)
    println()
    println(estilo("> ", :cian, :negrita), estilo(titulo, :negrita))
    println(linea_simple())
end

"""
    parametro(nombre, valor; ancho=18)

Una línea `nombre   valor` alineada en columna.
"""
function parametro(nombre, valor; ancho::Int=18)
    println("  ", estilo(rpad(string(nombre), ancho), :tenue), " ",
            estilo(string(valor), :negrita))
end

"""
    parametros("Semilla" => "UUDD", "Iteraciones" => 6, ...)

Imprime varios parámetros alineados entre sí.
"""
function parametros(pares::Pair...)
    isempty(pares) && return
    ancho = maximum(length(string(p.first)) for p in pares) + 2
    for p in pares
        parametro(p.first, p.second; ancho = ancho)
    end
end

"""
    paso(i, n, texto)

Indicador de progreso del tipo `[2/4] Texto`.
"""
paso(i::Int, n::Int, texto::AbstractString) =
    println(estilo("[$i/$n] ", :magenta, :negrita), texto)

# ------------------------------------------------------------------------------
# Mensajes etiquetados
# ------------------------------------------------------------------------------

msg_info(texto)  = println(estilo("[INFO] ", :azul,     :negrita), texto)
msg_ok(texto)    = println(estilo("[ OK ] ", :verde,    :negrita), texto)
msg_aviso(texto) = println(estilo("[WARN] ", :amarillo, :negrita), texto)
msg_error(texto) = println(stderr, estilo("[FAIL] ", :rojo, :negrita), texto)

"""
    salir_con_error(texto; codigo=1)

Muestra el error con el formato estándar y termina el script.
"""
function salir_con_error(texto; codigo::Int=1)
    msg_error(texto)
    exit(codigo)
end

"""
    msg_resultado(ruta; segundos=nothing)

Cierre estándar tras guardar un archivo: muestra la ruta relativa a la raíz
del repositorio (y el tiempo total si se entrega).
"""
function msg_resultado(ruta::AbstractString; segundos=nothing)
    println()
    msg_ok("Imagen guardada")
    parametro("Archivo", relpath(abspath(ruta), RAIZ))
    segundos === nothing || parametro("Tiempo", string(round(segundos; digits = 2), " s"))
    println(linea_doble())
end

# ------------------------------------------------------------------------------
# Lectura de datos (modo interactivo)
# ------------------------------------------------------------------------------

"""
    leer_texto(pregunta, defecto="")

Pregunta con valor por defecto entre corchetes. Enter acepta el defecto.
"""
function leer_texto(pregunta::AbstractString, defecto::AbstractString="")
    sufijo = isempty(defecto) ? "" : estilo(" [$defecto]", :tenue)
    print(estilo("? ", :magenta, :negrita), pregunta, sufijo, ": ")
    entrada = strip(readline())
    return isempty(entrada) ? String(defecto) : String(entrada)
end

"""
    leer_si_no(pregunta; defecto=true)

Pregunta sí/no. Muestra `[S/n]` o `[s/N]` según el defecto.
"""
function leer_si_no(pregunta::AbstractString; defecto::Bool=true)
    marca = defecto ? "S/n" : "s/N"
    print(estilo("? ", :magenta, :negrita), pregunta, estilo(" [$marca]", :tenue), ": ")
    return parsear_bool(readline(); defecto = defecto)
end

"""
    parsear_bool(texto; defecto=true)

Convierte "s", "si", "sí", "y", "yes", "true", "1" en `true` y
"n", "no", "f", "false", "0" en `false`. Vacío o desconocido → `defecto`.
"""
function parsear_bool(texto::AbstractString; defecto::Bool=true)
    v = lowercase(strip(texto))
    isempty(v) && return defecto
    v in ("1", "true", "t", "s", "si", "sí", "y", "yes") && return true
    v in ("0", "false", "f", "n", "no") && return false
    return defecto
end

function a_entero(texto::AbstractString, nombre::AbstractString)
    n = tryparse(Int, strip(texto))
    n === nothing && salir_con_error("'$nombre' debe ser un entero (recibido: '$texto').")
    return n
end

function a_real(texto::AbstractString, nombre::AbstractString)
    x = tryparse(Float64, strip(texto))
    x === nothing && salir_con_error("'$nombre' debe ser un número (recibido: '$texto').")
    return x
end

# ------------------------------------------------------------------------------
# Argumentos de línea de comandos
# ------------------------------------------------------------------------------

pide_ayuda(args) = any(a -> a in ("-h", "--help"), args)

"""
    parsear_banderas(args, alias)

`alias` asocia cada bandera con un símbolo, por ejemplo
`Dict("--iter" => :iter, "-i" => :iter)`. Devuelve un `Dict{Symbol,String}`.
Banderas desconocidas o sin valor terminan el script con un error claro.
"""
function parsear_banderas(args::AbstractVector{<:AbstractString}, alias::Dict{String,Symbol})
    valores = Dict{Symbol,String}()
    i = 1
    while i <= length(args)
        arg = String(args[i])
        haskey(alias, arg) ||
            salir_con_error("Opción desconocida: '$arg'. Usa --help para ver las opciones.")
        i == length(args) &&
            salir_con_error("La opción '$arg' requiere un valor.")
        valores[alias[arg]] = String(args[i + 1])
        i += 2
    end
    return valores
end

"""
    mostrar_ayuda(; titulo, uso, descripcion="", opciones=[], catalogos=[], ejemplos=[])

Menú de ayuda con el mismo formato en todos los scripts.
  - `opciones`:  vector de tuplas `("-i, --iter <int>", "Descripción [defecto: 6]")`
  - `catalogos`: vector de pares `"Paletas de color" => ["línea 1", "línea 2"]`
  - `ejemplos`:  vector de comandos de ejemplo
"""
function mostrar_ayuda(; titulo, uso, descripcion="", opciones=[], catalogos=[], ejemplos=[])
    banner(titulo; subtitulo = descripcion)

    seccion("Uso")
    println("  ", estilo(uso, :verde))

    if !isempty(opciones)
        seccion("Opciones")
        ancho = maximum(length(o[1]) for o in opciones) + 2
        for (bandera, desc) in opciones
            println("  ", estilo(rpad(bandera, ancho), :amarillo), desc)
        end
    end

    for (nombre, lineas) in catalogos
        seccion(nombre)
        for l in lineas
            println("  ", l)
        end
    end

    if !isempty(ejemplos)
        seccion("Ejemplos")
        for e in ejemplos
            println("  ", estilo("\$ ", :tenue), e)
        end
    end

    println()
    println(linea_doble())
end

# ------------------------------------------------------------------------------
# Catálogos de colores
# ------------------------------------------------------------------------------

"""
    muestra_color(hex)

Cuadrito de color (truecolor) para mostrar junto a cada paleta.
Devuelve "" si la terminal no admite color.
"""
function muestra_color(hex::AbstractString)
    usa_color() || return ""
    m = match(r"^#([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})$", hex)
    m === nothing && return ""
    r, g, b = (parse(Int, c; base = 16) for c in m.captures)
    return string("\e[48;2;", r, ";", g, ";", b, "m  ", CODIGOS[:reset], " ")
end

"""
    linea_catalogo(id, nombre, colores)

Línea `[id] ■■■■ Nombre` para listar paletas (en ayuda y en modo interactivo).
`colores` es un vector de códigos hexadecimales.
"""
function linea_catalogo(id, nombre::AbstractString, colores::AbstractVector{<:AbstractString})
    return string(estilo("[$id] ", :amarillo), join(muestra_color.(colores)), nombre)
end

# ------------------------------------------------------------------------------
# Rutas de salida
# ------------------------------------------------------------------------------

"""
    ruta_assets(subcarpeta, archivo)

Ruta absoluta `<repo>/assets/<subcarpeta>/<archivo>`, creando la carpeta si no
existe. No depende del directorio desde el que se ejecute el script.
"""
function ruta_assets(subcarpeta::AbstractString, archivo::AbstractString)
    dir = joinpath(RAIZ, "assets", subcarpeta)
    mkpath(dir)
    return joinpath(dir, archivo)
end

end # module TerminalUI
