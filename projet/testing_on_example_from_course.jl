using Test
include("node.jl")
include("edge.jl")
include("graph.jl")
include("edge_oriented.jl")
include("composante_connexe.jl")
include("arbre_de_recouvrement.jl")
#include("prim.jl")

# Initializing nodes from example from laboratories
noeud1 = Node("a", "a")
noeud2 = Node("b", "b")
noeud3 = Node("c", "c")
noeud4 = Node("d", "d")
noeud5 = Node("e", "e")
noeud6 = Node("f", "f")
noeud7 = Node("g", "g")
noeud8 = Node("h", "h")
noeud9 = Node("i", "i")

# Initializing edges from example from laboratories
edge1 = Edge(noeud1, noeud2, 4.0)
edge2 = Edge(noeud1, noeud8, 8.0)
edge3 = Edge(noeud2, noeud8, 11.0)
edge4 = Edge(noeud2, noeud3, 8.0)
edge5 = Edge(noeud8, noeud9, 7.0)
edge6 = Edge(noeud8, noeud7, 1.0)
edge7 = Edge(noeud7, noeud9, 6.0)
edge8 = Edge(noeud9, noeud3, 2.0)
edge9 = Edge(noeud7, noeud6, 2.0)
edge10 = Edge(noeud3, noeud4, 7.0)
edge11 = Edge(noeud3, noeud6, 4.0)
edge12 = Edge(noeud4, noeud6, 14.0)
edge13 = Edge(noeud4, noeud5, 9.0)
edge14 = Edge(noeud6, noeud5, 10.0)

# Initializing graph from example from laboratories
lab_nodes = [noeud1, noeud2, noeud3, noeud4, noeud5, noeud6, noeud7, noeud8, noeud9]
lab_edges = [edge1, edge2, edge3, edge4, edge5, edge6, edge7, edge8, edge9, edge10, edge11, edge12, edge13, edge14]
G = Graph("Lab", lab_nodes, lab_edges)

# Initializing expected kruskal connected component
kruskal_expected_edges = [edge1, edge2, edge6, edge8, edge9, edge10, edge11, edge13]
kruskal_expected_edges = convert(Array{EdgeOriented{Float64, Node{String}}}, kruskal_expected_edges)
expected_connected_component_kruskal = ComposanteConnexe(noeud1, lab_nodes, kruskal_expected_edges)

# Testing kruskal connected component
kruskal_component = kruskal(G)
print(kruskal_component)
print("\n")
print(expected_connected_component_kruskal)

testing_components_equal(kruskal_component, expected_connected_component_kruskal)
#@test kruskal(G) == expected_connected_component_kruskal

