using Plots

gr()

# ====================
# PALETA DE COLORES EN LA GAMA AZUL
# ====================
const PALETA_AZULES = [
    "#1d4ed8", # Azul rey
    "#0f766e", # Verde azulado / Teal
    "#4f46e5", # Índigo
    "#0284c7", # Azul cian profundo
    "#1e293b", # Azul pizarra oscuro
    "#2563eb", # Azul cobalto
    "#0369a1", # Azul océano
    "#334155"  # Gris pizarra azulado
]

# ====================
# LÓGICA DE TRANSFORMACIÓN DE SECUENCIAS
# ====================

"""
    inverse_sequence(s::AbstractString)

Calcula la palabra complementaria e invertida (S_n)^R (invierte el orden y cambia D <-> U).
"""
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

"""
    graficar_curva_unica_semilla(seed, iteraciones; metodo=1, archivo_salida="", grosor=1.5)

- `metodo = 1`: Recurrencia directa (S_{n+1} = S_n * S_1 * \bar{(S_n)^R})
- `metodo = 2`: Producto de plegado (Intercalado)
"""
function graficar_curva_unica_semilla(
        seed::AbstractString, 
        iteraciones::Int; 
        metodo::Int=1,
        archivo_salida::String="",
        grosor::Real=3
    )
    # Seleccionar algoritmo según la definición elegida
    word = metodo == 1 ? generate_word_direct(seed, iteraciones) : generate_word_folding(seed, iteraciones)
    nombre_metodo = metodo == 1 ? "Recurrencia Directa [S_{n+1} = S_n * S_1 * S̄_n^R]" : "Producto de Plegado [Intercalado]"
    carpeta_submetodo = metodo == 1 ? "first_definition" : "second_definition"

    # Impresión informativa en terminal
    println("\n==================================================")
    println("Método: ", nombre_metodo)
    println("Semilla (S₁): ", uppercase(seed))
    println("Iteración (n): ", iteraciones)
    println("Palabra resultante: ", word)
    println("Longitud total: ", length(word), " caracteres")
    println("==================================================\n")

    color_elegido = rand(PALETA_AZULES)
    println("Color seleccionado aleatoriamente: ", color_elegido)
    
    # Nombre de archivo por defecto según el método
    if isempty(archivo_salida)
        archivo_salida = "../assets/seed-curves/$carpeta_submetodo/curva_dragon_$(uppercase(seed))_i$(iteraciones).png"
    end

    # Crear directorio si no existe
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
        framestyle = :zerolines,
        xlabel = "Re(z)",
        ylabel = "Im(z)",
        guidefont = font(18, "DejaVu Serif", :black), 
        tickfont = font(14, "DejaVu Serif", :black),
        ticklinewidth = 2.0,
        grid = true,
        gridalpha = 0.25,
        gridstyle = :dash,
        gridlinewidth = 1.0,
        ticks = true,
        legend = false,
        size = (1200, 1200),
        dpi = 300,
        background_color = :white
    )

    scatter!(p, [0], [0], color=:black, markersize=4, markerstrokewidth=0)

    savefig(p, archivo_salida)
    println("Imagen generada exitosamente en: '$archivo_salida'")
    return p
end

# ====================
# MODO DE EJECUCIÓN (CLI / INTERACTIVO)
# ====================

function main()
    seed = ""
    iter = 0
    metodo = 1

    if length(ARGS) >= 2
        # MODO CLI: julia script.jl <semilla> <iteraciones> [metodo: 1 o 2]
        seed = ARGS[1]
        iter = parse(Int, ARGS[2])
        if length(ARGS) >= 3
            metodo = parse(Int, ARGS[3])
        end
    else
        # MODO INTERACTIVO
        println("=== GENERADOR UNIFICADO DE CURVA DEL DRAGÓN POR SEMILLA ===")
        
        print("Ingresa la semilla (ej: UUDD, UDU, D) [por defecto 'UUDD']: ")
        input_seed = strip(readline())
        seed = isempty(input_seed) ? "UUDD" : input_seed

        print("Ingresa el número de iteraciones (ej: 6) [por defecto 6]: ")
        input_iter = strip(readline())
        iter = isempty(input_iter) ? 6 : parse(Int, input_iter)

        println("\nSelecciona la definición formal de la curva:")
        println("  [1] Recurrencia Directa:  S_{n+1} = S_n * S_1 * S̄_n^R")
        println("  [2] Producto de Plegado: Intercala S_n y S̄_n^R con cada carácter de S_1")
        print("Opción (1/2) [por defecto 1]: ")
        input_metodo = strip(readline())
        metodo = isempty(input_metodo) ? 1 : parse(Int, input_metodo)
    end

    graficar_curva_unica_semilla(seed, iter; metodo=metodo)
end

main()
