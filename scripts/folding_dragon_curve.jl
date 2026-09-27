using Plots

gr()

# ==========================================
# 1. GENERACIÓN DEL DRAGÓN CLÁSICO (HEIGHWAY)
# ==========================================

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

# ==========================================
# 2. GRAFICACIÓN DEL PLEGADO Y AUTOSEMEJANZA
# ==========================================

function graficar_plegado_dragon(;
        iteraciones::Int = 10,
        color1::String = "#1d4ed8",  # Azul Rey (Copia 1)
        color2::String = "#ea580c",  # Naranja Intenso (Copia 2)
        grosor::Real = 2.5,
        archivo_salida::String = ""
    )
    if iteraciones < 2
        error("El número de iteraciones debe ser al menos 2.")
    end

    # Ruta por defecto en assets/self-similar-dragon
    if isempty(archivo_salida)
        dir_salida = "../assets/self-similar-dragon"
        archivo_salida = joinpath(dir_salida, "dragon_autosemejante_i$(iteraciones).png")
    else
        dir_salida = dirname(archivo_salida)
    end

    if !isempty(dir_salida) && !isdir(dir_salida)
        mkpath(dir_salida)
    end

    # Obtener puntos de la curva
    giros = generar_giros_dragon(iteraciones)
    pts = giros_a_puntos(giros)

    # División exacta por el punto medio en 2 copias autosemejantes
    total_puntos = length(pts)
    idx_medio = div(total_puntos - 1, 2) + 1

    pts_copia1 = pts[1:idx_medio]
    pts_copia2 = pts[idx_medio:end]
    pt_plegado = pts[idx_medio]

    # Crear figura sin ejes y formato apaisado/ancho
    p = plot(
        aspect_ratio = :equal,
        framestyle = :none,
        grid = false,
        ticks = false,
        
        # Leyenda amplia y limpia
        legend = :topright,
        legendfont = font(25, :black),
        legendtitlefont = font(50, :bold, :black),
        
        # Formato ancho (1600x1000) y márgenes de seguridad
        size = (1600, 1000),
        margin = 15Plots.mm,
        background_color = :white
    )

    # Trazar Copia 1: f1(D)
    plot!(
        p, real.(pts_copia1), imag.(pts_copia1),
        color = color1,
        linewidth = grosor,
        label = "Copia 1"
    )

    # Trazar Copia 2: f2(D)
    plot!(
        p, real.(pts_copia2), imag.(pts_copia2),
        color = color2,
        linewidth = grosor,
        label = "Copia 2"
    )

    # Marcador para el punto de plegado
    scatter!(
        p, [real(pt_plegado)], [imag(pt_plegado)],
        color = :black,
        markersize = 7,
        markerstrokewidth = 1.5,
        markerstrokecolor = :white,
        label = "Punto de pegado"
    )

    savefig(p, archivo_salida)
    println("Imagen generada exitosamente en: '$archivo_salida'")
    return p
end

# ==========================================
# 3. MENÚ DE AYUDA Y PARSER CLI
# ==========================================

function mostrar_ayuda()
    println("""
===================================================================
VISUALIZADOR DEL DRAGÓN AUTOSEMEJANTE (Plegado f1(D) ∪ f2(D))
===================================================================

Uso:
  julia folding_dragon_curve.jl [OPCIONES]

Opciones disponibles:
  -i, --iter <int>       Número de iteraciones (≥ 2) [defecto: 10]
  -g, --grosor <float>   Grosor de la línea del gráfico [defecto: 2.5]
  -c1, --color1 <hex>    Color en formato HEX/nombre para Copia 1 [defecto: #1d4ed8]
  -c2, --color2 <hex>    Color en formato HEX/nombre para Copia 2 [defecto: #ea580c]
  -o, --out <path>       Ruta del archivo de salida [defecto: ../assets/self-similar-dragon/...]
  -h, --help             Muestra este menú de ayuda

Ejemplos:
  julia folding_dragon_curve.jl -h
  julia folding_dragon_curve.jl -i 12 -g 3.0
===================================================================
""")
end

function main()
    if any(arg -> arg in ["-h", "--help"], ARGS)
        mostrar_ayuda()
        return
    end

    iteraciones = 10
    grosor = 2.5
    color1 = "#1d4ed8"
    color2 = "#ea580c"
    archivo_salida = ""

    idx = 1
    while idx <= length(ARGS)
        arg = ARGS[idx]
        if arg in ["--iter", "-i"] && idx < length(ARGS)
            iteraciones = parse(Int, ARGS[idx+1]); idx += 2
        elseif arg in ["--grosor", "-g"] && idx < length(ARGS)
            grosor = parse(Float64, ARGS[idx+1]); idx += 2
        elseif arg in ["--color1", "-c1"] && idx < length(ARGS)
            color1 = ARGS[idx+1]; idx += 2
        elseif arg in ["--color2", "-c2"] && idx < length(ARGS)
            color2 = ARGS[idx+1]; idx += 2
        elseif arg in ["--out", "-o"] && idx < length(ARGS)
            archivo_salida = ARGS[idx+1]; idx += 2
        else
            idx += 1
        end
    end

    graficar_plegado_dragon(
        iteraciones = iteraciones,
        color1 = color1,
        color2 = color2,
        grosor = grosor,
        archivo_salida = archivo_salida
    )
end

main()
