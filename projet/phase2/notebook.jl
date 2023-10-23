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
# First exercice of Phase 2
# We decided to represent connected component as a oriented graph with a root.
begin
fn = pwd() * "\\instances\\stsp\\bayg29.tsp"
#reads the data from the specified file (fn) and stores it in various variables such as header, almost_edges, and almost_nodes.
header = read_header(fn)
almost_edges = read_edges(header, fn)
almost_nodes = read_nodes(header, fn)
end


# ╔═╡ 6664eaff-46ae-4f26-a297-3eb2f2a74294
# Second exercice of Phase 2
begin


end
end

# ╔═╡ b91cfa11-627a-44d6-a18c-ae8a4220608e
# Third exercice of Phase 2
begin

end

# ╔═╡ ac1db0f2-ec4a-4834-80b1-6d0b4c0d91ea
# Fourth exercice of Phase 2


# ╔═╡ Cell order:
# ╠═75572c3f-0fea-4b7a-aa67-6d97661f5da6
# ╠═3334fbc2-a2bc-400e-9011-81fc018566ff
# ╠═6664eaff-46ae-4f26-a297-3eb2f2a74294
# ╠═b91cfa11-627a-44d6-a18c-ae8a4220608e
# ╠═ac1db0f2-ec4a-4834-80b1-6d0b4c0d91ea
