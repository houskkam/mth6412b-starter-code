
include("graph.jl")
include("composante_connexe.jl")

"
Elke knoop heeft een attribuut min_weight dat het gewicht van de minimale gewichtsrand voorstelt die deze knoop verbindt met de deelboom.
 Aanvankelijk is min_weight ingesteld op oneindig (d.w.z. +1).
Aanvankelijk is de ouder van elke knoop niets (nothing).
Het algoritme begint bij een door de gebruiker gekozen startknoop s, en het attribuut min_weight van s is ingesteld op 0.
Een prioriteitswachtrij bevat alle knopen die nog niet aan de boom zijn toegevoegd, en min_weight bepaalt de prioriteit.
Telkens wanneer een knoop aan de boom wordt verbonden, moeten de attributen min_weight en parent van de knopen die nog niet zijn verbonden,
 worden bijgewerkt.

"




function prim_alg(graph::Graph{Node{T}, Z}, startpoint::Node{T}) where {T, Z}
    nodes_gr = nodes(graph)
    minimum_spanning_tree = ComposanteConnexe{Node{T}, Z}(startpoint, [startpoint], Vector{EdgeOriented{T, Z}}())

    # un attribut min_weight -> Initialement, min_weight = -1 ; Initialement, le parent de chaque noeud est nothing
    for node in nodes_gr
        node.min_weight = Inf
        node.parent = nothing
    end

    #débute en un noeud source s(startpoint) choisi par l’utilisateur et l’attribut min_weight de s est 0 ;
    startpoint.min_weight = 0

    # Initialisation de l'ensemble inTree pour suivre les nœuds inclus dans l'arbre de couverture minimale
    inTree =  Set{Node{T}}([startpoint])

    #une file de priorité contient tous les noeuds qui n’ont pas encore été ajoutés à l’arbre et min_weight donne la priorité
    #chaque fois qu’un noeud est connecté à l’arbre, les attributs min_weight et parent de ceux qui n’ont pas encore été connectés doivent être mis à jour.
    pq = PriorityQueue{Int,Node{T}}()
    enqueue!(pq,startpoint.min_weight,startpoint)

    while !isempty(pq)
        # Le premier nœud dans la paire est le nœud ayant le poids minimal
        w = dequeue!(pq)

        # Si le nœud est déjà inclus dans l'arbre, passez au suivant
        if  w in inTree
            continue
        end
        

        inTree = union(inTree, Set{Node{T}}([w]))  # Marquez le nœud comme inclus dans l'arbre

        # Iterate through all adjacent nodes of w
        for edge in get_edges_for_node(graph, w)
            u= ifelse(debut(edge) == w, fin(edge), debut(edge))  # Trouver l'autre nœud connecté par l'arête
            weight= poids(edge)

            # If v is not in min. spanning tree and the weight of (u, v) is smaller than the current key of v
            if u ∉ inTree && weight < u.min_weight
                u.min_weight = weight
                u.parent = w

                enqueue!(pq, u.minweight, u)

                #add edge to minimum spanning tree
                add_node_and_edge!(minimum_spanning_tree, u, edge)
            end
        end
    end

    return minimum_spanning_tree

end