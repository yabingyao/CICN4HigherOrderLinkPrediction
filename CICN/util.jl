function include_all_files(folder_path::AbstractString)
    # 获取指定文件夹下所有以 ".jl" 结尾的文件路径
    file_paths = filter(file -> endswith(file, ".jl"), readdir(folder_path))
    # 循环遍历文件路径，并将每个文件包含到当前文件中
    indi = String[]
    for file_path in file_paths
        # 提取文件名（不包含扩展名）
        var_name = split(file_path, ".jl")[1]
        push!(indi, var_name)
        include(joinpath(folder_path, file_path))  # 更新此行
    end
    return indi
end

function common_attributes(edges_list_h,train,h)
    cn_seedEdge_nodes = Dict()
    for seed_edge in edges_list_h #取边的邻居
        cn_seedEdge_nodes_1 = neighbors(h, seed_edge[1])
        cn_seedEdge_nodes_2 = neighbors(h, seed_edge[2])
        cn_seedEdge_nodes[Tuple(seed_edge)] = vcat(cn_seedEdge_nodes_1,cn_seedEdge_nodes_2)#取并集
    end
    wuv_cn_dict = Dict()
    for wuv in train
        w = wuv[1][1]
        uv = wuv[2]
        w_neighbors = neighbors(h,w)
        uv_neighbors = cn_seedEdge_nodes[Tuple(uv)]
        wuv_cn_dict[Tuple([[w],uv])] = intersect(w_neighbors,uv_neighbors)
    end
    return cn_seedEdge_nodes,wuv_cn_dict
end


function savemeddle_result(datasets,AUC,AUPR,indi,filename_auc,filename_aupr)
    list_total_auc = [AUC["total_AUC_CN"], AUC["total_AUC_AA"], AUC["total_AUC_AA_MAX"], AUC["total_AUC_AA_MUL"], AUC["total_AUC_HOCI_3"], AUC["total_AUC_HOCI_4"], AUC["total_AUC_HOCI_5"], AUC["total_AUC_HOCI_34"],
    AUC["total_AUC_HOCI_345"], AUC["total_AUC_JS"], AUC["total_AUC_JS_MAX"], AUC["total_AUC_JS_MUL"], AUC["total_AUC_Pair_Seed"],
    AUC["total_AUC_PageRank_MAX"], AUC["total_AUC_PageRank_MUL"], AUC["total_AUC_TRPR"], AUC["total_AUC_TRPRW"]]

    # list_total_pre = [PRE["total_PRE_CN"], PRE["total_PRE_AA"], PRE["total_PRE_PA"], PRE["total_PRE_AA_MAX"], PRE["total_PRE_AA_MUL"], PRE["total_PRE_HOCI_2"],  PRE["total_PRE_HOCI_3"], PRE["total_PRE_HOCI_4"], PRE["total_PRE_HOCI_5"], PRE["total_PRE_HOCI_23"], PRE["total_PRE_HOCI_34"], PRE["total_PRE_HOCI_45"],  PRE["total_PRE_HOCI_234"],
    # PRE["total_PRE_HOCI_345"], PRE["total_PRE_HOCI_2345"], PRE["total_PRE_RB"], PRE["total_PRE_RBCC"], PRE["total_PRE_RA"], PRE["total_PRE_JS"], PRE["total_PRE_JS_MAX"], PRE["total_PRE_JS_MUL"], PRE["total_PRE_Pair_Seed"],
    # PRE["total_PRE_PageRank_MAX"], PRE["total_PRE_PageRank_MUL"], PRE["total_PRE_TRPR"], PRE["total_PRE_TRPRW"]]

    list_total_aupr = [AUPR["total_AUPR_CN"], AUPR["total_AUPR_AA"], AUPR["total_AUPR_AA_MAX"], AUPR["total_AUPR_AA_MUL"], AUPR["total_AUPR_HOCI_3"], AUPR["total_AUPR_HOCI_4"], AUPR["total_AUPR_HOCI_5"], AUPR["total_AUPR_HOCI_34"],
    AUPR["total_AUPR_HOCI_345"], AUPR["total_AUPR_JS"], AUPR["total_AUPR_JS_MAX"], AUPR["total_AUPR_JS_MUL"], AUPR["total_AUPR_Pair_Seed"],
    AUPR["total_AUPR_PageRank_MAX"], AUPR["total_AUPR_PageRank_MUL"], AUPR["total_AUPR_TRPR"], AUPR["total_AUPR_TRPRW"]]

    open(filename_auc, "a") do f
        write(f, datasets * ',')
        write(f, join(list_total_auc, ','))
        write(f, '\n')
    end

    # open(filename_pre, "a") do f
    #     write(f, datasets * ',')
    #     write(f, join(list_total_pre, ','))
    #     write(f, '\n')
    # end

    open(filename_aupr, "a") do f
        write(f, datasets * ',')
        write(f, join(list_total_aupr, ','))
        write(f, '\n')
    end
end
