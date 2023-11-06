import Base.show

"""Type abstrait dont d'autres types de graphes dériveront."""
abstract type AbstractTest{T} end

"""Type representant un graphe comme un ensemble de noeuds.

Exemple :

    noeud1 = Node("James", "ahooj")
    noeud2 = Node("Kirk", "guitar")
    noeud3 = Node("Lars", "tdd")
    edge1 = Edge(noeud1, noeud2, 5)
    edge2 = Edge(noeud2, noeud3, 4)
    G = Graph("Ick", [noeud1, noeud2, noeud3], [edge1, edge2])

Attention, tous les noeuds doivent avoir des données de même type.
"""
mutable struct TESTS{T,Z} <: AbstractTest{T}
  name::String
  nodes::Vector{T}
  edges::Vector{Edge{Z,T}}
end