include("node.jl")
include("graph.jl")
include("composante_connexe.jl")
include("prim.jl")
include("arbre_de_recouvrement.jl")
include("edge_oriented.jl")

include("edge.jl")
"
HK algorithm
1. Let k=0, pi^0=0 and W=-inf. 
2. Find a min 1-tree T-{pi}^k. 
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
    temp_graph = Graph("", nodes_base, edges_base)
    component = kruskal(temp_graph)
    println("edges kruskal  ",length(component.edges))
    #length(component.nodes) != 1 && error("kruskal has more than 1 component")

    #kruskal only gives the composante_connexe back and we also want a tree to be given back
    edges_tree = convert(Vector{Edge{Z, Node{T}}},edges(component))

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
    edge_sorted = sort(to_remove, by=poids)
    
    # Add the root and 2 cheapest arcs from the root to a leaf
    # Keep the component components updated
    # We are keeping the degree dictionary updated
    add_node!(tree_structure, root)
    for i in 1:2
        e = pop!(edge_sorted)    
        add_edge!(tree_structure, e)
        # If any of the 2 extremities is root, its degree won't be updated because it won't be part of the dictionary yet
        node_degrees[debut(e)] += 1
        node_degrees[fin(e)] += 1
    end
    node_degrees[root] = 2
    #println(tree_structure)
    return tree_structure, component
end



function compute_weight(graph::Graph{T, Z}, tour::Graph{T, Z}, pi::Vector{Float64}) where {T, Z}
    # Initialize total weight
    total_weight = 0.0

    # Define a function to get the index of a node in the graph
    node_index(graph, node) = findfirst(x -> x == node, nodes(graph))

    # Iterate over edges in the tour
    for edge in edges(tour)

        # Update total weight with edge weight and Lagrangian multipliers (pi)
        total_weight += poids(edge) + pi[node_index(graph, node1(edge))] + pi[node_index(graph, node2(edge))]
    end

    # Compute the weight of the tour using the 1-tree and pi vector

    return total_weight
end




function update_degrees(graph::Graph{Node{T}, Z}, component, root::Node{T}, pi::Vector{Float64}) where {T, Z}
    # Initialize degrees for all nodes
    node_degrees = zeros(Int64, nb_nodes(graph))

    # Define a function to get the index of a node in the graph
    node_index(graph, node) = findfirst(x -> x == node, nodes(graph))

    # Update degrees based on the 1-tree
    for edge in edges(component)
        # Increment degrees of the nodes in the 1-tree
        node_degrees[node_index(graph, node1(edge))] += 1
        node_degrees[node_index(graph, node2(edge))] += 1
    end

    # If the root is not present in the 1-tree, add it with a degree of 2
    node_degrees[node_index(graph, root)] += 2

    # Update degrees based on the Lagrangian multipliers (pi)
    node_degrees .+= round.(Int, pi)

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



function transform_matrix(graph::Graph{T, Z}, pi::Vector) where {T, Z}
    # when d_{ij}= c_{ij}+ pi_i+ pi_j
    transformed_graph = deepcopy(graph)

    # Define a function to get the index of a node in the graph
    node_index(graph, node) = findfirst(x -> x == node, nodes(graph))

    # Loop over alle randen in de grafiek
    for edge in edges(transformed_graph)
        
        # Calculate the new weights using the  Lagrangian multiplicators
        new_weight = poids(edge) + pi[node_index(graph, node1(edge))] + pi[node_index(graph, node2(edge))]

        # adjust the weights of the edges
        #set_weight!(transformed_graph, edge, new_weight)
        set_weight!(edge, new_weight)
    end

    return transformed_graph
end

function held_karp(graph::Graph{Node{T}, Z}, root::Node{T}, max_iterations::Int, max_time::Float64) where {T, Z}
    #n = size(graph, 1)
    n = length(nodes(graph))
    k = 0
    W = -Inf
    pi= zeros(Float64,n)

    starting_time = time()

    t_k=1
    while true
        # Step 2: Find a min 1-tree T-{pi}^k
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
        if stopping_criterion(v_k, max_iterations, elapsed_time)
            break
        end


        # Step 8: Update pi
        pi= pi + t_k * v_k
        # Stap 9: Transform the weight of the edges based on the new lagrangian multiplicator
        transformed_graph = transform_matrix(graph, pi)

        # Incrementeer k and repeat
        k += 1
        # Step 7: Choose a step size, t^k
        t_k = 1/k  # Adjust the step size based on your needs
        #println("2")
        max_iterations -= 1
    end

    return W
end

# Example usage:
# Replace `graph` with your specific graph representation
"
graph = [
    0 10 15 20;
    10 0 35 25;
    15 35 0 30;
    20 25 30 0
]

max_iterations = 100  
max_time = 60.0  
result = held_karp(graph, root, max_iterations, max_time)
println('Optimal tour cost: ', result)
"