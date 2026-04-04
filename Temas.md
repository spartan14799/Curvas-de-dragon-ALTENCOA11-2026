#Tema ponencia ALTENCOA 2026

## Curvas de dragón 

###Introducción
  - Breve marco histórico. 
  - Intuición: paperfolding.

###Cómo podemos modelar matemáticamente esta intuición?
  - Creación de palabras: alfabetos, palabras, concatenación, inversa, inversa opuesta, prefijo, sufijo.
  - La palabra del dragón (ilustrar, mostrar ambas maneras de definirla y enunciar equivalencia).

###Computacional
# TODO: Hablar de la parte conmutacional de la palabra de dragón.

###Características, propiedades.
  - Semillas generadoras.
  - Teselaciones del plano.
  - No se autointerseca.

###Perspectiva categórica de la auto-similaridad
Nociones básicas de categorías y coálgebras.
  - Objetos, morfismos, funtores. Ejemplo: categoría Top.
  - Endofuntores y G-coálgebras: el par (X, ξ: X → G(X)).
  - Coálgebra terminal y Lema de Lambek: la estructura map es isomorfismo.

Sistemas ecuacionales discretos (Leinster).
  - Categorificación de sistemas lineales: variables = espacios, suma = coproducto, igualdad = homeomorfismo.
  - El endofuntor de doblamiento G(X) = X ∪_* X y el Teorema de Freyd: [0,1] es la coálgebra terminal.

La curva del dragón como punto fijo.
  - Ecuación de autosimilaridad: D = f₁(D) ∪ f₂(D) como ecuación de punto fijo en (K(ℝ²), d_Hausdorff).
  - El par (D, ξ) como G-coálgebra: el mapa estructura ξ: D → D ∪_* D es homeomorfismo (Lambek).

La solución universal.
  - [0,1] como coálgebra terminal: cualquier espacio que satisfaga X ≅ X ∪_* X recibe un único morfismo desde [0,1].
  - La parametrización γ: [0,1] → D como morfismo de coálgebras: el cuadrado de conmutatividad entre ι y ξ.
  - El dragón como realización geométrica de la coálgebra terminal: la iteración G^n(1) → D como construcción explícita.