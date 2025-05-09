using SparseArrays
using Combinatorics
using LightGraphs

function PLP_DGLP(convey_dict::Convey_class)

    train = convey_dict.train
    h = convey_dict.h

    cn_seedEdge_nodes = convey_dict.cn_seedEdge_nodes
    col_degree=degree(h)

    wuv_cn_dict = convey_dict.wuv_cn_dict
    wuv_scores_dict = Dict{Tuple,Float64}()

    for wuv in train
        w = wuv[1][1]
        u = wuv[2][1]
        v = wuv[2][2]
        uv = wuv[2]
        w_neighbors = neighbors(h,w)
        uv_neighbors = cn_seedEdge_nodes[Tuple(uv)]

        path_bool_1 = has_path(h, w, u)
        path_bool_2 = has_path(h, w, v)

        if path_bool_1 && path_bool_2
            shortest_path_length_1 = shortest_path(h, w, u)
            shortest_path_length_2 = shortest_path(h, w, v)
            shortest_path_length = min(length(shortest_path_length_1), length(shortest_path_length_2))

            neighbors_degree = sum([col_degree[node] for node in wuv_cn_dict[Tuple([[w],uv])]])

            wuv_scores_dict[Tuple([[w],uv])] = (length(w_neighbors) + length(uv_neighbors)) / (shortest_path_length + 1) + neighbors_degree

        else:
            neighbors_degree = sum([col_degree[node] for node in wuv_cn_dict[Tuple([[w],uv])]])

            wuv_scores_dict[Tuple([[w],uv])] = neighbors_degree

        end

    end

    for (k,v) in wuv_scores_dict
        if isinf(v) || isnan(v)
            wuv_scores_dict[k] = 0.0
        end
    end

    return wuv_scores_dict

end
