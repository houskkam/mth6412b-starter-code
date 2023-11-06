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
# We decided to represent connected component as a oriented graph with a root. We created two new datatypes for that.
# The first one is EdgeOriented, which implements AbstractEdge. It is very similar to normal Edge but it has a start and an end.
# We also added a function that converts an Edge to EdgeOriented.
begin
    """Type abstrait dont d'autres types de edges orientés dériveront."""
    abstract type AbstractEdgeOriented{Z, T <: AbstractNode} <: AbstractEdge{Z, T}  end

    """Type représentant les edges orientés d'un graphe.

    Exemple:
            noeud1 = Node("James", "ahooj")
            noeud2 = Node("Kirk", "guitar")
            noeud3 = Node("Lars", "tdd")
            edge1 = EdgeOriented(noeud1, noeud2, 5)
            edge2 = EdgeOriented(noeud2, noeud3, 4)

    """
    mutable struct EdgeOriented{Z, T} <: AbstractEdgeOriented{Z, T}
    debut::T
    fin::T
    poids::Z
    end

    # on présume que tous les edges dérivant d'AbstractEdge
    # posséderont des champs `edge1`, `edge2` et `poids`.

    """Renvoie le nom du premiere noeud d'un edge."""
    debut(edge::AbstractEdgeOriented) = edge.debut

    """Renvoie le nom du deuxieme noeud d'un edge."""
    fin(edge::AbstractEdgeOriented) = edge.fin

    ==(e1::AbstractEdgeOriented, e2::AbstractEdgeOriented) = (debut(e1) == debut(e2)) && (fin(e1) == fin(e2)) && (poids(e1) == poids(e2))

    Base.convert(::Type{T}, e::Edge) where {T<:EdgeOriented} = EdgeOriented(node1(e), node2(e), poids(e))

    """Affiche un edge."""
    function show(edge::AbstractEdgeOriented)
    println("Parent node ", debut(edge), "child node: ", fin(edge) ,", weight: ", poids(edge))
    end
end

# Then we used it to create the ComposanteConnexe type, which is a connected component. It is a subtype of AbstractGraph, so all methods that are implemented for AbstractGraph function for ComposanteConnexe too.
begin

    """Type abstrait dont d'autres types de graphes dériveront."""
    abstract type AbstractComposanteConnexe{T, Z} <: AbstractGraph{T, Z} end

    """Type representant une composante connexe comme un ensemble de noeuds, .

    Exemple :
        noeud1 = Node("James", "ahooj")
        noeud2 = Node("Kirk", "guitar")
        noeud3 = Node("Lars", "tdd")
        edge_oriented_1 = EdgeOriented(noeud1, noeud2, 5)
        edge_oriented_2 = EdgeOriented(noeud2, noeud3, 4)
        C = ComposanteConnexe(noeud1, [noeud1, noeud2, noeud3], [edge_oriented_1, edge_oriented_2])

    Attention, tous les noeuds doivent avoir des données de même type.
    """
    mutable struct ComposanteConnexe{T, Z} <: AbstractComposanteConnexe{T, Z}
    root::T
    nodes::Vector{T}
    edges::Vector{EdgeOriented{Z,T}}
    end

    """Ajoute un noeud et l'arret qui le relie au graphe."""
    function add_node_and_edge!(composante::ComposanteConnexe{Node{T}, Z}, node::Node{T}, edge::EdgeOriented{Z, Node{T}}) where {T, Z}
    push!(composante.nodes, node)
    push!(composante.edges, edge)
    composante
    end


    """Determines that connected components are equal if their contents equal."""
    ==(c1::ComposanteConnexe, c2::ComposanteConnexe) = (nodes(c1) == nodes(c2)) && (edges(c1) == edges(c2))

    """Takes a vector of connected components and merges them into one."""
    function connect_into_one(composantes::Vector{ComposanteConnexe{T, Z}}, edge::EdgeOriented{Z, T}) where {T, Z}
    new_component = composantes[1]
    for node in nodes(composantes[2])
        if !(node in nodes(new_component))
        add_node!(new_component, node)
        end
    end
    for edge in edges(composantes[2])
        add_edge!(new_component, edge)
    end
    if(length(composantes) > 2)
        print("have to connect more than 2 components")
    end
    add_edge!(new_component, edge)
    new_component
    end

    """Affiche un graphe."""
    function show(graph::ComposanteConnexe)
    println("Graph ", name(graph), " has ", nb_nodes(graph), " nodes")
    for node in nodes(graph)
        show(node)
    end
    println("and ", nb_edges(graph), "edges.")
    for edge in edges(graph)
        show(edge)
    end
    end

end


# ╔═╡ 6664eaff-46ae-4f26-a297-3eb2f2a74294
# Second exercice of Phase 2
begin


end
end

# ╔═╡ b91cfa11-627a-44d6-a18c-ae8a4220608e
# Third exercice of Phase 2
#because composante connexe can lead to long chains and thus is time inefficient, another strategy can be used to form a chain.
begin
    #Include the other files we use  
    include("../graph.jl")
    
    #This new strategy starts from disjoints sets. Because this is not yet implemented, a new type is created. 
    #This is DisjointSet which gives a parent and rank for a certain node. 
    mutable struct DisjointSet{T}
        parent::T 
        rank::Int
    end
    

    #There are only graphs given so the first step consists of creatin a disjoint-set for each node in the graph.
    function create_disjoint_sets(graph::Graph{T, Z}) where {T, Z}
        #an empty vector is made where everything will be stored.
        #when iterating through all the nodes in the graph, the disjoint set gets filled up.
        disjoint_sets= [DisjointSet(node, 0) for node in graph.nodes]
        #A vector of disjoint sets is returned.
        return disjoint_sets
    end
    
    #For this method the roots have to be found to compare the ranks of each node
    #This method does that without path compression
    function find_roots(disjoint_sets::Vector{DisjointSet{T}}, node::T) where T
        # iteratively follows the parent pointers until it reaches a node that is its own parent,
        # which indicates it is the root of the set.
        while disjoint_sets[node].parent != node
            node = disjoint_sets[node].parent
        end
        #the node that is the root of the given node is returned
        return node
    end
    
    #This method uses path compression
    function find_roots_compression(disjoint_sets::Vector{DisjointSet{T}}, node::T) where T
        # iteratively follows the parent pointers until it reaches a node that is its own parent,
        # which indicates it is the root of the set.
        if disjoint_sets[node].parent != node
            #but here the parent of each node is set as the root, which differentiates from the previous method.
            disjoint_sets[node].parent = find_roots(disjoint_sets, disjoint_sets[node].parent)
        end
        #the root (parent) is given 
        return disjoint_sets[node].parent
    end
    
    #Union-by-Rank method
    function heuristique_union(graph::Graph{T, Z}) where {T, Z}
        # get all edges
        all_edges = edges(graph) 
        # Make a disjoint-set for each node in the graph
        disjoints = create_disjoint_sets(graph) 
        #an empty vector is made to 
        tree_edges = Vector{Edge{T, Z}}()
        
        #all the edges in the graph are looked at
        for edge in all_edges
            #two nodes will get compared eached time to know whos rank is higher
            node1 = edge.node1
            node2 = edge.node2
            #to know the rank we will have to find their roots so the function find_roots is called upon. This will be done without path compression
            root_1 = find_roots(disjoints, node1)
            root_2 = find_roots(disjoints, node2)
            
            #if they both have the same parent they can't be connected because you would have a cycle
            if root_1!=root_2
                #the node with the highest rank becomes the parent of the other node
                if disjoints[root_1].rank < disjoints[root_2].rank
                    disjoints[root_1].parent = root_2
                    #rank goes up when they become the parent of someone new
                    disjoints[root_2].rank += 1
                #the node with the highest rank becomes the parent of the other node
                elseif disjoints[root_1].rank > disjoints[root_2].rank
                    disjoints[root_2].parent = root_1
                    #rank goes up when they become the parent of someone new
                    disjoints[root_1].rank += 1
                else
                    #if they have the same rank we can choose the parent
                    disjoints[root_2].parent = root_1
                    #rank goes up when they become the parent of someone new
                    disjoints[root_1].rank += 1
                end
                #the new edge that is made will be pushed into the tree
                push!(tree_edges, edge) 
            end
        end
        #this gives back all the connections
        for edge in tree_edges
            println("Edge from node ", edge.node1, " to node ", edge.node2)
        end

    end

    #Montrer que le rang d’un noeud sera toujours inférieur à |S|-1. 
    "Let us presume a random node x and we want to show that the rang will always be smaller than |S|-1, with S the number of nodes.
    1.When initialising every node gets a rank of O (base case) 
    2.When comparing two sets we look at the rank of the roots of the nodes. When the nodes are different, the node with the highest rank becomes the parent.
    Node 'x' can only be a root when it is in a set with a lower rank node.
    3.At each union  the rank of the root with lowest rank will be minimum highered with one. So if node 'x' is in a set with rank 0 and gets connected with another set, the new root of the set will have 
    a rank of at least 1.
    4.This will be repeated for all the nodes. All nodes except one will be connected, so we work with |S|-1 unions. This means the rank will never be higher than |S|-1.
    "
    #Montrer ensuite que ce rang sera en fait toujours inférieur à floor[log_{2}(|S|)] ;
    "
    1.Every node gets a rank 0 at creation
    2.With every union of two sets with different ranks, the new parents increases with minimum 1 in rank.
    3.To prove that the rank of each node is smaller than floor[log_{2}(|S|)] induction will be used.
    4.Base case: for one node with |S|=1 , the rank is zero and floor[log_{2}(|1|)]=0. -> this is true
    5.Induction hypothesis: the rank of a node is always smaller than floor[log_{2}(|n|)] for every set dimension |S| going to n.
    rank ( of set n) < floor[log_{2}(|n|)]
    6.Induction: prove this for n+1 
    We split this set into a set of n and a set of 1. When connecting the two sets the new root will have a rank of at least 1 (because the ranks are different).
    This will lead to a rank, of a set of (n+1), lower than floor[log_{2}(|n|)]+1
    Because: rank ( of set n+1) < floor[log_{2}(|n|)]+1
    rank ( of set n) < floor[log_{2}(|n|)]
    rank ( of set n)+1 < floor[log_{2}(|n|)] +1
    This shows that the rank of every node will always be lower than floor[log_{2}(|S|)] vor every given set size |S|.
    "
    
    # Using path compression
    function heuristique_compression(graph::Graph{T, Z}) where {T, Z}
        # get all edges
        all_edges = edges(graph)  
        # Make a disjoint-set for each node in the graph
        disjoints = create_disjoint_sets(graph) 
        #empty vector is made to collect all the edes 
        tree_edges = Vector{Edge{T, Z}}()
    
        #all the edges in the graph are looked at
        for edge in all_edges
            #two nodes will get compared eached time to know whos rank is higher
            node1 = edge.node1
            node2 = edge.node2
            #to know the rank we will have to find their roots so the function find_roots is called upon. This will be done with path compression
            root_1 = find_roots_compression(disjoints, node1)
            root_2 = find_roots_compression(disjoints, node2)
            
            #if they both have the same parent they can't be connected because you would have a cycle
            if root_1 != root_2
                #the node with the highest rank becomes the parent of the other node
                #rank goes up when they become the parent of someone new
                if disjoints[root_1].rank < disjoints[root_2].rank
                    disjoints[root_1].parent = root_2
                    disjoints[root_2].rank += 1
                elseif disjoints[root_1].rank > disjoints[root_2].rank
                    disjoints[root_2].parent = root_1
                    disjoints[root_1].rank += 1
                else
                    #if they have the same rank we can choose the parent
                    disjoints[root_2].parent = root_1
                    disjoints[root_1].rank += 1
                end
                #the new edge that is made will be pushed into the tree
                push!(tree_edges, edge)
            end
        end

        #this gives back all the connections
        for edge in tree_edges
            println("Edge from node ", edge.node1, " to node ", edge.node2)
        end
    end
    

end

# ╔═╡ ac1db0f2-ec4a-4834-80b1-6d0b4c0d91ea
# Fourth exercice of Phase 2
begin 
    #we include the other files we use 
    include("graph.jl")
    include("composante_connexe.jl") 
    
    #start of the function that uses prim algorithm to find the minimum spanning tree
    function prim_alg(graph::Graph{T, Z}, startpoint::Node{T}) where {T, Z}
        nodes_gr = nodes(graph)
        minimum_spanning_tree = ComposanteConnexe{T, Z}(startpoint, [startpoint], Vector{Edge{T, Z}}())
    
        # un attribut min_weight -> Initialement, min_weight = infinity ; Initialement, le parent de chaque noeud est nothing
        for node in nodes_gr
            node.min_weight = Inf
            node.parent = nothing
        end
    
        # Begin at a source node s (startpoint) chosen by the user, and set the min_weight attribute of s to 0
        startpoint.min_weight = 0

        # Initialize the set inTree to keep track of nodes included in the minimum spanning tree
        inTree = Set{Node{T}}([startpoint])
    
        #A priority queue contains all the nodes that have not yet been added to the tree, and min_weight determines the priority.
        #Each time a node is connected to the tree, the min_weight and parent attributes of those that have not yet been connected must be updated.
        pq = PriorityQueue{Int,Node{T}}()
        enqueue!(pq,startpoint.min_weight,startpoint)
    
        while !isempty(pq)
            # The first node in the pair is the node with the minimum weight.
            w = dequeue!(pq)
    
            # If the node is already included , continue to the next
            if  w in inTree
                continue
            end
            
            # Mark the node as included
            inTree = union(inTree, Set{Node{T}}([w]))  
    
            # Iterate through all adjacent nodes of w
            for edge in get_edges_for_node(graph, w)
                # Find the other node connected by the edge
                u= ifelse(node1(edge) == w, node2(edge), node1(edge)) 
                weight= poids(edge)
    
                # If v is not in min. spanning tree and the weight of (u, v) is smaller than the current key of v
                if u ∉ inTree && weight < u.min_weight
                    u.min_weight = weight
                    u.parent = w
                    
                    #add in the priority queue
                    enqueue!(pq, u.minweight, u)
    
                    #add edge to minimum spanning tree
                    add_node_and_edge!(minimum_spanning_tree, u, edge)
                end
            end
        end
        #give the minimum spanning tree back
        return minimum_spanning_tree
    
    end
end


# ╔═╡ Cell order:
# ╠═75572c3f-0fea-4b7a-aa67-6d97661f5da6
# ╠═3334fbc2-a2bc-400e-9011-81fc018566ff
# ╠═6664eaff-46ae-4f26-a297-3eb2f2a74294
# ╠═b91cfa11-627a-44d6-a18c-ae8a4220608e
# ╠═ac1db0f2-ec4a-4834-80b1-6d0b4c0d91ea
