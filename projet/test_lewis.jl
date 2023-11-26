include("rsl_algorithm.jl")


G = get_graph_from_file(pwd() * "\\instances\\stsp\\bayg29.tsp")
for i in 1:length(nodes(G))
start_point = nodes(G)[i]

my_edges = lewis(G, start_point)
@test length(my_edges) == length(nodes(G))
sum = 0
last_n1 = node1(my_edges[1])
last_n2 = node2(my_edges[1])

# Testing that we really do get a cycle and creating the sum of weights at the same time
for e in my_edges
    sum = sum + poids(e)
    @test node1(e) == last_n1 || node1(e) == last_n2 || node2(e) == last_n1 || node2(e) == last_n2
    last_n1 = node1(e)
    last_n2 = node2(e)
end
@test node1(my_edges[1]) == last_n1 || node1(my_edges[1]) == last_n2 || node2(my_edges[1]) == last_n1 || node2(my_edges[1]) == last_n2

print(sum, ", ", i, "\n")
end