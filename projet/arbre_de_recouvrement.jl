include("graph.jl")
include("composante_connexe.jl")

function kruskal(graph::Graph{T, Z}) where {T, Z}
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
            edge = convert(EdgeOriented{Z,T}, edge)
            #print("#\n")
            #print(edge, length(add_edge_to))
            # create new one and add it to the list of existing components
            if length(add_edge_to) == 0
                new_component = ComposanteConnexe(debut(edge), [debut(edge), fin(edge)], [edge])
                push!(connected_components, new_component)
            # add the edge and the node that connects it to the connected component
            elseif length(add_edge_to) == 1
                if node1(edge) in nodes(add_edge_to[1])
                    add_node_and_edge!(add_edge_to[1], fin(edge), edge)
                else
                    add_node_and_edge!(add_edge_to[1], debut(edge), edge)
                end
            # I have to connect all components and the new edge from add_edge_to into one,
            # delete the old unconnected components               
            else
                push!(connected_components, connect_into_one(add_edge_to, edge))
                for component in add_edge_to
                    component_idx = findfirst(==(component), connected_components)
                    deleteat!(connected_components, component_idx)
                end
            end
            num_added_edges = num_added_edges + 1
        end
        if num_added_edges >= length(graph.nodes)
            break
        end
    end
    if length(connected_components) > 1
        println("error, too many connected components left")
    end
    connected_components[1]
end


