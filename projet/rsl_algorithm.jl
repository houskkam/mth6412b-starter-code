include("node.jl")
using Test
include("prim.jl")
include("composante_connexe.jl")
include("tree.jl")
include("graph.jl")

"""
Pré ordre: examiner le noeud courant, parcourir le sous-arbre de gauche, parcourir le sous-arbre de droite
"""
function preordre_nodes!(root::Tree{T}, tour_nodes::Vector{Node{T}}) where T
    isnothing(root) && return 
    push!(tour_nodes, get_node(root))
    for t in children(root)
        preordre_nodes!(t, tour_nodes)
    end
    tour_nodes
end

"""
Returns the edges connecting nodes ordered by a preordre traversal of a given graph.
"""
function preorder_not_recursive!(tree::Tree{T}, g::Graph{Node{T}, Z}) where {T, Z}
    tour_nodes = Vector{Node{T}}() #empty vector with all the nodes
    tour_nodes = preordre_nodes!(tree, tour_nodes)
    tour_edges = Vector{AbstractEdge{Z, Node{T}}}()

    for i in 1:(length(tour_nodes) - 1)
        e = get_edge(g, tour_nodes[i], tour_nodes[i+1])
        if !(isnothing(e))
            push!(tour_edges, e)
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
                if poids(e) > poids(get_edge(g, n1, n3))+poids(get_edge(g, n2, n3))
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
    minimum_spanning_tree = prim_alg(graph, start_point)

    tree_structure = Tree(start_point,  Vector{Tree{T}}(), missing)
    aleady_added = Vector{Node{T}}()
    push!(aleady_added, start_point)
    create_child!(minimum_spanning_tree, tree_structure, aleady_added)

    tour_edges = preorder_not_recursive!(tree_structure, graph)

    cycle_weight = sum(poids.(tour_edges))
    println("Weight of the cycle: $(cycle_weight)")
    return tour_edges#Graph{T}("RSL_Cycle of $(name(graph))", nodes(graph), tour_edges)
end


# Initializing nodes from example from laboratories
noeud1 = Node("a", "a")
noeud2 = Node("b", "b")
noeud3 = Node("c", "c")
noeud4 = Node("d", "d")
noeud5 = Node("e", "e")
noeud6 = Node("f", "f")
noeud7 = Node("g", "g")
noeud8 = Node("h", "h")
noeud9 = Node("i", "i")

# Initializing edges from example from laboratories
edge1 = Edge(noeud1, noeud2, 4.0)
edge2 = Edge(noeud1, noeud8, 8.0)
edge3 = Edge(noeud2, noeud8, 11.0)
edge4 = Edge(noeud2, noeud3, 8.0)
edge5 = Edge(noeud8, noeud9, 7.0)
edge6 = Edge(noeud8, noeud7, 1.0)
edge7 = Edge(noeud7, noeud9, 6.0)
edge8 = Edge(noeud9, noeud3, 2.0)
edge9 = Edge(noeud7, noeud6, 2.0)
edge10 = Edge(noeud3, noeud4, 7.0)
edge11 = Edge(noeud3, noeud6, 4.0)
edge12 = Edge(noeud4, noeud6, 14.0)
edge13 = Edge(noeud4, noeud5, 9.0)
edge14 = Edge(noeud6, noeud5, 10.0)

# Initializing graph from example from laboratories
lab_nodes = [noeud1, noeud2, noeud3, noeud4, noeud5, noeud6, noeud7, noeud8, noeud9]
lab_edges = [edge1, edge2, edge3, edge4, edge5, edge6, edge7, edge8, edge9, edge10, edge11, edge12, edge13, edge14]
G = Graph("Lab", lab_nodes, lab_edges)

start_point = nodes(G)[1]
typeof(start_point)
lewis(G, start_point)

