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

# ╔═╡ f6bbd625-f650-4f3a-beda-f471cefe7ed5
md"""
## The reconstruction of the images
In this part of the code the goal is to reconstruct the  shredded picture. This reconstruction is done after a tour is found using the previous functions. 

```julia
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
```
"""

# ╔═╡ 7e9b0da1-ec1d-4973-92f5-c15f9b5644a3
md"""
This function reads the tour nodes from a .tour file and returns them as an array of Node objects. It returns an array of Node objects representing the tour nodes.

```julia 
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

```
"""

# ╔═╡ fd996a87-b276-480a-a428-c0f9d3bf0c09
md"""
## Compare the images 
In this part the reconstructed and original pricture are placed next to eachother, to evaluate how well the reconstruction went. A fuction generate_picture() is made to depict these images. Now it can be tested on multiple pictures when calling up the function.

```julia
function generate_picture(original_picture::AbstractArray, reconstructed_picture::AbstractArray)
    plot(
        heatmap(original_picture, color=:grays, title="Original Picture"),
        heatmap(reconstructed_picture, color=:grays, title="Reconstructed Picture"),
        layout=(1,2),
        size=(800, 400)
    )
end
```
"""

# ╔═╡ 12b09f82-7096-4ea7-8711-b1e167352c21
md"""
This can now be tested on the following examples:
WE STILL NEED TO FILL THIS IN!!!

"""

# ╔═╡ Cell order:
# ╟─75572c3f-0fea-4b7a-aa67-6d97661f5da6
# ╟─630f16ad-1f55-42df-a771-e1f5e90b2898
# ╟─1d83b40c-f15a-445f-9760-d5eb94bd9638
# ╟─f598ae3c-4d44-4a8f-be60-e5df1169d87e
# ╟─a7fd766e-3dc2-4252-88b6-579375ae9b6b
# ╟─f6bbd625-f650-4f3a-beda-f471cefe7ed5
# ╟─7e9b0da1-ec1d-4973-92f5-c15f9b5644a3
# ╟─fd996a87-b276-480a-a428-c0f9d3bf0c09
# ╟─12b09f82-7096-4ea7-8711-b1e167352c21
