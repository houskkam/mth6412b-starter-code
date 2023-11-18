include("node.jl")
using Test
include("prim.jl")
include("composante_connexe.jl")

"""
Returns a preordre traversal of a given graph.
"""
#isn't done yet, wrong.
#why did you only put tree inside? 
function preorder!(tree::ComposanteConnexe{T, Z}) where {T, Z}
    #Pré ordre: examiner le noeud courant, parcourir le sous-arbre de gauche, parcourir le sous-arbre de droite ;
    tour_nodes= Vector{Node{T}}() #empty vector with all the nodes
    root= tree.root #gives the root of the tree 
    while !isempty(tour_nodes) 
        current=pop!(tour_nodes)
        add_node_and_edge!(tree,nodes(current),edges(current))
        for t in nodes(root) #looks for the children in ordre
            if t != root # in nodes of tree is also the root, this can't be chosen again.
                push!(tour_nodes,t)
        end
    tree
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
function lewis(graph::Graph{T, Z}) where {T, Z}

    if !has_triang_inequality
        return false
    end
    start_point = nodes(graph)[1]
    minimum_spanning_tree = prim_alg(graph, start_point)

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

lewis(G)

