using MAT
using StatsBase

# [match_mistakes, match_ratio, match_acc, match_edgesat, match_run,lb]
ratdig = 2
accdig = 2
satdig = 2
rundig = 2
Mat = matread("Output/Trivago_comb_results.mat")
maj = mean(Mat["maj_stats"],dims = 1)
majmis = round(maj[1],digits = 0)
majrat = round(maj[2],digits = ratdig)
majacc = round(maj[3],digits = accdig)
majsat = round(maj[4],digits = satdig)
majrun = round(maj[5],digits = rundig)

pitt = mean(Mat["pitt_stats"],dims = 1)
pittmis = round(pitt[1],digits = 0)
pittacc = round(pitt[3],digits = accdig)
pittsat = round(pitt[4],digits = satdig)
pittrun = round(pitt[5],digits = rundig)

match = mean(Mat["match_stats"],dims = 1)
matchmis = round(match[1],digits = 0)
matchrat = round(match[2],digits = ratdig)
matchacc = round(match[3],digits = accdig)
matchsat = round(match[4],digits = satdig)
matchrun = round(match[5],digits = rundig)

hyb = mean(Mat["hyb_stats"],dims = 1)
hybmis = round(hyb[1],digits = 0)
hybrat = round(hyb[2],digits = ratdig)
hybacc = round(hyb[3],digits = accdig)
hybsat = round(hyb[4],digits = satdig)
hybrun = round(hyb[5],digits = rundig)

# standard deviation

maj = StatsBase.std(Mat["maj_stats"],dims = 1)
majrats = round(maj[2],digits = ratdig)
majaccs = round(maj[3],digits = accdig)
majsats = round(maj[4],digits = satdig)
majruns = round(maj[5],digits = rundig)

match = StatsBase.std(Mat["match_stats"],dims = 1)
matchrats = round(match[2],digits = ratdig)
matchaccs = round(match[3],digits = accdig)
matchsats = round(match[4],digits = satdig)
matchruns = round(match[5],digits = rundig)

hyb = StatsBase.std(Mat["hyb_stats"],dims = 1)
hybrats = round(hyb[2],digits = ratdig)
hybaccs = round(hyb[3],digits = accdig)
hybsats = round(hyb[4],digits = satdig)
hybruns = round(hyb[5],digits = rundig)

## print
println("\\textsf{PittColoring} & $pittmis & $pittsat  & \$2^*\$  & $pittacc  & $pittrun  \\\\")
println("\\textsf{MatchColoring} & $matchmis & $matchsat  & $matchrat  & $matchacc  & $matchrun  \\\\")
println("\\textsf{MajorityVote} & $majmis & $majsat  & $majrat  & $majacc  & $majrun  \\\\")
println("\\textsf{Hybrid} & $hybmis & $hybsat  & $hybrat  & $hybacc  & $hybrun  \\\\")

# println("MatchCol. & $matchsat {\\small \$\\pm $matchsats\$} & $matchrat {\\small \$\\pm $matchrats\$} & $matchacc {\\small \$\\pm $matchaccs\$} & $matchrun {\\small \$\\pm $matchruns\$} \\\\")