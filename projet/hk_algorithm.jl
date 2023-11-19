include("composante_connexe.jl")
include("graph.jl")
include("prim.jl")
include("node.jl")
"
HK algorithm
1. Let k=0, pi^0=0 and W=-inf. 
2.Find a min 1-tree T-{pi}^k. 
3. Compute w(pi^k)=L(T_{pi}^k) -2*summation (pi_{i}). 
4. Let W=max(W, w(pi^k)). 
5. Let v^k=d^k-2 (with all of this vectors) where d^k contains the degrees of nodes in T_{pi}^k.  
6. if v^k=0 ((T_{pi}^k) is an optimal tour), or a stop criterion is satisfied, then stop. 
7. Choose a step size, t^k 
8. let pi ^(k+1)=pi^k+t^k*v^k 
9. Let k=k+1 and go to step 2. 

l'algorithme contient plusieurs paramètres:
1 Kruskal vs. Prim ;
2 le choix du sommet privilégié (la racine) ;
3 le choix de la longueur de pas t (HK) ;
4 le choix du critère d'arrêt (HK).
"


function min_one_tree(graph::Graph{Node{T}, Z}, start_point::Node{T}) where {T, Z}
    #get the adjacent edges of the root
    to_remove = get_oriented_edges(graph, root)

    # Creates a vector of all graph's node except the root
    nodes_base = filter(x -> x != root, all_nodes)

    # Creates a vector of all graphs edges except the edges adjacent to the root
    edges_base = filter(x -> !(x in to_remove), edges(graph))
    
    # Gets the MST tree and its corresponding connex component c for the subgraph graph[V\{root}]
    components = kruskal(Graph("", nodes_base, edges_base))
    #kruskal only gives the composante_connexe back and we also want a tree to be given back
    edges_tree = Vector{Edge{T}}()
    for component in components
        append!(edges_tree, edges(component))
    end
    tree_structure = Graph("MST Tree", nodes_base, edges_tree)
    
    # Get degrees of nodes in the components (assuming it's a directed graph)
    node_degrees = Dict(node => 0 for node in all_nodes)
    for component in components
        for edge in edges(component)
            node_degrees[debut(edge)] += 1
            node_degrees[fin(edge)] -= 1
        end
    end

    # Filter nodes with degree 1
    leaves = filter(kv -> kv.second == 1, node_degrees)
   
    # Order these edges by weight
    edge_sorted = sort(to_remove, by=weight)
    
    # Add the root and 2 cheapest arcs from the root to a leaf
    # Keep the component components updated
    # ATTENTION: from now on, because the tree is now a 1-tree, the components does not contain the information for the edges touching root.
    # We are keeping the degree dictionary updated
    add_node!(tree_structure, root)
    for i in 1:2
        e = pop!(edge_sorted)    
        add_edge!(tree_structure, e)
        # If any of the 2 extremities is root, its degree won't be updated because it won't be part of the dictionary yet
        node_degrees[ends(e)[1]] += 1
        node_degrees[ends(e)[2]] += 1
    end
    node_degrees[root] = 2
    return tree_structure, components
end



function compute_weight(graph::Graph{T,Z}, tour::Graph{T,Z}, pi::Dict{Node{T}, Float64}) where {T,Z}
    # Initialize total weight
    total_weight = 0.0

    # Iterate over edges in the tour
    for edge in edges(tour)
        # Extract nodes of the edge
        node1, node2 = ends(edge)

        # Update total weight with edge weight and Lagrangian multipliers (pi)
        total_weight += weight(edge) + pi[node1] + pi[node2]
    end

    # Compute the weight of the tour using the 1-tree and pi vector
    # Adjust the implementation based on your specific needs

    return total_weight
end


function update_degrees(graph::Graph{T,Z}, components, root::Node{T}, dict_pi::Dict{Node{T}, Float64}) where {T,Z}
    # Create a dictionary to store the degrees of nodes
    node_degrees = Dict{Node{T}, Int64}()

    # Initialize degrees for all nodes
    for node in nodes(graph)
        node_degrees[node] = 0
    end

    # Update degrees based on the 1-tree
    for component in components
        for edge in edges(component)
            # Increment degrees of the nodes in the 1-tree
            increase_degree!(node_degrees, ends(edge)[1])
            increase_degree!(node_degrees, ends(edge)[2])
        end
    end

    # If the root is not present in the dictionary, add it with a degree of 2
    if !haskey(node_degrees, root)
        node_degrees[root] = 2
    end

    # Update degrees based on the Lagrangian multipliers (pi)
    for (node, degree) in node_degrees
        node_degrees[node] += Int(round(dict_pi[node]))
    end

    return node_degrees
end


# Implement your stopping criterion, e.g., based on degrees or other conditions
function stopping_criterion(v_k, max_iterations, max_time)
    #The stopping criterium stops when looking at these two conditions
    # Check if v^k is all zeros
    all_zeros = all(x -> x == 0, v_k)

    #If the number of iterations max_iterations is zero OR if  the maximum time max_time is zero. 
    return all_zeros || max_iterations <= 0 || max_time <= 0
end


function held_karp(graph::Graph{Node{T}, Z}, root::Node{T}, max_iterations::Int, max_time::Float64, dict_pi::Dict{Node{T}, Float64}) where {T, Z}
    n = size(graph, 1)
    k = 0
    pi = zeros(Int, n)
    W = -Inf

    starting_time = time()

    while true
        # Step 2: Find a min 1-tree T-{pi}^k
        tree_structure, components = min_one_tree(graph, root)

        # Step 3: Compute w(pi^k)
        w_pk = compute_weight(graph, tree_structure, pi)

        # Step 4: Update W
        W = max(W, w_pk)

        # Step 5: Let v^k=d^k-2
        node_degrees = update_degrees(graph, components, root, dict_pi)
        v_k = node_degrees .- 2

        # Step 6: Stopping criterion
        elapsed_time = time() - starting_time
        if stopping_criterion(v_k)
            break
        end

        # Step 7: Choose a step size, t^k
        t_k = 0.1  # Adjust the step size based on your needs

        # Step 8: Update pi
        pi = pi + t_k * v_k

        # Step 9: Increment k and repeat
        k += 1
    end

    return W
end


# Example usage:
# Replace `graph` with your specific graph representation
graph = [
    0 10 15 20;
    10 0 35 25;
    15 35 0 30;
    20 25 30 0
]

max_iterations = 1000  # replace with your desired value
max_time = 60.0  # replace with your desired value in seconds

result = held_karp(graph, root, max_iterations, max_time)
println("Optimal tour cost: ", result)