include("read_graph.jl")
include("rsl_algorithm.jl")
using Dates

"""Function get_difference gets argument input_name, which specifies the name of picture for which we 
want to calculate the difference of shades that are close to each other"""
function get_difference(input_name::String)
    picture = load(input_name)
    nb_row, nb_col = size(picture)
    w = zeros(nb_col, nb_col)
    for j1 = 1 : nb_col
        for j2 = j1 + 1 : nb_col
            w[j1, j2] = compareColumn(picture[:, j1], picture[:, j2])
        end
    end
    return w
end

"""Function sum_weight_of_edges gets a vector of edges and returns the sum of weights of all the edges"""
function sum_weight_of_edges(my_edges::Vector{Edge{Z, T}}) where {Z, T}
    sum = 0
    last_n1 = node1(my_edges[1])
    last_n2 = node2(my_edges[1])

    # Testing that we really do get a cycle and creating the sum of weights at the same time
    for e in my_edges
        sum = sum + poids(e)
        last_n1 = node1(e)
        last_n2 = node2(e)
    end
end

"""Function get_cycle gets argument input_name, which specifies the name of picture for which we 
want to create the cycle. It creates a file input_name.tour containing information about the cycle and returns
information about the difference of the cycle."""
function get_cycle(input_name::String)
    g_create = get_graph_from_file(input_name)
    (cycle, my_edges, elapsed_time, elapsed_time_no_test) = lewis(g_create, nodes(g_create)[1], true)
    tour_weight = sum_weight_of_edges(my_edges)
    write_tour(input_name, tour_weight, cycle)

    #cycle_difference = get_difference("$(input_name).tour")

    #return cycle_difference
end


"""Function write_tour creates a file .tour that describes the minimal weight cycle we found"""
function write_tour(filename::String, tour_weight::Number, nodes::Vector{Node{T}}) where T
    # writing out all variables that will be used in 
    time_now = Dates.format(Dates.now(), "e u d  H:MM:SS Y")
    tour_length = length(nodes)

    nodes_str = ""
    for node in nodes
        nodes_str = nodes_str * name(node) * "\n"
    end
    nodes_str = chop(nodes_str)
    file = "$(filename).tour"

    inside_string = "NAME : $(filename).tour\n\
    COMMENT : Length = $(tour_weight)\n\
    COMMENT : Found by LKH [Keld Helsgaun], $(time_now)\n\
    TYPE : TOUR\n\
    DIMENSION : $(tour_length)\n\
    TOUR_SECTION\n\
    $(nodes_str)\n\
    EOF\n"

    # creating file named : filename.tour and writing the inside of inside_string to it
    write(file, inside_string)
end

"""
Reconstructs an image based on a tour file and an input picture.
returns a reconstructed picture based on the tour information.
"""
function reconstruct_picture(tour_filename::String, input_picture::AbstractArray)
    # Read the tour data from the specified file
    tour_data = read_tour(tour_filename)
    # Extract the tour nodes from the tour data
    tour_nodes = tour_data["TOUR_SECTION"]
    # Get the number of columns in the input picture
    nb_col = size(input_picture, 2)

    # Initialize the reconstructed picture with zeros
    reconstructed_picture = zeros(size(input_picture))

    # Iterate through the tour nodes to reconstruct the image
    for i in 1:length(tour_nodes)-1
        # Get the indices of the current and next nodes
        node1_idx = parse(Int, tour_nodes[i])
        node2_idx = parse(Int, tour_nodes[i+1])

        # Reconstructing the image based on the tour
        # Copy the column from the next node to the current node in the reconstructed picture
        reconstructed_picture[:, node1_idx] = input_picture[:, node2_idx]
    end

    # Complete the cycle by connecting the last and first nodes
    last_node_idx = parse(Int, tour_nodes[end])
    first_node_idx = parse(Int, tour_nodes[1])
    # Copy the column from the first node to the last node in the reconstructed picture
    reconstructed_picture[:, last_node_idx] = input_picture[:, first_node_idx]

    return reconstructed_picture
end


"""
Reads the tour nodes from a .tour file and returns them as an array of Node objects.
It returns an array of Node objects representing the tour nodes.
"""
function read_tour(tour_filename::String, graph::Graph{T, Z}) where {T, Z}
    # Initialize an array to store tour nodes
    tour_nodes = Vector{Node{T}}()

    # Open the .tour file for reading
    file = open(tour_filename, "r")

    # Skip header information until TOUR_SECTION is reached
    while true
        line = readline(file)
        if occursin(r"^TOUR_SECTION", line)
            break
        end
    end

    # Read the nodes in the tour until EOF is reached
    while true
        line = readline(file)
        if occursin(r"^EOF", line)
            break
        end
        # Parse the node index from the line and find the corresponding Node index in the graph
        node_index = findfirst(x -> x == parse(Int, line), nodes(graph))
        if isnothing(node_index)
            error("Node not found in the graph.")
        end
        # Retrieve the corresponding Node from the graph
        push!(tour_nodes, nodes(graph)[node_index])
    end

    # Close the file
    close(file)

    return tour_nodes
end



using Plots

function generate_picture(original_picture::AbstractArray, reconstructed_picture::AbstractArray)
    plot(
        heatmap(original_picture, color=:grays, title="Original Picture"),
        heatmap(reconstructed_picture, color=:grays, title="Reconstructed Picture"),
        layout=(1,2),
        size=(800, 400)
    )
end


fn = pwd() * "\\shredder\\shredder-julia\\tsp\\instances\\alaska-railroad.tsp"


noeud1 = Node("a", "a")
noeud2 = Node("b", "b")
noeud3 = Node("c", "c")
noeud4 = Node("d", "d")
noeud5 = Node("e", "e")
noeud6 = Node("f", "f")
noeud7 = Node("g", "g")
noeud8 = Node("h", "h")
noeud9 = Node("i", "i")
lab_nodes = [noeud1, noeud2, noeud3, noeud4, noeud5, noeud6, noeud7, noeud8, noeud9]

#write_tour("hahahh", 5, lab_nodes)
get_cycle(fn)