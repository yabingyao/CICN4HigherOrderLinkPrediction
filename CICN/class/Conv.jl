# 定义一个名为MyClass的类
struct Convey_class
    # 类的属性
    test::Vector{Any}
    train::Vector{Any}
    train_matrix::SparseMatrixCSC{Int64, Int64}
    h::SimpleGraph{Int64}
    nodes_list_h::Vector{Int64}
    edges_list_h::Vector{Vector{Int64}}
    cn_seedEdge_nodes::Dict{Any, Any}
    wuv_cn_dict::Dict{Any, Any}
    
    # 类的构造函数
    function Convey_class(test::Vector{Any}, train::Vector{Any}, train_matrix::SparseMatrixCSC{Int64, Int64},
                          h::SimpleGraph{Int64}, nodes_list_h::Vector{Int64}, edges_list_h::Vector{Vector{Int64}},
                          cn_seedEdge_nodes::Dict{Any, Any}, wuv_cn_dict::Dict{Any, Any})
        new(test, train, train_matrix, h, nodes_list_h, edges_list_h, cn_seedEdge_nodes, wuv_cn_dict)
    end
    
end