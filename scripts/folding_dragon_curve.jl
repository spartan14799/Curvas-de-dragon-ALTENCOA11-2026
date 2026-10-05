# ==============================================================================
# folding_dragon_curve.jl — Autosemejanza del dragón: D = f₁(D) ∪ f₂(D)
# ==============================================================================
# Dibuja el dragón clásico (Heighway) dividido por su punto medio en dos copias
# autosemejantes (Copia 1 y Copia 2) y marca el punto de pegado.
#
# Uso:     julia --project=. scripts/folding_dragon_curve.jl [OPCIONES]
# Ayuda:   julia --project=. scripts/folding_dragon_curve.jl --help
# Salida:  assets/self-similar-dragon/dragon_autosemejante_i<iter>.png
# ==============================================================================

using Plots

include(joinpath(@__DIR__, "terminal_ui.jl"))
using .TerminalUI

gr()

const ALIAS = Dict(
    "--iter" => :iter,     "-i" => :iter,
    "--grosor" => :grosor, "-g" => :grosor,
    "--color1" => :color1, "-c1" => :color1,
    "--color2" => :color2, "-c2" => :color2,
    "--out" => :out,       "-o" => :out,
)

# ==============================================================================
# 1. GENERACIÓN DEL DRAGÓN CLÁSICO (HEIGHWAY)
# ==============================================================================

function generar_giros_dragon(iteraciones::Int)
    giros = Int[]
    for _ in 1:iteraciones
        giros_inversos = [-g for g in reverse(giros)]
        push!(giros, 1)
        append!(giros, giros_inversos)
    end
    return giros
end

function giros_a_puntos(giros::Vector{Int})
    puntos = ComplexF64[0.0 + 0.0im]
    angulo = 0.0

    push!(puntos, last(puntos) + cis(angulo))

    for g in giros
        angulo += g * (π / 2)
        push!(puntos, last(puntos) + cis(angulo))
    end
    return puntos
end

# ==============================================================================
# 2. GRAFICACIÓN DEL PLEGADO Y LA AUTOSEMEJANZA
# ==============================================================================

"""
    graficar_plegado_dragon(; iteraciones=10, color1, color2, grosor, archivo_salida="")

Dibuja las dos copias autosemejantes del dragón y guarda el PNG.
Devuelve la ruta del archivo.
"""
function graficar_plegado_dragon(;
        iteraciones::Int = 10,
        color1::String = "#1d4ed8",   # Azul rey (Copia 1)
        color2::String = "#ea580c",   # Naranja intenso (Copia 2)
        grosor::Real = 2.5,
        archivo_salida::String = ""
    )
    t0 = time()

    iteraciones < 2 && salir_con_error("El número de iteraciones debe ser al menos 2.")

    if isempty(archivo_salida)
        archivo_salida = ruta_assets("self-similar-dragon",
                                     "dragon_autosemejante_i$(iteraciones).png")
    else
        mkpath(dirname(abspath(archivo_salida)))
    end

    seccion("Parámetros")
    parametros(
        "Iteraciones" => iteraciones,
        "Copia 1"     => color1,
        "Copia 2"     => color2,
        "Grosor"      => grosor,
    )

    seccion("Generación")
    paso(1, 3, "Generando giros y puntos del dragón")
    giros = generar_giros_dragon(iteraciones)
    pts = giros_a_puntos(giros)
    msg_info("Puntos de la curva: $(length(pts))")

    # División exacta por el punto medio en 2 copias autosemejantes
    total_puntos = length(pts)
    idx_medio = div(total_puntos - 1, 2) + 1

    pts_copia1 = pts[1:idx_medio]
    pts_copia2 = pts[idx_medio:end]
    pt_plegado = pts[idx_medio]

    paso(2, 3, "Dibujando las dos copias y el punto de pegado")
    p = plot(
        aspect_ratio = :equal,
        framestyle = :none,
        grid = false,
        ticks = false,

        legend = :topright,
        legendfont = font(25, :black),
        legendtitlefont = font(50, :bold, :black),

        size = (1600, 1000),
        margin = 15Plots.mm,
        background_color = :white
    )

    # Copia 1: f₁(D)
    plot!(p, real.(pts_copia1), imag.(pts_copia1),
          color = color1, linewidth = grosor, label = "Copia 1")

    # Copia 2: f₂(D)
    plot!(p, real.(pts_copia2), imag.(pts_copia2),
          color = color2, linewidth = grosor, label = "Copia 2")

    # Punto de plegado
    scatter!(p, [real(pt_plegado)], [imag(pt_plegado)],
             color = :black,
             markersize = 7,
             markerstrokewidth = 1.5,
             markerstrokecolor = :white,
             label = "Punto de pegado")

    paso(3, 3, "Guardando la imagen")
    savefig(p, archivo_salida)

    msg_resultado(archivo_salida; segundos = time() - t0)
    return archivo_salida
end

# ==============================================================================
# 3. AYUDA
# ==============================================================================

function ayuda()
    mostrar_ayuda(
        titulo = "Dragón autosemejante: D = f₁(D) ∪ f₂(D)",
        descripcion = "Plegado del dragón en dos copias unidas por el punto de pegado",
        uso = "julia --project=. scripts/folding_dragon_curve.jl [OPCIONES]",
        opciones = [
            ("-i, --iter <int>",      "Número de iteraciones, ≥ 2 [defecto: 10]"),
            ("-g, --grosor <float>",  "Grosor de la línea [defecto: 2.5]"),
            ("-c1, --color1 <color>", "Color de la Copia 1, HEX o nombre [defecto: #1d4ed8]"),
            ("-c2, --color2 <color>", "Color de la Copia 2, HEX o nombre [defecto: #ea580c]"),
            ("-o, --out <ruta>",      "Archivo de salida [defecto: assets/self-similar-dragon/...]"),
            ("-h, --help",            "Muestra esta ayuda"),
        ],
        ejemplos = [
            "julia --project=. scripts/folding_dragon_curve.jl",
            "julia --project=. scripts/folding_dragon_curve.jl -i 12 -g 3.0",
            "julia --project=. scripts/folding_dragon_curve.jl -c1 \"#0f766e\" -c2 \"#d97706\"",
        ],
    )
end

# ==============================================================================
# 4. PUNTO DE ENTRADA
# ==============================================================================

function main()
    if pide_ayuda(ARGS)
        ayuda()
        return
    end

    iteraciones, grosor, color1, color2, salida = 10, 2.5, "#1d4ed8", "#ea580c", ""

    banner("Dragón autosemejante: D = f₁(D) ∪ f₂(D)")

    v = parsear_banderas(ARGS, ALIAS)
    haskey(v, :iter)   && (iteraciones = a_entero(v[:iter], "--iter"))
    haskey(v, :grosor) && (grosor = a_real(v[:grosor], "--grosor"))
    haskey(v, :color1) && (color1 = v[:color1])
    haskey(v, :color2) && (color2 = v[:color2])
    haskey(v, :out)    && (salida = v[:out])

    graficar_plegado_dragon(
        iteraciones = iteraciones,
        color1 = color1,
        color2 = color2,
        grosor = grosor,
        archivo_salida = salida
    )
end

main()
