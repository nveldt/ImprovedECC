## Read in the data using the CSV package
filename = homedir()*"/data/Trivago-raw/train.csv"

using CSV
cf = CSV.File(filename)

## read and save locations
Item2Location = Dict()
for row in cf
    #println("$(row.reference)\t $(row.action_type) \t $(row.platform) \t $(row.city)")
    if occursin("item",row.action_type) &&  row.reference != "unknown"
        # if this doesn't work, it's not a number and not a location we worry about
        try
            #@show row.reference
            item = parse(Int64,row.reference)
            location = row.city
            #println("$item \t $location")
            Item2Location[item] = location
        catch

        end
    end

end
## Save itemID to location
ItemID = collect(keys(Item2Location))

Locations = Vector{String}()
for i= 1:length(ItemID)
    push!(Locations,Item2Location[ItemID[i]])
end

matwrite("compact_raw_data/ItemID_to_Location.mat", Dict("ItemID"=>ItemID, "Locations"=>Locations))
