module DragonCurve

export palabra_dragon_rec, puntos_dragon

"""
    palabra_dragon_rec(n)

Devuelve la palabra del dragón de orden `n` como una cadena de caracteres 'D' (valle) y 'U' (montaña).
"""
function palabra_dragon_rec(n::Int)::String
    if n == 0
        return ""
    else
        prev = palabra_dragon_rec(n-1)
        # Negar e invertir la palabra anterior
        neg_rev = reverse(map(c -> c == 'D' ? 'U' : 'D', prev))
        return prev * "D" * neg_rev
    end
end

"""
    puntos_dragon(n)

Genera los puntos (x,y) de la curva del dragón tras n iteraciones.
Devuelve dos vectores: `xs`, `ys`.
"""
function puntos_dragon(n::Int)
    palabra = palabra_dragon_rec(n)
    dir = 1 + 0im                # dirección inicial (derecha)
    giros = Dict('D' => im, 'U' => -im)   # giro antihorario / horario
    puntos = [0 + 0im]           # origen
    for c in palabra
        push!(puntos, puntos[end] + dir)
        dir *= giros[c]
    end
    xs = real.(puntos)
    ys = imag.(puntos)
    return xs, ys
end

end # module
