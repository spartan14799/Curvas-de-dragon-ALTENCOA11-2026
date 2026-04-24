using Plots
using FileIO        # para cargar imágenes
using Images        # para redimensionar

gr()

# Paleta de colores vibrante
paleta_nueva = [
    "#0d0887", "#46039f", "#7201a8", "#9e1795", "#bd3786",
    "#d8576b", "#ed7953", "#fb9f3a", "#fdca26", "#f0e821",
    "#b9de28", "#6ece58", "#29af7f", "#1fa187", "#1c7c93",
    "#2a5a8a"
]
grad = cgrad(paleta_nueva, 256)

function dragon_points(n::Int)
    N = 2^n
    puntos = ComplexF64[0.0+0.0im, 1.0+0.0im]
    dir = 1.0+0.0im
    for k in 2:N
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

function generar_curva_png(
        n::Int;
        alto_inicial::Int=1200,   # resolución de trabajo (más = más detalle)
        ancho_final::Int=1200,    # tamaño de salida
        archivo_final::String="curva_dragon.png"
    )
    println("Generando curva para n = $n")
    pts = dragon_points(n)
    println("Segmentos totales: $(length(pts)-1)")

    t = range(0, 1, length=length(pts))
    xs = real.(pts)
    ys = imag.(pts)

    # Dibujo de alta resolución
    plot(xs, ys,
         line_z = t,
         color = grad,
         linewidth = 0.8,         # muy fino para capturar detalle
         aspect_ratio = :equal,
         legend = false,
         axis = false,
         grid = false,
         ticks = false,
         size = (alto_inicial, alto_inicial))

    archivo_temp = "temp_dragon.png"
    savefig(archivo_temp)
    println("Imagen temporal guardada ($(alto_inicial)×$(alto_inicial) px)")

    # Redimensionar suavemente
    img = load(archivo_temp)
    img_red = imresize(img, (ancho_final, ancho_final))
    save(archivo_final, img_red)
    rm(archivo_temp)
    println("Imagen final guardada como '$archivo_final' ($(ancho_final)×$(ancho_final) px)")
end

# Ejecución
n = 18
generar_curva_png(n, alto_inicial=2500, ancho_final=1200, archivo_final="assets/curva_dragon.png")
