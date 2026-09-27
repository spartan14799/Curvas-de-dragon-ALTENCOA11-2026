using Plots

gr()

# ====================
# CATÁLOGO DE PALETAS DE COLORES
# ====================
# NOTA: Para las paletas de 2 colores, se alternan los tonos [Color1, Color2, Color1, Color2]
# para aplicarlos a los 4 dragones rotados.

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
          ["#1d4ed8", "#ea580c", "#0284c7", "#f59e0b"])
)

# ====================
# LÓGICA DE GENERACIÓN
# ====================

function inverse_sequence(s::AbstractString)
    trans = Dict('D' => 'U', 'U' => 'D')
    return String([trans[c] for c in reverse(uppercase(s))])
end

# Secuencia del dragón clásico (S_{n+1} = S_n * D * S̄_n^R)
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

# ====================
# GRAFICACIÓN DEL MOSAICO
# ====================

"""
    graficar_4_dragones(iteraciones; con_ejes=true, id_paleta=1, archivo_salida="", grosor=2.2)

Genera el mosaico con la paleta de colores seleccionada y opción de mostrar/ocultar ejes.
"""
function graficar_4_dragones(
        iteraciones::Int; 
        con_ejes::Bool=true, 
        id_paleta::Int=1,
        archivo_salida::String="", 
        grosor::Real=2.2
    )
    # Validar paleta elegida
    id_valido = haskey(PALETAS, id_paleta) ? id_paleta : 1
    nombre_paleta, colores_elegidos = PALETAS[id_valido]

    word = generate_classic_dragon_word(iteraciones)
    pts_base = word_to_points(word)
    
    suffix_ejes = con_ejes ? "" : "_sinejes"
    if isempty(archivo_salida)
        archivo_salida = "../assets/four-dragons/mosaico_4dragones_i$(iteraciones)_p$(id_valido)$(suffix_ejes).png"
    end

    dir_salida = dirname(archivo_salida)
    if !isempty(dir_salida) && !isdir(dir_salida)
        mkpath(dir_salida)
    end

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

    # Multiplicadores de rotación: 1, i, -1, -i
    rotaciones = [1.0 + 0.0im, 0.0 + 1.0im, -1.0 + 0.0im, 0.0 - 1.0im]

    println("Generando mosaico de 4 dragones:")
    println(" - Iteraciones: $iteraciones")
    println(" - Paleta [$id_valido]: $nombre_paleta")
    println(" - Ejes: $(con_ejes ? "Sí" : "No")")

    for (k, rot) in enumerate(rotaciones)
        pts_rot = pts_base .* rot
        xs = real.(pts_rot)
        ys = imag.(pts_rot)
        
        plot!(
            p,
            xs, ys,
            color = colores_elegidos[k],
            linewidth = grosor
        )
    end

    if con_ejes
        scatter!(p, [0], [0], color=:black, markersize=5, markerstrokewidth=0)
    end

    savefig(p, archivo_salida)
    println("Imagen generada exitosamente en: '$archivo_salida'")
    return p
end

# ====================
# ENTRADA DE TERMINAL (CLI / INTERACTIVO)
# ====================

function main()
    iter = 6
    con_ejes = true
    id_paleta = 1

    if length(ARGS) >= 1
        # MODO CLI: julia four_dragons.jl <iteraciones> [con_ejes: true/false] [id_paleta: 1-7]
        try
            iter = parse(Int, ARGS[1])
        catch
            println("Error: El primer parámetro debe ser un número entero de iteraciones.")
            return
        end
        
        if length(ARGS) >= 2
            param_ejes = lowercase(strip(ARGS[2]))
            con_ejes = !(param_ejes in ["0", "false", "f", "no", "n"])
        end

        if length(ARGS) >= 3
            id_paleta = parse(Int, ARGS[3])
        end
    else
        # MODO INTERACTIVO
        println("=== GENERADOR DE MOSAICO DE 4 DRAGONES ===")
        
        print("Ingresa el número de iteraciones (ej: 8) [por defecto 6]: ")
        input_iter = strip(readline())
        iter = isempty(input_iter) ? 6 : parse(Int, input_iter)

        print("¿Mostrar ejes y cuadrícula? (s/n) [por defecto 's']: ")
        input_ejes = lowercase(strip(readline()))
        con_ejes = isempty(input_ejes) || input_ejes in ["s", "si", "sí", "y", "yes", "true", "1"]

        println("\nSelecciona una paleta de colores:")
        for k in sort(collect(keys(PALETAS)))
            println("  [$k] $(PALETAS[k][1])")
        end
        print("Opción (1-7) [por defecto 1]: ")
        input_paleta = strip(readline())
        id_paleta = isempty(input_paleta) ? 1 : parse(Int, input_paleta)
    end

    graficar_4_dragones(iter; con_ejes = con_ejes, id_paleta = id_paleta)
end

main()
