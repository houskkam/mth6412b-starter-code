include("rsl_algorithm.jl")

G = get_graph_from_file(pwd() * "\\instances\\stsp\\bayg29.tsp")
(lowest_sum, lowest_i) = (10000, 10000)

for i in 1:length(nodes(G))
    start_point = nodes(G)[i]

    (my_nodes, my_edges, elapsed_time, elapsed_time_no_test) = lewis(G, start_point, false)
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

    print(sum, ", ", i, " ", elapsed_time, " ", elapsed_time_no_test, "\n")
    if lowest_sum > sum
        lowest_sum = sum
        lowest_i = i
    end
end

best_start_point_kruskal = nodes(G)[lowest_i]
(my_nodes, my_edges, elapsed_time, elapsed_time_no_test) = lewis(G, best_start_point_kruskal, true)
print("lowest sum: ", lowest_sum, " for ", lowest_i, "th starting node and times ", elapsed_time, " with a test and ", elapsed_time_no_test, " without\n")
print(my_edges)