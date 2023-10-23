import Base.show

"""Type abstrait dont d'autres types de graphes dériveront."""
abstract type AbstractComposanteConnexe{T, Z} <: AbstractGraph{T, Z} end

"""Type representant une composante connexe comme un ensemble de noeuds, .

Exemple :
    noeud1 = Node("James", "ahooj")
    noeud2 = Node("Kirk", "guitar")
    noeud3 = Node("Lars", "tdd")
    edge1 = EdgeOriented(noeud1, noeud2, 5)
    edge2 = EdgeOriented(noeud2, noeud3, 4)
    G = Graph("Ick", [noeud1, noeud2, noeud3], [edge1, edge2])

Attention, tous les noeuds doivent avoir des données de même type.
"""
mutable struct ComposanteConnexe{T, Z} <: AbstractComposanteConnexe{T, Z}
  root::T
  nodes::Vector{T}
  edges::Vector{EdgeOriented{Z,T}}
end

"""Ajoute un noeud au graphe."""
function add_node!(graph::ComposanteConnexe{T, Z}, node::Node{T}) where {T, Z}
  push!(graph.nodes, node)
  graph
end

"""Ajoute un edge au graphe."""
function add_edge!(graph::ComposanteConnexe{T, Z}, edge::Edge{T, Z}) where {T, Z} 
  push!(graph.edges, edge)
  graph
end

"""Affiche un graphe"""
function show(graph::ComposanteConnexe)
  println("Graph ", name(graph), " has ", nb_nodes(graph), " nodes")
  for node in nodes(graph)
    show(node)
  end
  println("and ", nb_edges(graph), "edges.")
  for edge in edges(graph)
    show(edge)
  end
end
