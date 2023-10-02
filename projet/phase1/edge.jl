import Base.show

"""Type abstrait dont d'autres types de edges dériveront."""
abstract type AbstractEdge{T, Y <: AbstractNode} end

"""Type représentant les edges d'un graphe.

Exemple:
        noeud1 = Node("James", "ahooj")
        noeud2 = Node("Kirk", "guitar")
        noeud3 = Node("Lars", "tdd")
        edge1 = Edge(noeud1, noeud2, 5)
        edge2 = Edge(noeud2, noeud3, 4)

"""
mutable struct Edge{T, Y} <: AbstractEdge{T, Y}
  node1::Y
  node2::Y
  poids::T
end

# on présume que tous les edges dérivant d'AbstractEdge
# posséderont des champs `edge1`, `edge2` et `poids`.

"""Renvoie le nom du premiere noeud d'un edge."""
node1(edge::AbstractEdge) = edge.node1

"""Renvoie le nom du deuxieme noeud d'un edge."""
node2(edge::AbstractEdge) = edge.node2

"""Renvoie le poids d'un edge."""
poids(edge::AbstractEdge) = edge.poids

"""Affiche un edge."""
function show(edge::AbstractEdge)
  println("First node ", node1(edge), "second node: ", node2(edge) ,", poids: ", poids(edge))
end
