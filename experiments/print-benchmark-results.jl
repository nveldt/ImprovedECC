include("../src/vc-ecc-algs.jl")
include("../src/helpers.jl")


## Load a hypergraph
using MAT
using JLD
include("../include/CategoricalEdgeClustering-master/src/EdgeCatClusAlgs.jl")
include("../include/CategoricalEdgeClustering-master/src/lp_isocut.jl")
datasets = ["Brain","Cooking","DAWN", "MAG-10","Walmart-Trips"]


##

for i = 1:length(datasets)
ratdig = 2
rundig = 3
satdig = 2
    dataset = datasets[i]

    # Load the LP relaxation
    Mat = matread("Output/"*dataset*"_results.mat")
    LPval = Mat["LPval"]
    lprun = round(Mat["lp_run"],digits = rundig)
    lpratio = round(Mat["lp_ratio"],digits = ratdig+10)
    lpsat = round(Mat["lp_edgesat"],digits = satdig)

    # [maj_mistakes, maj_ratio, maj_edgesat, maj_run]
    Mat = matread("Output/$(dataset)_vc_results.mat")
    maj = Mat["maj_stats"]
    majrat = round(maj[2],digits = ratdig)
    majsat = round(maj[3],digits = satdig)
    majrun = round(maj[4],digits = rundig)

    pitt = mean(Mat["pitt_stats"],dims = 1)
    prat = round(pitt[2],digits = ratdig)
    psat = round(pitt[3],digits = satdig)
    prun = round(pitt[4],digits = rundig)

    match = mean(Mat["match_stats"],dims = 1)
    mrat = round(match[2],digits = ratdig)
    msat = round(match[3],digits = satdig)
    mrun = round(match[4],digits = rundig)

    pitt2 = mean(Mat["pitt_many_stats"],dims = 1)
    p2rat = round(pitt2[2],digits = ratdig)
    p2sat = round(pitt2[3],digits = satdig)
    p2run = round(pitt2[4],digits = rundig)

    match2 = mean(Mat["match_many_stats"],dims = 1)
    m2rat = round(match2[2],digits = ratdig)
    m2sat = round(match2[3],digits = satdig)
    m2run = round(match2[4],digits = rundig)

    ## Standard deviations
    pitt = StatsBase.std(Mat["pitt_stats"],dims = 1)
    prat_s = round(pitt[2],digits = ratdig)
    psat_s = round(pitt[3],digits = satdig)
    prun_s = round(pitt[4],digits = rundig)

    match = StatsBase.std(Mat["match_stats"],dims = 1)
    mrat_s = round(match[2],digits = ratdig)
    msat_s = round(match[3],digits = satdig)
    mrun_s = round(match[4],digits = rundig)

    pitt2 = StatsBase.std(Mat["pitt_many_stats"],dims = 1)
    p2rat_s = round(pitt2[2],digits = ratdig)
    p2sat_s = round(pitt2[3],digits = satdig)
    p2run_s = round(pitt2[4],digits = rundig)

    match2 = StatsBase.std(Mat["match_many_stats"],dims = 1)
    m2rat_s = round(match2[2],digits = ratdig)
    m2sat_s = round(match2[3],digits = satdig)
    m2run_s = round(match2[4],digits = rundig)
    
    ds = Mat["dataset_stats"]
    n = ds[1]
    M = ds[2]
    emax = ds[3]
    k = ds[4]
  
    # println(dataset*" & $n & $M & $emax & $k & $lprun & $majrun & $prun {\\small \$\\pm $prun_s\$} & $mrun {\\small \$\\pm $mrun_s\$}& $p2run {\\small \$\\pm $p2run_s\$}& $m2run {\\small \$\\pm $m2run_s\$} \\\\")
    # println("\\texttt{$dataset}  & $lpratio & $majrat & $prat {\\small \$\\pm $prat_s\$} & $mrat {\\small \$\\pm $mrat_s\$}& $p2rat {\\small \$\\pm $p2rat_s\$}& $m2rat {\\small \$\\pm $m2rat_s\$} \\\\")
    #println("\\texttt{$dataset}   & $lpsat & $majsat & $psat {\\small \$\\pm $psat_s\$} & $msat {\\small \$\\pm $msat_s\$}& $p2sat {\\small \$\\pm $p2sat_s\$}& $m2sat {\\small \$\\pm $m2sat_s\$}\\\\")
    println("\\texttt{$dataset}  &  $lprun & $majrun & $prun {\\small \$\\pm $prun_s\$} & $mrun {\\small \$\\pm $mrun_s\$}& $p2run {\\small \$\\pm $p2run_s\$}& $m2run {\\small \$\\pm $m2run_s\$} \\\\")

end


## Load the LP relaxation, check integrality

i = 5
ratdig = 2
rundig = 3
satdig = 2
dataset = datasets[i]

Mat = matread("Output/"*dataset*"_results.mat")

X = Mat["X"]
@show unique(X)