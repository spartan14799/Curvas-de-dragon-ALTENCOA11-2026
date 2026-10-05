# ==============================================================================
# dragon_curve.jl — Curva del dragón con gradiente de color
# ==============================================================================
# Construye la curva de Heighway con 2ⁿ segmentos usando la regla de giros
# en el plano complejo Z[i]. Dibuja la curva con gradiente de color.
#
# Uso:     julia --project=. scripts/dragon_curve.jl [OPCIONES]
# Ayuda:   julia --project=. scripts/dragon_curve.jl --help
# Salida:  assets/basic-dragon/curva_dragon_i<n>_p<paleta>[_sinejes].png
# ==============================================================================

using Plots

include(joinpath(@__DIR__, "terminal_ui.jl"))
using .TerminalUI

gr()

# ==============================================================================
# CATÁLOGO DE PALETAS Y GRADIENTES
# ==============================================================================

const PALETAS = Dict(
    1 => ("Gradiente Mágico (Viridis/Plasma)", cgrad([
            "#0d0887", "#46039f", "#7201a8", "#9e1795", "#bd3786",
            "#d8576b", "#ed7953", "#fb9f3a", "#fdca26", "#f0e821",
            "#b9de28", "#6ece58", "#29af7f", "#1fa187", "#1c7c93", "#2a5a8a"
        ], 256)),
    2 => ("Fuego e Incienso", cgrad(["#000000", "#7f0000", "#d7301f", "#ef6548", "#fdbb84", "#fff7ec"], 256)),
    3 => ("Océano Profundo", cgrad(["#020617", "#0f172a", "#1e3a8a", "#0284c7", "#38bdf8", "#a5f3fc"], 256)),
    4 => ("Neón Ciberpunk", cgrad(["#2e1065", "#7e22ce", "#c026d3", "#db2777", "#f43f5e", "#22d3ee"], 256)),
    5 => ("Bosque Esmeralda", cgrad(["#022c22", "#064e3b", "#047857", "#10b981", "#6ee7b7", "#a7f3d0"], 256)),
    6 => ("Arcoíris Turbo", :turbo),
    7 => ("Atardecer Ámbar", cgrad(["#31103f", "#621850", "#b83253", "#e66045", "#f89e47", "#fae368"], 256)),
    8 => ("Piedra Pizarra", cgrad(["#0f172a", "#1e293b", "#334155", "#475569", "#64748b", "#cbd5e1"], 256)),
)

const ALIAS = Dict(
    "--iter"   => :iter,   "-i" => :iter,
    "--paleta" => :paleta, "-p" => :paleta,
    "--ejes"   => :ejes,   "-e" => :ejes,
    "--grosor" => :grosor, "-g" => :grosor,
    "--tam"    => :tam,    "-t" => :tam,
    "--out"    => :out,    "-o" => :out,
)

lineas_paletas() = [linea_catalogo(k, PALETAS[k][1], String[]) for k in sort(collect(keys(PALETAS)))]

# ==============================================================================
# GENERACIÓN DE PUNTOS EN Z[i]
# ==============================================================================

function dragon_points(n::Int)
    N = 2^n
    puntos = ComplexF64[0.0 + 0.0im, 1.0 + 0.0im]
    dir = 1.0 + 0.0im
    for k in 1:(N - 1)
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
    generar_curva_png(n; id_paleta=1, con_ejes=false, grosor=2.0, tam=800, archivo_final="")

Dibuja la curva del dragón con 2ⁿ segmentos.
Devuelve la ruta del archivo generado.
"""
function generar_curva_png(
        n::Int;
        id_paleta::Int = 1,
        con_ejes::Bool = false,
        grosor::Real = 2.0,
        tam::Int = 800,
        archivo_final::String = ""
    )
    t0 = time()

    id_valido = haskey(PALETAS, id_paleta) ? id_paleta : 1
    id_valido != id_paleta && msg_aviso("La paleta $id_paleta no existe; se usa la paleta $id_valido.")
    nombre_paleta, gradiente = PALETAS[id_valido]

    if isempty(archivo_final)
        sufijo_ejes = con_ejes ? "" : "_sinejes"
        archivo_final = ruta_assets("basic-dragon",
            "curva_dragon_i$(n)_p$(id_valido)$(sufijo_ejes).png")
    else
        mkpath(dirname(abspath(archivo_final)))
    end

    seccion("Parámetros")
    parametros(
        "Iteraciones" => n,
        "Segmentos"   => 2^n,
        "Gama/Paleta" => "[$id_valido] $nombre_paleta",
        "Ejes"        => con_ejes ? "Sí" : "No",
        "Grosor"      => grosor,
        "Tamaño"      => "$(tam)×$(tam) px",
    )

    seccion("Generación")
    paso(1, 3, "Calculando puntos en Z[i]")
    pts = dragon_points(n)
    msg_info("Puntos generados: $(length(pts))")

    paso(2, 3, "Graficando la curva con gradiente")
    xs = real.(pts)
    ys = imag.(pts)
    t = range(0, 1, length = length(pts))

    p = plot(
        aspect_ratio = :equal,
        framestyle = con_ejes ? :zerolines : :none,
        xlabel = con_ejes ? "Re(z)" : "",
        ylabel = con_ejes ? "Im(z)" : "",
        guidefont = font(14, "DejaVu Serif", :black),
        tickfont = font(10, "DejaVu Serif", :black),
        grid = con_ejes,
        gridalpha = 0.25,
        gridstyle = :dash,
        ticks = con_ejes,
        legend = false,
        size = (tam, tam),
        dpi = 300,
        background_color = :white
    )

    plot!(p, xs, ys,
          line_z = t,
          color = gradiente,
          linewidth = grosor)

    con_ejes && scatter!(p, [0], [0], color = :black, markersize = 4, markerstrokewidth = 0)

    paso(3, 3, "Guardando la imagen")
    savefig(p, archivo_final)

    msg_resultado(archivo_final; segundos = time() - t0)
    return archivo_final
end

# ==============================================================================
# AYUDA
# ==============================================================================

function ayuda()
    mostrar_ayuda(
        titulo = "Curva del dragón con gradiente de color",
        descripcion = "Curva de Heighway con 2ⁿ segmentos y paletas de color",
        uso = "julia --project=. scripts/dragon_curve.jl [OPCIONES]",
        opciones = [
            ("-i, --iter <int>",     "Número de iteraciones n (2ⁿ segmentos) [defecto: 7]"),
            ("-p, --paleta <int>",   "ID de la gama de colores, 1 a 8 [defecto: 1]"),
            ("-e, --ejes <bool>",    "Mostrar ejes y cuadrícula: true/false [defecto: false]"),
            ("-g, --grosor <float>", "Grosor de la línea [defecto: 2.0]"),
            ("-t, --tam <int>",      "Lado de la imagen en píxeles [defecto: 800]"),
            ("-o, --out <ruta>",     "Archivo de salida [defecto: assets/basic-dragon/...]"),
            ("-h, --help",           "Muestra esta ayuda"),
        ],
        catalogos = ["Gamas de colores disponibles" => lineas_paletas()],
        ejemplos = [
            "julia --project=. scripts/dragon_curve.jl",
            "julia --project=. scripts/dragon_curve.jl -i 12 -p 4 -g 1.5",
            "julia --project=. scripts/dragon_curve.jl -i 10 -p 2 -e true",
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

    n, id_paleta, con_ejes, grosor, tam, salida = 7, 1, false, 2.0, 800, ""

    banner("Curva del dragón con gradiente")

    if isempty(ARGS)
        msg_info("Modo interactivo (usa --help para ver opciones por terminal)")
        println()
        n = a_entero(leer_texto("Número de iteraciones n (ej: 10)", string(n)), "iteraciones")

        seccion("Gamas de colores")
        foreach(l -> println("  ", l), lineas_paletas())
        println()
        id_paleta = a_entero(leer_texto("Gama de colores (1-8)", string(id_paleta)), "paleta")

        con_ejes = leer_si_no("¿Mostrar ejes y cuadrícula?"; defecto = false)
        grosor = a_real(leer_texto("Grosor de línea", string(grosor)), "grosor")

    elseif any(a -> startswith(a, "-"), ARGS)
        v = parsear_banderas(ARGS, ALIAS)
        haskey(v, :iter)   && (n = a_entero(v[:iter], "--iter"))
        haskey(v, :paleta) && (id_paleta = a_entero(v[:paleta], "--paleta"))
        haskey(v, :ejes)   && (con_ejes = parsear_bool(v[:ejes]))
        haskey(v, :grosor) && (grosor = a_real(v[:grosor], "--grosor"))
        haskey(v, :tam)    && (tam = a_entero(v[:tam], "--tam"))
        haskey(v, :out)    && (salida = v[:out])
    else
        n = a_entero(ARGS[1], "iteraciones")
        length(ARGS) >= 2 && (id_paleta = a_entero(ARGS[2], "paleta"))
        length(ARGS) >= 3 && (con_ejes = parsear_bool(ARGS[3]))
    end

    n < 1 && salir_con_error("Las iteraciones deben ser ≥ 1.")
    tam < 50 && salir_con_error("El tamaño debe ser de al menos 50 px.")

    generar_curva_png(
        n;
        id_paleta = id_paleta,
        con_ejes = con_ejes,
        grosor = grosor,
        tam = tam,
        archivo_final = salida
    )
end

main()
