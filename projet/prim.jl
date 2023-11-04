
include("graph.jl")


"
Elke knoop heeft een attribuut min_weight dat het gewicht van de minimale gewichtsrand voorstelt die deze knoop verbindt met de deelboom. Aanvankelijk is min_weight ingesteld op oneindig (d.w.z. +1).
Aanvankelijk is de ouder van elke knoop niets (nothing).
Het algoritme begint bij een door de gebruiker gekozen startknoop s, en het attribuut min_weight van s is ingesteld op 0.
Een prioriteitswachtrij bevat alle knopen die nog niet aan de boom zijn toegevoegd, en min_weight bepaalt de prioriteit.
Telkens wanneer een knoop aan de boom wordt verbonden, moeten de attributen min_weight en parent van de knopen die nog niet zijn verbonden, worden bijgewerkt.

function prim_alg(graph::Graph{T, Z},startpoint::Node{T}) where {T, Z}
    sorted_edges = sort(graph.edges)
    nodes_gr=nodes(graph::AbstractGraph)
    connected_components = Vector{ComposanteConnexe{T, Z}}()
    num_added_edges = 0
    should_add = true
    for node in nodes_gr
        node.min_weight = Inf  # Stel min_weight in op oneindig
        node.parent = nothing  # Stel parent in op niets (nothing)
    end
end 
"




function prim_alg(graph::Graph{T, Z}, startpoint::Node{T}) where {T, Z}
    sorted_edges = sort(graph.edges)
    nodes_gr = nodes(graph)
    connected_components = Vector{ComposanteConnexe{T, Z}}()
    num_added_edges = 0
    should_add = true

 # un attribut min_weight -> Initialement, min_weight = Inf ; Initialement, le parent de chaque noeud est nothing
    for node in nodes_gr
        node.min_weight = Inf
        node.parent = nothing
    end

#débute en un noeud source s(startpoint) choisi par l’utilisateur et l’attribut min_weight de s est 0 ;
    startpoint.min_weight = 0


#une file de priorité contient tous les noeuds qui n’ont pas encore été ajoutés à l’arbre et min_weight donne la priorité
#chaque fois qu’un noeud est connecté à l’arbre, les attributs min_weight et parent de ceux qui n’ont pas encore été connectés doivent être mis à jour.
    pq = PriorityQueue{Node{T}}()
    for node in nodes_gr
        push!(pq, node)
    end
#haal startpunt weg en zet in lijst
    push!(connected_components, startpoint)
    if 
 


end