include("../src/vc-ecc-algs.jl")
include("../src/helpers.jl")


## Load a hypergraph
using MAT
using JLD
include("../include/CategoricalEdgeClustering-master/src/EdgeCatClusAlgs.jl")
include("../include/CategoricalEdgeClustering-master/src/lp_isocut.jl")
datasets = ["Brain","Cooking","DAWN", "MAG-10","Walmart-Trips"]



numruns = 50  # number of times to run a method

for i = 1:length(datasets)

    dataset = datasets[i]

    data = load("../include/CategoricalEdgeClustering-master/data/JLD_Files/"*dataset*".jld")
    EdgeColors = data["EdgeColors"]
    EdgeList = data["EdgeList"]
    n = data["n"]
    M = length(EdgeColors)
    msize = MaxHyperedgeSize(EdgeList)
    k = maximum(EdgeColors)
    println("Hypergraph: "*dataset*" has $M edges $n nodes, and $msize maximum order, $k colors")

    dataset_stats = [n,M,msize,k]

    # Hypergraph formatting
    H = elist2incidence(EdgeList,n)
    NodeList = incidence2elist(H,true)

    # Storing output for VC algorithms
    match_stats = zeros(numruns,5)
    pitt_stats = zeros(numruns,4)
    match_stats_many = zeros(numruns,5)
    pitt_stats_many = zeros(numruns,4)

    # Load the LP relaxation
    Mat = matread("Output/"*dataset*"_results.mat")
    LPval = Mat["LPval"]

    println("Running Majority")
    ## Majority vote
    start = time()
    maj_c = MajorityVote(EdgeList,EdgeColors,n,k)
    maj_run = time()-start
    maj_mistakes = EdgeCatClusObj(EdgeList,EdgeColors,maj_c)
    maj_ratio = maj_mistakes/LPval
    maj_edgesat = 1 - maj_mistakes/M
    maj_stats = [maj_mistakes, maj_ratio, maj_edgesat, maj_run]

    println("Running Match One Time Algorithm")

    for j = 1:numruns
        start = time()
        D, deleted = implicit_maximalmatch_vc_onetime(NodeList,EdgeColors,M)
        match_c = EdgeDeletion2clustering(EdgeList,EdgeColors,D,n)
        match_run = time()-start
        match_mistakes = EdgeCatClusObj(EdgeList,EdgeColors,match_c)
        match_ratio = match_mistakes/LPval
        match_edgesat = 1 - match_mistakes/M
        lb = round(Int64,deleted/2) # lower bound for the objective
        match_stats[j,:] = [match_mistakes, match_ratio, match_edgesat, match_run, lb]
    end

    println("Running Pitt One Time Algorithm")

    for j = 1:numruns
        start = time()
        D, deleted = implicit_pitt_vc_onetime(NodeList,EdgeColors,M)
        pitt_c = EdgeDeletion2clustering(EdgeList,EdgeColors,D,n)
        pitt_run = time()-start
        pitt_mistakes = EdgeCatClusObj(EdgeList,EdgeColors,pitt_c)
        pitt_ratio = pitt_mistakes/LPval
        pitt_edgesat = 1 - pitt_mistakes/M
        pitt_stats[j,:] = [pitt_mistakes, pitt_ratio, pitt_edgesat, pitt_run]
    end

    println("Running Pitt Many")
    numtimes = 100
    for j = 1:numruns
        start = time()
        pitt_c_many, deleted = pittcoloring(EdgeList,EdgeColors,n,numtimes)
        pitt_run_many = time()-start
        pitt_mistakes_many = EdgeCatClusObj(EdgeList,EdgeColors,pitt_c_many)
        pitt_ratio_many = pitt_mistakes_many/LPval
        pitt_edgesat_many = 1 - pitt_mistakes_many/M
        pitt_stats_many[j,:] = [pitt_mistakes_many, pitt_ratio_many, pitt_edgesat_many, pitt_run_many]
    end

    println("Running Match Many")
    for j = 1:numruns
        start = time()
        match_c_many, deleted, best_lb = matchvccoloring(EdgeList,EdgeColors,n,numtimes)
        match_run_many = time()-start
        match_mistakes_many = EdgeCatClusObj(EdgeList,EdgeColors,match_c_many)
        match_ratio_many = match_mistakes_many/LPval
        match_edgesat_many = 1 - match_mistakes_many/M
        match_stats_many[j,:] = [match_mistakes_many, match_ratio_many, match_edgesat_many, match_run_many, best_lb]
    end

    matwrite("Output/$(dataset)_vc_results.mat", Dict("maj_stats"=>maj_stats,
    "pitt_stats"=>pitt_stats, "match_stats"=>match_stats,"numtimes"=>numtimes,"numruns"=>numruns,
    "dataset_stats"=>dataset_stats,
    "pitt_many_stats"=>pitt_stats_many, "match_many_stats"=>match_stats_many))
end
