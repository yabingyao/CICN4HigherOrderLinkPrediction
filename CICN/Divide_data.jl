using SparseArrays
using LightGraphs
using LinearAlgebra
using Random
using StatsBase
include("data_reconstruction.jl")

function random_triangles(datasets::AbstractString, train_ratio::Float64, all_triangles)
    # 重建数据
    #all_triangles = data_reconstruction(datasets)
    # 计算测试集所占的比例
    test_ratio = 1 - train_ratio
    # 计算测试集的个数
    test_length = Int(round(test_ratio * length(all_triangles)))
    test_length = test_length > 1 ? test_length : 1
    #y = x > 5 ? "Greater than 5" : "Less than or equal to 5"
    # 用于存储随机三角形的列表
    random_triangles = Vector{Any}()
    # 过滤器初始为所有三角形
    test = Vector{Any}()
    while length(test) < test_length
        # 从过滤器中随机选择一个三角形，不放回
        item = sample(all_triangles, 1, replace=false)[1]
        remove_edges_list = remove_edges(test)
        obj,test = filter_triangles(item,test,remove_edges_list)
    end
    return test
end

function filter_triangles(random_triangles,test,remove_edges_list)
    test_seededge = Vector{Any}() #创建一个空数组用于存储满足条件的三角形
    for i in test
        push!(test_seededge,i[2])
    end
    #triangle_edges储存三角形的每条边
    triangle_edges = Vector{Any}()
    @inbounds begin
        push!(triangle_edges,
        [random_triangles[1],random_triangles[2]],
        [random_triangles[1],random_triangles[3]],
        [random_triangles[2],random_triangles[3]])
        intersect_edges = intersect(test_seededge,triangle_edges)
        intersect_edges_quantity = length(intersect_edges)
        if intersect_edges_quantity <= 1
            if intersect_edges_quantity == 0
                seed_removeedge = setdiff(triangle_edges,remove_edges_list)
                if length(seed_removeedge) >= 1
                    item_edge = sample(seed_removeedge,1)[1]
                    triangle_node = setdiff(random_triangles,item_edge)
                    triangle_pattern = [triangle_node,item_edge]
                    push!(test,triangle_pattern)
                    return true ,test

                else
                    return false ,test
                end
            else
                intersect_edges = pop!(intersect_edges)
                triangle_node = setdiff(random_triangles,intersect_edges)
                triangle_pattern = [triangle_node,intersect_edges]
                push!(test,triangle_pattern)
            end
            return true ,test
        else
            return false,test
        end
    end
end

function remove_edges(test_list::AbstractArray)
    target_nodes = [i[1] for i in test_list]  # 获取待推荐点
    seed_edges = [i[2] for i in test_list]  # 获取测试集中的种子边
    remove_edges = Vector{Any}()  # 存储要移除的边
    @inbounds begin
        for i in 1:length(seed_edges)
            target_node = target_nodes[i][1]  # 取一个待推荐节点
            edge_node_1, edge_node_2 = seed_edges[i]  # 取种子边的两个端点，然后去找出三角形中删除的两条边
            remove_edge_a, remove_edge_b = [], []
            if target_node > edge_node_1  # 判断边里面两个端点的位置顺序，小的在左，大的在右
                remove_edge_a = [edge_node_1, target_node]
            else
                remove_edge_a = [target_node, edge_node_1]
            end
            if target_node > edge_node_2
                remove_edge_b = [edge_node_2, target_node]
            else
                remove_edge_b = [target_node, edge_node_2]
            end
            pushfirst!(remove_edges, remove_edge_a)
            pushfirst!(remove_edges, remove_edge_b)
        end
    end
    return unique(remove_edges)
end

function divide_data(dataset_path::AbstractString, rate::Float64, all_triangles)
    # 读取数据集
    data = load_example_data(dataset_path)
    # 构建图
    g = SimpleGraph(data)
    # 获取边列表
    edges_list = [[edge.src, edge.dst] for edge in LightGraphs.edges(g)]
    # 获取点列表
    nodes_list = LightGraphs.vertices(g)
    # 获取测试集中需要破坏的三角形
    test = random_triangles(dataset_path,rate,all_triangles)
    #println("test:",test)
    # 获取测试集
    # 通过已知测试集获取训练集中需要移除的边
    remove_edges_list = remove_edges(test)
    # 从边列表中移除测试集中的边，得到剩余的边列表
    remain_edges_list = filter(x -> !(x in remove_edges_list), edges_list)
    node_size = length(nodes_list)
    h = SimpleGraph(node_size)
    for edge in remain_edges_list
        # 将剩余的边添加到新的图中
        add_edge!(h, edge[1], edge[2])
    end
    nodes_list_h = collect(vertices(h))#获取数据集的节点列表
    edges_list_h = [[edge.src, edge.dst] for edge in collect(LightGraphs.edges(h))]

    all_train = []
    sizehint!(all_train, length(remain_edges_list) * length(nodes_list))
    adj_matrix = adjacency_matrix(h)
    for edge in remain_edges_list
        for node in nodes_list
            if adj_matrix[node, edge[1]] == 0 && adj_matrix[node, edge[2]] == 0
                # 将满足条件的边和节点添加到训练集中
                push!(all_train, [[node], edge])
            end
        end
    end

    neg_train = setdiff(all_train, test)
    n = length(test) # 随机选择的键值对数量
    train = vcat(rand(neg_train, n), test)
    train_matrix = adjacency_matrix(h)

    return test, train, train_matrix, h, nodes_list_h, edges_list_h
end
