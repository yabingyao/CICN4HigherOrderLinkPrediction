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

function PLP_TRPR(convey_dict::Convey_class)
    train = convey_dict.train
    h = convey_dict.h
    adjacent_matrix = convey_dict.train_matrix
    nodes_list = convey_dict.nodes_list_h
    eps = 1e-8
    col_degree = degree(h)
    graph_size = length(nodes_list)

    P = construct_P(h,adjacent_matrix,graph_size)

    initial_PR = fill(1.0/graph_size, graph_size)

    wuv_cn_dict = Dict{Tuple,Float64}()
    seed_edge = []
    for wuv in train
        if wuv[2] ∉ seed_edge
            push!(seed_edge,wuv[2])
            w = wuv[1][1]
            u = wuv[2][1]
            v = wuv[2][2]

            e = zeros(graph_size)
            e[u] = 0.5
            e[v] = 0.5

            PR_u = iteration(e,initial_PR,P,max_interactions,min_delta,damping_factor)

            for i in train
                if i[2] == wuv[2]
                    a = i[1][1]
                    wuv_cn_dict[Tuple([[a],wuv[2]])] = PR_u[a]
                end
            end

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

function construct_P(h::SimpleGraph{Int}, adjacent_matrix::SparseMatrixCSC{Int,Int}, graph_size::Int)
    X = spzeros(graph_size, graph_size)
    for i in 1:graph_size
        for j in 1:graph_size
            if i != j && adjacent_matrix[i,j] != 0
                triangle_nodes = common_neighbors(h,i,j)
                x = sum(triangle_nodes)
                X[i,j] += x
            end
        end
    end

    P = X + adjacent_matrix
    P_sum = sum(P, dims=1)
    for i in 1:graph_size
        for j in 1:graph_size
            if P[i,j] != 0
                P[i,j] /= (P_sum[j] + 0.00001)
            end
        end
    end

    return P
end
