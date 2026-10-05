# ==============================================================================
# dragon_curve.jl — Curva del dragón con gradiente de color
# ==============================================================================
# Construye la curva de Heighway con 2ⁿ segmentos usando la regla de giros
# (según el último bit impar de k) y la dibuja con un gradiente a lo largo
# de la curva.
#
# Uso:     julia --project=. scripts/dragon_curve.jl [OPCIONES]
# Ayuda:   julia --project=. scripts/dragon_curve.jl --help
# Salida:  assets/basic-dragon/curva_dragon_i<n>.png
# ==============================================================================

using Plots

include(joinpath(@__DIR__, "terminal_ui.jl"))
using .TerminalUI

gr()

# Paleta de colores del gradiente (viridis/plasma extendida)
const PALETA_GRADIENTE = [
    "#0d0887", "#46039f", "#7201a8", "#9e1795", "#bd3786",
    "#d8576b", "#ed7953", "#fb9f3a", "#fdca26", "#f0e821",
    "#b9de28", "#6ece58", "#29af7f", "#1fa187", "#1c7c93",
    "#2a5a8a",
]
const GRADIENTE = cgrad(PALETA_GRADIENTE, 256)

const ALIAS = Dict(
    "--iter" => :iter, "-i" => :iter,
    "--tam"  => :tam,  "-t" => :tam,
    "--out"  => :out,  "-o" => :out,
)

# ==============================================================================
# GENERACIÓN DE PUNTOS
# ==============================================================================

function dragon_points(n::Int)
    N = 2^n
    puntos = ComplexF64[0.0+0.0im, 1.0+0.0im]
    dir = 1.0+0.0im
    for k in 2:N
        j = k
        while iseven(j)
            j >>= 1
        end
        giro = (j % 4 == 1) ? im : -im
        dir *= giro
        push!(puntos, puntos[end] + dir)
    end
    return puntos
end

# ==============================================================================
# GRAFICACIÓN
# ==============================================================================

"""
    generar_curva_png(n; tam=400, archivo_final="")

Dibuja la curva con 2ⁿ segmentos en una imagen cuadrada de `tam`×`tam` píxeles.
Devuelve la ruta del archivo.
"""
function generar_curva_png(n::Int; tam::Int = 400, archivo_final::String = "")
    t0 = time()

    if isempty(archivo_final)
        archivo_final = ruta_assets("basic-dragon", "curva_dragon_i$(n).png")
    else
        mkpath(dirname(abspath(archivo_final)))
    end

    seccion("Parámetros")
    parametros(
        "Iteraciones" => n,
        "Segmentos"   => 2^n,
        "Tamaño"      => "$(tam)×$(tam) px",
    )

    seccion("Generación")
    paso(1, 3, "Calculando los puntos de la curva")
    pts = dragon_points(n)
    msg_info("Segmentos totales: $(length(pts) - 1)")

    paso(2, 3, "Dibujando con gradiente de color")
    t = range(0, 1, length = length(pts))
    plot(real.(pts), imag.(pts),
         line_z = t,
         color = GRADIENTE,
         linewidth = 2.0,
         aspect_ratio = :equal,
         legend = false,
         axis = false,
         grid = false,
         ticks = false,
         size = (tam, tam))

    paso(3, 3, "Guardando la imagen")
    savefig(archivo_final)

    msg_resultado(archivo_final; segundos = time() - t0)
    return archivo_final
end

# ==============================================================================
# AYUDA
# ==============================================================================

function ayuda()
    mostrar_ayuda(
        titulo = "Curva del dragón con gradiente",
        descripcion = "Curva de Heighway con 2ⁿ segmentos",
        uso = "julia --project=. scripts/dragon_curve.jl [OPCIONES]",
        opciones = [
            ("-i, --iter <int>", "Número de iteraciones n (2ⁿ segmentos) [defecto: 7]"),
            ("-t, --tam <int>",  "Lado de la imagen en píxeles [defecto: 400]"),
            ("-o, --out <ruta>", "Archivo de salida [defecto: assets/basic-dragon/...]"),
            ("-h, --help",       "Muestra esta ayuda"),
        ],
        ejemplos = [
            "julia --project=. scripts/dragon_curve.jl",
            "julia --project=. scripts/dragon_curve.jl -i 12 -t 1200",
        ],
    )
end

# ==============================================================================
# PUNTO DE ENTRADA
# ==============================================================================

function main()
    if pide_ayuda(ARGS)
        ayuda()
        return
    end

    n, tam, salida = 7, 400, ""

    banner("Curva del dragón con gradiente")

    v = parsear_banderas(ARGS, ALIAS)
    haskey(v, :iter) && (n = a_entero(v[:iter], "--iter"))
    haskey(v, :tam)  && (tam = a_entero(v[:tam], "--tam"))
    haskey(v, :out)  && (salida = v[:out])

    n < 1 && salir_con_error("Las iteraciones deben ser ≥ 1.")
    tam < 50 && salir_con_error("El tamaño debe ser de al menos 50 px.")

    generar_curva_png(n; tam = tam, archivo_final = salida)
end

main()
