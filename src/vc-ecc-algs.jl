## This file include vertex cover based algorithms for Edge-Colored Clustering in hypergraphs and graphs
include("../include/CategoricalEdgeClustering-master/src/EdgeCatClusAlgs.jl")

"""
Given an edge colored hypergraph, run MatchVCColoring multiple times. This 
does not assume the input is given to you nicely, so you must take time to
format it correctly.
"""
function matchvccoloring(EdgeList::Vector{Vector{Int64}},EdgeColors::Vector{Int64},n::Int64,numtimes::Int64=10)
    e2n, colors, n2e = hypergraph_sortbycolor(EdgeList,EdgeColors,n)

    best_D, min_del = implicit_maximalmatch_vc(e2n,n2e,colors)

    # Keep track of the best lower bound too:
    # Half the number of deleted edges is a matching in the reduced graph
    best_match = min_del/2

    for i = 1:(numtimes-1)
        D, del = implicit_maximalmatch_vc(e2n,n2e,colors)
        if del < min_del
            best_D = D
            min_del = del
        end
        if del/2 > best_match
            best_match = del/2
        end
    end
        
    c = EdgeDeletion2clustering(e2n,colors,best_D,n)

    return c, min_del, best_match
end

"""
Given an edge colored hypergraph, run PittColoring multiple times. This 
does not assume the input is given to you nicely, so you must take time to
format it correctly.
"""
function pittcoloring(EdgeList::Vector{Vector{Int64}},EdgeColors::Vector{Int64},n::Int64,numtimes::Int64=10)
    
    e2n, colors, n2e = hypergraph_sortbycolor(EdgeList,EdgeColors,n)
    best_D, min_del = implicit_pitt_vc(e2n,n2e,colors)
    for i = 1:(numtimes-1)
        D, del = implicit_pitt_vc(e2n,n2e,colors)
        if del < min_del
            best_D = D
            min_del = del
        end
    end
        
    c = EdgeDeletion2clustering(e2n,colors,best_D,n)

    return c, min_del
end


"""
An implicit implementation of Pitt's 2-approximation for vertex cover,
run directly on the edge-colored hypergraph H that can be reduced to vertex cover.

This can be generalized to edge-weighted hypergraphs, but this implementation
is only designed for the unweighted case.

Input:
    e2n = edge id to node id list
    n2e = node id to edge id list
    colors = color label for edges in H.

Output:
    labels = node color labels corresponding to the vertex cover approximation

"""
function implicit_pitt_vc(e2n::Vector{Vector{Int64}},n2e::Vector{Vector{Int64}},colors::Vector{Int64})

    D = zeros(Bool,length(e2n)) # indicator for deleted edges
    n = length(n2e)
    pm = randperm(n)
    deleted = 0
    for i = 1:n
        v = pm[i]
        Lev = n2e[v]
        f = 1
        b = length(Lev)

        # Move past all bad edge pairs that are covered already
        while D[Lev[f]] && b > f
            f = f + 1
        end
        while D[Lev[b]] && b > f
            b = b - 1
        end

        while colors[Lev[f]] != colors[Lev[b]]
            @assert(D[Lev[f]] == false)
            @assert(D[Lev[b]] == false)
            rho = rand(1)[1]
            deleted += 1
            if rho < 1/2
                # delete the first/front edge
                D[Lev[f]] = true
                while D[Lev[f]] && b > f
                    f = f + 1
                end
            else
                # delete the back edge
                D[Lev[b]] = true
                while D[Lev[b]] && b > f
                    b = b - 1
                end
            end
        end
    end

    return D, deleted
end



"""
An implicit implementation of the standard maximal matching 2-approximation for vertex cover,
run directly on the edge-colored hypergraph H that can be reduced to vertex cover.

Works only for unweighted hypergraphs.
    
Input:
    e2n = edge id to node id list
    n2e = node id to edge id list
    colors = color label for edges in H.

Output:
    labels = node color labels corresponding to the vertex cover approximation

"""
function implicit_maximalmatch_vc(e2n::Vector{Vector{Int64}},n2e::Vector{Vector{Int64}},colors::Vector{Int64})

    n = length(n2e)
    D = zeros(Bool,length(e2n)) # indicator for deleted edges
    pm = randperm(n)
    deleted = 0
    for i = 1:n
        v = pm[i]
        Lev = n2e[v]
        f = 1
        b = length(Lev)

        # Move past all bad edge pairs that are covered already
        while D[Lev[f]] && b > f
            f = f + 1
        end
        while D[Lev[b]] && b > f
            b = b - 1
        end

        while colors[Lev[f]] != colors[Lev[b]]
            # @assert(D[Lev[f]] == false)
            # @assert(D[Lev[b]] == false)
            D[Lev[f]] = true
            D[Lev[b]] = true
            deleted += 2
            while D[Lev[f]] && b > f
                f = f + 1
            end
            while D[Lev[b]] && b > f
                b = b - 1
            end
        end
    end

    return D, deleted
end

"""
EdgeDeletion2clustering

Given a set of edges to delete to make an instance of ECC satisfiable,
get the appripriate clustering or return that this is not actually satisfiable
"""

function EdgeDeletion2clustering(e2n::Vector{Vector{Int64}},colors::Vector{Int64},D::Vector{Bool},n::Int64)

    k = maximum(colors)
    c = (k+1)*ones(n)
    for j = 1:length(D)
        if D[j] == false
            # then all nodes in j can be labeled the color of D
            nodes = e2n[j]
            cl = colors[j]
            for v in nodes
                @assert(c[v] == k+1 || c[v] == cl)
                c[v] = cl
            end
        end
    end
    return c
end


"""
Put the hypergraph in the format required for the 
    vertex cover based algorithms.
"""
function hypergraph_sortbycolor(EdgeList::Vector{Vector{Int64}},EdgeColors::Vector{Int64},n::Int64,returnperm::Bool=false)

    H = elist2incidence(EdgeList,n)
    p = sortperm(EdgeColors)
    srtd = H[p,:]
    EdgeList = incidence2elist(srtd)

    node2edges = incidence2elist(srtd,true)
    if returnperm
        return EdgeList, EdgeColors[p], node2edges, p
    else
        return EdgeList, EdgeColors[p], node2edges
    end
end

"""
Check to make sure the formatting of the hypergraph is as needed by the vertex cover algorithms.

d = degree vector
n2e = node id to edge id list
colors = color of each edge
"""
function check_vc_alg_formatting(Colors::Vector{Int64},n2e::Vector{Vector{Int64}},d::Vector{Int64})
    @assert(issorted(Colors))
    n = length(n2e)
    for k = 1:n
        lev = n2e[k]
        @assert(length(lev) == d[k])    
        colsk = Colors[lev]
        @assert(issorted(colsk))
    end

end


"""
Does not assume that the hyperedges are ordered by color.

This is faster if you just want to run the algorithm once. If you want to run it multiple times,
    it is faster to first re-order the entire hypergraph so that edges are arranged by color,
    then run multiple times on that nicer formatted input.
"""
function implicit_maximalmatch_vc_onetime(n2e::Vector{Vector{Int64}},colors::Vector{Int64},m::Int64)

    n = length(n2e)
    D = zeros(Bool,m) # indicator for deleted edges
    pm = randperm(n)
    deleted = 0
    for i = 1:n
        v = pm[i]
        Lev_unsrt = n2e[v]
        p = sortperm(colors[Lev_unsrt])
        Lev = Lev_unsrt[p]
        f = 1
        b = length(Lev)

        # Move past all bad edge pairs that are covered already
        while D[Lev[f]] && b > f
            f = f + 1
        end
        while D[Lev[b]] && b > f
            b = b - 1
        end

        while colors[Lev[f]] != colors[Lev[b]]
            # @assert(D[Lev[f]] == false)
            # @assert(D[Lev[b]] == false)
            D[Lev[f]] = true
            D[Lev[b]] = true
            deleted += 2
            while D[Lev[f]] && b > f
                f = f + 1
            end
            while D[Lev[b]] && b > f
                b = b - 1
            end
        end
    end

    return D, deleted
end

"""
Does not assume the hypergraph is set up so hyperedges are sorted by color

This is faster if you just want to run the algorithm once. If you want to run it multiple times,
    it is faster to first re-order the entire hypergraph so that edges are arranged by color,
    then run multiple times on that nicer formatted input.
"""
function implicit_pitt_vc_onetime(n2e::Vector{Vector{Int64}},colors::Vector{Int64},m::Int64)

    D = zeros(Bool,m) # indicator for deleted edges
    n = length(n2e)
    pm = randperm(n)
    deleted = 0
    for i = 1:n
        v = pm[i]
        Lev_unsrt = n2e[v]
        p = sortperm(colors[Lev_unsrt])
        Lev = Lev_unsrt[p]

        f = 1
        b = length(Lev)

        # Move past all bad edge pairs that are covered already
        while D[Lev[f]] && b > f
            f = f + 1
        end
        while D[Lev[b]] && b > f
            b = b - 1
        end

        while colors[Lev[f]] != colors[Lev[b]]
            @assert(D[Lev[f]] == false)
            @assert(D[Lev[b]] == false)
            rho = rand(1)[1]
            deleted += 1
            if rho < 1/2
                # delete the first/front edge
                D[Lev[f]] = true
                while D[Lev[f]] && b > f
                    f = f + 1
                end
            else
                # delete the back edge
                D[Lev[b]] = true
                while D[Lev[b]] && b > f
                    b = b - 1
                end
            end
        end
    end

    return D, deleted
end

"""
Does not assume that the hyperedges are ordered by color.

This is faster if you just want to run the algorithm once. If you want to run it multiple times,
    it is faster to first re-order the entire hypergraph so that edges are arranged by color,
    then run multiple times on that nicer formatted input.
"""
function hybrid_vc_majority(e2n::Vector{Vector{Int64}},n2e::Vector{Vector{Int64}},colors::Vector{Int64})
    
    k = length(unique(colors))
    n = length(n2e)
    m = length(e2n)

    start = time()
    maj_c = MajorityVote(e2n,colors,n,k)
    maj_run = time()-start

    start2 = time()
    D = zeros(Bool,m) # indicator for deleted edges
    pm = randperm(n)
    deleted = 0
    for i = 1:n
        v = pm[i]
        Lev_unsrt = n2e[v]
        p = sortperm(colors[Lev_unsrt])
        Lev = Lev_unsrt[p]
        f = 1
        b = length(Lev)

        # Move past all bad edge pairs that are covered already
        while D[Lev[f]] && b > f
            f = f + 1
        end
        while D[Lev[b]] && b > f
            b = b - 1
        end

        while colors[Lev[f]] != colors[Lev[b]]
            # @assert(D[Lev[f]] == false)
            # @assert(D[Lev[b]] == false)
            D[Lev[f]] = true
            D[Lev[b]] = true
            deleted += 2
            while D[Lev[f]] && b > f
                f = f + 1
            end
            while D[Lev[b]] && b > f
                b = b - 1
            end
        end
    end
    lb = round(Int64,deleted/2)
    match_c = EdgeDeletion2clustering(e2n,colors,D,n)
    match_run = time()-start2

    hyb_c = copy(match_c)
    for i = 1:n
        if match_c[i] > k
            hyb_c[i] = maj_c[i]
        end
    end
    return match_c, maj_c, hyb_c, lb, maj_run, match_run
end


function linear_objective(EdgeList::Union{Array{Int64,2},Vector{Vector{Int64}}},EdgeColors::Array{Int64,1},c::Vector)
        n = length(c); Mistakes = 0
        for i = 1:size(EdgeList,1)
            if size(EdgeList,2) == 2
                edge = EdgeList[i,:]
            else
                edge = EdgeList[i]
            end
            for v in edge
                if c[v] != EdgeColors[i]
                    Mistakes += 1
                end
            end
        end
        return Mistakes
    end