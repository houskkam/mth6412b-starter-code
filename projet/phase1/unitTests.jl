using Test
include("node.jl")
include("edge.jl")
include("graph.jl")

# Testing node.jl
noeud1 = Node("James", "ahooj")
@test name(noeud1) == "James"
@test data(noeud1) == "ahooj"

noeud2 = Node("Kirk", "guitar")
noeud3 = Node("Lars", 2)

# Testing edge.jl
edge1 = Edge(noeud1, noeud2, 5)
@test node1(edge1) == noeud1
@test node2(edge1) == noeud2
@test poids(edge1) == 5

@test_throws MethodError Edge(noeud1, noeud3, 5)

# Testing graph.jl
G = Graph("Ick", [noeud1, noeud2, noeud3], [edge1, edge2])

