using SparseArrays
using Combinatorics
using LightGraphs
using LinearAlgebra
#using Iterators
# include("find_triangles.jl")

#root_edges_tr = MyModule.root_edges
max_interactions = 10
min_delta = 0.0001
damping_factor = 0.85
function PLP_PageRank_MAX(convey_dict::Convey_class)
    train = convey_dict.train
    h = convey_dict.h
    adjacent_matrix = convey_dict.train_matrix
    eps = 1e-8
    col_degree = degree(h)
    nodes_list = collect(vertices(h))
    graph_size = length(nodes_list)

    P = spzeros(graph_size, graph_size)
    for i in 1:graph_size
        for j in 1:graph_size
            if adjacent_matrix[i,j] != 0
                P[i,j] = adjacent_matrix[i,j] / (col_degree[j] + eps)
            end
        end
    end

    initial_PR = fill(1.0/graph_size, graph_size)

    wuv_cn_dict = Dict{Tuple,Float64}()
    seed_edge = []
    for wuv in train
        if wuv[2] ∉ seed_edge
            push!(seed_edge,wuv[2])
            w = wuv[1][1]
            u = wuv[2][1]
            v = wuv[2][2]

            e_u = construct_e(u,nodes_list)
            PR_u = iteration(e_u,initial_PR,P,max_interactions,min_delta,damping_factor)

            e_v = construct_e(v,nodes_list)
            PR_v = iteration(e_v,initial_PR,P,max_interactions,min_delta,damping_factor)

            edge_PR = max.(PR_u, PR_v)

            for i in train
                if i[2] == wuv[2]
                    a = i[1][1]
                    wuv_cn_dict[Tuple([[a],wuv[2]])] = edge_PR[a]
                end
            end

        end
    end
    for (k,v) in wuv_cn_dict
        if isinf(v) || isnan(v)
            wuv_cn_dict[k] = 0.0
        end
    end
    return wuv_cn_dict
end

function iteration(e::Vector{Float64}, initial_PR::Vector{Float64}, P::SparseMatrixCSC{Float64,Int}, max_interactions::Int, min_delta::Float64, damping_factor::Float64)
    PR = copy(initial_PR)
    y = similar(PR)
    for i in 1:max_interactions
        mul!(y, P, PR)
        y .*= damping_factor
        axpy!(1 - damping_factor, e, y)
        normalize!(y)
        change = sqrt(sum((y - PR).^2))
        copyto!(PR, y)
        if change < min_delta
            break
        end
    end
    return PR
end

function construct_e(seed_node::Int,nodes_list::Vector{Int})
    e = zeros(length(nodes_list))
    e[seed_node] = 1.0
    return e
end
