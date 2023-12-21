import Pkg
Pkg.add("Plots")
include("node.jl")
include("edge.jl")
include("graph.jl")
include("read_stsp.jl")

"""Renvoie le graphe récupéré du fichier qui s'appele fn."""
function get_graph_from_file(fn::String)
    graph_nodes, graph_edges, edges_brut, weights = read_stsp(fn)
    
    # Constructing my_nodes of type Node from the given file 
    if length(graph_nodes[collect(keys(graph_nodes))[1]]) == 0
        my_nodes = Vector{Node{Int64}}()
    else
        my_nodes = Vector{Node{Float64}}()
    end

    for name in keys(graph_nodes)
        #println(typeof(almost_node[2]))
        if length(graph_nodes[name]) == 0
            new_node = Node(string(name), name)
        else
            new_node = Node(string(graph_nodes[name][1]), graph_nodes[name][2])
        end
        push!(my_nodes, new_node)           
    end
    #print(my_edges[5])

    # getting all keys of graph nodes, so that we can link nodes according to index
    node_keys = collect(keys(graph_nodes))#convert(Array{Int64}, keys(graph_nodes))

    # Constructing my_edges of type Edge from the given file 
    my_edges = Vector{Edge{Float64, typeof(my_nodes[1])}}()
    #has_deleted_first_one = false
    # Creates a vector of all graphs edges except the edges adjacent to the root
    #edges_base = filter(x -> !(x in to_remove), edges(graph))
    for almost_edge in edges_brut
        #if !has_deleted_first_one
        #    has_deleted_first_one = true
        #    print(almost_edge, "\n almost edge")
        #    break
        #end
        idx_first_node = findfirst(isequal(almost_edge[1]), node_keys)
        idx_second_node = findfirst(isequal(almost_edge[2]), node_keys)
        if(isnothing(idx_first_node))
            println(almost_edge[1])
        end
        if(isnothing(idx_second_node))
            println(almost_edge[2])
        end
        new_edge = Edge(my_nodes[idx_first_node], my_nodes[idx_second_node], almost_edge[3])
        push!(my_edges, new_edge)           
    end
    
    my_graph = Graph(fn, my_nodes, my_edges)
    return my_graph
end

# Make sure you are in the mth6412b-starter-code directory
# by using `pwd()` and `cd ..` commands before executing next line.
# You can also change the file you are reading data from.

#fn = pwd() * "\\instances\\stsp\\bayg29.tsp"
#fn = pwd() * "\\shredder\\shredder-julia\\tsp\\instances\\alaska-railroad.tsp"
#g = get_graph_from_file(fn)
#println(g)




