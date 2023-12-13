
## The naming convention used here is absolutely horrible. 
## That's because these were created in a succession of "upgrades" to the code
## Below listed are the ones that are important and works

function find_clusters_hehe(lat)
    arr_sites = Set{Int64}([i for i=1:(size(lat)[1])])#1:(size(t)[1]+size(t)[2])
    cl_id = 0
    while length(arr_sites) != 0 
        cl_id += 1
                
        temp = first(arr_sites)
        cluster = Set([temp])

        lat[temp].cluster_id = cl_id #set cl_id of first element in cluster list

        track = Set{Int64}([])    
        while length(cluster) != length(track)
            for obj in setdiff(cluster,track)
                cluster = union(cluster, lat[obj].neighbours)
                
                lat[obj].cluster_id = cl_id
                
                push!(track,obj) 
            end
        end
        arr_sites = setdiff(arr_sites, cluster)
 
        #sleep(1)
        #println(arr_sites)
    end
    return lat
end


#####################################################################################################################


function find_clusters_shit(lat)
    arr_sites = Set{Int64}([i for i=1:(size(lat)[1])])#1:(size(t)[1]+size(t)[2])
    cl_id = 0
    while length(arr_sites) != 0 
        cl_id += 1
                
        temp = first(arr_sites)
        cluster = Set([temp])

        lat[temp].cluster_id = cl_id #set cl_id of first element in cluster list

        track = Set{Int64}([])    
        while length(cluster) != length(track)
            diff_set = setdiff(cluster,track)
            for obj in diff_set
                cluster = union(cluster, lat[obj].neighbours)
                
                lat[obj].cluster_id = cl_id 
            end
            track = union(track, diff_set)
        end
        arr_sites = setdiff(arr_sites, cluster)
 
        #sleep(1)
        #println(arr_sites)
    end
    return lat
end

#####################################################################################################################

function find_clusters_new_algo_not_condi_optim_static(lat)  # Ok, good, nice!
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
            neighbour_arr = neighbours_set
            # sleep(0.1)
            # println(neighbours_set," ", track)
            #arr_sites = difference_array(arr_sites,neighbours_set)
        end
        
 
        #sleep(1)
        #println(arr_sites)
    end
    return lat
end
#####################################################################################################################


function find_clusters_new_algo_not_condi_optim_static_all(lat)  # Damn. Faster than previous, but more allocs
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
#####################################################################################################################

function find_clusters_trial(lat)  # My latest invention. Around 22 seconds at 500x500

    arr_sites = Array{Int64}([i for i=1:(size(lat)[1])])
    cl_id = 0

    while length(arr_sites) != 0 
        cl_id += 1
                
        start_site = arr_sites[1]

        arr_sites = deleteat!(arr_sites, findfirst(==(start_site), arr_sites))  # No need to use function del_element_first, as we know only one element exist
                                    ######REMOVE THE findfirst, we know its the FIRST ELEMENT!!

        lat[start_site].cluster_id = cl_id #set cl_id of first element in cluster list
     
        
        track = size(lat[start_site].neighbours)[1] #tracking the length of neighbours set using this variable 
        
        #neighbour_arr = lat[start_site].neighbours #initial neighbours 

        neighbour_arr = SVector{track,Int64}(lat[start_site].neighbours)

        while track!=0      #terminate loop when can't find any viable next site for cluster

            neighbours_set = Int64[] #next neighbour

            for obj in neighbour_arr
                if lat[obj].cluster_id != 0
                else 
                    lat[obj].cluster_id = cl_id
                    neighbours_set = union_array_push(neighbours_set, lat[obj].neighbours)
                    #println(neighbours_set," ", track)
                    
                end

                # if !(obj in arr_sites)
                # else
                #     arr_sites = deleteat!(arr_sites, findfirst(==(obj), arr_sites))
                # end

                if obj in arr_sites
                    arr_sites = deleteat!(arr_sites, findfirst(==(obj), arr_sites))
                end


                #println(arr_sites)
                
            end            
            track = size(neighbours_set)[1]

            # neighbour_arr = neighbours_set
            neighbour_arr = SVector{track,Int64}(neighbours_set)
            # sleep(0.1)
   
        end
        
 
        #sleep(1)
        #println(arr_sites)
    end
    return lat
end
#############################################################################################



#############################################################################################

function find_clusters_trial_test(lat)  # Best so far....1000x1000 in 78 seconds

    arr_sites = Array{Int64}([i for i=1:(size(lat)[1])])
    cl_id = 0

    while length(arr_sites) != 0 
        cl_id += 1
                
        start_site = arr_sites[1]

        arr_sites = deleteat!(arr_sites, 1)

        lat[start_site].cluster_id = cl_id #set cl_id of first element in cluster list
        
        track = size(lat[start_site].neighbours)[1] #tracking the length of neighbours set using this variable 
        
        neighbour_arr = SVector{track,Int64}(lat[start_site].neighbours)

        while track!=0      #terminate loop when can't find any viable next site for cluster

            neighbours_set = Int64[] #next neighbour

            for obj in neighbour_arr
                lat[obj].cluster_id = cl_id

                for nnn in lat[obj].neighbours
                    
                    if lat[nnn].cluster_id == 0  #!(nnn in neighbours_set)
                        # lat[obj].cluster_id = cl_id
                        if !(nnn in neighbours_set)
                            push!(neighbours_set, nnn)
                        end
                    end
                end

                #arr_sites = deleteat!(arr_sites, findfirst(==(obj), arr_sites))
                if obj in arr_sites
                    arr_sites = deleteat!(arr_sites, findfirst(==(obj), arr_sites))
                end

                #sleep(0.5)
                #println(arr_sites)
                
            end            
            track = size(neighbours_set)[1]

            # neighbour_arr = neighbours_set
            neighbour_arr = SVector{track,Int64}(neighbours_set)
   
        end

    end
    return lat
end
#############################################################################################
