## Read in the data using the CSV package
filename = homedir()*"/data/Trivago-raw/train.csv"

using CSV
cf = CSV.File(filename)

## read and save locations
Session2platform = Dict()
for row in cf
    #println("$(row.reference)\t $(row.action_type) \t $(row.platform) \t $(row.city)")
    if occursin("item",row.action_type) &&  row.reference != "unknown"
        # if this doesn't work, it's not a number and not a location we worry about
        try
            #@show row.reference
            sess = row.session_id
            plat = row.platform
            if haskey(Session2platform,sess)
                @assert(Session2platform[sess] == plat)
            end
            Session2platform[sess] = plat
        catch

        end
    end

end

## Save itemID to location
SessionID = collect(keys(Session2platform))

##

Platforms = Vector{String}()
for i= 1:length(SessionID)
    push!(Platforms,Session2platform[SessionID[i]])
end

matwrite("compact_raw_data/SessionID_to_Platforms.mat", Dict("SessionID"=>SessionID, "Platforms"=>Platforms))
