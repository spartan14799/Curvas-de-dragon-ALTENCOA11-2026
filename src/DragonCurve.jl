# src/DragonCurve.jl

function palabra_dragon(n::Int)::String
    if n == 0
        return ""
    else
        prev = palabra_dragon(n-1)
        neg_rev = reverse(map(c -> c == 'D' ? 'U' : 'D', prev))
        return prev * "D" * neg_rev
    end
end

function puntos_dragon(n::Int)
    palabra = palabra_dragon(n)
    dir = 1 + 0im
    giros = Dict('U' => im, 'D' => -im)   
    puntos = [0 + 0im]
    for c in palabra
        push!(puntos, puntos[end] + dir)
        dir *= giros[c]
    end
    push!(puntos, puntos[end] + dir)
    return real.(puntos), imag.(puntos)
end

function teselacion_dragon(n::Int)
    xs, ys = puntos_dragon(n)
    z = xs .+ im .* ys
    return z, z .* im, z .* -1, z .* -im
end
