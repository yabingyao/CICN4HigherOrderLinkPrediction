using SparseArrays
using Combinatorics
using LightGraphs
#using Iterators
# include("find_triangles.jl")


#root_edges_tr = MyModule.root_edges


function PLP_RA(convey_dict::Convey_class)

    train = convey_dict.train
    h = convey_dict.h
    edges_list = convey_dict.edges_list_h
    col_degree=degree(h)
    cn_seedEdge_nodes = convey_dict.cn_seedEdge_nodes
    wuv_cn_dict = convey_dict.wuv_cn_dict
    wuv_scores_dict = Dict{Tuple,Float64}()
    for wuv in train
        w = wuv[1][1]
        uv = wuv[2]
        w_neighbors = neighbors(h,w)
        uv_neighbors = cn_seedEdge_nodes[Tuple(uv)]
        wuv_scores_dict[Tuple([[w],uv])] = sum([1/col_degree[node] for node in wuv_cn_dict[Tuple([[w],uv])]])

    end
    for (k,v) in wuv_scores_dict
        if isinf(v) || isnan(v)
            wuv_scores_dict[k] = 0.0
        end
    end

    return wuv_scores_dict

end
