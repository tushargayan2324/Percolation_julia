using Plots
using Profile
using ProfileView

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

function find_clusters_new(lat)
    arr_sites = Set([i for i=1:(size(lat)[1])])#1:(size(t)[1]+size(t)[2])
    cl_id = 0
    while length(arr_sites) != 0 
        cluster = Set([first(arr_sites)])
        track = Set{Int64}([])    
        while length(cluster) != length(track)
            for obj in setdiff(cluster,track)
                cluster = union(cluster, lat[obj].neighbours)
                push!(track,obj) 
            end
        end
        arr_sites = setdiff(arr_sites, cluster)
 
        cl_id += 1
        for i in cluster    
            lat[i].cluster_id = cl_id
        end
        #sleep(1)
        #println(arr_sites)
    end
    return lat
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

function find_clusters_threaded(lat)
    arr_sites = Set{Int64}([i for i=1:(size(lat)[1])])#1:(size(t)[1]+size(t)[2])
    cl_id = 0
    while length(arr_sites) != 0 
        cl_id += 1
                
        temp = first(arr_sites)
        cluster = Set([temp])

        lat[temp].cluster_id = cl_id #set cl_id of first element in cluster list

        track = Set{Int64}([])    
        while length(cluster) != length(track)
            Threads.@threads for obj in setdiff(cluster,track)
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


n = 250

Profile.Allocs.clear()
#f = assign_cluster_id_new(lattice_initialise(n,0.4))
f = @time @profile find_clusters_new(lattice_initialise(n,0.5))

# Profile.print()

g = lattice_initialise(n,0.5)

@time find_clusters_new(g)

@time find_clusters_hehe(g)


ProfileView.@profview find_clusters_new(g)

# @time Profile.Allocs.@profile sample_rate=1 lattice_initialise(n,0.5)

# using PProf

# PProf.Allocs.pprof(from_c = false)

# @pprof lattice_initialise(n,0.5)

# show(err)



Threads.nthreads()

n = 250
@time find_clusters_hehe(lattice_initialise(n,0.5))
@time find_clusters_threaded(lattice_initialise(n,0.5))

println(f)


scatter(0,0);
for obj in f
    x1 = mod_num(obj.site_id,n)
    y1 = 1+y_coord(obj.site_id,n)
    scatter!((x1,y1), marker_z=obj.cluster_id, markersize=10,legend=false)#,axis=([], false))
    for nei in obj.neighbours
            xs = [x1,mod_num(nei,n)]
            ys = [y1,1+y_coord(nei,n)]
            plot!(xs,ys,color=:black)
    end
end

# xs = [1,2]
# ys = [2,2]


# plot!(xs,ys, color = :green)




#display(plot)
Plots.savefig("hehe.png")


p = @time find_clusters_new(f)
print(p)