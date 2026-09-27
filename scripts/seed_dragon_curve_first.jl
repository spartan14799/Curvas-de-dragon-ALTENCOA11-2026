using Plots

gr()

# ====================
# PALETA DE COLORES EN LA GAMA AZUL
# ====================
const PALETA_AZULES = [
    "#1d4ed8", "#0f766e", "#4f46e5", "#0284c7",
    "#1e293b", "#2563eb", "#0369a1", "#334155"
]

# ====================
# LÓGICA DE LA SEMILLA Y GENERACIÓN
# ====================

"""
    inverse_sequence(s::AbstractString)

Calcula la palabra complementaria e invertida (S_n)^R reemplazando D <-> U.
"""
function inverse_sequence(s::AbstractString)
    trans = Dict('D' => 'U', 'U' => 'D')
    return String([trans[c] for c in reverse(uppercase(s))])
end

"""
    generate_word(seed::AbstractString, iterations::Int)

Genera la palabra aplicando la recurrencia:
S_{n+1} = S_n * S_1 * \bar{(S_n)^R}
"""
function generate_word(seed::AbstractString, iterations::Int)
    s1 = uppercase(seed)  # Semilla inicial S_1
    sn = s1               # S_1
    
    for _ in 2:iterations
        sn_bar = inverse_sequence(sn) # \bar{(S_n)^R}
        sn = sn * s1 * sn_bar         # S_{n+1} = S_n * S_1 * \bar{(S_n)^R}
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

# ====================
# GENERACIÓN DE IMAGEN Y EXPORTACIÓN
# ====================

function graficar_curva_unica_semilla(
        seed::AbstractString, 
        iteraciones::Int; 
        archivo_salida::String="",
        grosor::Real=1.5
    )
    color_elegido = rand(PALETA_AZULES)
    println("Color seleccionado aleatoriamente: ", color_elegido)
    
    if isempty(archivo_salida)
        archivo_salida = "../assets/seed-curves/first_definition/curva_dragon_$(uppercase(seed))_i$(iteraciones).png"
    end

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

    if length(ARGS) >= 2
        seed = ARGS[1]
        iter = parse(Int, ARGS[2])
    else
        println("=== GENERADOR DE CURVA DEL DRAGÓN POR SEMILLA (FÓRMULA DIRECTA) ===")
        
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
