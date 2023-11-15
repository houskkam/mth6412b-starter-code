### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# ╔═╡ b4b81322-5632-11ee-39de-e3a0b20a4a8f
md"""
Rapport Projet 									    MTH6412B
<h1>Phase 4</h1>
"""

# ╔═╡ d1426d43-4b3d-4e41-bed6-1460ee7631c5
"""
We started by implementing the Rosenkrantz, Stearns and Lewis algorithm as a function named lewis, 
which takes in only one argument and this argument is of type Graph. To do that we also created a 
function preorder that arranges the nodes of a given graph according to the preorder traversal, 
which means in the order of visiting. As you can see below, we use the function preorder in lewis 
in order to create a cycle.
"""

# ╔═╡ c6c6dd31-de50-4d3f-9317-a49577d6ef41
# Julia code can follow here
x = 1

# ╔═╡ 7d84c474-c132-4845-a0d2-e06c097c6e1f
y = 2

# ╔═╡ 88a23236-a6c0-48da-b682-e94c1de5069b
z = x + y

# ╔═╡ Cell order:
# ╠═b4b81322-5632-11ee-39de-e3a0b20a4a8f
# ╠═d1426d43-4b3d-4e41-bed6-1460ee7631c5
# ╠═c6c6dd31-de50-4d3f-9317-a49577d6ef41
# ╠═7d84c474-c132-4845-a0d2-e06c097c6e1f
# ╠═88a23236-a6c0-48da-b682-e94c1de5069b