import Base.show, Base.convert, Base.==

include("edge.jl")

"""Type abstrait dont d'autres types de edges orientés dériveront."""
abstract type AbstractEdgeOriented{Z, T <: AbstractNode} <: AbstractEdge{Z, T}  end

"""Type représentant les edges orientés d'un graphe.

Exemple:
        noeud1 = Node("James", "ahooj")
        noeud2 = Node("Kirk", "guitar")
        noeud3 = Node("Lars", "tdd")
        edge1 = EdgeOriented(noeud1, noeud2, 5)
        edge2 = EdgeOriented(noeud2, noeud3, 4)

"""
mutable struct EdgeOriented{Z, T} <: AbstractEdgeOriented{Z, T}
  debut::T
  fin::T
  poids::Z
end

# on présume que tous les edges dérivant d'AbstractEdge
# posséderont des champs `edge1`, `edge2` et `poids`.

"""Renvoie le nom du premiere noeud d'un edge."""
debut(edge::AbstractEdgeOriented) = edge.debut

"""Renvoie le nom du deuxieme noeud d'un edge."""
fin(edge::AbstractEdgeOriented) = edge.fin

"""Renvoie le nom du premiere noeud d'un edge."""
node1(edge::AbstractEdgeOriented) = debut(edge)

"""Renvoie le nom du deuxieme noeud d'un edge."""
node2(edge::AbstractEdgeOriented) = fin(edge)

==(e1::AbstractEdgeOriented, e2::AbstractEdgeOriented) = (debut(e1) == debut(e2)) && (fin(e1) == fin(e2)) && (poids(e1) == poids(e2))

Base.convert(::Type{T}, e::Edge) where {T<:EdgeOriented} = EdgeOriented(node1(e), node2(e), poids(e))
Base.convert(::Type{T}, e::EdgeOriented) where {T<:Edge} = Edge(debut(e), fin(e), poids(e))

"""Affiche un edge."""
function show(edge::AbstractEdgeOriented)
  println("Parent node ", debut(edge), "child node: ", fin(edge) ,", weight: ", poids(edge))
end

function set_weight!(edge::EdgeOriented{Z, T}, new_weight::Z) where {T, Z}
  edge.poids = new_weight
  return edge
end
