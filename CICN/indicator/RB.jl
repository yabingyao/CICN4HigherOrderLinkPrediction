using SparseArrays
using Combinatorics
using LightGraphs
#using Iterators
# include("find_triangles.jl")


#root_edges_tr = MyModule.root_edges


function PLP_RB(convey_dict::Convey_class)

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
        Z = wuv_cn_dict[Tuple([[w],uv])]
        first_part = 1/col_degree[w]
        middle = Dict()
        for z in Z
            second_part=0
            X = intersect(neighbors(h,z),w_neighbors)
            for x in X
                second_part += 1/(col_degree[x]*col_degree[w])
            end
            middle[z] = first_part+second_part
        end

        finnal = Float64[]
        for z in keys(middle)
            T = intersect(neighbors(h,z),uv_neighbors)
            first_part = middle[z]/col_degree[z]
            second_part=0
            for t in T
                second_part += middle[z]/(col_degree[z]*length(uv_neighbors))
            end
            push!(finnal,first_part + second_part)
        end
        a = sum(finnal)


        first_part = 1/length(uv_neighbors)
        middle_2 = Dict()
        for z in Z
            second_part=0
            X = intersect(neighbors(h,z),uv_neighbors)
            for x in X
                second_part += 1/(col_degree[x]*length(uv_neighbors))
            end
            middle_2[z] = first_part+second_part

        end
        finnal_2 = Float64[]
        for z in keys(middle)
            T = intersect(neighbors(h,z),w_neighbors)
            first_part = middle_2[z]/col_degree[z]
            second_part=0
            for t in T
                second_part += middle[z]/(col_degree[z]*col_degree[w])
            end
            push!(finnal_2,first_part + second_part)
        end
        b = sum(finnal_2)

        wuv_scores_dict[Tuple([[w],uv])] = a + b

    end
    for (k,v) in wuv_scores_dict
        if isinf(v) || isnan(v)
            wuv_scores_dict[k] = 0.0
        end
    end

    return wuv_scores_dict

end
