using Plots

gr()

# ====================
# PALETA DE COLORES EN LA GAMA AZUL / COMPLEMENTARIOS
# ====================
const PALETA_AZULES = [
    "#1d4ed8", # Azul rey clásico
    "#0f766e", # Verde azulado / Teal
    "#4f46e5", # Índigo
    "#0284c7", # Azul cian profundo
    "#1e293b", # Azul pizarra oscuro
    "#2563eb", # Azul cobalto
    "#0369a1", # Azul océano
    "#334155"  # Gris pizarra azulado
]

# ====================
# LÓGICA DE LA SEMILLA Y PLEGADO
# ====================

function inverse_sequence(s::AbstractString)
    trans = Dict('D' => 'U', 'U' => 'D')
    return String([trans[c] for c in reverse(uppercase(s))])
end

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

function generate_word(seed::AbstractString, iterations::Int)
    word = uppercase(seed)
    for _ in 2:iterations
        word = folding_product(word, uppercase(seed))
    end
    return word
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

# ====================
# GENERACIÓN DE IMAGEN Y EXPORTACIÓN
# ====================

"""
    graficar_curva_unica_semilla(seed::AbstractString, iteraciones::Int; archivo_salida="", grosor=1.5)

Genera la curva con un color aleatorio de la paleta azul sobria y la guarda en disco.
"""
function graficar_curva_unica_semilla(
        seed::AbstractString, 
        iteraciones::Int; 
        archivo_salida::String="",
        grosor::Real=1.5
    )
    # Seleccionar un color aleatorio dentro de la gama armoniosa
    color_elegido = rand(PALETA_AZULES)
    println("Color seleccionado aleatoriamente: ", color_elegido)
    
    # Nombre de archivo dinámico si no se provee uno
    if isempty(archivo_salida)
        archivo_salida = "../assets/seed-curves/curva_dragon_$(uppercase(seed))_i$(iteraciones).png"
    end

    # Crear directorio si no existe
    dir_salida = dirname(archivo_salida)
    if !isempty(dir_salida) && !isdir(dir_salida)
        mkpath(dir_salida)
    end

    word = generate_word(seed, iteraciones)
    pts = word_to_points(word)
    
    xs = real.(pts)
    ys = imag.(pts)

    p = plot(
        xs, ys,
        color = color_elegido,
        linewidth = grosor,
        aspect_ratio = :equal,
        
        # --- CONFIGURACIÓN DE EJES ---
        framestyle = :zerolines,       # Solo ejes cruzados en (0,0)
        xlabel = "Re(z)",
        ylabel = "Im(z)",
        
        # Usar DejaVu Serif para ser compatible con Arch Linux
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

    # Punto de origen z₀ = 0
    scatter!(p, [0], [0], color=:black, markersize=4, markerstrokewidth=0)

    # Exportación
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

    if length(ARGS) >= 2
        # MODO 1: Parámetros pasados desde la terminal
        seed = ARGS[1]
        iter = parse(Int, ARGS[2])
    else
        # MODO 2: Prompt interactivo si se ejecuta sin parámetros
        println("=== GENERADOR DE CURVA DEL DRAGÓN POR SEMILLA ===")
        
        print("Ingresa la semilla (ej: UUDD, UDU, D) [por defecto 'UUDD']: ")
        input_seed = strip(readline())
        seed = isempty(input_seed) ? "UUDD" : input_seed

        print("Ingresa el número de iteraciones (ej: 6) [por defecto 6]: ")
        input_iter = strip(readline())
        iter = isempty(input_iter) ? 6 : parse(Int, input_iter)
    end

    graficar_curva_unica_semilla(seed, iter)
end

main()
