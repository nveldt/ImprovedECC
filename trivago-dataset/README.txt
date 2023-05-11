README

-------------
Original data
-------------

The original Trivago data from which the edge-colored Trivago hypergraph was constructed was obtained at https://recsys.acm.org/recsys19/challenge/.

This data was given in the form of the following CSV files:

item_metadata.csv
submission_popular.csv
test.csv
train.csv

To run the Julia files for generating the hypergraph, these CSV files need to be downloaded and stored in a directory "/data/Trivago-raw/" (or store them elsewhere and update the path in the .jl files).

--------------------------------
Compact storage of original data
--------------------------------

ClickoutData.mat stores a compact subset of the data from train.csv, more specifically, data from the session_id column and the reference column. ClickOutData only includes rows where the action was a “clickout”.

SessionID_to_Platforms.mat and ItemID_to_Location.mat need to be generated before the hypergraph can be constructed. This is done in session_to_locationplatform.jl and read_location_data.jl.

SessionID_to_Platforms.mat stores the platform label (e.g., "AU" for Australia), which means the location platform from which the session happened. This is what provides location metadata (i.e., colors) for the hyperedges.


--------------------------------
Conversion to a hypergraph
--------------------------------

Details for converting to an initial hypergraph with edge labels and node labels and storing it in .mat format are contained in clickout_edgecolored_hypergraph.jl
