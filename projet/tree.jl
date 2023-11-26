include("node.jl")

"""Type abstrait dont d'autres types d'arbre dériveront."""
abstract type AbstractTree{T} end


mutable struct Tree{T} <: AbstractTree{Node{T}}
    node::Node{T}
    children::Vector{Tree{T}}
    parent::Union{Tree{T}, Missing}
end

get_node(t::Tree) = t.node
children(t::Tree) = t.children
parent(t::Tree) = t.parent

"""Creates a tree from a given g of type AbstractGraph. The argument parent is going to be the root.
Returns the parent of the tree and nodes in preorder tree traversal"""
function create_child!(g::AbstractGraph{Node{T}, Z}, parent::Tree{T}, already_added::Vector{Node{T}}) where {T,Z}
    root = get_node(parent)
    print("treating node", name(root))

    for n in nodes(g)
        # if the node is not in the tree yet but there is
        # an edge that connects it to the tree, add it
        if isnothing( findfirst(x -> name(x)== name(n), already_added)) && !isnothing(get_edge(g, root, n)) 
            new_item = Tree{T}(n, Vector{Tree{T}}(), parent)
            push!(already_added, n)
            push!(children(parent), new_item)
            #print("adding", name(n),"\n")
        else
            #print("already inside",  !isnothing(get_edge(g, root, n)), name(n), "\n")
            #isnothing( findfirst(x -> name(x)== name(n), already_added)),
        end
    end
    for c in children(parent)
        (_, already_added) = create_child!(g, c, already_added)
    #push!(children(parent), new_item)
    end

    # repete the process for all subtrees
    #for c in children(parent)
    #    create_child!(g, c, already_added)
    #end

    (parent, already_added)
end


function create_child!(g::AbstractGraph{Node{T}, Z}, parent::Tree{T}, already_added::Vector{Node{T}}) where {T,Z}
    root = get_node(parent)
    print("treating node", name(root))

    for n in nodes(g)
        # if the node is not in the tree yet but there is
        # an edge that connects it to the tree, add it
        if isnothing( findfirst(x -> name(x)== name(n), already_added)) && !isnothing(get_edge(g, root, n)) 
            new_item = Tree{T}(n, Vector{Tree{T}}(), parent)
            push!(already_added, n)
            push!(children(parent), new_item)
            #print("adding", name(n),"\n")
        else
            #print("already inside",  !isnothing(get_edge(g, root, n)), name(n), "\n")
            #isnothing( findfirst(x -> name(x)== name(n), already_added)),
        end
    end
    for c in children(parent)
        (_, already_added) = create_child!(g, c, already_added)
    #push!(children(parent), new_item)
    end

    # repete the process for all subtrees
    #for c in children(parent)
    #    create_child!(g, c, already_added)
    #end

    (parent, already_added)
end

function show(t::Tree)
    print(get_node(t))
    for c in children(t)
        println("(child ", c, ")")   
    end
  end
