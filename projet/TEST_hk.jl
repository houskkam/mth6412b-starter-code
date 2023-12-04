include("node.jl")
include("graph.jl")
using Test
include("composante_connexe.jl")
include("arbre_de_recouvrement.jl")
include("hk_algorithm.jl")
include("read_graph.jl")
include("read_stsp.jl")

G = get_graph_from_file(pwd() * "\\instances\\stsp\\bayg29.tsp")
(lowest_sum, lowest_i) = (10000, 10000)


sum = held_karp(G,nodes(G)[1],1000, 100.0)
print(sum)