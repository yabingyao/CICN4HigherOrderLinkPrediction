using SparseArrays
using LightGraphs
using LinearAlgebra
using Random
using StatsBase
include("data_reconstruction.jl")

function random_triangles(datasets::AbstractString, train_ratio::Float64, g::SimpleGraph{Int64})
    # 重建数据
    all_triangles = data_reconstruction(datasets)
    # 设定起始顶点为1
    s = 1
    # 获取图的最小生成树的边列表
    mst = [[edge.src, edge.dst] for edge in collect(edges(bfs_tree(g, s)))]
    # 检查三角形，如果三角形中包含图的最小生成树的边，不能破坏它
    data_triangles = check_elements(mst, all_triangles)
    # 计算测试集所占的比例
    test_ratio = round(1 - train_ratio, digits=1)
    # 计算测试集的个数
    test_length = Int(round(test_ratio * length(all_triangles)))
    # 用于存储随机三角形的列表
    random_triangles = []
    # 过滤器初始为所有三角形
    filter = all_triangles

    for i in 1:test_length
        # 从过滤器中随机选择一个三角形，不放回
        item = sample(filter, 1, replace=false)[1]
        # 将选中的三角形添加到随机三角形列表中
        push!(random_triangles, item)
        # 更新过滤器，移除与已选三角形共享边的三角形
        filter = filter_triangles(item, filter)
    end

    # 返回测试集中删边的随机三角形列表
    return random_triangles
end


function filter_triangles(random_triangles, data_triangles)
    filter = [] # 创建一个空数组用于存储满足条件的三角形
    for i in data_triangles
        # 使用集合的交集操作来判断两个集合的公共元素个数
        if count(x -> x in random_triangles, i) <= 1
            push!(filter, i) # 将满足条件的三角形添加到结果数组中
        end
    end
    return filter # 返回满足条件的三角形数组
end

function check_elements(mst::Array{Array{Int64,1},1}, all_triangles::Array{Any,1})
    # 危险三角形，表示不能删掉的三角形，一旦删除，图就不连通了，后面训练集无法重构图
    dangerous_triangles = [i for i in all_triangles if any(j -> all(x -> x in i, j), mst)]  
    # 可用的三角形，即从所有三角形中减去危险三角形
    usable_triangles = setdiff(all_triangles, dangerous_triangles)  
    return usable_triangles
end

function get_test_list(test_triangle_list::AbstractArray)
    test_list = []
    for test_triangle in test_triangle_list
        remove_one_elements = sample(test_triangle, 1,replace=false)#从集合i（三角形）中随机抽取一个点，不放回
        remain_two_elements = setdiff(test_triangle, remove_one_elements)#三角形中剩下的两个点，三角形和remove_one_elements做差集
        push!(test_list,[remove_one_elements,remain_two_elements])#[[10],[1,7]]
    end
    return test_list
end

function remove_edges(test_list::AbstractArray)
    target_nodes = [i[1] for i in test_list]  # 获取待推荐点
    seed_edges = [i[2] for i in test_list]  # 获取测试集中的种子边
    remove_edges = []  # 存储要移除的边

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

        append!(remove_edges, [remove_edge_a, remove_edge_b])
    end

    return remove_edges
end




function divide_data(dataset_path::AbstractString, rate::Float64)
    # 读取数据集
    data = load_example_data(dataset_path)
    # 构建图
    g = SimpleGraph(data)
    # 获取边列表
    edges_list = [[edge.src, edge.dst] for edge in LightGraphs.edges(g)]
    # 获取点列表
    nodes_list = LightGraphs.vertices(g)
    # 获取测试集中需要破坏的三角形
    random_triangles_list = random_triangles(dataset_path, rate, g)
    # 获取测试集
    test = get_test_list(random_triangles_list)
    # 通过已知测试集获取训练集中需要移除的边
    remove_edges_list = remove_edges(test)
    # 从边列表中移除测试集中的边，得到剩余的边列表
    remain_edges_list = setdiff(edges_list, remove_edges_list)
    node_size = length(nodes_list)
    h = SimpleGraph(node_size)
    for edge in remain_edges_list
        # 将剩余的边添加到新的图中
        add_edge!(h, edge[1], edge[2])
    end

    train = []
    for edge in remain_edges_list
        for node in nodes_list
            if !has_edge(h, node, edge[1]) && !has_edge(h, node, edge[2])
                # 将满足条件的边和节点添加到训练集中
                push!(train, [[node], edge])
            end
        end
    end
    train_matrix = adjacency_matrix(h)

    return test, train, train_matrix, h
end
