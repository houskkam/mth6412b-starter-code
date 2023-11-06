
include("graph.jl")
include("composante_connexe.jl")

function prim_alg(graph::Graph{Node{T}, Z}, startpoint::Node{T}) where {T, Z}
    nodes_gr = nodes(graph)
    minimum_spanning_tree = ComposanteConnexe{Node{T}, Z}(startpoint, [startpoint], [])

    min_weights= Dict{Node{T}, Float64}()
    parents = Dict{Node{T}, Node{T}}()

    # un attribut min_weight -> Initialement, min_weight = -1 ; Initialement, le parent de chaque noeud est nothing
    for node in nodes_gr
        # Voeg alle knooppunten toe aan de Dicts
        min_weights[node] = Inf
        parents[node] = nothing
    end

    #débute en un noeud source s(startpoint) choisi par l’utilisateur et l’attribut min_weight de s est 0 ;
    #startpoint.min_weight = 0
    min_weights[startpoint] = 0

    # Initialisation de l'ensemble inTree pour suivre les nœuds inclus dans l'arbre de couverture minimale
    inTree =  Set{Node{T}}([startpoint])

    #une file de priorité contient tous les noeuds qui n’ont pas encore été ajoutés à l’arbre et min_weight donne la priorité
    #chaque fois qu’un noeud est connecté à l’arbre, les attributs min_weight et parent de ceux qui n’ont pas encore été connectés doivent être mis à jour.
    pq = PriorityQueue{Int,Node{T}}()
    enqueue!(pq,min_weight[startpoint],startpoint)

    while !isempty(pq)
        # Le premier nœud dans la paire est le nœud ayant le poids minimal
        w = dequeue!(pq)

        # Si le nœud est déjà inclus dans l'arbre, passez au suivant
        if  w in inTree
            continue
        end
        

        inTree = union(inTree, Set{Node{T}}([w]))  # Marquez le nœud comme inclus dans l'arbre

        # Iterate through all adjacent nodes of w
        for edge in get_oriented_edges(graph, w)
            u= ifelse(debut(edge) == w, fin(edge), debut(edge))  # Trouver l'autre nœud connecté par l'arête
            weight= poids(edge)

            # If v is not in min. spanning tree and the weight of (u, v) is smaller than the current key of v
            if u ∉ inTree && weight < u.min_weight
                min_weight[u] = weight
                parent[u] = w

                enqueue!(pq, minweight[u], u)

                #add edge to minimum spanning tree
                add_node_and_edge!(minimum_spanning_tree, u, edge)
            end
        end
    end

    return minimum_spanning_tree

end