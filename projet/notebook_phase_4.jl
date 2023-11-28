### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 087373f5-e590-497d-b149-5829250ffe0f


# ╔═╡ b4b81322-5632-11ee-39de-e3a0b20a4a8f
md"""
# Rapport Projet 4
## MTH6412B
"""

# ╔═╡ ca69731a-4b04-408c-b2cd-9ff44b90cc8b


# ╔═╡ d1426d43-4b3d-4e41-bed6-1460ee7631c5
md"""
# L’algorithme de Rosenkrantz, Stearns et Lewis


We started by implementing the Rosenkrantz, Stearns and Lewis algorithm as a function named lewis, 
which takes in three arguments. First argument is type Graph specifies which graph we want to find the cycle for, the second argument is type Node that specifies from which node we want to start constructing the tree and the last argument is a Boolean and specifies whether we used Kruskal's algorithm to find minimum spanning tree or not.

### has\_triang\_inequality function
To do that we also created a 
function has\_triang\_inequality, which verifies whether the triangular inequality of costs in a graph is satisfied. If it was not the case we cannost use the Rosenkrantz, Stearns and Lewis algorithm to find the cycle.

"""

# ╔═╡ 5550507b-071c-419c-8756-52159add7cdd
md"""
```julia
include("node.jl")
using Test
include("arbre_de_recouvrement.jl")
include("composante_connexe.jl")
include("tree.jl")
include("graph.jl")
include("read_graph.jl")
include("prim.jl")
```
"""

# ╔═╡ 1f2f5965-2e76-4170-91d9-971a27c46fad
md"""
Returns true if the triangle inequality : c(u,w) <= c(u,v) + c(v,w)
is valid for the graph, false if it is not.
"""

# ╔═╡ e8cd37bb-16c3-40f8-a95a-a67896fce64d
md"""
```julia
function has_triang_inequality(g::Graph{T, Z}) where {T, Z}
	for e in edges(g)
        n1 = node1(e)
        n2 = node2(e)
        for n3 in nodes(g)
	           if !isnothing(get_edge(g, n1, n3)) && !isnothing(get_edge(g, n2, n3))
	            # if there exists a case where the triangle inequality of cost
	            # is not satisfied, return false
                if poids(get_edge(g, n1, n3)) > poids(e)+poids(get_edge(g, n2, n3))
	                print(poids(e), "\n")
	                print(poids(get_edge(g, n1, n3)), "\n")
	                print(poids(get_edge(g, n2, n3)), "\n")
	                return false
	            end
	        end
	    end
	end
	# we checked all edges of the graph and found none that would not satisfy the triangle inequality
	return true
end
```
"""

# ╔═╡ bf1edaad-1ec7-44f7-8842-3effca157c2a
md"""
### preordre\_graph! function
We also created a recursive function preordre\_graph!, which takes in a connected component, root, parent of the root and a vector of already processed nodes. For the first iteration, we pretend that the root is also its parent because otherwise we would have to be checking whether the parent exists, which would cost us some time.

This function goes through all the edges of a connected component. It takes all edges belonging to the node that is currently being processed, checks whether the other node belonging to the edge is the parent of the first one in which case it would do nothing. If the other node is not our node's parent, it pushes it to the vector of preorder traversal nodes and then calls preordre_graph! on it. Therefore, the list of nodes is indeed ordered in the order of visiting. 

"""

# ╔═╡ e0e531e1-0d22-40dc-851e-a36cfdfd48be
md"""
```julia
function preordre_graph!(g::AbstractGraph{Node{T}, Z}, root::Node{T}, parent::Node{T}, tour_nodes::Vector{Node{T}}) where {T, Z}
	for e in get_edges_for_node(g, root)
        if (e != get_edge(g, root, parent))
	        if debut(e) == root
	            push!(tour_nodes, fin(e))
	            preordre_graph!(g, fin(e), root, tour_nodes)
            else
                push!(tour_nodes, debut(e))
	            preordre_graph!(g, debut(e), root, tour_nodes)
	        end
	    end
	end
    tour_nodes
end
```
"""

# ╔═╡ 0bb585d7-a59d-4d04-a892-b7c41c49e0c0
md"""

### get\_edges function
Then we also use a function named get\_edges with parameters graph and vector of nodes that we just got from the last function. It returns a vector of edges connecting the nodes that we just created. As we will verify later, this vector is the cycle we were looking for.

We also considered other methods of doing this exercice but in the end they were not used.

"""

# ╔═╡ 26bc66fe-0655-4d95-9884-677534101bf4
md"""
Returns the edges connecting nodes ordered by a preordre traversal of a given graph.
"""

# ╔═╡ 0b2081a7-ba58-4d14-a07a-4c3cbfe06e93
md"""
```julia
function get_edges(g::Graph{Node{T}, Z}, tour_nodes::Vector{Node{T}}) where {T, Z}
	tour_edges = Vector{AbstractEdge{Z, Node{T}}}()
	
	for i in 1:(length(tour_nodes) - 1)
	    e = get_edge(g, tour_nodes[i], tour_nodes[i+1])
	    if !(isnothing(e))
	        push!(tour_edges, e)
	    else
	        print("error, no edge between", tour_nodes[i], tour_nodes[i+1], "\n")
	    end
	end
	e = get_edge(g, tour_nodes[1], tour_nodes[length(tour_nodes)])
	if !(isnothing(e))
        push!(tour_edges, e)
	else
	     println("Did not find a cycle")
	end
	tour_edges
end
```
"""

# ╔═╡ 94c2d349-88d2-4af7-8300-c9ef14d84574
md"""
## Testing 
After creating the code, tests can be used to verify the algorithm. We tested the algorithm in test\_lewis.jl file as follows.
"""

# ╔═╡ 2527cb8d-ea35-4c97-a8ef-c0ba3b8fb76b
md"""
#### Looking for the best parameters to resolve a symetric TSP problem with Kruskal

We found out several things. First of all, we measured two times - one that included checking of whether triangular inequality holds or not and one that only started measuring time after this check. We found that checking the condition takes up a lot of time - more than the rest of the algorithm.

Secondly, when we used Kruskal's algorithm to find the minimal spanning tree, we got total price around 2000-2200 for different roots of the tree even though the optimal cost for this graph is 1600. This is correct because Rosenkrantz, Stearns and Lewis algorithm guarantees to return a cycle with weights less than 2 times the optimal, which is exactly what we got here.
"""

# ╔═╡ 7b0fda6f-d917-4e3a-a44c-ff85261e7507
md"""
```julia
include("rsl_algorithm.jl")
	
G = get_graph_from_file(pwd() * "\\instances\\stsp\\bayg29.tsp")
(lowest_sum, lowest_i) = (10000, 10000)
	
for i in 1:length(nodes(G))
	 start_point = nodes(G)[i]
	
	(my_edges, elapsed_time, elapsed_time_no_test) = lewis(G, start_point, true)
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
(my_edges, elapsed_time, elapsed_time_no_test) = lewis(G, best_start_point_kruskal, true)
print("lowest sum: ", lowest_sum, " for ", lowest_i, "th starting node and times ", elapsed_time, " with a test and ", elapsed_time_no_test, " without\n")
print(my_edges)
```
"""

# ╔═╡ baa49694-bc28-4c64-8045-4005dd7fe7d9
md"""
The results we got were concretely:

2210.0, 1 0.17499995231628418 0.0279998779296875

2134.0, 2 0.14700007438659668 0.0

2168.0, 3 0.14400005340576172 0.0

2166.0, 4 0.14699983596801758 0.0009999275207519531

2178.0, 5 0.1549999713897705 0.0

2244.0, 6 0.1380000114440918 0.0009999275207519531

2064.0, 7 0.13899993896484375 0.0009999275207519531

2149.0, 8 0.1399998664855957 0.0009999275207519531

2147.0, 9 0.13299989700317383 0.0

2167.0, 10 0.12199997901916504 0.0010001659393310547

2134.0, 11 0.127000093460083 0.0010001659393310547

2224.0, 12 0.11999988555908203 0.0009999275207519531

2167.0, 13 0.1359999179840088 0.0009999275207519531

2104.0, 14 0.12600016593933105 0.0010001659393310547

2095.0, 15 0.14300012588500977 0.0

2156.0, 16 0.11899995803833008 0.0009999275207519531

2014.0, 17 0.13000011444091797 0.0

2095.0, 18 0.12600016593933105 0.0010001659393310547

2075.0, 19 0.1510000228881836 0.0

2134.0, 20 0.15799999237060547 0.0010001659393310547

2168.0, 21 0.1359999179840088 0.0009999275207519531

2134.0, 22 0.11799979209899902 0.0009999275207519531

2175.0, 23 0.13100004196166992 0.0

2210.0, 24 0.13100004196166992 0.0

2064.0, 25 0.19000005722045898 0.002000093460083008

2178.0, 26 0.23200011253356934 0.0010001659393310547

2175.0, 27 0.21000003814697266 0.0009999275207519531

2244.0, 28 0.1679999828338623 0.0009999275207519531

2168.0, 29 0.14299988746643066 0.0

"""

# ╔═╡ 29321506-8c84-419a-a7ea-75dacd589107
md"""
### The cycle with lowest weight while using Kruskal to find minimum spanning tree

Concretely, the program told us this:

lowest sum: 2014.0 for 17th starting node and times 0.17199993133544922 with a test and 0.0 without

We can see that the weight of this sum is 2014, which is 404 more than the optimal cycle of this graph (1610). The execution was very quick - so much so that when we did not check the condition of triangular inequality, the program did not even consider such low execution time. We got this result when we started the preorder traversal with the 17th node as a root.

### Graphical illustration of this cycle that we got from our program

AbstractEdge{Float64, Node{Float64}}[Edge{Float64, Node{Float64}}(Node{Float64}("40.0", 2090.0), Node{Float64}("970.0", 1340.0), 47.0), Edge{Float64, Node{Float64}}(Node{Float64}("840.0", 550.0), Node{Float64}("970.0", 1340.0), 36.0), Edge{Float64, Node{Float64}}(Node{Float64}("840.0", 550.0), Node{Float64}("360.0", 1980.0), 32.0), Edge{Float64, Node{Float64}}(Node{Float64}("790.0", 2260.0), Node{Float64}("360.0", 1980.0), 56.0), Edge{Float64, Node{Float64}}(Node{Float64}("1170.0", 2300.0), Node{Float64}("790.0", 2260.0), 34.0), Edge{Float64, Node{Float64}}(Node{Float64}("1170.0", 2300.0), Node{Float64}("1040.0", 950.0), 39.0), Edge{Float64, Node{Float64}}(Node{Float64}("1040.0", 950.0), Node{Float64}("1280.0", 790.0), 25.0), Edge{Float64, Node{Float64}}(Node{Float64}("1280.0", 1200.0), Node{Float64}("1280.0", 790.0), 49.0), Edge{Float64, Node{Float64}}(Node{Float64}("1280.0", 1200.0), Node{Float64}("750.0", 1100.0), 41.0), Edge{Float64, Node{Float64}}(Node{Float64}("1260.0", 1500.0), Node{Float64}("750.0", 1100.0), 50.0), Edge{Float64, Node{Float64}}(Node{Float64}("1260.0", 1500.0), Node{Float64}("1150.0", 1760.0), 42.0), Edge{Float64, Node{Float64}}(Node{Float64}("1260.0", 1910.0), Node{Float64}("1150.0", 1760.0), 56.0), Edge{Float64, Node{Float64}}(Node{Float64}("1260.0", 1910.0), Node{Float64}("1840.0", 1240.0), 46.0), Edge{Float64, Node{Float64}}(Node{Float64}("1840.0", 1240.0), Node{Float64}("490.0", 2130.0), 71.0), Edge{Float64, Node{Float64}}(Node{Float64}("750.0", 2030.0), Node{Float64}("490.0", 2130.0), 34.0), Edge{Float64, Node{Float64}}(Node{Float64}("750.0", 2030.0), Node{Float64}("630.0", 1660.0), 52.0), Edge{Float64, Node{Float64}}(Node{Float64}("630.0", 1660.0), Node{Float64}("830.0", 1770.0), 38.0), Edge{Float64, Node{Float64}}(Node{Float64}("230.0", 590.0), Node{Float64}("830.0", 1770.0), 39.0), Edge{Float64, Node{Float64}}(Node{Float64}("230.0", 590.0), Node{Float64}("510.0", 700.0), 84.0), Edge{Float64, Node{Float64}}(Node{Float64}("510.0", 700.0), Node{Float64}("750.0", 900.0), 98.0), Edge{Float64, Node{Float64}}(Node{Float64}("750.0", 900.0), Node{Float64}("460.0", 860.0), 286.0), Edge{Float64, Node{Float64}}(Node{Float64}("460.0", 860.0), Node{Float64}("1460.0", 1420.0), 36.0), Edge{Float64, Node{Float64}}(Node{Float64}("590.0", 1390.0), Node{Float64}("1460.0", 1420.0), 60.0), Edge{Float64, Node{Float64}}(Node{Float64}("590.0", 1390.0), Node{Float64}("1030.0", 2070.0), 215.0), Edge{Float64, Node{Float64}}(Node{Float64}("1030.0", 2070.0), Node{Float64}("1650.0", 650.0), 71.0), Edge{Float64, Node{Float64}}(Node{Float64}("1650.0", 650.0), Node{Float64}("710.0", 1310.0), 52.0), Edge{Float64, Node{Float64}}(Node{Float64}("1490.0", 1630.0), Node{Float64}("710.0", 1310.0), 72.0), Edge{Float64, Node{Float64}}(Node{Float64}("1490.0", 1630.0), Node{Float64}("490.0", 500.0), 147.0), Edge{Float64, Node{Float64}}(Node{Float64}("490.0", 500.0), Node{Float64}("40.0", 2090.0), 106.0)]
"""

# ╔═╡ 717a3920-0f31-4e12-87c5-52351f30bcd1
md"""
### Looking for the best parameters to resolve a symetric TSP problem with Prim

We executed the same program that we have shown above only with the line calling the RSL algorithm with parameter false, so that the algorithm would have to use Prim algorithm to fin the minimum spanning tree.

(my_edges, elapsed_time, elapsed_time_no_test) = lewis(G, start_point, false)

"""

# ╔═╡ 559c26ed-12fa-4ddf-be28-a54c305b30f5
md"""
#### Results

The weights seems to be the same for each starting node. The only difference we percieve is that prim seems to be taking longer time to execute than Kruskal from the last section

2210.0, 1 0.12099981307983398 0.02299976348876953

2134.0, 2 0.12400007247924805 0.0010001659393310547

2168.0, 3 0.1119999885559082 0.0009999275207519531

2166.0, 4 0.12599992752075195 0.0009999275207519531

2215.0, 5 0.11499977111816406 0.0009999275207519531

2244.0, 6 0.11300015449523926 0.0009999275207519531

2064.0, 7 0.12100005149841309 0.0010001659393310547

2149.0, 8 0.11500000953674316 0.0

2197.0, 9 0.11799979209899902 0.0009999275207519531

2167.0, 10 0.11999988555908203 0.0009999275207519531

2134.0, 11 0.12100005149841309 0.0010001659393310547

2224.0, 12 0.11100006103515625 0.0010001659393310547

2167.0, 13 0.10899996757507324 0.0009999275207519531

2104.0, 14 0.10899996757507324 0.0009999275207519531

2095.0, 15 0.11299991607666016 0.0009999275207519531

2156.0, 16 0.12100005149841309 0.0009999275207519531

2014.0, 17 0.1099998950958252 0.0009999275207519531

2095.0, 18 0.13199996948242188 0.0009999275207519531

2075.0, 19 0.12800002098083496 0.0010001659393310547

2134.0, 20 0.1399998664855957 0.0

2168.0, 21 0.11599993705749512 0.0

2134.0, 22 0.13199996948242188 0.0010001659393310547

2175.0, 23 0.12000012397766113 0.0009999275207519531

2210.0, 24 0.1380000114440918 0.0009999275207519531

2064.0, 25 0.12899994850158691 0.0009999275207519531

2178.0, 26 0.12799978256225586 0.0009999275207519531

2175.0, 27 0.14100003242492676 0.0010001659393310547

2244.0, 28 0.127000093460083 0.0010001659393310547

2168.0, 29 0.1119999885559082 0.0009999275207519531

### The best parameters to resolve a symetric TSP problem with Prim
The best parameter that our algorithm found is once again when we start with the 17th node as a root and we get the weight of 2014. The only difference from Kruskal seem to be the execution times, so using Kruskal might be better.

lowest sum: 2014.0 for 17th starting node and times 0.12999987602233887 with a test and 0.0009999275207519531 without

### Graphical illustration of this cycle that we got from out program

AbstractEdge{Float64, Node{Float64}}[Edge{Float64, Node{Float64}}(Node{Float64}("40.0", 2090.0), Node{Float64}("970.0", 1340.0), 47.0), Edge{Float64, Node{Float64}}(Node{Float64}("840.0", 550.0), Node{Float64}("970.0", 1340.0), 36.0), Edge{Float64, Node{Float64}}(Node{Float64}("840.0", 550.0), Node{Float64}("360.0", 1980.0), 32.0), Edge{Float64, Node{Float64}}(Node{Float64}("790.0", 2260.0), Node{Float64}("360.0", 1980.0), 56.0), Edge{Float64, Node{Float64}}(Node{Float64}("1170.0", 2300.0), Node{Float64}("790.0", 2260.0), 34.0), Edge{Float64, Node{Float64}}(Node{Float64}("1170.0", 2300.0), Node{Float64}("1040.0", 950.0), 39.0), Edge{Float64, Node{Float64}}(Node{Float64}("1040.0", 950.0), Node{Float64}("1280.0", 790.0), 25.0), Edge{Float64, Node{Float64}}(Node{Float64}("1280.0", 1200.0), Node{Float64}("1280.0", 790.0), 49.0), Edge{Float64, Node{Float64}}(Node{Float64}("1280.0", 1200.0), Node{Float64}("750.0", 1100.0), 41.0), Edge{Float64, Node{Float64}}(Node{Float64}("1260.0", 1500.0), Node{Float64}("750.0", 1100.0), 50.0), Edge{Float64, Node{Float64}}(Node{Float64}("1260.0", 1500.0), Node{Float64}("1150.0", 1760.0), 42.0), Edge{Float64, Node{Float64}}(Node{Float64}("1260.0", 1910.0), Node{Float64}("1150.0", 1760.0), 56.0), Edge{Float64, Node{Float64}}(Node{Float64}("1260.0", 1910.0), Node{Float64}("1840.0", 1240.0), 46.0), Edge{Float64, Node{Float64}}(Node{Float64}("1840.0", 1240.0), Node{Float64}("490.0", 2130.0), 71.0), Edge{Float64, Node{Float64}}(Node{Float64}("750.0", 2030.0), Node{Float64}("490.0", 2130.0), 34.0), Edge{Float64, Node{Float64}}(Node{Float64}("750.0", 2030.0), Node{Float64}("630.0", 1660.0), 52.0), Edge{Float64, Node{Float64}}(Node{Float64}("630.0", 1660.0), Node{Float64}("830.0", 1770.0), 38.0), Edge{Float64, Node{Float64}}(Node{Float64}("230.0", 590.0), Node{Float64}("830.0", 1770.0), 39.0), Edge{Float64, Node{Float64}}(Node{Float64}("230.0", 590.0), Node{Float64}("510.0", 700.0), 84.0), Edge{Float64, Node{Float64}}(Node{Float64}("510.0", 700.0), Node{Float64}("750.0", 900.0), 98.0), Edge{Float64, Node{Float64}}(Node{Float64}("750.0", 900.0), Node{Float64}("460.0", 860.0), 286.0), Edge{Float64, Node{Float64}}(Node{Float64}("460.0", 860.0), Node{Float64}("1460.0", 1420.0), 36.0), Edge{Float64, Node{Float64}}(Node{Float64}("590.0", 1390.0), Node{Float64}("1460.0", 1420.0), 60.0), Edge{Float64, Node{Float64}}(Node{Float64}("590.0", 1390.0), Node{Float64}("1030.0", 2070.0), 215.0), Edge{Float64, Node{Float64}}(Node{Float64}("1030.0", 2070.0), Node{Float64}("1650.0", 650.0), 71.0), Edge{Float64, Node{Float64}}(Node{Float64}("1650.0", 650.0), Node{Float64}("710.0", 1310.0), 52.0), Edge{Float64, Node{Float64}}(Node{Float64}("1490.0", 1630.0), Node{Float64}("710.0", 1310.0), 72.0), Edge{Float64, Node{Float64}}(Node{Float64}("1490.0", 1630.0), Node{Float64}("490.0", 500.0), 147.0), Edge{Float64, Node{Float64}}(Node{Float64}("490.0", 500.0), Node{Float64}("40.0", 2090.0), 106.0)]


"""

# ╔═╡ c6c6dd31-de50-4d3f-9317-a49577d6ef41


# ╔═╡ caa97f05-c634-415e-92ae-695f8538474e
md"""
# L’algorithme de Held et Karp
For the Held Karp method the following algorithm is used:
1. Let ``k=0``, ``\pi^0=0`` en ``W=-\infty``.
2. Find the minimum 1-tree ``T_{\pi}^k``.
3. Calculate ``w(\pi^k)=L(T_{\pi}^k) - 2\sum_{i}\pi_{i}``.
4. Let ``W=\max(W, w(\pi^k))``.
5. Let ``v^k=d^k-2`` (with all vectors), where ``d^k`` contains the degrees of the nodes in ``T_{\pi}^k``.
6. If ``v^k=0`` (``T_{\pi}^k`` is an optimal tour), or a stop criterion is satisfied, then stop.
7. Choose a step size, ``t^k``.
8. Let ``\pi^{(k+1)}=\pi^k+t^k\cdot v^k``.
9. Let ``k=k+1`` and go to step 2.

To start the Held Karp function a few helping functions are made, to make the real code less heavy. These functions are mentioned below.
"""

# ╔═╡ 2d52d2c8-5a2b-4fe1-b1fb-adde64e8ea68
md"""
### Creating the minimum one tree
```julia
function min_one_tree(graph::Graph{Node{T}, Z}, root::Node{T}) where {T, Z}
    #get the adjacent edges of the root
    to_remove = get_oriented_edges(graph, root)

    #get all the nodes
    all_nodes= nodes(graph)

    # Creates a vector of all graph's node except the root
    nodes_base = filter(x -> x != root, all_nodes)

    # Creates a vector of all graphs edges except the edges adjacent to the root
    edges_base = filter(x -> !(x in to_remove), edges(graph))
    
    # Gets the MST tree and its corresponding connex component c for the subgraph graph[V\{root}]
    component = kruskal(Graph("", nodes_base, edges_base))
    length(component) != 1 && error("kruskal has more than 1 component")
    #kruskal only gives the composante_connexe back and we also want a tree to be given back
    edges_tree = edges(component)

    tree_structure = Graph("MST", nodes_base, edges_tree)
    
    # Get degrees of nodes in the components (assuming it's a directed graph)
    node_degrees = Dict(node => 0 for node in all_nodes)
    for edge in edges(component)
        node_degrees[debut(edge)] += 1
        node_degrees[fin(edge)] += 1
    end

    # Filter nodes with degree 1
    leaves = filter(kv -> kv.second == 1, node_degrees)
   
    # Order these edges by weight
    edge_sorted = sort(to_remove, by=weight)
    
    # Add the root and 2 cheapest arcs from the root to a leaf
    # Keep the component components updated
    # We are updating the degrees
    add_node!(tree_structure, root)
    for i in 1:2
        e = pop!(edge_sorted)    
        add_edge!(tree_structure, e)
        # If any of the 2 extremities is root, its degree won't be updated because it           won't be part of the dictionary yet
        node_degrees[ends(e)[1]] += 1
        node_degrees[ends(e)[2]] += 1
    end
    node_degrees[root] = 2
    return tree_structure, component
end
```
"""

# ╔═╡ 34a3bd75-4f8c-4914-b186-a04c06263e3a
md"""
### Computing the weights
```julia
function compute_weight(graph::Graph{T, Z}, tour::Graph{T, Z}, pi::Vector{Float64}) where {T, Z}
    # Initialize total weight
    total_weight = 0.0

    # Define a function to get the index of a node in the graph
    node_index(graph, node) = findfirst(x -> x == node, nodes(graph))

    # Iterate over edges in the tour
    for edge in edges(tour)
        # Extract nodes of the edge
        node1, node2 = ends(edge)

        # Update total weight with edge weight and Lagrangian multipliers (pi)
        total_weight += weight(edge) + pi[node_index(graph, node1)] + pi[node_index(graph, node2)]
    end

    # Compute the weight of the tour using the 1-tree and pi vector

    return total_weight
end
```
"""


# ╔═╡ 4452c2e0-a957-41a0-a79d-2e342b7e2e43
md"""
### Updating the degrees of the nodes
```julia
function update_degrees(graph::Graph{T, Z}, components, root::Node{T}, pi::Vector{Float64}) where {T, Z}
    # Initialize degrees for all nodes
    node_degrees = zeros(Int64, nb_nodes(graph))

    # Update degrees based on the 1-tree
    for component in components
        for edge in edges(component)
            # Increment degrees of the nodes in the 1-tree
            node_degrees[node_index(graph, ends(edge)[1])] += 1
            node_degrees[node_index(graph, ends(edge)[2])] += 1
        end
    end

    # If the root is not present in the 1-tree, add it with a degree of 2
    node_degrees[node_index(graph, root)] += 2

    # Update degrees based on the Lagrangian multipliers (pi)
    node_degrees .+= round.(Int, pi)

    return node_degrees
end

```
"""

# ╔═╡ 4a7e4b4e-4683-4b66-b108-061b33808501
md"""
### Choose a stopping criterium
Implement your stopping criterion, e.g., based on degrees or other conditions
```julia
function stopping_criterion(v_k, max_iterations, max_time)
    #The stopping criterium stops when looking at these two conditions
    # Check if v^k is all zeros
    all_zeros = all(x -> x == 0, v_k)

    #If the number of iterations max_iterations is zero OR if  the maximum time max_time is zero. 
    return all_zeros || max_iterations <= 0 || max_time <= 0
end
```
"""

# ╔═╡ e9fe1ef8-f516-4958-8938-5bfbd0506a0d
md"""
### Transform your matrix
```julia
function transform_matrix(graph::Graph{T, Z}, pi::Vector) where {T, Z}
    # when d_{ij}= c_{ij}+ pi_i+ pi_j 
    transformed_graph = deepcopy(graph)

    # Define a function to get the index of a node in the graph
    node_index(graph, node) = findfirst(x -> x == node, nodes(graph))

    # Loop over all edges in the graph
    for edge in edges(transformed_graph)
        node1, node2 = ends(edge)

        # Calculate the new weights based on the Lagrangian multiplicators
        new_weight = weight(edge) + pi[node_index(graph, node1)] + pi[node_index(graph, node2)]

        # Adjust the weights of the edges
        set_weight!(transformed_graph, edge, new_weight)
    end

    return transformed_graph
end
```
"""

# ╔═╡ 0bcf9455-13b9-4b8f-aac5-39883f57adef
md"""
## The Held and Karp function implemented
After the helping functions are implemented the held karp function is created.
```julia
function held_karp(graph::Graph{Node{T}, Z}, root::Node{T}, max_iterations::Int, max_time::Float64) where {T, Z}
    n = length(nodes(graph))
    k = 0
    W = -Inf
    pi= zeros(Float64,n)

    starting_time = time()

    t_k=1
    while true
        # Step 2: Find a min 1-tree T_{\pi}^k
        tree_structure, components = min_one_tree(graph, root)

        # Step 3: Compute w(pi^k)
        w_pk = compute_weight(graph, tree_structure, pi)

        # Step 4: Update W
        W = max(W, w_pk)

        # Step 5: Let v^k=d^k-2
        node_degrees = update_degrees(graph, components, root, pi)
        v_k = node_degrees .- 2

        # Step 6: Stopping criterion
        elapsed_time = time() - starting_time
        if stopping_criterion(v_k, max_iterations, max_time)
            break
        end


        # Step 8: Update pi
        pi= pi + t_k * v_k
        # Stap 9: Transform the weight of the edges based on the new lagrangian multiplicator
        transformed_graph = transform_matrix(graph, pi)

        # Increment k and repeat
        k += 1
        # Step 7: Choose a step size, t^k
        t_k = 1/k  # Adjust the step size based on your needs
    end

    return W
end
```
"""

# ╔═╡ dbbff07b-3842-40f1-ade4-637b2551ac65
md"""
#### Testing 
After creating the code, tests can be used to verify the algorithm.
Because the held Karp algorithm uses a startpoint, the optimal startpoint when testing an example has to be done by searching for this optimal point via trial and error.
Unfortunately there is an error that we couldn't solve in time, leading to the disability to properly test our code.
The TSP test would start with 

```julia
G = get_graph_from_file(pwd() * "\\instances\\stsp\\bayg29.tsp")
#we need to test with starting node is the most efficient so we change j
j=1
held_karp(G,nodes(G)[j],60, 100.0)
```
"""

# ╔═╡ Cell order:
# ╠═087373f5-e590-497d-b149-5829250ffe0f
# ╟─b4b81322-5632-11ee-39de-e3a0b20a4a8f
# ╟─ca69731a-4b04-408c-b2cd-9ff44b90cc8b
# ╟─d1426d43-4b3d-4e41-bed6-1460ee7631c5
# ╟─5550507b-071c-419c-8756-52159add7cdd
# ╟─1f2f5965-2e76-4170-91d9-971a27c46fad
# ╟─e8cd37bb-16c3-40f8-a95a-a67896fce64d
# ╟─bf1edaad-1ec7-44f7-8842-3effca157c2a
# ╟─e0e531e1-0d22-40dc-851e-a36cfdfd48be
# ╟─0bb585d7-a59d-4d04-a892-b7c41c49e0c0
# ╟─26bc66fe-0655-4d95-9884-677534101bf4
# ╟─0b2081a7-ba58-4d14-a07a-4c3cbfe06e93
# ╟─94c2d349-88d2-4af7-8300-c9ef14d84574
# ╟─2527cb8d-ea35-4c97-a8ef-c0ba3b8fb76b
# ╟─7b0fda6f-d917-4e3a-a44c-ff85261e7507
# ╟─baa49694-bc28-4c64-8045-4005dd7fe7d9
# ╟─29321506-8c84-419a-a7ea-75dacd589107
# ╠═717a3920-0f31-4e12-87c5-52351f30bcd1
# ╟─559c26ed-12fa-4ddf-be28-a54c305b30f5
# ╟─c6c6dd31-de50-4d3f-9317-a49577d6ef41
# ╟─caa97f05-c634-415e-92ae-695f8538474e
# ╟─2d52d2c8-5a2b-4fe1-b1fb-adde64e8ea68
# ╟─34a3bd75-4f8c-4914-b186-a04c06263e3a
# ╟─4452c2e0-a957-41a0-a79d-2e342b7e2e43
# ╟─4a7e4b4e-4683-4b66-b108-061b33808501
# ╟─e9fe1ef8-f516-4958-8938-5bfbd0506a0d
# ╟─0bcf9455-13b9-4b8f-aac5-39883f57adef
# ╟─dbbff07b-3842-40f1-ade4-637b2551ac65
