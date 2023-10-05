include("node.jl")
include("edge.jl")
include("graph.jl")
include("read_stsp.jl")

# Make sure you are in the mth6412b-starter-code directory
# by using `pwd()` and `cd ..` commands before executing next line.
# You can also change the file you are reading data from.
fn = pwd() * "\\instances\\stsp\\bayg29.tsp"

header = read_header(fn)
almost_edges = read_edges(header, fn)
almost_nodes = read_nodes(header, fn)

#println(almost_edges)
#println(Node(string(almost_nodes[2][1]), almost_nodes[2][2]))

# Constructing my_nodes of type Node from the given file 
my_nodes = []
for almost_node in almost_nodes
    #println(typeof(almost_node[2]))
    new_node = Node(string(almost_node[2][1]), almost_node[2][2])
    push!(my_nodes, new_node)           
end
#print(my_edges[5])

# Constructing my_edges of type Edge from the given file 
my_edges = []
for almost_edge in almost_edges
    new_edge = Edge(my_nodes[almost_edge[1]], my_nodes[almost_edge[2]], almost_edge[3])
    #println(poids(new_edge))
    push!(my_edges, new_edge)           
end
#print(my_edges)

# this command is not working right now
G = Graph("Ick", my_nodes, my_edges)


