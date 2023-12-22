### A Pluto.jl notebook ###
# v0.19.36

using Markdown
using InteractiveUtils

# ╔═╡ 75572c3f-0fea-4b7a-aa67-6d97661f5da6
md"""
# Rapport Projet 5
## MTH6412B
Githib branch: https://github.com/houskkam/mth6412b-starter-code/tree/phase5
In this phase the earlier written code will be used to remake shredded photos.

TODO: Pour chaque image reconstruite, donnez la longueur de la meilleure tournée trouvée, l’image originale ainsi que l’image reconstruite côte-à-côte.

We encountered a problem during this last phase. We didn't realise the tools.jl file with the code was given so we constructed a write\_tour and reconstruct\_picture ourselves. When we got stuck at the reconstruct\_picture, because we thought we didn't have enough information on how to write it a student reminded us the tools file was given. Sadly this was the day of the deadline. We did our best to write as much code as possible until the deadline.

"""

# ╔═╡ a64c5f62-f695-47bf-a854-a96f4cb36ff4
md"""
## Project 4
This part of the project gives the code for shredding and reconstructing a picture. For every reconstructed picture it is tried to give the length of the optimal tour.

The most important function we created in this phase is get\_cycle. It gets one argument input\_name, which specifies the name of picture for which we 
want to create the cycle. It creates a file input\_name.tour containing information about the cycle and returns information about the difference of the cycle.
```julia
function get_cycle(input_name::String)
    g_create = get_graph_from_file(input_name)
    # Filtering out the node 0 that has 0 lenght edges with all other nodes

    node_to_be_deleted = g_create.nodes[1]
    # Creates a vector of all graph's node except the root
    g_create.nodes = filter(x -> x != node_to_be_deleted, g_create.nodes)

    # Creates a vector of all graphs edges except the edges adjacent to the root
    to_remove = get_oriented_edges(g_create, node_to_be_deleted)
    g_create.edges = filter(x -> !(x in to_remove), g_create.edges)

    (cycle, my_edges, elapsed_time, elapsed_time_no_test) = lewis(g_create, nodes(g_create)[1], true)
    tour_weight = sum_weight_of_edges(my_edges)
    tour_filename = write_tour(input_name, tour_weight, cycle)
    return tour_filename, cycle, tour_weight
end

```
"""

# ╔═╡ 91da7dd3-4bf6-4887-ba19-b86ac08f4554
md"""
This for-loop will give back the weight of the loops.

```julia
files_path = pwd() * "\\shredder\\shredder-julia\\tsp\\instances\\"

files = ["abstract-light-painting.tsp", "alaska-railroad.tsp", "blue-hour-paris.tsp", "lower-kananaskis-lake.tsp", "marlet2-radio-board.tsp", "nikos-cat.tsp", "pizza-food-wallpaper.tsp", "the-enchanted-garden.tsp", "tokyo-skytree-aerial.tsp"]
for file in files
    name_of_file_now = filespath * file
    , _, tour_weight = get_cycle(name_of_file_now)
    println("The cycle we found for ", file, " has length equal to ", tour_weight)
end

```
"""

# ╔═╡ 0dc99503-35b4-4746-aea3-6fdeb6fe7157
md"""
In the next part a picture is shuffled so that it can be reconstructed again to test the reconstruct\_picture file. This way the original and reconstructed picture can be compared.

```julia
shuffle_picture(fn, fn_out)

fn_tsp = pwd() * "\\projet\\shredder\\shredder-julia\\tsp\\instances\\alaska-railroad.tsp"
old_fn_tsp = pwd() * "\\projet\\shredder\\shredder-julia\\tsp\\instances\\alaska-railroad.tsp"
fn_out_reconstructed = pwd() * "\\projet\\output\\alaska-railroad-reconstructed.png"

reconstruct_picture(fn_tsp, old_fn_tsp, fn_out_reconstructed)

```
"""

# ╔═╡ 630f16ad-1f55-42df-a771-e1f5e90b2898
md"""
## The first code we wrote
As mentioned earlier we thought the exercise also consisted of creating the write\_tour and recontruct\_picture file. Luckily we noticed this and didn't finish our code, but because we weren't able to succeed with the other part we thought it would still be good to show the code we started on. 

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

The get\_cycle function from our original strategy is reused in our last version. This can be seen at the top.

"""


# ╔═╡ a74145e2-09ee-444d-bc79-88a0c00025ae
md"""
In the next pert of the project the picture has to be recontructed using the cycle that was previously calculated. By reading the file this will give us a correct order to place the shredded pieces of the image.
```julia
function reconstruct_picture(tour_filename::String, input_picture::AbstractArray)
    ur_filename, cycle_nodes = get_cycle(filename)
    
    # Get the number of columns in the input picture
    nb_col = size(input_picture, 2)

    # Initialize the reconstructed picture with zeros
    reconstructed_picture = zeros(size(input_picture))

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

```
"""

# ╔═╡ Cell order:
# ╠═75572c3f-0fea-4b7a-aa67-6d97661f5da6
# ╟─a64c5f62-f695-47bf-a854-a96f4cb36ff4
# ╟─91da7dd3-4bf6-4887-ba19-b86ac08f4554
# ╟─0dc99503-35b4-4746-aea3-6fdeb6fe7157
# ╟─630f16ad-1f55-42df-a771-e1f5e90b2898
# ╟─1d83b40c-f15a-445f-9760-d5eb94bd9638
# ╟─f598ae3c-4d44-4a8f-be60-e5df1169d87e
# ╟─a7fd766e-3dc2-4252-88b6-579375ae9b6b
# ╟─a74145e2-09ee-444d-bc79-88a0c00025ae
