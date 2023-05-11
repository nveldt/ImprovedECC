"""
Naive majority vote implementation. Other implementation is faster
"""
function naive_majority_vote(n2e::Vector{Vector{Int64}},colors::Vector{Int64})
    n = length(n2e)
    c = zeros(Int64,n)
    for v = 1:n
        Lev = n2e[v]
        cls = colors[Lev]
        c[v] = StatsBase.mode(cls)
    end
    return c
end



"""
Given an edge colored hypergraph, run PittColoring or MatchVCColoring multiple times. This 
does not assume the input is given to you nicely, so you must take time to
format it correctly.
"""
function vc_either_coloring(EdgeList::Vector{Vector{Int64}},EdgeColors::Vector{Int64},n::Int64,numtimes::Int64=1,match::Bool=false)
    e2n, colors, n2e = hypergraph_sortbycolor(EdgeList,EdgeColors,n)

    if match
        best_D, min_del = implicit_maximalmatch_vc(e2n,n2e,colors)
        for i = 1:(numtimes-1)
            D, del = implicit_maximalmatch_vc(e2n,n2e,colors)
            if del < min_del
                best_D = D
                min_del = del
            end
        end
    else
        best_D, min_del = implicit_pitt_vc(e2n,n2e,colors)
        for i = 1:(numtimes-1)
            D, del = implicit_pitt_vc(e2n,n2e,colors)
            if del < min_del
                best_D = D
                min_del = del
            end
        end
    end

    return EdgeDeletion2clustering(e2n,colors,best_D,n), min_del
end



"""
Reduces an edge colored hypergraph H to an instance of vertex cover.

Input: 
    H = edge-to-node incidence matrix for the graph
    colors = color label for edges in H.

Output:
    A = adjacency matrix for a graph where node i in A corresponds to edge in in H
"""
function colorec_to_vc(H,colors)



end


"""
Simple maximal matching 2-approximation algorithm for vertex cover.

Input:
    A = adjacency matrix for an unweighted and undirected graph

Output:
    C = node labels for a vertex cover of A
"""
function matching_vc(A)



end
