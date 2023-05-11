using MAT
include("../include/CategoricalEdgeClustering-master/src/EdgeCatClusAlgs.jl")
include("../src/vc-ecc-algs.jl")
include("../src/helpers.jl")


mat = matread("../trivago-dataset/Trivago_Clickout_EdgeLabels.mat")
EdgeColors = mat["EdgeLabels"]
NodeColors = mat["NodeLabels"]
H = mat["H"]
LabelNames = mat["LabelNames"]
m,n = size(H)
M = length(EdgeColors)
EdgeList = incidence2elist(H)
r = MaxHyperedgeSize(EdgeList)
k = maximum(EdgeColors)
println("Trivago has $M edges $n nodes, and $r maximum order, $k colors")


## Hypergraph formatting
H = elist2incidence(EdgeList,n)
NodeList = incidence2elist(H,true)

# Storing output for VC algorithms
match_stats = zeros(numruns,6)
hyb_stats = zeros(numruns,6)
maj_stats = zeros(numruns,6)
pitt_stats = zeros(numruns,5)

## Hybrid, and individual
c = NodeColors
match_c, maj_c, hyb_c, lb, maj_run, match_run = hybrid_vc_majority(EdgeList,NodeList,EdgeColors)
truth_mistakes = EdgeCatClusObj(EdgeList,EdgeColors,c)
truth_ratio = truth_mistakes/lb
truth_acc = sum(c .== NodeColors)/n
truth_edgesat = 1 - truth_mistakes/M
truth_stats = [truth_mistakes, truth_acc, truth_edgesat]

##
println("Running combinatorial methods")
numruns = 50
for j = 1:numruns

    start = time()
    match_c, maj_c, hyb_c, lb, maj_run, match_run = hybrid_vc_majority(EdgeList,NodeList,EdgeColors)
    hyb_run = time()-start
    hyb_mistakes = EdgeCatClusObj(EdgeList,EdgeColors,hyb_c)
    hyb_ratio = hyb_mistakes/lb
    hyb_acc = sum(hyb_c .== NodeColors)/n
    hyb_edgesat = 1 - hyb_mistakes/M
    hyb_stats[j,:] = [hyb_mistakes, hyb_ratio, hyb_acc, hyb_edgesat, hyb_run,lb]

    maj_mistakes = EdgeCatClusObj(EdgeList,EdgeColors,maj_c)
    maj_linear = linear_objective(EdgeList,EdgeColors,maj_c)
    @assert(maj_mistakes <= maj_linear)
    maj_lb = maj_linear/r
    maj_ratio = maj_mistakes/maj_lb
    maj_acc = sum(maj_c .== NodeColors)/n
    maj_edgesat = 1 - maj_mistakes/M
    maj_stats[j,:] = [maj_mistakes, maj_ratio, maj_acc, maj_edgesat, maj_run,maj_lb]

    match_mistakes = EdgeCatClusObj(EdgeList,EdgeColors,match_c)
    match_ratio = match_mistakes/lb
    match_acc = sum(match_c .== NodeColors)/n
    match_edgesat = 1 - match_mistakes/M
    match_stats[j,:] = [match_mistakes, match_ratio, match_acc, match_edgesat, match_run,lb]

    start = time()
    D, deleted = implicit_pitt_vc_onetime(NodeList,EdgeColors,M)
    pitt_c = EdgeDeletion2clustering(EdgeList,EdgeColors,D,n)
    pitt_run = time()-start
    pitt_mistakes = EdgeCatClusObj(EdgeList,EdgeColors,pitt_c)
    pitt_edgesat = 1 - pitt_mistakes/M
    pitt_acc = sum(pitt_c .== NodeColors)/n
    pitt_stats[j,:] = [pitt_mistakes, 2, pitt_acc, pitt_edgesat, pitt_run]

    # println("$j \t $match_acc \t $maj_acc \t $hyb_acc")
    t = 1
    match_val = match_stats[j,t]
    maj_val = maj_stats[j,t]
    hyb_val = hyb_stats[j,t]
    println("$j \t $match_val \t $maj_val \t $hyb_val")
end

##
matwrite("Output/Trivago_comb_results.mat", Dict("maj_stats"=>maj_stats,
"hyb_stats"=>hyb_stats, "match_stats"=>match_stats,"numruns"=>numruns,"truth_stats"=>truth_stats,"pitt_stats"=>pitt_stats))

