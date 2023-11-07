
using DataStructures
include("edge_oriented.jl")
include("edge.jl")
include("graph.jl")
include("composante_connexe.jl")

mutable struct NodeKey{T,Z}
    node::Node{T}
    edge::EdgeOriented{Z,Node{T}}
    it::Int
  end
  
""" This function gets as an argument an instance of Graph 
  and a startpoint of type Node.
  It returns the graph's spanning tree of type ComposanteConnexe 
  while using Prim's algorithm beginning at the node startpoint
"""
function prim_alg(graph::Graph{Node{T}, Z}, startpoint::Node{T}) where {T, Z}
    nodes_gr = nodes(graph)
    minimum_spanning_tree = ComposanteConnexe{Node{T}, Z}(startpoint, [startpoint], [])

    min_weights= Dict{Node{T}, Float64}()
    parents = Dict{Node{T}, Node{T}}()

    # un attribut min_weight -> Initialement, min_weight = -1 ; Initialement, le parent de chaque noeud est nothing
    for node in nodes_gr
        # Voeg alle knooppunten toe aan de Dicts
        min_weights[node] = Inf
    end

    #débute en un noeud source s(startpoint) choisi par l’utilisateur et l’attribut min_weight de s est 0 ;
    #startpoint.min_weight = 0
    min_weights[startpoint] = 0

    # Initialisation de l'ensemble inTree pour suivre les nœuds inclus dans l'arbre de couverture minimale
    inTree =  Set{Node{T}}()

    #une file de priorité contient tous les noeuds qui n’ont pas encore été ajoutés à l’arbre et min_weight donne la priorité
    #chaque fois qu’un noeud est connecté à l’arbre, les attributs min_weight et parent de ceux qui n’ont pas encore été connectés doivent être mis à jour.
    pq = PriorityQueue{NodeKey{T,Z},Int}()
    it=0
    edge_nodekey=EdgeOriented(startpoint, startpoint, 0.0)
    enqueue!(pq,NodeKey(startpoint,edge_nodekey,it),min_weights[startpoint])

    while !isempty(pq)
        it+=1
        # Le premier nœud dans la paire est le nœud ayant le poids minimal
        node_key = dequeue!(pq)
        w, h = node_key.node, node_key.edge
        #w = dequeue!(pq).node
        #println(w)

        # Si le nœud est déjà inclus dans l'arbre, passez au suivant
        if  w in inTree
            continue
        end
        

        push!(inTree,w) # Marquez le nœud comme inclus dans l'arbre
        add_node_and_edge!(minimum_spanning_tree, w, h)


        # Iterate through all adjacent nodes of w
        for edge in get_oriented_edges(graph, w)
            #println(min_weights)
            u= ifelse(debut(edge) == w, fin(edge), debut(edge))  # Trouver l'autre nœud connecté par l'arête
            weight= poids(edge)
            #println(u,weight)


            # If v is not in min. spanning tree and the weight of (u, v) is smaller than the current key of v
            if u ∉ inTree && weight < min_weights[u]
                min_weights[u] = weight
                parents[u] = w

                enqueue!(pq, NodeKey(u,edge,it), min_weights[u])

                #add edge to minimum spanning tree
                #add_node_and_edge!(minimum_spanning_tree, u, edge)
            end
        end
    end
    component_idx = findfirst(==(startpoint), nodes(minimum_spanning_tree))
    deleteat!(nodes(minimum_spanning_tree), component_idx)

    component_idx = findfirst(==(edge_nodekey), edges(minimum_spanning_tree))
    deleteat!(edges(minimum_spanning_tree), component_idx)
    
    return minimum_spanning_tree

end