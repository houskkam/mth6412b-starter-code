include("graph.jl")

function kruskal(graph::Graph{T, Z})
    sorted_edges = sort(graph.edges)
    connected_components = Vector{ComposanteConnexe{T, Z}}()
    num_added_edges = 0
    should_add = true
    for edge in sorted_edges
        should_add = true
        add_edge_to = Vector{ComposanteConnexe{T, Z}}()
        for component in connected_components
            # if both nodes already exist in the came cnnected component, 
            # there is already a way between them, so we will not add this edge
            if (node1(edge) in nodes(component)) && (node2(edge) in nodes(component))
                should_add = false
                break
            # if one of the nodes is already in one of the composed components, we note the component        
            elseif (node1(edge) in nodes(component)) || (node2(edge) in nodes(component))
                push!(add_edge_to, component)
            end
        end
        if should_add
            if length(add_edge_to) == 0
                # create new one
            elseif length(add_edge_to) == 1
                # add it
            else 
                #I have to connect some components into one
            end
            num_added_edges = num_added_edges + 1
        end
        if num_added_edges >= length(graph.nodes)
            break
        end
    end
end


