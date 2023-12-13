### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# ╔═╡ 75572c3f-0fea-4b7a-aa67-6d97661f5da6
md"""
# Rapport Projet 5
## MTH6412B
Githib branch: https://github.com/houskkam/mth6412b-starter-code/tree/phase5
In this phase the earlier written code will be used to remake shredded photos. 
### TODO: Pour chaque image reconstruite, donnez la longueur de la meilleure tournée trouvée, l’image originale ainsi que l’image reconstruite côte-à-côte.

"""

# ╔═╡ 630f16ad-1f55-42df-a771-e1f5e90b2898
md"""
To implement this phase, we used many functions. One of them is called write\_tour. 
Function write\_tour creates a file .tour that describes the minimal weight cycle that we put in through argument nodes.

```julia
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

    # creating file named : filename.tour and writing the inside of 
	# inside_string to it
    write(file, inside_string)
end
```
"""

# ╔═╡ 1d83b40c-f15a-445f-9760-d5eb94bd9638
md"""
Another function is sum\_weight\_of\_edges. This function gets only one argument - a vector of edges and it returns the sum of weights of all the edges.

```julia
function sum_weight_of_edges(my_edges::Vector{Edge{Z, T}}) where {Z, T}
    sum = 0
    last_n1 = node1(my_edges[1])
    last_n2 = node2(my_edges[1])
    # Testing that we really do get a cycle and creating 
	# the sum of weights at the same time
    for e in my_edges
        sum = sum + poids(e)
        last_n1 = node1(e)
        last_n2 = node2(e)
    end
end
```
"""

# ╔═╡ f598ae3c-4d44-4a8f-be60-e5df1169d87e
md"""
The next function is based on the code we got from the Phase 5 instructions. get\_difference gets argument input\_name, which specifies the name of picture for which we want to calculate the difference of shades that are close to each other.

```julia
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
```
"""

# ╔═╡ a7fd766e-3dc2-4252-88b6-579375ae9b6b
md"""

The most important function we created in this phase is get\_cycle. It gets one argument input\_name, which specifies the name of picture for which we 
want to create the cycle. It creates a file input\_name.tour containing information about the cycle and returns information about the difference of the cycle.

```julia


```
"""

# ╔═╡ Cell order:
# ╠═75572c3f-0fea-4b7a-aa67-6d97661f5da6
# ╠═630f16ad-1f55-42df-a771-e1f5e90b2898
# ╠═1d83b40c-f15a-445f-9760-d5eb94bd9638
# ╠═f598ae3c-4d44-4a8f-be60-e5df1169d87e
# ╠═a7fd766e-3dc2-4252-88b6-579375ae9b6b
