using Plots
using Profile

mutable struct lat_site
    site_id::Int
    # Position::Tuple{Int,Int}
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

# f = lattice_initialise(4,0.9)

# f[1]


function assign_cluster_id(lat) #Naive approach first, iterate over all the elements, O(n^2) time complexity
    cl_id = 0
    for i=1:size(lat)[1]
        # print(0)
        if size(lat[i].neighbours) == 0
            cl_id = cl_id + 1
            lat[i].cluster_id = cl_id
            continue
        end

        tp=0 #if all the neighbours have unassigned cluster_id
        for j in lat[i].neighbours
            tp+= lat[j].cluster_id
            if  lat[j].cluster_id != 0
                for k in lat[i].neighbours
                    lat[k].cluster_id = lat[j].cluster_id
                end
                # continue
            end
        end
        if tp==0
            cl_id += 1
            for j in lat[i].neighbours
                lat[j].cluster_id = cl_id
            end  
            lat[i].cluster_id = cl_id
            continue
        end        


    end

    return lat
end

function assign_cluster_id_new(lat) #Naive approach first, iterate over all the elements, O(n^2) time complexity
    cl_id = 0
    for i=1:size(lat)[1]
        # print(0)
        if size(lat[i].neighbours) == 0
            cl_id = cl_id + 1
            lat[i].cluster_id = cl_id
            continue
        end

        tp=0 #if all the neighbours have unassigned cluster_id
        for j in lat[i].neighbours
            tp+= lat[j].cluster_id
            if  lat[j].cluster_id != 0
                for k in lat[i].neighbours
                    lat[k].cluster_id = lat[j].cluster_id
                end
                break
            end
        end
        if tp==0
            cl_id += 1
            for j in lat[i].neighbours
                lat[j].cluster_id = cl_id
            end  
            lat[i].cluster_id = cl_id
            continue
        end        


    end

    return lat
end

# n = 5
# f = assign_cluster_id_new(lattice_initialise(n,0.5))

# println(f)



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

function find_clusters(lat)
    arr_sites = Set([i for i=1:(size(lat)[1])])#1:(size(t)[1]+size(t)[2])
    for i in arr_sites
        cluster = Set([i])
        track = Set([])    
        while length(cluster) != length(track)
            for obj in setdiff(cluster,track)
                cluster = union(cluster, lat[obj].neighbours)
                push!(track,obj) 
            end
        end
        # for assigned in cluster
        #     println(assigned)
        #     arr_sites = deleteat!(arr_sites, assigned)
        # end
        arr_sites = setdiff(arr_sites, cluster)
        # return cluster, arr_sites, track
        for i in cluster
            cl_id += 1
            lat[i].cluster_id = cl_id
        end
    end
    return lat#arr_sites, cluster, track
end


function find_clusters_new(lat)
    arr_sites = Set([i for i=1:(size(lat)[1])])#1:(size(t)[1]+size(t)[2])
    #for i in arr_sites
    cl_id = 0
    while length(arr_sites) != 0 
        cluster = Set([first(arr_sites)])
        track = Set([])    
        while length(cluster) != length(track)
            for obj in setdiff(cluster,track)
                cluster = union(cluster, lat[obj].neighbours)
                push!(track,obj) 
            end
        end
        # for assigned in cluster
        #     println(assigned)
        #     arr_sites = deleteat!(arr_sites, assigned)
        # end
        arr_sites = setdiff(arr_sites, cluster)
        # return cluster, arr_sites, track
        cl_id += 1
        for i in cluster    
            lat[i].cluster_id = cl_id
        end
        #sleep(1)
        #println(arr_sites)
    end
    return lat#arr_sites, cluster, track
end

f = lattice_initialise(4,0.5)
print(f)
p = find_clusters_new(f)


t = Set([1,2,3])
s = [4,2]

for i in t
    print(i, typeof(i))
end

p = setdiff(t,s)

print(setdiff(Set(t),Set(s)))

for i in t
    print(t)
    t = setdiff(t, 3)
    print(t)
end




n = 200
#f = assign_cluster_id_new(lattice_initialise(n,0.4))
f = @time @profile find_clusters_new(lattice_initialise(n,0.5))

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