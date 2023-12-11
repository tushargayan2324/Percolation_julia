using Plots
#using Profile
#using ProfileView

mutable struct lat_site
    site_id::Int
    neighbours::Array{Int64,1}
    cluster_id::Int
end

function lattice_initialise(n, p)
    len = n*n
    lat = [lat_site(i,[],0) for i=1:len]

    for i=n+1:len # Giving top-bottom neighbours with some probability p
        if rand() < p
            push!(lat[i].neighbours,i-n)
            push!(lat[i-n].neighbours, i)
        end
    end   

    for i=1:len # Giving top neighbours with some probability p
        if i%n==0
            continue
        end
        if rand() < p
            push!(lat[i].neighbours,i+1)
            push!(lat[i+1].neighbours, i)
        end
    end   


    return lat
end

function difference_array(X,Y) #return array with ele in X but not in Y
    for i in X
        if !(i in Y)
            continue
        end
        deleteat!(X, X .== i);
    end
    return X
end

# difference_array([1,2,2,3,4,4,4], [3,4])

function union_array_assigned(X,Y) #NOT A UNION LIKE SET!!!
    n = size(X)[1]+size(Y)[1]
    M = zeros(Int, n)
    for i=1:size(X)[1]
        M[i] = X[i]        
    end
    for j=size(X)[1]+1:size(X)[1]+size(Y)[1]
        M[j] = Y[j-size(X)[1]]
    end
    return M
end

# union_array_assigned([1,2,3],[5,6,7])

function union_array_push(X,Y)
    for i in Y
        if i in X
        else
            push!(X,i)
        end
    end
    return X
end


function union_array_push_new(X,Y)
    for i in Y
        if !(i in X)
            push!(X,i)
        end
    end
    return X
end

# union_array_push_new([1,2,3],[2,4,5,6])


function del_element_first(arr, x)
    for i in arr
        if i!=x
            continue
        end
        deleteat!(arr, findfirst(==(i), arr))
    end

    return arr    
end

# del_element_first([1,2,3,4,4], 2)

# zeros(Int, 5,5)


# union_array_push([1,2,3], [2,4])

# @time union_array_1(zeros(10^5), ones(10^5))

# @time union_array_push(zeros(10^5), ones(10^5))


function mod_num(x,n)
    if x%n == 0
        return n
    else
        return x%n
    end
end


function y_coord(y,n)
    if y%n == 0
        return trunc(Int,y/n) - 1
    else
        return trunc(Int,y/n)
    end
end


function find_clusters_no_set_new(lat)
    arr_sites = Array{Int64}([i for i=1:(size(lat)[1])])
    cl_id = 0
    while length(arr_sites) != 0 
        cl_id += 1
                
        temp = arr_sites[1]
        cluster = [temp]

        lat[temp].cluster_id = cl_id #set cl_id of first element in cluster list

        neighbours_set = lat[temp].neighbours #Setting initial neighbours     
        track = size(neighbours_set)[1] #tracking the length of neighbours set using this variable
        
        while track!=0 #terminate loop when can't find any viable cluster

            temp_arr = deepcopy(neighbours_set)     # I dont like this line at all...this is scheisse
            neighbours_set = Vector{Int64}([])

            for obj in temp_arr
                if lat[obj].cluster_id == 0 
                    lat[obj].cluster_id = cl_id 
                    push!(neighbours_set, obj)
                end
            end            
            track = size(neighbours_set)[1]
            #sleep(0.01)
            #println(neighbours_set, track)

        end
        arr_sites = difference_array(arr_sites, cluster)
 
        #sleep(1)
        #println(arr_sites)
    end
    return lat
end
################################################################################



function find_clusters_new_algo(lat)  # ITS BESSER!!!!---- T-T ITS NOT WORKING
    arr_sites = Array{Int64}([i for i=1:(size(lat)[1])])
    cl_id = 0
    while length(arr_sites) != 0 
        cl_id += 1
                
        temp = arr_sites[1]
        arr_sites = del_element_first(arr_sites, temp)

        #cluster = [temp]
        
        lat[temp].cluster_id = cl_id #set cl_id of first element in cluster list

        neighbours_set = lat[temp].neighbours #Setting initial neighbours     
        track = size(neighbours_set)[1] #tracking the length of neighbours set using this variable
        

        while track!=0 #terminate loop when can't find any viable cluster

            temp_arr = deepcopy(neighbours_set)     # I dont like this line at all...this is scheisse
            neighbours_set = [] #next neighbour


            for obj in temp_arr
                if lat[obj].cluster_id == 0 
                    lat[obj].cluster_id = cl_id
                    neighbours_set = union_array_push_new(neighbours_set, lat[obj].neighbours)
                    #println(neighbours_set," ", track)
                end

                arr_sites = del_element_first(arr_sites,obj)
                #println(arr_sites)


                #push!(neighbours_set, obj)
                # println(obj)
                
            end            
            track = size(neighbours_set)[1]
            # sleep(0.1)
            # println(neighbours_set," ", track)
            #arr_sites = difference_array(arr_sites,neighbours_set)
        end
        
 
        #sleep(1)
        #println(arr_sites)
    end
    return lat
end
####################################################################################################
function find_clusters_new_algo_not_condi(lat)  # ITS BESSER!!!!---- T-T ITS NOT WORKING
    arr_sites = Array{Int64}([i for i=1:(size(lat)[1])])
    cl_id = 0
    while length(arr_sites) != 0 
        cl_id += 1
                
        temp = arr_sites[1]
        arr_sites = del_element_first(arr_sites, temp)

        #cluster = [temp]
        
        lat[temp].cluster_id = cl_id #set cl_id of first element in cluster list

        neighbours_set = lat[temp].neighbours #Setting initial neighbours     
        track = size(neighbours_set)[1] #tracking the length of neighbours set using this variable
        

        while track!=0 #terminate loop when can't find any viable cluster

            temp_arr = deepcopy(neighbours_set)     # I dont like this line at all...this is scheisse
            neighbours_set = [] #next neighbour


            for obj in temp_arr
                if lat[obj].cluster_id != 0
                    #continue
                else 
                    lat[obj].cluster_id = cl_id
                    neighbours_set = union_array_push_new(neighbours_set, lat[obj].neighbours)
                    #println(neighbours_set," ", track)
                end

                arr_sites = del_element_first(arr_sites,obj)
                #println(arr_sites)


                #push!(neighbours_set, obj)
                # println(obj)
                
            end            
            track = size(neighbours_set)[1]
            # sleep(0.1)
            # println(neighbours_set," ", track)
            #arr_sites = difference_array(arr_sites,neighbours_set)
        end
        
 
        #sleep(1)
        #println(arr_sites)
    end
    return lat
end
####################################################################################################

n = 400
g = lattice_initialise(n,0.5)

h = @time find_clusters_new_algo(g)

f = @time find_clusters_new_algo_not_condi(g)

my_plot(h)


@time find_clusters_no_set_new(g)

typeof([1,2,3,4])


neighbour_arr_temp = Array{Int64,1}[]

print()


typeof([1,2])

g[1].neighbours


neighbour_arr_temp = union_array_push_new(neighbour_arr_temp, g[1].neighbours)


my_plot(find_clusters_new_algo_not_condi(lattice_initialise(n,0.5)))

my_plot(find_clusters_new_algo(lattice_initialise(n,0.5)))













# print(g)

# @time find_clusters_no_set_new_new(g)

@time print(find_clusters_no_set_new_new(g) )

f = find_clusters_no_set_new_new(g)

my_plot(lattice_initialise(n,0.5))

println("#######################################################")

















@time find_clusters_no_set(g)

@time find_clusters_hehe(g)

#@time 

f = @time find_clusters_no_set(g)


function my_plot(f)
	plt = scatter(0,0);
	for obj in f
    	x1 = mod_num(obj.site_id,n)
    	y1 = 1+y_coord(obj.site_id,n)
    		plt = scatter!((x1,y1), c=:prism,marker_z=obj.cluster_id, markersize=10,legend=false)#,axis=([], false))
    	for nei in obj.neighbours
        	    xs = [x1,mod_num(nei,n)]
        	    ys = [y1,1+y_coord(nei,n)]
        	    plt = plot!(xs,ys,color=:black)
    	end
	end
    Plots.savefig("hehe.png")
	return plt
end


# function my_plot(f)
# 	plt = scatter(0,0);
# 	for obj in f
#     	x1 = mod_num(obj.site_id,n)
#     	y1 = 1+y_coord(obj.site_id,n)
#     		plt = scatter!((x1,y1), marker_z=obj.cluster_id, markersize=10,legend=false)#,axis=([], false))
#     	for nei in obj.neighbours
#         	    xs = [x1,mod_num(nei,n)]
#         	    ys = [y1,1+y_coord(nei,n)]
#         	    plt = plot!(xs,ys,color=:black)
#     	end
# 	end
# 	return plt
# end


function my_plot_no_line(f)
	plt = scatter(0,0);
	for obj in f
    	x1 = mod_num(obj.site_id,n)
    	y1 = 1+y_coord(obj.site_id,n)
    		plt = scatter!((x1,y1), marker_z=obj.cluster_id, markersize=10,legend=false)#,axis=([], false))
#    	for nei in obj.neighbours
#        	    xs = [x1,mod_num(nei,n)]
#        	    ys = [y1,1+y_coord(nei,n)]
#        	    plt = plot!(xs,ys,color=:black)
#    	end
	end
	#return plt
	Plots.savefig("hehe.png")
end


# xs = [1,2]
# ys = [2,2]


# plot!(xs,ys, color = :green)

# my_plot_no_line(f)
#my_plot(f)

#display(plot)
#Plots.savefig("hehe.png")

#print(f)
