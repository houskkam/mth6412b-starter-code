import Base.show
import Base.==
include("graph.jl")

"""Type abstrait dont d'autres types de graphes dériveront."""
abstract type AbstractComposanteConnexe{T, Z} <: AbstractGraph{T, Z} end

"""Type representant une composante connexe comme un ensemble de noeuds, .

Exemple :
    noeud1 = Node("James", "ahooj")
    noeud2 = Node("Kirk", "guitar")
    noeud3 = Node("Lars", "tdd")
    edge_oriented_1 = EdgeOriented(noeud1, noeud2, 5)
    edge_oriented_2 = EdgeOriented(noeud2, noeud3, 4)
    C = ComposanteConnexe(noeud1, [noeud1, noeud2, noeud3], [edge_oriented_1, edge_oriented_2])

Attention, tous les noeuds doivent avoir des données de même type.
"""
mutable struct ComposanteConnexe{T, Z} <: AbstractComposanteConnexe{T, Z}
  root::T
  nodes::Vector{T}
  edges::Vector{EdgeOriented{Z,T}}
end

"""Ajoute un noeud et l'arret qui le relie au graphe."""
function add_node_and_edge!(composante::ComposanteConnexe{Node{T}, Z}, node::Node{T}, edge::EdgeOriented{Z, Node{T}}) where {T, Z}
  push!(composante.nodes, node)
  push!(composante.edges, edge)
  composante
end


"""Determines that connected components are equal if their contents equal."""
==(c1::ComposanteConnexe, c2::ComposanteConnexe) = (nodes(c1) == nodes(c2)) && (edges(c1) == edges(c2))

"""Takes a vector of connected components and merges them into one."""
function connect_into_one(composantes::Vector{ComposanteConnexe{T, Z}}, edge::EdgeOriented{Z, T}) where {T, Z}
  new_component = composantes[1]
  for node in nodes(composantes[2])
    if !(node in nodes(new_component))
      add_node!(new_component, node)
    end
  end
  for edge in edges(composantes[2])
    add_edge!(new_component, edge)
  end
  if(length(composantes) > 2)
    print("have to connect more than 2 components")
  end
  add_edge!(new_component, edge)
  new_component
end

"""Affiche un graphe."""
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
