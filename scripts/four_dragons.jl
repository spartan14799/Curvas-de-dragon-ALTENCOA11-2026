# ==============================================================================
# four_dragons.jl — Teselado del plano con 4 dragones
# ==============================================================================
# Dibuja el dragón clásico (Heighway) rotado por 1, i, -1, -i alrededor del
# origen para obtener el mosaico de 4 dragones.
#
# Uso:     julia --project=. scripts/four_dragons.jl [OPCIONES]
# Ayuda:   julia --project=. scripts/four_dragons.jl --help
# Salida:  assets/four-dragons/mosaico_4dragones_i<iter>_p<paleta>[_sinejes].png
# ==============================================================================

using Plots

include(joinpath(@__DIR__, "terminal_ui.jl"))
using .TerminalUI

gr()

# ==============================================================================
# CATÁLOGO DE PALETAS
# ==============================================================================
# Para las paletas de 2 colores se alternan los tonos [C1, C2, C1, C2]
# y así se aplican a los 4 dragones rotados.

const PALETAS = Dict(
    1 => ("Monocromática Azul Profundo (4 tonos)",
          ["#0a1128", "#1c2541", "#2a3d66", "#475b87"]),
    2 => ("Ocean Teal / Azul-Verdoso (4 tonos)",
          ["#0f172a", "#133e4b", "#1e555c", "#2a7272"]),
    3 => ("Azul e Índigo Profundo (4 tonos)",
          ["#0f172a", "#1e1b4b", "#2e1065", "#3730a3"]),
    4 => ("Azul Pizarra y Neutros (4 tonos)",
          ["#0f172a", "#1e293b", "#334155", "#475569"]),
    5 => ("Bicromática Azul y Naranja Intenso (2 colores)",
          ["#1d4ed8", "#ea580c", "#1d4ed8", "#ea580c"]),
    6 => ("Bicromática Azul Marino y Ámbar Suave (2 colores)",
          ["#1e3a8a", "#d97706", "#1e3a8a", "#d97706"]),
    7 => ("Cuadricromática Azul y Naranja (4 colores)",
          ["#1d4ed8", "#ea580c", "#0284c7", "#f59e0b"]),
)

const ALIAS = Dict(
    "--iter" => :iter,     "-i" => :iter,
    "--ejes" => :ejes,     "-e" => :ejes,
    "--paleta" => :paleta, "-p" => :paleta,
    "--grosor" => :grosor, "-g" => :grosor,
    "--out" => :out,       "-o" => :out,
)

lineas_paletas() = [linea_catalogo(k, PALETAS[k][1], PALETAS[k][2])
                    for k in sort(collect(keys(PALETAS)))]

# ==============================================================================
# LÓGICA DE GENERACIÓN
# ==============================================================================

function inverse_sequence(s::AbstractString)
    trans = Dict('D' => 'U', 'U' => 'D')
    return String([trans[c] for c in reverse(uppercase(s))])
end

# Secuencia del dragón clásico: S_{n+1} = S_n * D * S̄_n^R
function generate_classic_dragon_word(iterations::Int)
    sn = "D"
    for _ in 2:iterations
        sn_bar = inverse_sequence(sn)
        sn = sn * "D" * sn_bar
    end
    return sn
end

function word_to_points(word::AbstractString)
    turns = [c == 'D' ? π/2 : -π/2 for c in uppercase(word)]
    all_turns = vcat(0.0, turns)

    points = ComplexF64[0.0 + 0.0im]
    current_angle = 0.0

    for α in all_turns
        current_angle += α
        push!(points, last(points) + cis(current_angle))
    end
    return points
end

# ==============================================================================
# GRAFICACIÓN DEL MOSAICO
# ==============================================================================

"""
    graficar_4_dragones(iteraciones; con_ejes=true, id_paleta=1, archivo_salida="", grosor=5.0)

Genera el mosaico con la paleta elegida y lo guarda como PNG.
Devuelve la ruta del archivo.
"""
function graficar_4_dragones(
        iteraciones::Int;
        con_ejes::Bool = true,
        id_paleta::Int = 1,
        archivo_salida::String = "",
        grosor::Real = 5.0
    )
    t0 = time()

    id_valido = haskey(PALETAS, id_paleta) ? id_paleta : 1
    id_valido != id_paleta &&
        msg_aviso("La paleta $id_paleta no existe; se usa la paleta $id_valido.")
    nombre_paleta, colores_elegidos = PALETAS[id_valido]

    if isempty(archivo_salida)
        sufijo = con_ejes ? "" : "_sinejes"
        archivo_salida = ruta_assets("four-dragons",
            "mosaico_4dragones_i$(iteraciones)_p$(id_valido)$(sufijo).png")
    else
        mkpath(dirname(abspath(archivo_salida)))
    end

    seccion("Parámetros")
    parametros(
        "Iteraciones" => iteraciones,
        "Paleta"      => "[$id_valido] $nombre_paleta",
        "Ejes"        => con_ejes ? "Sí" : "No",
        "Grosor"      => grosor,
    )

    seccion("Generación")
    paso(1, 3, "Generando la palabra del dragón")
    word = generate_classic_dragon_word(iteraciones)
    pts_base = word_to_points(word)
    msg_info("Longitud de la palabra: $(length(word)) giros")

    paso(2, 3, "Trazando las 4 rotaciones (1, i, -1, -i)")
    p = plot(
        aspect_ratio = :equal,
        framestyle = con_ejes ? :zerolines : :none,
        xlabel = con_ejes ? "Re(z)" : "",
        ylabel = con_ejes ? "Im(z)" : "",
        guidefont = font(18, "DejaVu Serif", :black),
        tickfont = font(14, "DejaVu Serif", :black),
        ticklinewidth = con_ejes ? 2.0 : 0.0,
        grid = con_ejes,
        gridalpha = 0.25,
        gridstyle = :dash,
        gridlinewidth = 1.0,
        ticks = con_ejes,
        legend = false,
        size = (1200, 1200),
        dpi = 300,
        background_color = :white
    )

    rotaciones = [1.0 + 0.0im, 0.0 + 1.0im, -1.0 + 0.0im, 0.0 - 1.0im]
    for (k, rot) in enumerate(rotaciones)
        pts_rot = pts_base .* rot
        plot!(p, real.(pts_rot), imag.(pts_rot),
              color = colores_elegidos[k], linewidth = grosor)
    end

    con_ejes && scatter!(p, [0], [0], color = :black, markersize = 5, markerstrokewidth = 0)

    paso(3, 3, "Guardando la imagen")
    savefig(p, archivo_salida)

    msg_resultado(archivo_salida; segundos = time() - t0)
    return archivo_salida
end

# ==============================================================================
# AYUDA
# ==============================================================================

function ayuda()
    mostrar_ayuda(
        titulo = "Teselado del plano: mosaico de 4 dragones",
        descripcion = "Dragón de Heighway rotado por 1, i, -1, -i",
        uso = "julia --project=. scripts/four_dragons.jl [OPCIONES]",
        opciones = [
            ("-i, --iter <int>",    "Número de iteraciones [defecto: 6]"),
            ("-e, --ejes <bool>",   "Mostrar ejes y cuadrícula: true/false [defecto: true]"),
            ("-p, --paleta <int>",  "ID de paleta, 1 a 7 [defecto: 1]"),
            ("-g, --grosor <float>", "Grosor de la línea [defecto: 5.0]"),
            ("-o, --out <ruta>",    "Archivo de salida [defecto: assets/four-dragons/...]"),
            ("-h, --help",          "Muestra esta ayuda"),
        ],
        catalogos = ["Paletas de color" => lineas_paletas()],
        ejemplos = [
            "julia --project=. scripts/four_dragons.jl",
            "julia --project=. scripts/four_dragons.jl -i 8 -e false -p 7",
            "julia --project=. scripts/four_dragons.jl 8 false 7   # modo posicional",
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

    iter, con_ejes, id_paleta, grosor, salida = 6, true, 1, 5.0, ""

    banner("Teselado del plano: mosaico de 4 dragones")

    if isempty(ARGS)
        # MODO INTERACTIVO
        msg_info("Modo interactivo (usa --help para ver las opciones por terminal)")
        println()
        iter = a_entero(leer_texto("Número de iteraciones (ej: 8)", string(iter)), "iteraciones")
        con_ejes = leer_si_no("¿Mostrar ejes y cuadrícula?")
        seccion("Paletas de color")
        foreach(l -> println("  ", l), lineas_paletas())
        println()
        id_paleta = a_entero(leer_texto("Paleta (1-7)", string(id_paleta)), "paleta")

    elseif any(a -> startswith(a, "-"), ARGS)
        # MODO BANDERAS
        v = parsear_banderas(ARGS, ALIAS)
        haskey(v, :iter)   && (iter = a_entero(v[:iter], "--iter"))
        haskey(v, :ejes)   && (con_ejes = parsear_bool(v[:ejes]))
        haskey(v, :paleta) && (id_paleta = a_entero(v[:paleta], "--paleta"))
        haskey(v, :grosor) && (grosor = a_real(v[:grosor], "--grosor"))
        haskey(v, :out)    && (salida = v[:out])

    else
        # MODO POSICIONAL: <iteraciones> [ejes] [paleta]
        iter = a_entero(ARGS[1], "iteraciones")
        length(ARGS) >= 2 && (con_ejes = parsear_bool(ARGS[2]))
        length(ARGS) >= 3 && (id_paleta = a_entero(ARGS[3], "paleta"))
    end

    iter < 1 && salir_con_error("Las iteraciones deben ser ≥ 1.")

    graficar_4_dragones(iter; con_ejes = con_ejes, id_paleta = id_paleta,
                        grosor = grosor, archivo_salida = salida)
end

main()
