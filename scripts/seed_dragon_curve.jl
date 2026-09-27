using Plots

gr()

# ====================
# CATÁLOGO DE COLORES ÚNICOS
# ====================
const PALETAS = Dict(
    1 => ("Azul Rey", "#1d4ed8"),
    2 => ("Azul Noche / Oscuro", "#0f172a"),
    3 => ("Azul Océano", "#0284c7"),
    4 => ("Naranja Intenso", "#ea580c"),
    5 => ("Naranja Ámbar / Dorado", "#d97706"),
    6 => ("Verde Teal / Turquesa", "#0f766e"),
    7 => ("Índigo / Violeta", "#4f46e5"),
    8 => ("Gris Pizarra", "#334155")
)

const FUENTE_POSTER = "Palatino-Roman"

# ====================
# LÓGICA DE TRANSFORMACIÓN DE SECUENCIAS
# ====================

function inverse_sequence(s::AbstractString)
    trans = Dict('D' => 'U', 'U' => 'D')
    return String([trans[c] for c in reverse(uppercase(s))])
end

# --- DEFINICIÓN 1: Recurrencia directa (S_{n+1} = S_n * S_1 * \bar{(S_n)^R}) ---
function generate_word_direct(seed::AbstractString, iterations::Int)
    s1 = uppercase(seed)
    sn = s1
    for _ in 2:iterations
        sn_bar = inverse_sequence(sn)
        sn = sn * s1 * sn_bar
    end
    return sn
end

# --- DEFINICIÓN 2: Producto de plegado (Intercalado por caracteres) ---
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

# --- CONVERSIÓN DE CADENA A COORDENADAS PLANO COMPLEJO ---
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

# ====================
# GENERACIÓN DE IMAGEN Y EXPORTACIÓN
# ====================

function graficar_curva_unica_semilla(
        seed::AbstractString, 
        iteraciones::Int; 
        metodo::Int=1,
        id_paleta::Int=1,
        con_ejes::Bool=true,
        grosor::Real=3.0,
        archivo_salida::String=""
    )
    # Validar color elegido
    id_valido = haskey(PALETAS, id_paleta) ? id_paleta : 1
    nombre_color, color_elegido = PALETAS[id_valido]

    # Seleccionar algoritmo según la definición elegida
    word = metodo == 1 ? generate_word_direct(seed, iteraciones) : generate_word_folding(seed, iteraciones)
    nombre_metodo = metodo == 1 ? "Recurrencia Directa" : "Producto de Plegado"
    carpeta_submetodo = metodo == 1 ? "first_definition" : "second_definition"

    println("\n==================================================")
    println("Método: ", nombre_metodo)
    println("Semilla (S₁): ", uppercase(seed))
    println("Iteración (n): ", iteraciones)
    println("Palabra resultante: ", word)
    println("Longitud total: ", length(word), " caracteres")
    println("Color seleccionado [$id_valido]: ", nombre_color, " (", color_elegido, ")")
    println("Grosor de línea: ", grosor)
    println("Ejes visibles: ", con_ejes ? "Sí" : "No")
    println("Fuente empleada: ", FUENTE_POSTER)
    println("==================================================\n")

    suffix_ejes = con_ejes ? "" : "_sinejes"
    if isempty(archivo_salida)
        archivo_salida = "../assets/seed-curves/$carpeta_submetodo/curva_dragon_$(uppercase(seed))_i$(iteraciones)_p$(id_valido)$(suffix_ejes).png"
    end

    dir_salida = dirname(archivo_salida)
    if !isempty(dir_salida) && !isdir(dir_salida)
        mkpath(dir_salida)
    end

    pts = word_to_points(word)
    xs = real.(pts)
    ys = imag.(pts)

    p = plot(
        xs, ys,
        color = color_elegido,
        linewidth = grosor,
        aspect_ratio = :equal,
        fontfamily = FUENTE_POSTER,
        
        # --- CONFIGURACIÓN CON / SIN EJES ---
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

    if con_ejes
        scatter!(p, [0], [0], color=:black, markersize=4, markerstrokewidth=0)
    end

    # --- ETIQUETA DE SEMILLA (SIEMPRE VISIBLE) ---
    min_x, max_x = minimum(xs), maximum(xs)
    min_y, max_y = minimum(ys), maximum(ys)
    
    mid_x = (min_x + max_x) / 2.0
    dy = max_y - min_y
    dy = dy == 0 ? 1.0 : dy
    
    # Expandir los límites verticales para asegurar margen al texto inferior
    ylims!(p, min_y - 0.12 * dy, max_y + 0.05 * dy)
    
    # Anotación en el centro inferior de la curva
    annotate!(p, mid_x, min_y - 0.06 * dy, text("Semilla: $(uppercase(seed))", font(18, FUENTE_POSTER, :black)))

    savefig(p, archivo_salida)
    println("Imagen generada exitosamente en: '$archivo_salida'")
    return p
end

# ====================
# MENÚ DE AYUDA DESCRIPTIVO
# ====================

function mostrar_ayuda()
    println("""
===================================================================
GENERADOR DE CURVA DEL DRAGÓN POR SEMILLA (Julia)
===================================================================

Uso mediante Banderas Descriptivas:
  julia seed_dragon_curve_2.jl [OPCIONES]

Banderas disponibles:
  --seed, -s <string>     Semilla inicial (ej: UUDD, UDU, D) [defecto: UUDD]
  --iter, -i <int>        Número de iteraciones (ej: 6) [defecto: 6]
  --metodo, -m <int>      Definición formal: 1 (Directa) o 2 (Plegado) [defecto: 1]
  --paleta, -p <int>      ID de color (1 a 8) [defecto: 1]
  --ejes, -e <bool>       Mostrar ejes y cuadrícula (true/false) [defecto: true]
  --grosor, -g <float>    Grosor de la línea (ej: 1.5, 3.0, 5.0) [defecto: 3.0]
  --help, -h              Muestra este menú de ayuda

Catálogo de Colores:
  [1] Azul Rey
  [2] Azul Noche / Oscuro
  [3] Azul Océano
  [4] Naranja Intenso
  [5] Naranja Ámbar / Dorado
  [6] Verde Teal / Turquesa
  [7] Índigo / Violeta
  [8] Gris Pizarra

Ejemplos de ejecución:
  julia seed_dragon_curve_2.jl -s UUDD -i 6 -m 1 -p 4 -e true -g 3.5
  julia seed_dragon_curve_2.jl --seed UDU --iter 7 --paleta 2 --grosor 4.0 --ejes false
===================================================================
""")
end

# ====================
# PARSER Y MODO DE EJECUCIÓN
# ====================

function main()
    seed = "UUDD"
    iter = 6
    metodo = 1
    id_paleta = 1
    con_ejes = true
    grosor = 3.0

    if length(ARGS) == 0
        # MODO INTERACTIVO
        println("=== GENERADOR DE CURVA DEL DRAGÓN POR SEMILLA ===")
        
        print("Ingresa la semilla (ej: UUDD, UDU, D) [por defecto '$seed']: ")
        input_seed = strip(readline())
        seed = isempty(input_seed) ? seed : input_seed

        print("Ingresa el número de iteraciones (ej: 6) [por defecto $iter]: ")
        input_iter = strip(readline())
        iter = isempty(input_iter) ? iter : parse(Int, input_iter)

        println("\nSelecciona la definición formal de la curva:")
        println("  [1] Recurrencia Directa:  S_{n+1} = S_n * S_1 * S̄_n^R")
        println("  [2] Producto de Plegado: Intercala S_n y S̄_n^R con cada carácter de S_1")
        print("Opción (1/2) [por defecto 1]: ")
        input_metodo = strip(readline())
        metodo = isempty(input_metodo) ? metodo : parse(Int, input_metodo)

        println("\nSelecciona el color de la curva:")
        for k in sort(collect(keys(PALETAS)))
            println("  [$k] $(PALETAS[k][1])")
        end
        print("Opción (1-8) [por defecto 1]: ")
        input_paleta = strip(readline())
        id_paleta = isempty(input_paleta) ? id_paleta : parse(Int, input_paleta)

        print("¿Mostrar ejes y cuadrícula? (s/n) [por defecto 's']: ")
        input_ejes = lowercase(strip(readline()))
        con_ejes = isempty(input_ejes) || input_ejes in ["s", "si", "sí", "y", "yes", "true", "1"]

        print("Ingresa el grosor de la línea (ej: 3.0) [por defecto 3.0]: ")
        input_grosor = strip(readline())
        grosor = isempty(input_grosor) ? grosor : parse(Float64, input_grosor)

    elseif any(arg -> arg in ["-h", "--help"], ARGS)
        mostrar_ayuda()
        return
    else
        # PARSER DE BANDERAS CLI Y POSICIONALES
        is_flag_mode = any(startswith(arg, "-") for arg in ARGS)

        if is_flag_mode
            idx = 1
            while idx <= length(ARGS)
                arg = ARGS[idx]
                if arg in ["--seed", "-s"] && idx < length(ARGS)
                    seed = ARGS[idx+1]; idx += 2
                elseif arg in ["--iter", "-i"] && idx < length(ARGS)
                    iter = parse(Int, ARGS[idx+1]); idx += 2
                elseif arg in ["--metodo", "-m"] && idx < length(ARGS)
                    metodo = parse(Int, ARGS[idx+1]); idx += 2
                elseif arg in ["--paleta", "-p"] && idx < length(ARGS)
                    id_paleta = parse(Int, ARGS[idx+1]); idx += 2
                elseif arg in ["--ejes", "-e"] && idx < length(ARGS)
                    val = lowercase(ARGS[idx+1])
                    con_ejes = !(val in ["0", "false", "f", "no", "n"])
                    idx += 2
                elseif arg in ["--grosor", "-g"] && idx < length(ARGS)
                    grosor = parse(Float64, ARGS[idx+1]); idx += 2
                else
                    idx += 1
                end
            end
        else
            # MODO POSICIONAL DIRECTO: <semilla> <iteraciones> [metodo] [paleta] [ejes] [grosor]
            if length(ARGS) >= 1; seed = ARGS[1]; end
            if length(ARGS) >= 2; iter = parse(Int, ARGS[2]); end
            if length(ARGS) >= 3; metodo = parse(Int, ARGS[3]); end
            if length(ARGS) >= 4; id_paleta = parse(Int, ARGS[4]); end
            if length(ARGS) >= 5
                val = lowercase(ARGS[5])
                con_ejes = !(val in ["0", "false", "f", "no", "n"])
            end
            if length(ARGS) >= 6; grosor = parse(Float64, ARGS[6]); end
        end
    end

    graficar_curva_unica_semilla(
        seed, iter; 
        metodo = metodo, 
        id_paleta = id_paleta, 
        con_ejes = con_ejes, 
        grosor = grosor
    )
end

main()
