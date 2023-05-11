using MAT

## Load in the hypergraph data
mat = matread("compact_raw_data/ClickoutData.mat")
sessions = mat["session"]
items = parse.(Int64,mat["ref"])


## Load in the session platform locations
mat = matread("compact_raw_data/SessionID_to_platforms.mat")
SessionID = mat["SessionID"]
Platforms = mat["Platforms"]

## Load in the location data
matl = matread("compact_raw_data/ItemID_to_Location.mat")
Locations = matl["Locations"]
items_loc = matl["ItemID"]
OldID2Location = Dict()         # map from original item ID to location
for i = 1:length(Locations)
    OldID2Location[items_loc[i]] = Locations[i]
end


## Extract the sessions and give them unique integer identifiers
SessionNames = SessionID
Sess_Name2id = Dict()
Sess_Name2loc = Dict()
for i = 1:length(SessionNames)
    Sess_Name2id[SessionNames[i]] = i
    Sess_Name2loc[SessionNames[i]] = Platforms[i]
end

## Get unique set of items/accommodations
ItemNames = unique(items)


## Create the map from item names to item ids (item = accomodation = node)
# The item name is just the id from the original dataset
Item_Name2id = Dict()
for i = 1:length(ItemNames)
    Item_Name2id[ItemNames[i]] = i
end

## Get locations when possible (it's always possible)
times = 0
Locations = Vector{String}()  # map from new item ID to location
for i = 1:length(ItemNames)
    global times
    if haskey(OldID2Location,ItemNames[i])
        loca = OldID2Location[ItemNames[i]]
    else
        loca = ""
        times += 1
    end
    push!(Locations,loca)
end
@show times

## Form the hypergraph
I = Vector{Int64}()     # Items are nodes
S = Vector{Int64}()     # Sessions are hyperedges

empty = 0
for i = 1:length(sessions)
    global empty
    sess_name = sessions[i]
    item_name = items[i]
    sess_location = Sess_Name2loc[sess_name]

    if haskey(Item_Name2id,item_name)
        sess_id = Sess_Name2id[sess_name]
        item_id = Item_Name2id[item_name]
        push!(I,item_id)
        push!(S,sess_id)
    else
        empty += 1
    end
end

## Construct an edge-labeled hypergraph from this
using SparseArrays

m = length(SessionNames)
n = length(ItemNames)
H = sparse(S,I,ones(length(S)),m,n)

## Don't double count if the same item was viewed multiple times in the same session
I,S,vals = findnz(H)

H = sparse(I,S,ones(length(S)),m,n)
@show maximum(H)

## location check: none of these are empty locations
for i = 1:length(Locations)
    @assert(length(Locations[i])>0)
end

## Renaming
EdgeNames = SessionNames
EdgeLabels = Platforms
NodeNames = ItemNames
NodeLabels = Locations

## Get just the country labels for the nodes
n = size(H,2)
Nlab = Vector{String}()
for i = 1:n
    ln = strip.(split(NodeLabels[i],","))
    push!(Nlab,ln[2])
end

## Load in the map from country code to country name
fl = readlines("platform-to-country.txt")
code2country = Dict()
code_countries = Vector{String}()
codes = Vector{String}()
for i = 2:length(fl)
    ln = strip.(split(fl[i],","))
    code2country[ln[1]] = ln[2]
    push!(codes,ln[1])
    push!(code_countries,ln[2])
end

## Change edge labels to full country names
Elab = Vector{String}()
for i = 1:length(EdgeLabels)
    push!(Elab,code2country[EdgeLabels[i]])
end

## No go through and remove all nodes that are not in this set of countries
keep = Vector{Int64}()
for i = 1:n
    if in(Nlab[i],code_countries)
        push!(keep,i)
    end
end
H = H[:,keep]
NodeCountries = Nlab[keep]
EdgeCountries = Elab
@assert(sort(unique(NodeCountries)) == sort(unique(EdgeCountries)))

## Get rid of any hyperedges of size 0 or 1
order = round.(Int64,vec(sum(H,dims=2)))
e = findall(x->x>1,order)
H = H[e,:]
EdgeCountries = EdgeCountries[e]

## Get rid of zero-degree nodes
d = round.(Int64,vec(sum(H,dims=1)))
keep = findall(x->x>0,d)
H = H[:,keep]
NodeCountries = NodeCountries[keep]

## Go from country name to unique integer id

Countries = sort(unique(NodeCountries))
country2id = Dict()
for i = 1:length(Countries)
    country2id[Countries[i]] = i
end

m,n = size(H)
@assert(m == length(EdgeCountries))
@assert(n == length(NodeCountries))

NodeLabels = zeros(Int64,n)
EdgeLabels = zeros(Int64,m)

for i = 1:n
    NodeLabels[i] = country2id[NodeCountries[i]]
end
for i = 1:m
    EdgeLabels[i] = country2id[EdgeCountries[i]]
end

## Now save
matwrite("Trivago_Clickout_EdgeLabels.mat",Dict("H"=>H, "EdgeLabels"=>EdgeLabels,"NodeLabels"=>NodeLabels,"LabelNames"=>Countries))


