include("graph.jl")
"
1Modifier la structure de données d'ensembles disjoints pour implémenter l'union
via le rang ;
2. montrer que le rang d'un noeud sera toujours inférieur à jSj 􀀀 1. Montrer ensuite
que ce rang sera en fait toujours inférieur à blog2(jSj)c ;
3. modifier la procédure de remontée vers la racine pour implémenter la compression
des chemins.
"

mutable struct DisjointSet{T}
    parent::T
    rank::Int
end

#all the nodes will have to be collected in another way than composante connexe. So a new type is introduced.
mutable struct TreeNode{T}
    node::T
    children::Vector{TreeNode{T}}
end

# Create a disjoint-set for each node in the graph.
function create_disjoint_sets_with_trees(graph::Graph{T, Z}) where {T, Z}
    #disjoint_sets = [DisjointSet(node, 0) for node in graph.nodes]
    disjoint_sets= [DisjointSet(node, 0) for node in graph.nodes]
    tree_nodes = [TreeNode(node, []) for node in graph.nodes]
    return disjoint_sets, tree_nodes
end


function find_roots(disjoint_sets::Vector{DisjointSet{T}}, node::T) where T
    while disjoint_sets[node].parent != node
        node = disjoint_sets[node].parent
    end
    return node
end

function find_roots_compression(disjoint_sets::Vector{DisjointSet{T}}, node::T) where T
    if disjoint_sets[node].parent != node
        disjoint_sets[node].parent = find_roots(disjoint_sets, disjoint_sets[node].parent)
    end
    return disjoint_sets[node].parent
end

#Union-by-Rank method
function heuristique_union(graph::Graph{T, Z}) where {T, Z}
    all_edges = edges(graph)  # get all edges
    disjoint_sets, tree_nodes = create_disjoint_sets_with_trees(graph)

    for edge in all_edges
        node1 = edge.node1
        node2 = edge.node2
        root_1 = find_roots(disjoint_sets, node1)
        root_2 = find_roots(disjoint_sets, node2)

        if root_1!=root_2 #if they both have the same parent they can't be connected because you would have a cycle
            if disjoints[root_1].rank < disjoints[root_2].rank
                disjoints[root_1].parent = root_2
                #rank goes up when they become the parent of someone new
                disjoints[root_2].rank += 1
            elseif disjoints[root_1].rank > disjoints[root_2].rank
                disjoints[root_2].parent = root_1
                disjoints[root_1].rank += 1
            else
                #if they have the same rank we can choose the parent
                disjoints[root_2].parent = root_1
                disjoints[root_1].rank += 1
            end
            push!(tree_edges, edge) 
        end
    end
    for edge in tree_edges
        println("Edge from node ", edge.node1, " to node ", edge.node2)
    end
end


# Using path compression
function heuristique_compression(graph::Graph{T, Z}) where {T, Z}
    all_edges = edges(graph)  # get all edges
    disjoint_sets, tree_nodes = create_disjoint_sets_with_trees(graph)

    for edge in all_edges
        node1 = edge.node1
        node2 = edge.node2
        root_1 = find_roots_compression(disjoints, node1)
        root_2 = find_roots_compression(disjoints, node2)

        if root_1 != root_2
            if disjoints[root_1].rank < disjoints[root_2].rank
                disjoints[root_1].parent = root_2
                disjoints[root_2].rank += 1
            elseif disjoints[root_1].rank > disjoints[root_2].rank
                disjoints[root_2].parent = root_1
                disjoints[root_1].rank += 1
            else
                disjoints[root_2].parent = root_1
                disjoints[root_1].rank += 1
            end
            push!(tree_edges, edge)
        end
    end

    for edge in tree_edges
        println("Edge from node ", edge.node1, " to node ", edge.node2)
    end
end

