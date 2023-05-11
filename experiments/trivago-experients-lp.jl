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

## Solve the Chromatic Clustering Objective
start = time()
LPval, X, runtime = EdgeCatClusGeneral(EdgeList,EdgeColors,n,false,1)
lp_run = round(time()-start,digits=2)

# Round the clustering
C = rowmin(X)
lp_c = C[:,2]
lp_mistakes = EdgeCatClusObj(EdgeList,EdgeColors,lp_c)
lp_ratio = lp_mistakes/LPval
lp_edgesat = 1 - lp_mistakes/M
lp_acc = sum(lp_c .== NodeColors)/n
lp_stats = [lp_mistakes, lp_ratio, lp_edgesat, lp_run, lp_acc]

matwrite("Output/Trivago_LP.mat", Dict("lp_stats"=>lp_stats))