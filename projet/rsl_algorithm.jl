include("node.jl")
using Test
include("arbre_de_recouvrement.jl")
include("composante_connexe.jl")
include("tree.jl")
include("graph.jl")
include("read_graph.jl")
include("prim.jl")

"""
Pré ordre: examiner le noeud courant, parcourir le sous-arbre de gauche, parcourir le sous-arbre de droite
"""
function preordre_nodes!(root::Tree{T}, tour_nodes::Vector{Node{T}}) where T
    isnothing(root) && return 
    push!(tour_nodes, get_node(root))
    print(get_node(root), "\n")
    for t in children(root)
        preordre_nodes!(t, tour_nodes)
    end
    tour_nodes
end

"""
Pré ordre: examiner le noeud courant, parcourir le sous-arbre de gauche, parcourir le sous-arbre de droite
"""
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

"""
Returns the edges connecting nodes ordered by a preordre traversal of a given graph.
"""
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


"""
Returns true if the triangle inequality : c(u,w) <= c(u,v) + c(v,w)
is valid for the graph, false if it is not.
"""
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

"""
Returns a cycle withing the given graph using Rosenkrantz, Stearns and Lewis algorithm.
"""
function lewis(graph::Graph{Node{T}, Z}, start_point::Node{T}) where {T, Z}
    # make sure the triangle inequality holds
    if !has_triang_inequality(graph)
        return false
    end

    minimum_spanning_tree = kruskal(graph)
    
    my_nodes = preordre_graph!(minimum_spanning_tree, start_point, start_point, [start_point])
    
    tour_edges = []
    tour_edges = get_edges(graph, my_nodes)
    return tour_edges
end

