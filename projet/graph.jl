import Base.show

"""Type abstrait dont d'autres types de graphes dériveront."""
abstract type AbstractGraph{T, Z} end

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
mutable struct Graph{T, Z} <: AbstractGraph{T, Z}
  name::String
  nodes::Vector{T}
  edges::Vector{Edge{Z,T}}
end

"""Ajoute un noeud au graphe."""
function add_node!(graph::AbstractGraph{Node{T}, Z}, node::Node{T}) where {T, Z}
  push!(graph.nodes, node)
  graph
end

"""Ajoute un edge au graphe."""
function add_edge!(graph::AbstractGraph{T, Z}, edge::AbstractEdge{Z, T}) where {T, Z} 
  push!(graph.edges, edge)
  graph
end

# on présume que tous les graphes dérivant d'AbstractGraph
# posséderont des champs `name` et `nodes`.

"""Renvoie le nom du graphe."""
name(graph::Graph) = graph.name

"""Renvoie la liste des noeuds du graphe."""
nodes(graph::AbstractGraph) = graph.nodes

"""Renvoie la liste des edges du graphe."""
edges(graph::AbstractGraph) = graph.edges

"""Renvoie le nombre de noeuds du graphe."""
nb_nodes(graph::AbstractGraph) = length(graph.nodes)

"""Renvoie le nombre des edges du graphe."""
nb_edges(graph::AbstractGraph) = length(graph.edges)

"""Affiche un graphe"""
function show(graph::Graph)
  println("Graph ", name(graph), " has ", nb_nodes(graph), " nodes")
  for node in nodes(graph)
    show(node)
  end
  println("and ", nb_edges(graph), "edges.")
  for edge in edges(graph)
    show(edge)
  end
end

"Get all the edges for a certain node"
function get_edges_for_node(graph::AbstractGraph{T, Z}, node::T) where {T, Z}
  corresponding_edges = Vector{Edge{Z, T}}()
  for edge in edges(graph)
      if edge.node1 == node || edge.node2 == node
          push!(corresponding_edges, edge)
      end
  end
  return corresponding_edges
end

function get_oriented_edges(graph::AbstractGraph{T, Z}, node::T) where {T, Z}
  corresponding_edges = Vector{EdgeOriented{Z, T}}()
  for edge in edges(graph)
    edge_new=convert(EdgeOriented,edge)
    if edge_new.debut == node || edge_new.fin == node
      push!(corresponding_edges, edge_new)
    end
  end
  return corresponding_edges
end
