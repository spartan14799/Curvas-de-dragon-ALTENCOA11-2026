# ==============================================================================
# seed_dragon_curve.jl — Curva del dragón generada por una semilla
# ==============================================================================
# Genera la palabra del dragón a partir de una semilla S₁ (palabra en {D, U})
# con dos definiciones equivalentes y dibuja la curva en el plano complejo.
#   Método 1 (Recurrencia directa):  S_{n+1} = S_n · S₁ · S̄_n^R
#   Método 2 (Producto de plegado):  intercala S_n y S̄_n^R con cada letra de S₁
#
# Uso:     julia --project=. scripts/seed_dragon_curve.jl [OPCIONES]
# Ayuda:   julia --project=. scripts/seed_dragon_curve.jl --help
# Salida:  assets/seed-curves/{first_definition,second_definition}/
#          curva_dragon_<SEMILLA>_i<iter>_p<paleta>[_sinejes].png
# ==============================================================================

using Plots

include(joinpath(@__DIR__, "terminal_ui.jl"))
using .TerminalUI

gr()

# ==============================================================================
# CATÁLOGO DE COLORES
# ==============================================================================

const PALETAS = Dict(
    1 => ("Azul Rey",              "#1d4ed8"),
    2 => ("Azul Noche / Oscuro",   "#0f172a"),
    3 => ("Azul Océano",           "#0284c7"),
    4 => ("Naranja Intenso",       "#ea580c"),
    5 => ("Naranja Ámbar / Dorado", "#d97706"),
    6 => ("Verde Teal / Turquesa", "#0f766e"),
    7 => ("Índigo / Violeta",      "#4f46e5"),
    8 => ("Gris Pizarra",          "#334155"),
)

const FUENTE_POSTER = "Palatino-Roman"

const ALIAS = Dict(
    "--seed" => :seed,     "-s" => :seed,
    "--iter" => :iter,     "-i" => :iter,
    "--metodo" => :metodo, "-m" => :metodo,
    "--paleta" => :paleta, "-p" => :paleta,
    "--ejes" => :ejes,     "-e" => :ejes,
    "--grosor" => :grosor, "-g" => :grosor,
    "--out" => :out,       "-o" => :out,
)

lineas_paletas() = [linea_catalogo(k, PALETAS[k][1], [PALETAS[k][2]])
                    for k in sort(collect(keys(PALETAS)))]

# ==============================================================================
# LÓGICA DE TRANSFORMACIÓN DE SECUENCIAS
# ==============================================================================

function inverse_sequence(s::AbstractString)
    trans = Dict('D' => 'U', 'U' => 'D')
    return String([trans[c] for c in reverse(uppercase(s))])
end

# --- Definición 1: recurrencia directa  S_{n+1} = S_n * S_1 * \bar{(S_n)^R} ---
function generate_word_direct(seed::AbstractString, iterations::Int)
    s1 = uppercase(seed)
    sn = s1
    for _ in 2:iterations
        sn_bar = inverse_sequence(sn)
        sn = sn * s1 * sn_bar
    end
    return sn
end

# --- Definición 2: producto de plegado (intercalado por caracteres) ---
function folding_product(s::AbstractString, t::AbstractString)
    s_upper = uppercase(s)
    t_upper = uppercase(t)
    s_bar = inverse_sequence(s_upper)
    len_t = length(t_upper)
    chars_t = collect(t_upper)

    buf = IOBuffer()
    for i in 1:len_t
        block = isodd(i) ? s_upper : s_bar
        print(buf, block)
        print(buf, chars_t[i])
    end
    print(buf, isodd(len_t + 1) ? s_upper : s_bar)

    return String(take!(buf))
end

function generate_word_folding(seed::AbstractString, iterations::Int)
    word = uppercase(seed)
    for _ in 2:iterations
        word = folding_product(word, uppercase(seed))
    end
    return word
end

# --- Conversión de la palabra a coordenadas en el plano complejo ---
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

# Muestra solo el inicio de palabras muy largas para no inundar la terminal.
resumen_palabra(w::AbstractString; max::Int = 64) =
    length(w) <= max ? w : string(first(w, max), "… (+", length(w) - max, " más)")

# ==============================================================================
# GENERACIÓN DE IMAGEN Y EXPORTACIÓN
# ==============================================================================

"""
    graficar_curva_unica_semilla(seed, iteraciones; metodo=1, id_paleta=1,
                                 con_ejes=true, grosor=3.0, archivo_salida="")

Genera la curva para la semilla dada y la guarda como PNG.
Devuelve la ruta del archivo.
"""
function graficar_curva_unica_semilla(
        seed::AbstractString,
        iteraciones::Int;
        metodo::Int = 1,
        id_paleta::Int = 1,
        con_ejes::Bool = true,
        grosor::Real = 3.0,
        archivo_salida::String = ""
    )
    t0 = time()

    id_valido = haskey(PALETAS, id_paleta) ? id_paleta : 1
    id_valido != id_paleta &&
        msg_aviso("El color $id_paleta no existe; se usa el color $id_valido.")
    nombre_color, color_elegido = PALETAS[id_valido]

    nombre_metodo = metodo == 1 ? "Recurrencia directa" : "Producto de plegado"
    carpeta_metodo = metodo == 1 ? "first_definition" : "second_definition"

    if isempty(archivo_salida)
        sufijo = con_ejes ? "" : "_sinejes"
        archivo_salida = ruta_assets(joinpath("seed-curves", carpeta_metodo),
            "curva_dragon_$(uppercase(seed))_i$(iteraciones)_p$(id_valido)$(sufijo).png")
    else
        mkpath(dirname(abspath(archivo_salida)))
    end

    seccion("Parámetros")
    parametros(
        "Método"      => "[$metodo] $nombre_metodo",
        "Semilla (S₁)" => uppercase(seed),
        "Iteraciones" => iteraciones,
        "Color"       => "[$id_valido] $nombre_color ($color_elegido)",
        "Grosor"      => grosor,
        "Ejes"        => con_ejes ? "Sí" : "No",
        "Fuente"      => FUENTE_POSTER,
    )

    seccion("Generación")
    paso(1, 3, "Generando la palabra del dragón")
    word = metodo == 1 ? generate_word_direct(seed, iteraciones) :
                         generate_word_folding(seed, iteraciones)
    msg_info("Longitud: $(length(word)) giros")
    msg_info("Palabra:  $(resumen_palabra(word))")

    paso(2, 3, "Convirtiendo la palabra en puntos del plano complejo")
    pts = word_to_points(word)
    xs = real.(pts)
    ys = imag.(pts)

    paso(3, 3, "Dibujando y guardando la imagen")
    p = plot(
        xs, ys,
        color = color_elegido,
        linewidth = grosor,
        aspect_ratio = :equal,
        fontfamily = FUENTE_POSTER,

        # --- Con / sin ejes ---
        framestyle = con_ejes ? :zerolines : :none,
        xlabel = con_ejes ? "Re(z)" : "",
        ylabel = con_ejes ? "Im(z)" : "",
        guidefont = font(18, FUENTE_POSTER, :black),
        tickfont = font(14, FUENTE_POSTER, :black),
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

    con_ejes && scatter!(p, [0], [0], color = :black, markersize = 4, markerstrokewidth = 0)

    # --- Etiqueta de la semilla (siempre visible) ---
    min_x, max_x = minimum(xs), maximum(xs)
    min_y, max_y = minimum(ys), maximum(ys)

    mid_x = (min_x + max_x) / 2.0
    dy = max_y - min_y
    dy = dy == 0 ? 1.0 : dy

    # Margen vertical extra para el texto inferior
    ylims!(p, min_y - 0.12 * dy, max_y + 0.05 * dy)
    annotate!(p, mid_x, min_y - 0.06 * dy,
              text("Semilla: $(uppercase(seed))", font(18, FUENTE_POSTER, :black)))

    savefig(p, archivo_salida)

    msg_resultado(archivo_salida; segundos = time() - t0)
    return archivo_salida
end

# ==============================================================================
# AYUDA
# ==============================================================================

function ayuda()
    mostrar_ayuda(
        titulo = "Curva del dragón por semilla",
        descripcion = "Palabra del dragón sobre {D, U} a partir de una semilla S₁",
        uso = "julia --project=. scripts/seed_dragon_curve.jl [OPCIONES]",
        opciones = [
            ("-s, --seed <palabra>", "Semilla inicial en {D, U} (ej: UUDD, UDU, D) [defecto: UUDD]"),
            ("-i, --iter <int>",     "Número de iteraciones [defecto: 6]"),
            ("-m, --metodo <int>",   "Definición: 1 (directa) o 2 (plegado) [defecto: 1]"),
            ("-p, --paleta <int>",   "ID de color, 1 a 8 [defecto: 1]"),
            ("-e, --ejes <bool>",    "Mostrar ejes y cuadrícula: true/false [defecto: true]"),
            ("-g, --grosor <float>", "Grosor de la línea [defecto: 3.0]"),
            ("-o, --out <ruta>",     "Archivo de salida [defecto: assets/seed-curves/...]"),
            ("-h, --help",           "Muestra esta ayuda"),
        ],
        catalogos = ["Colores" => lineas_paletas()],
        ejemplos = [
            "julia --project=. scripts/seed_dragon_curve.jl",
            "julia --project=. scripts/seed_dragon_curve.jl -s UUDD -i 6 -m 1 -p 4 -e true -g 3.5",
            "julia --project=. scripts/seed_dragon_curve.jl --seed UDU --iter 7 --paleta 2 --ejes false",
            "julia --project=. scripts/seed_dragon_curve.jl UDU 7 2 2 false   # posicional",
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

    seed, iter, metodo, id_paleta, con_ejes, grosor, salida =
        "UUDD", 6, 1, 1, true, 3.0, ""

    banner("Curva del dragón por semilla")

    if isempty(ARGS)
        # MODO INTERACTIVO
        msg_info("Modo interactivo (usa --help para ver las opciones por terminal)")
        println()
        seed = leer_texto("Semilla en {D, U} (ej: UUDD, UDU, D)", seed)
        iter = a_entero(leer_texto("Número de iteraciones", string(iter)), "iteraciones")

        seccion("Definición formal de la curva")
        println("  ", linea_catalogo(1, "Recurrencia directa:  S_{n+1} = S_n · S₁ · S̄_n^R", String[]))
        println("  ", linea_catalogo(2, "Producto de plegado:  intercala S_n y S̄_n^R con cada letra de S₁", String[]))
        println()
        metodo = a_entero(leer_texto("Opción (1/2)", string(metodo)), "método")

        seccion("Colores")
        foreach(l -> println("  ", l), lineas_paletas())
        println()
        id_paleta = a_entero(leer_texto("Color (1-8)", string(id_paleta)), "color")

        con_ejes = leer_si_no("¿Mostrar ejes y cuadrícula?")
        grosor = a_real(leer_texto("Grosor de la línea", string(grosor)), "grosor")

    elseif any(a -> startswith(a, "-"), ARGS)
        # MODO BANDERAS
        v = parsear_banderas(ARGS, ALIAS)
        haskey(v, :seed)   && (seed = v[:seed])
        haskey(v, :iter)   && (iter = a_entero(v[:iter], "--iter"))
        haskey(v, :metodo) && (metodo = a_entero(v[:metodo], "--metodo"))
        haskey(v, :paleta) && (id_paleta = a_entero(v[:paleta], "--paleta"))
        haskey(v, :ejes)   && (con_ejes = parsear_bool(v[:ejes]))
        haskey(v, :grosor) && (grosor = a_real(v[:grosor], "--grosor"))
        haskey(v, :out)    && (salida = v[:out])

    else
        # MODO POSICIONAL: <semilla> <iteraciones> [metodo] [paleta] [ejes] [grosor]
        length(ARGS) >= 1 && (seed = ARGS[1])
        length(ARGS) >= 2 && (iter = a_entero(ARGS[2], "iteraciones"))
        length(ARGS) >= 3 && (metodo = a_entero(ARGS[3], "método"))
        length(ARGS) >= 4 && (id_paleta = a_entero(ARGS[4], "paleta"))
        length(ARGS) >= 5 && (con_ejes = parsear_bool(ARGS[5]))
        length(ARGS) >= 6 && (grosor = a_real(ARGS[6], "grosor"))
    end

    # --- Validaciones ---
    (isempty(seed) || !all(c -> c in ('D', 'U'), uppercase(seed))) &&
        salir_con_error("La semilla debe ser una palabra no vacía formada solo por D y U (recibido: '$seed').")
    iter < 1 && salir_con_error("Las iteraciones deben ser ≥ 1.")
    metodo in (1, 2) || salir_con_error("El método debe ser 1 (directa) o 2 (plegado).")

    graficar_curva_unica_semilla(
        seed, iter;
        metodo = metodo,
        id_paleta = id_paleta,
        con_ejes = con_ejes,
        grosor = grosor,
        archivo_salida = salida
    )
end

main()
