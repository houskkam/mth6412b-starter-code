### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 75572c3f-0fea-4b7a-aa67-6d97661f5da6
#the repository can be found on the github link: https://github.com/houskkam/mth6412b-starter-code
begin
import Pkg
Pkg.add("Plots")
include("projet\\phase1\\node.jl")
include("projet\\phase1\\edge.jl")
include("projet\\phase1\\graph.jl")
include("projet\\phase1\\read_stsp.jl")
end

# ╔═╡ 3334fbc2-a2bc-400e-9011-81fc018566ff
#A file name (fn) is defined by obtaining the current working directory with pwd() and combining it with a relative path to a file named "bayg29.tsp."
begin
fn = pwd() * "\\instances\\stsp\\bayg29.tsp"
#reads the data from the specified file (fn) and stores it in various variables such as header, almost_edges, and almost_nodes.
header = read_header(fn)
almost_edges = read_edges(header, fn)
almost_nodes = read_nodes(header, fn)
end


# ╔═╡ 6664eaff-46ae-4f26-a297-3eb2f2a74294
# Constructing my_nodes of type Node from the given file 
#starting with an empty array for nodes and filling it up with a for loop
begin
my_nodes = Vector{Node{Float64}}()
for almost_node in almost_nodes
    new_node = Node(string(almost_node[2][1]), almost_node[2][2])
	#adding the new nodes
    push!(my_nodes, new_node) 
end
end

# ╔═╡ b91cfa11-627a-44d6-a18c-ae8a4220608e
# Constructing my_edges of type Edge from the given file 
#starting with an empty array for edges and filling it up with a for loop
begin
my_edges = Vector{Edge{Float64, Node{Float64}}}()
for almost_edge in almost_edges
    new_edge = Edge(my_nodes[almost_edge[1]], my_nodes[almost_edge[2]], almost_edge[3])
	#adding the new edges
    push!(my_edges, new_edge)
end
end

# ╔═╡ ac1db0f2-ec4a-4834-80b1-6d0b4c0d91ea
G = Graph("Ick", my_nodes, my_edges)

# ╔═╡ Cell order:
# ╠═75572c3f-0fea-4b7a-aa67-6d97661f5da6
# ╠═3334fbc2-a2bc-400e-9011-81fc018566ff
# ╠═6664eaff-46ae-4f26-a297-3eb2f2a74294
# ╠═b91cfa11-627a-44d6-a18c-ae8a4220608e
# ╠═ac1db0f2-ec4a-4834-80b1-6d0b4c0d91ea
