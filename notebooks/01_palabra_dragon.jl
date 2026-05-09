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

# ╔═╡ 54d35e14-11de-4620-9074-cb7775b49964
begin
    using Pkg
    Pkg.activate("..")
    using PlutoUI, Plots
end

# ╔═╡ a294c7fa-168c-497c-81ef-738498a8418b
include("../src/DragonCurve.jl")

# ╔═╡ 80ba9ba4-2608-4029-b739-84fd7e7bf689
md"""
# La Curva del Dragón: Del Plegado al Fractal

En esta notebook exploraremos la **curva del dragón**, un fractal que surge de un proceso físico sumamente intuitivo.

## La Palabra del Dragón
Queremos ver que le pasaria a un papel si pudiera doblarlo por la mitad y en la misma direccion una cantidad indeterminada de veces.

Al desdoblar nuestra tira de papel, observamos en la hoja que los pliegues en el perfil forman un patrón alternado. Podemos clasificar estos dobleces como "montañas" (Up) y "valles" (Down), podemos repetir este proceso fisicamente pocas veces, pues el papel no se deja doblarar tanto.

Entonces tenemos que modelar esto de alguna manera, para eso definimos un alfabeto binario:

```math
\Sigma=\{U,D\}
```
U representando Up y D representando Down.

Y con esto podemos escribir una palabra usando este alfabeto, que sea el patron de dobleces que se forma en el perfil de la hoja.

Veamos el comportamiento de la palabra con algunos dobleces para buscar un patron:

"""

# ╔═╡ 5bbdb964-7d7d-473d-9d7a-ab77ee558802
md"""
Desliza para ver como se forma la palabra.
"""

# ╔═╡ 9569a9ab-8ac5-4323-8418-9b6f1e1b1431
@bind n Slider(1:10, show_value=true)

# ╔═╡ 9e9f53d7-7e4a-469c-9f3f-119aba97f193
word = palabra_dragon(n);

# ╔═╡ 77c0f046-b851-477a-ae7f-3efcdfb783f4
md"""
### Iteración $n
La palabra generada es: 
**$word**
"""

# ╔═╡ 62ed0025-ddf5-4db2-bedc-e9afb5e7e2e0
md"""
Note que al realizar el primer doblez físico, obtenemos un único pliegue que tomaremos como caso inicial:
```math
S_0 = D
```
"""

# ╔═╡ e7818342-e7ef-43fb-b28f-a7fbff8eaa49
md"""

¿Qué ocurre al hacer un doblez adicional? 
Si tomamos la tira ya doblada $n$ veces (descrita por la secuencia de pliegues $S_n$) y la doblamos una vez más por la mitad, al desdoblarla observamos que la nueva secuencia se compone de tres partes geométricas:

* **El segmento inicial:** La mitad derecha del papel conserva intacto el patrón de pliegues que ya teníamos en la iteración anterior ($S_n$).
* **El pliegue central:** El doblez adicional genera un pliegue principal justo en el centro de la hoja poniendo el caracter D en el centro.
* **El segmento final:** La mitad izquierda contiene los mismos pliegues anteriores, pero como el papel estaba doblado sobre sí mismo, la secuencia se despliega en orden inverso (operación reversa, $R$) y la orientación de cada pliegue se voltea de montaña a valle y viceversa.

De esta observación física, deducimos la construcción recursiva formal de la palabra del dragón $(S_n)$
```math
S_{n+1} = S_{n}D\overline{(S_{n})^R}
```
"""

# ╔═╡ 92cf90ba-1019-4246-88ea-8346e6dede4c
begin
    xs, ys = puntos_dragon(n)
    plot(xs, ys, line=:path, aspect_ratio=:equal, legend=false,
         title="Curva del dragón, n=$n")
end

# ╔═╡ Cell order:
# ╠═54d35e14-11de-4620-9074-cb7775b49964
# ╠═a294c7fa-168c-497c-81ef-738498a8418b
# ╟─80ba9ba4-2608-4029-b739-84fd7e7bf689
# ╟─5bbdb964-7d7d-473d-9d7a-ab77ee558802
# ╟─9569a9ab-8ac5-4323-8418-9b6f1e1b1431
# ╟─9e9f53d7-7e4a-469c-9f3f-119aba97f193
# ╟─77c0f046-b851-477a-ae7f-3efcdfb783f4
# ╟─62ed0025-ddf5-4db2-bedc-e9afb5e7e2e0
# ╟─e7818342-e7ef-43fb-b28f-a7fbff8eaa49
# ╟─92cf90ba-1019-4246-88ea-8346e6dede4c
