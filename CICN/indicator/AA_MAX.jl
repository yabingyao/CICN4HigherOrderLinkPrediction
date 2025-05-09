using SparseArrays
using Combinatorics
using LightGraphs


function PLP_AA_MAX(convey_dict::Convey_class)

    train = convey_dict.train
    h = convey_dict.h
    col_degree=degree(h)
    wuv_cn_dict = Dict{Tuple,Float64}()

    for wuv in train
        w = wuv[1][1]
        u = wuv[2][1]
        v = wuv[2][2]
        cn_seedEdge_nodes_1 = neighbors(h, u)
        cn_seedEdge_nodes_2 = neighbors(h, v)
        w_neighbors = neighbors(h,w)
        score1 = sum([1/log2(col_degree[node] + 0.00001) for node in intersect(w_neighbors,cn_seedEdge_nodes_1)])
        score2 = sum([1/log2(col_degree[node] + 0.00001) for node in intersect(w_neighbors,cn_seedEdge_nodes_2)])
        if score1 >= score2
            wuv_cn_dict[Tuple([[w],wuv[2]])] = score1
        else
            wuv_cn_dict[Tuple([[w],wuv[2]])] = score2
        end
    end

    for (k,v) in wuv_cn_dict
        if isinf(v) || isnan(v)
            wuv_cn_dict[k] = 0.0
        end
    end
    return wuv_cn_dict

end
