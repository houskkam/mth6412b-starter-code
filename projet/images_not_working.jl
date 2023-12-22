include("read_graph.jl")
include("rsl_algorithm.jl")
include(".\\shredder\\shredder-julia\\bin\\tools.jl")
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
function sum_weight_of_edges(my_edges::Vector{AbstractEdge{Z, T}}) where {Z, T}
    sum = 0
    last_n1 = node1(my_edges[1])
    last_n2 = node2(my_edges[1])

    # Testing that we really do get a cycle and creating the sum of weights at the same time
    for e in my_edges
        sum = sum + poids(e)
        last_n1 = node1(e)
        last_n2 = node2(e)
    end
    return sum
end

"""Function get_cycle gets argument input_name, which specifies the name of picture for which we 
want to create the cycle. It creates a file input_name.tour containing information about the cycle and returns
information about the difference of the cycle."""
function get_cycle(input_name::String)
    #print("in function")
    g_create = get_graph_from_file(input_name)
    print(length(g_create.nodes))

    # Filtering out the node 0 that has 0 lenght edges with all other nodes

    node_to_be_deleted = g_create.nodes[1]
    # Creates a vector of all graph's node except the root
    g_create.nodes = filter(x -> x != node_to_be_deleted, g_create.nodes)

    # Creates a vector of all graphs edges except the edges adjacent to the root
    to_remove = get_oriented_edges(g_create, node_to_be_deleted)
    g_create.edges = filter(x -> !(x in to_remove), g_create.edges)

    #fitlered = filter(x -> x != g_create.nodes[1], g_create.nodes)
    #nodes(g_create) = fitlered
    #print("graph done")
    (cycle, my_edges, elapsed_time, elapsed_time_no_test) = lewis(g_create, nodes(g_create)[1], true)
    #print("cycle done")
    tour_weight = sum_weight_of_edges(my_edges)
    #print("writing cycle now", tour_weight)
    #tour_filename = write_tour(input_name, tour_weight, cycle)
    #cycle_difference = get_difference("$(input_name).tour")
    cycle_numbers_array = Vector{Int64}()
    for node in cycle
        push!(cycle_numbers_array, data(node))
    end
    print("\n", length(g_create.nodes), length(cycle))
    return cycle_numbers_array, tour_weight
end


"""Function write_tour creates a file .tour that describes the minimal weight cycle we found"""
function our_write_tour(filename::String, tour_weight::Number, nodes::Vector{Node{T}}) where T
    # writing out all variables that will be used in 
    time_now = Dates.format(Dates.now(), "e u d  H:MM:SS Y")
    tour_length = length(nodes)

    nodes_str = ""
    for node in nodes
        nodes_str = nodes_str * name(node) * "\n"
    end
    nodes_str = chop(nodes_str)
    file = "$(filename)-our_tour.tour"

    inside_string = "NAME : $(filename)-our_tour.tour\n\
    COMMENT : Length = $(tour_weight)\n\
    COMMENT : Found by LKH [Keld Helsgaun], $(time_now)\n\
    TYPE : TOUR\n\
    DIMENSION : $(tour_length)\n\
    TOUR_SECTION\n\
    $(nodes_str)\n\
    EOF\n"

    # creating file named : filename.tour and writing the inside of inside_string to it
    write(file, inside_string)
    return file
end

"""
Reconstructs an image based on a tour file and an input picture.
returns a reconstructed picture based on the tour information.
"""
function our_reconstruct_picture(filename::String, input_picture::AbstractArray)
    # Create .tour file and get cycle nodes
    tour_filename, cycle_nodes = get_cycle(filename)
    
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
function our_read_tour(tour_filename::String, graph::Graph{T, Z}) where {T, Z}
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


fn_tsp = pwd() * "\\projet\\shredder\\shredder-julia\\tsp\\instances\\alaska-railroad.tsp"
old_fn_tsp = pwd() * "\\projet\\shredder\\shredder-julia\\tsp\\instances\\alaska-railroad.tsp"

fn = pwd() * "\\projet\\shredder\\shredder-julia\\images\\original\\alaska-railroad.png"
fn_out = pwd() * "\\projet\\output\\alaska-railroad.png"
fn_out_reconstructed = pwd() * "\\projet\\output\\alaska-railroad-reconstructed.png"



#write_tour("hahahh", 5, lab_nodes)
#cycle_numbers_array, tour_weight = get_cycle(old_fn_tsp)
write_tour(fn, cycle_numbers_array, convert(Float32, tour_weight))
#shuffle_picture(fn, fn_out)
reconstruct_picture(fn_tsp, fn, fn_out_reconstructed)

files_path = pwd() * "\\shredder\\shredder-julia\\tsp\\instances\\"

files = ["abstract-light-painting.tsp", "alaska-railroad.tsp", "blue-hour-paris.tsp", "lower-kananaskis-lake.tsp", "marlet2-radio-board.tsp", "nikos-cat.tsp", "pizza-food-wallpaper.tsp", "the-enchanted-garden.tsp", "tokyo-skytree-aerial.tsp"]
for file in files
    name_of_file_now = files_path * file
    _, _, tour_weight = get_cycle(name_of_file_now)
    println("The cycle we found for ", file, " has length equal to ", tour_weight)
end



fn_tsp = pwd() * "\\projet\\shredder\\shredder-julia\\tsp\\instances\\alaska-railroad.tsp"
old_fn_tsp = pwd() * "\\projet\\shredder\\shredder-julia\\tsp\\instances\\alaska-railroad.tsp"
fn_out_reconstructed = pwd() * "\\projet\\output\\alaska-railroad-reconstructed.png"

reconstruct_picture(fn_tsp, old_fn_tsp, fn_out_reconstructed)
