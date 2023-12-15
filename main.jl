include("initialisation_module.jl")
using .initialise_module
using StaticArrays

function find_clusters(lat) #latest algo from perc_algo_compare.jl

    arr_sites = Array{Int64}([i for i=1:(size(lat)[1])])
    cl_id = 0

    while length(arr_sites) != 0 
        cl_id += 1
                
        start_site = arr_sites[1]

        deleteat!(arr_sites, 1) 

        lat[start_site].cluster_id = cl_id #set cl_id of first element in cluster list
        
        track = size(lat[start_site].neighbours)[1] #tracking the length of neighbours set using this variable 
        
        neighbour_arr = SVector{track,Int64}(lat[start_site].neighbours)

        while track!=0      #terminate loop when can't find any viable next site for cluster

            neighbours_set = zeros(Int64, 2*size(neighbour_arr)[1]+4)

            iter_track::Int64 = 0

            for obj in neighbour_arr
                lat[obj].cluster_id = cl_id

                
                for nnn in lat[obj].neighbours
                    
                    if lat[nnn].cluster_id == 0 && !(nnn in neighbours_set)
                            iter_track += 1

                            neighbours_set[iter_track] = nnn
                    end
                end

                deleteat!(arr_sites, findfirst(==(obj), arr_sites))                
            end            
            

            deleteat!(neighbours_set, neighbours_set.==0)

            track = size(neighbours_set)[1]

            neighbour_arr = SVector{track,Int64}(neighbours_set)
   
        end

    end
    return lat
end

n = 100

f = lattice_initialise(n,0.5);

h = @time find_clusters(f);

heatmap_plot(h)
