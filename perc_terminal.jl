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
        if i in Y
            deleteat!(X, X .== i);
        end
    end
    return X
end

# difference_array([1,2,2,3,4,4,4], [3,4])

function union_array_assigned(X,Y)
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

function union_array_push(X,Y)
    for i in Y
        if i in X
        else
            push!(X,i)
        end
    end
    return X
end

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


function find_clusters_no_set(lat)
    arr_sites = Array{Int64}([i for i=1:(size(lat)[1])])
    cl_id = 0
    while length(arr_sites) != 0 
        cl_id += 1
                
        temp = arr_sites[1]
        cluster = [temp]

        lat[temp].cluster_id = cl_id #set cl_id of first element in cluster list

        track = Array{Int64}([])    
        while length(cluster) != length(track)
            diff_set = difference_array(cluster,track) #difference set
            for obj in diff_set
                cluster = union_array_push(cluster, lat[obj].neighbours)
                
                # cluster = union(cluster, lat[obj].neighbours)
                
                lat[obj].cluster_id = cl_id 
            end
            track = union_array_push(track, diff_set)
        end
        arr_sites = difference_array(arr_sites, cluster)
 
        #sleep(1)
        #println(arr_sites)
    end
    return lat
end


n = 800
g = @time lattice_initialise(n,0.5)

@time find_clusters_shit(g)
#@time 
f = @time find_clusters_no_set(g)

function my_plot(f)
	plt = scatter(0,0);
	for obj in f
    	x1 = mod_num(obj.site_id,n)
    	y1 = 1+y_coord(obj.site_id,n)
    		plt = scatter!((x1,y1), marker_z=obj.cluster_id, markersize=10,legend=false)#,axis=([], false))
    	for nei in obj.neighbours
        	    xs = [x1,mod_num(nei,n)]
        	    ys = [y1,1+y_coord(nei,n)]
        	    plt = plot!(xs,ys,color=:black)
    	end
	end
	return plt
end


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
