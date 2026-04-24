### A Pluto.jl notebook ###
# v0.20.24

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ 7888f351-a517-4e54-ae51-789076aff6ae
using Pkg; Pkg.activate("..")

# ╔═╡ e9cae057-0a3d-44e8-aa1c-557b68c00821
using PlutoUI, Plots, DragonCurve

# ╔═╡ 9569a9ab-8ac5-4323-8418-9b6f1e1b1431
@bind n Slider(0:6, show_value=true)

# ╔═╡ 87100501-46b2-448c-8d41-77baf0b20ab0
word = palabra_dragon_rec(n)

# ╔═╡ ce03f68c-85fd-4d49-aefe-02f67144e5b0
md"Palabra: $word (longitud: $(length(word)))"

# ╔═╡ 92cf90ba-1019-4246-88ea-8346e6dede4c
begin
    xs, ys = puntos_dragon(n)
    plot(xs, ys, line=:path, aspect_ratio=:equal, legend=false,
         title="Curva del dragón, n=$n")
end

# ╔═╡ Cell order:
# ╠═7888f351-a517-4e54-ae51-789076aff6ae
# ╠═e9cae057-0a3d-44e8-aa1c-557b68c00821
# ╟─9569a9ab-8ac5-4323-8418-9b6f1e1b1431
# ╟─87100501-46b2-448c-8d41-77baf0b20ab0
# ╟─ce03f68c-85fd-4d49-aefe-02f67144e5b0
# ╟─92cf90ba-1019-4246-88ea-8346e6dede4c
