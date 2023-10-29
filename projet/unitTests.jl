using Test
include("node.jl")
include("edge.jl")
include("graph.jl")
include("edge_oriented.jl")
include("composante_connexe.jl")

# Testing node.jl
noeud1 = Node("James", "ahooj")
@test name(noeud1) == "James"
@test data(noeud1) == "ahooj"

noeud2 = Node("Kirk", "guitar")
noeud3 = Node("Lars", 2)
noeud4 = Node("Lars", "char")


# Testing edge.jl
edge1 = Edge(noeud1, noeud2, 5)
@test node1(edge1) == noeud1
@test node2(edge1) == noeud2
@test poids(edge1) == 5

@test_throws MethodError Edge(noeud1, noeud3, 5)

oriente_edge = EdgeOriented(noeud1, noeud2, 3)
@test debut(oriente_edge) == noeud1
@test fin(oriente_edge) == noeud2
@test poids(oriente_edge) == 3

edge2 = Edge(noeud1, noeud2, 5)

# Testing graph.jl
G = Graph("Ick", [noeud1, noeud2, noeud4], [edge1, edge2])

@test name(G) == "Ick"
@test nodes(G) == [noeud1, noeud2, noeud4]
@test edges(G) == [edge1, edge2]

edge_oriented_1 = EdgeOriented(noeud1, noeud2, 5)
edge_oriented_2 = EdgeOriented(noeud2, noeud4, 4)
    
C = ComposanteConnexe(noeud1, [noeud1, noeud2, noeud4], [edge_oriented_1, edge_oriented_2])

@test nodes(C) == [noeud1, noeud2, noeud4]
@test edges(C) == [edge_oriented_1, edge_oriented_2]

@test isless(edge_oriented_1, edge_oriented_2) == false
@test <(edge_oriented_1, edge_oriented_2) == false
@test >(edge_oriented_1, edge_oriented_2) == true

v = [edge_oriented_1, edge_oriented_2, edge_oriented_2]
sort!(v)

@test sort([edge_oriented_1, edge_oriented_2]) == [edge_oriented_2, edge_oriented_1]
@test convert(EdgeOriented, edge1) == EdgeOriented{Int64, Node{String}}(Node{String}("James", "ahooj"), Node{String}("Kirk", "guitar"), 5)
