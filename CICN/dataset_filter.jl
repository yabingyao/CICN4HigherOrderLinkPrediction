using SparseArrays
using LightGraphs
using Statistics
include("read_undir_txt.jl")
include("HigherOrderClustering.jl")

function calculate_adcc(matrix)
    graph = Graph(matrix)
    average_degree = mean(degree(graph))
    global_clustering_coefficients = global_clustering_coefficient(graph)
    return average_degree, global_clustering_coefficients
end

function ccfs(node::Int64, order::Int64, matrix, ccfs2, ccfs3, ccfs4, ccfs5)
    if order == 3
        return ccfs3[node]
    elseif order == 4
        return ccfs4[node]
    elseif order == 5
        return ccfs5[node]
    elseif order == 23
        return 1 - (1 - ccfs2[node]) * (1 - ccfs3[node])
    else
        return 1 - (1 - ccfs2[node]) * (1 - ccfs3[node]) * (1 - ccfs4[node])
    end
end

function main()
    target = "data"
    path = "../datasets/$target/"
    jobs = readdir(path)
    res_adcc = "../result/resADCC.csv"
    use_indicator = "datasets,ad,CC,C3,C4,C5"
    open(res_adcc, "a") do f
        write(f, use_indicator)
        write(f, '\n')
    end
    for i in jobs
    #try
        println(i)
        file_path = joinpath(path, i)
        data = load_example_data(file_path)
        g = SimpleGraph(data)
        println(nv(g))
        println(ne(g))
        # all_cliques = cliques(g)
        # cliques_3 = filter(c -> length(c) == 3, all_cliques)
        # cliques_4 = filter(c -> length(c) == 4, all_cliques)
        # num_cliques_3 = length(cliques_3)
        # num_cliques_4 = length(cliques_4)
        # println("Number of 3-cliques: ", num_cliques_3)
        # println("Number of 4-cliques: ", num_cliques_4)
        #D = density(g)
        #println(D)
        # matrix = adjacency_matrix(g)
        # c, d = calculate_adcc(matrix)
        # nodes_list = collect(vertices(g))
        # cc3 = 0
        # cc4 = 0
        # cc5 = 0
        # # Pre-calculate the values of ccfs2, ccfs3, ccfs4 and ccfs5 and pass them as arguments to the ccfs function.
        # sp_matrix = sparse(matrix)
        # ccfs2 = clustercoeffs(sp_matrix)
        # ccfs3all = higher_order_ccfs(sp_matrix, 3)
        # ccfs3 = ccfs3all.local_hoccfs
        # ccfs4all = higher_order_ccfs(sp_matrix, 4)
        # ccfs4 = ccfs4all.local_hoccfs
        # ccfs5all = higher_order_ccfs(sp_matrix, 5)
        # ccfs5 = ccfs5all.local_hoccfs
        # for node in nodes_list
        #     cc3 += ccfs(node, 3, matrix, ccfs2, ccfs3, ccfs4, ccfs5)
        #     cc4 += ccfs(node, 4, matrix, ccfs2, ccfs3, ccfs4, ccfs5)
        #     cc5 += ccfs(node, 5, matrix, ccfs2, ccfs3, ccfs4, ccfs5)
        # end
        # c3 = cc3 / nv(g)
        # c4 = cc4 / nv(g)
        # c5 = cc5 / nv(g)
        # open(res_adcc,"a") do f
        #     write(f,i)
        #     write(f,',')
        #     write(f,string(c))
        #     write(f,',')
        #     write(f,string(d))
        #     write(f,',')
        #     write(f,string(c3))
        #     write(f,',')
        #     write(f,string(c4))
        #     write(f,',')
        #     write(f,string(c5))
        #     write(f,'\n')
        # end
        # rm(file_path)
    #catch ex
        println("------<<这个网络不能计算>>")
    #end
    end
end
t1 = time()
main()
t2 = time()
println("time:", t2 - t1)
