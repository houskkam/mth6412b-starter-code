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