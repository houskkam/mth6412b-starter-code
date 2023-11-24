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
### L’algorithme de Rosenkrantz, Stearns et Lewis

We started by implementing the Rosenkrantz, Stearns and Lewis algorithm as a function named lewis, 
which takes in only one argument and this argument is of type Graph.
To do that we also created a 
function preorder that arranges the nodes of a given graph according to the preorder traversal, which means in the order of visiting. 
As you can see below, we use the function preorder in lewis 
in order to create a cycle.
"""

# ╔═╡ 5550507b-071c-419c-8756-52159add7cdd


# ╔═╡ 94c2d349-88d2-4af7-8300-c9ef14d84574
md"""
#### Testing 
After creating the code, tests can be used to verify the algorithm.
"""

# ╔═╡ c6c6dd31-de50-4d3f-9317-a49577d6ef41
# Julia code can follow here
x = 1

# ╔═╡ caa97f05-c634-415e-92ae-695f8538474e
md"""
### L’algorithme de Held et Karp
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
"""

# ╔═╡ 2d52d2c8-5a2b-4fe1-b1fb-adde64e8ea68
md"""
To start the Held Karp function a few helping functions are made to make the real code less heavy.

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
    
    # Gets the MST tree and its corresponding connex component c for the subgraph 	        graph[V\{root}]
    component = kruskal(Graph("", nodes_base, edges_base))
    length(component) != 1 && error("kruskal has more than 1 component")
    #kruskal only gives the composante_connexe back and we also want a tree to be           given back
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
    # ATTENTION: from now on, because the tree is now a 1-tree, the components does         not contain the information for the edges touching root.
    # We are keeping the degree dictionary updated
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
After the helping functions are implemented the held karp function is created.
```julia
function held_karp(graph::Graph{Node{T}, Z}, root::Node{T}, max_iterations::Int, max_time::Float64) where {T, Z}
    n = size(graph, 1)
    k = 0
    W = -Inf
    pi= zeros(Float64,n)

    starting_time = time()

    # Initial dict_pi corresponding to pi^0=0
    #dict_pi = Dict{Node{T}, Float64}(node => 0.0 for node in nodes(graph))
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
"""

# ╔═╡ Cell order:
# ╠═087373f5-e590-497d-b149-5829250ffe0f
# ╟─b4b81322-5632-11ee-39de-e3a0b20a4a8f
# ╟─ca69731a-4b04-408c-b2cd-9ff44b90cc8b
# ╟─d1426d43-4b3d-4e41-bed6-1460ee7631c5
# ╠═5550507b-071c-419c-8756-52159add7cdd
# ╠═94c2d349-88d2-4af7-8300-c9ef14d84574
# ╟─c6c6dd31-de50-4d3f-9317-a49577d6ef41
# ╟─caa97f05-c634-415e-92ae-695f8538474e
# ╟─2d52d2c8-5a2b-4fe1-b1fb-adde64e8ea68
# ╟─34a3bd75-4f8c-4914-b186-a04c06263e3a
# ╟─4452c2e0-a957-41a0-a79d-2e342b7e2e43
# ╟─4a7e4b4e-4683-4b66-b108-061b33808501
# ╟─e9fe1ef8-f516-4958-8938-5bfbd0506a0d
# ╟─0bcf9455-13b9-4b8f-aac5-39883f57adef
# ╟─dbbff07b-3842-40f1-ade4-637b2551ac65
