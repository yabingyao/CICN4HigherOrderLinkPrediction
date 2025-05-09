using SparseArrays
using Combinatorics
using LightGraphs
include("../class/Conv.jl")

function PLP_HOCI(convey_dict::Convey_class)
    train = convey_dict.train
    h = convey_dict.h
    nodes_list = convey_dict.nodes_list_h
    edges_list = convey_dict.edges_list_h
    adjacent_matrix = convey_dict.train_matrix
    A = MatrixNetwork(adjacent_matrix)
    train_all_triangles = find_triangles_2(A)
    train_triangles_total = Int(length(train_all_triangles)/3)
    N = nv(h)
    M = ne(h)
    Probability_node_edge = train_triangles_total/((M*(N-2))/3)
    information_entropy_node_edge = -log2(Probability_node_edge)

    Edge_neighbors = Dict()
    for seed_edge in edges_list
        edge_node1_neighbors = neighbors(h, seed_edge[1])
        edge_node2_neighbors = neighbors(h, seed_edge[2])
        Edge_neighbors[Tuple(seed_edge)] = vcat(edge_node1_neighbors,edge_node2_neighbors)
    end

    node_edge_cn = Dict()
    cn_nodes = []
    for node_edge in train
        node = node_edge[1][1]
        edge = node_edge[2]
        node_neighbors = neighbors(h,node)
        edge_neighbors = Edge_neighbors[Tuple(edge)]
        node_edge_cn[Tuple([[node],edge])] = intersect(node_neighbors,edge_neighbors)
        push!(cn_nodes,intersect(node_neighbors,edge_neighbors))
    end

    elements = [x for sublist in cn_nodes for x in sublist]
    non_null_elements = unique(elements)

    cn_ccfs = Dict()
    for node in non_null_elements
        tempvalue = ccfs(node,adjacent_matrix)
        cn_ccfs[node] = [tempvalue["3"],tempvalue["4"],tempvalue["5"],tempvalue["34"],tempvalue["345"]]
    end

    big_scores = Dict()
    for (order, value) in enumerate(["3","4","5","34","345"])
       total_mutual_information = Dict{Tuple,Float64}()
       for (key, value) in node_edge_cn
           temp_result_node_edge = 0
           for node in value
               tempvalue = cn_ccfs[node][order]
               temp_result_node_edge += information_entropy_node_edge - tempvalue
           end
           mutual_information_node_edge = temp_result_node_edge - information_entropy_node_edge
           total_mutual_information[key] = mutual_information_node_edge
       end
       for (k,v) in total_mutual_information
           if isinf(v) || isnan(v)
               total_mutual_information[k] = 0.0
           end
       end
       big_scores[value] = total_mutual_information
   end

   return big_scores
end

function ccfs(node::Int, adjacent_matrix::SparseMatrixCSC{Int,Int})
    return_value = Dict()
    ccfs2 = clustercoeffs(adjacent_matrix)
    ccfs3all = higher_order_ccfs(adjacent_matrix, 3)
    ccfs3 = ccfs3all.local_hoccfs
    ccfs4all = higher_order_ccfs(adjacent_matrix, 4)
    ccfs4 = ccfs4all.local_hoccfs
    ccfs5all = higher_order_ccfs(adjacent_matrix, 5)
    ccfs5 = ccfs5all.local_hoccfs

    return_value["3"] = ccfs3[node][1]
    return_value["4"] = ccfs4[node][1]
    return_value["5"] = ccfs5[node][1]
    return_value["34"] = 1 - (1-ccfs3[node][1])*(1-ccfs4[node][1])      
    return_value["345"] = 1 - (1-ccfs3[node][1])*(1-ccfs4[node][1])*(1-ccfs5[node][1])

    for key in keys(return_value)
        return_value[key] = return_value[key] == 0 ? 0 : -log2(return_value[key])
    end
    return return_value
end
