include("initialisation_module.jl")
using .initialise_module
using StaticArrays

function find_clusters(lat)  #OG name - find_clusters_new_algo_not_condi_optim_static_all  
    arr_sites = Array{Int64}([i for i=1:(size(lat)[1])])
    cl_id = 0
    while length(arr_sites) != 0 
        cl_id += 1
                
        start_site = arr_sites[1]
        arr_sites = del_element_first(arr_sites, start_site)

        lat[start_site].cluster_id = cl_id #set cl_id of first element in cluster list
     
        
        track = size(lat[start_site].neighbours)[1] #tracking the length of neighbours set using this variable 
        
        #neighbour_arr = lat[start_site].neighbours #initial neighbours 

        neighbour_arr = SVector{track,Int64}(lat[start_site].neighbours)

        while track!=0 #terminate loop when can't find any viable next site for cluster

            neighbours_set = Int64[] #next neighbour

            for obj in neighbour_arr
                if lat[obj].cluster_id != 0
                else 
                    lat[obj].cluster_id = cl_id
                    neighbours_set = union_array_push(neighbours_set, lat[obj].neighbours)
                    #println(neighbours_set," ", track)
                end

                arr_sites = del_element_first(arr_sites,obj)
                #println(arr_sites)


                #push!(neighbours_set, obj)
                # println(obj)
                
            end            
            track = size(neighbours_set)[1]
            
            neighbour_arr = SVector{track,Int64}(neighbours_set)
            # neighbour_arr = neighbours_set
        end
        
     end
    return lat
end

n = 100

f = lattice_initialise(n,0.5);

h = @time find_clusters(f);

heatmap_plot(h)