using DataFrames
using CSV
using LightGraphs
#using Threads  # 直接使用Threads中的函数
using Distributed
using SparseArrays

include("read_undir_txt.jl")
include("find_triangles.jl")
include("HigherOrderClustering.jl")
include("util.jl")
include("Divide_data.jl")
include("Measure.jl")
include("./special_indi/HOCI.jl")
include("./class/Conv.jl")


# 调用函数，指定文件夹路径
indi = include_all_files("indicator")
# 存放结果文件
res_auc = "../result/resAUC.csv"
res_topr = "../result/resTOPR.csv"
res_aupr = "../result/resAUPR.csv"
meddle_auc = "../result/meddleAUC.csv"
meddle_aupr = "../result/meddleAUPR.csv"

use_indicator = "datasets,CN,AA,AA_MAX,AA_MUL,HOCI_3,HOCI_4,HOCI_5,HOCI_34,HOCI_345,JS,JS_MAX,JS_MUL,Pair_Seed,PageRank_MAX,PageRank_MUL,TRPR,TRPRW"

function calculate_indicator(one_indi::String, convey_dict::Convey_class)
    method_name = "PLP_"*one_indi
    expr = Meta.parse("$method_name")
    scores = getfield(Main, expr)(convey_dict)
    return scores
end

function run(datasets::String,rate::Float64,times::Int64)
    variables_dict = Dict{String,Float64}()
    # TopL = 25
    # TopR = 25
    for str in indi
        var_name1 = "total_AUC_" * str
        var_name2 = "total_AUPR_" * str
        value = 0

        # 将变量存储到字典中
        variables_dict[var_name1] = value
        variables_dict[var_name2] = value
    end

    variables_dict["total_AUC_HOCI_3"] = 0
    variables_dict["total_PRE_HOCI_3"] = 0
    variables_dict["total_TOPR_HOCI_3"] = 0
    variables_dict["total_AUPR_HOCI_3"] = 0

    variables_dict["total_AUC_HOCI_4"] = 0
    variables_dict["total_PRE_HOCI_4"] = 0
    variables_dict["total_TOPR_HOCI_4"] = 0
    variables_dict["total_AUPR_HOCI_4"] = 0

    variables_dict["total_AUC_HOCI_5"] = 0
    variables_dict["total_PRE_HOCI_5"] = 0
    variables_dict["total_TOPR_HOCI_5"] = 0
    variables_dict["total_AUPR_HOCI_5"] = 0


    variables_dict["total_AUC_HOCI_34"] = 0
    variables_dict["total_PRE_HOCI_34"] = 0
    variables_dict["total_TOPR_HOCI_34"] = 0
    variables_dict["total_AUPR_HOCI_34"] = 0


    variables_dict["total_AUC_HOCI_345"] = 0
    variables_dict["total_PRE_HOCI_345"] = 0
    variables_dict["total_TOPR_HOCI_345"] = 0
    variables_dict["total_AUPR_HOCI_345"] = 0


    all_triangles = data_reconstruction(datasets)
    # 执行times次
    for i in 1:times
        println(datasets*"第"*string(i)*"次计算")
        # 划分测试集训练集
        t9 = time()
        test,train,train_matrix,h,nodes_list_h,edges_list_h = divide_data(datasets, rate, all_triangles)
        t10 = time()
        #println("common_attributes:", t10 - t9)
        cn_seedEdge_nodes,wuv_cn_dict = common_attributes(edges_list_h,train,h)
        # 正负样例
        positive_key = collect(test)
        wuv_scores = collect(train)
        negitive_key = setdiff(wuv_scores,positive_key)
        # 构建参数对象
        convey_dict  = Convey_class(test, train, train_matrix, h, nodes_list_h, edges_list_h,
        cn_seedEdge_nodes, wuv_cn_dict)
        measure_parameter = Dict{String,Any}()
        measure_parameter["positive_key"] = positive_key
        measure_parameter["negitive_key"] = negitive_key
        AUC_meddle = Dict{String,Float64}()
        # PRE_meddle = Dict{String,Float64}()
        AUPR_meddle = Dict{String,Float64}()
        for one_indi in indi
            # println("LLLLLLLLLLLLLLL")
            t1 = time()
            scores = calculate_indicator(one_indi, convey_dict)
            t2 = time()
            # if one_indi == "TRPR"
            #     println("TRPR:",scores)
            # end
            # if one_indi == "TRPRW"
            #     println("TRPRW:",scores)
            # end
            #println(one_indi)
            #println("scores:", t2 - t1)
            # println(typeof(scores))
            auc = AUC(scores,measure_parameter)
            t3 = time()
            t4 = time()
            #println("pre:", t4 - t3)
            aupr = AUPR(scores,measure_parameter)
            t5 = time()

            variables_dict["total_AUC_"*one_indi] += auc
            variables_dict["total_AUPR_"*one_indi] += aupr
            AUC_meddle["total_AUC_"*one_indi] = auc
            AUPR_meddle["total_AUPR_"*one_indi] = aupr
            t6 = time()
        end

        all_scores = PLP_HOCI(convey_dict)
        for scores_key in keys(all_scores)
            scores = all_scores[scores_key]
            auc = AUC(scores,measure_parameter)
            aupr = AUPR(scores,measure_parameter)
            variables_dict["total_AUC_HOCI_"*scores_key] += auc
            variables_dict["total_AUPR_HOCI_"*scores_key] += aupr
            AUC_meddle["total_AUC_HOCI_"*scores_key] = auc
            AUPR_meddle["total_AUPR_HOCI_"*scores_key] = aupr
        end
        savemeddle_result(datasets,AUC_meddle,AUPR_meddle,use_indicator,meddle_auc,meddle_aupr)
    end
    file = replace(datasets,".txt"=>"")
    # 记录汇总值
    # AUC 汇总结果暂存列表
    list_total_auc = [variables_dict["total_AUC_CN"], variables_dict["total_AUC_AA"], variables_dict["total_AUC_AA_MAX"], variables_dict["total_AUC_AA_MUL"], variables_dict["total_AUC_HOCI_3"], variables_dict["total_AUC_HOCI_4"], variables_dict["total_AUC_HOCI_5"],  variables_dict["total_AUC_HOCI_34"],
    variables_dict["total_AUC_HOCI_345"], variables_dict["total_AUC_JS"], variables_dict["total_AUC_JS_MAX"], variables_dict["total_AUC_JS_MUL"], variables_dict["total_AUC_Pair_Seed"],
    variables_dict["total_AUC_PageRank_MAX"], variables_dict["total_AUC_PageRank_MUL"], variables_dict["total_AUC_TRPR"], variables_dict["total_AUC_TRPRW"]] / times

    list_total_aupr = [variables_dict["total_AUPR_CN"], variables_dict["total_AUPR_AA"], variables_dict["total_AUPR_AA_MAX"], variables_dict["total_AUPR_AA_MUL"], variables_dict["total_AUPR_HOCI_3"], variables_dict["total_AUPR_HOCI_4"], variables_dict["total_AUPR_HOCI_5"], variables_dict["total_AUPR_HOCI_34"],
    variables_dict["total_AUPR_HOCI_345"], variables_dict["total_AUPR_JS"], variables_dict["total_AUPR_JS_MAX"], variables_dict["total_AUPR_JS_MUL"], variables_dict["total_AUPR_Pair_Seed"],
    variables_dict["total_AUPR_PageRank_MAX"], variables_dict["total_AUPR_PageRank_MUL"], variables_dict["total_AUPR_TRPR"], variables_dict["total_AUPR_TRPRW"]] / times

    # 写入AUC
    open(res_auc, "a") do f
        write(f, file * ',')
        write(f, join(list_total_auc, ','))
        write(f, '\n')
    end

    open(res_aupr, "a") do f
        write(f, file * ',')
        write(f, join(list_total_aupr, ','))
        write(f, '\n')
    end

end
function lk()
    mode = 2
    target = "data"
    train_percent = 0.9
    # 指定路径下所有的图数据
    path = "../datasets/$target/"
    jobs = readdir(path)
    println("读取到$(length(jobs))个文件")

    if mode == 0 || mode == 2
        exist_file = "resAUC.csv"
    end
    if mode == 1
        exist_file = "resPRE.csv"
    end
    if mode == 3
        exist_file = "resAUPR.csv"
    end

    if isfile(exist_file)
        res = read(exist_file, String)
        li = split(res, '\n')[1:end]
        fi = [replace(split(i, ',')[1] * ".txt", Regex(path) => "")   for i in li]
        jobs = setdiff(jobs, fi)
        println("计算过的图有$(length(fi))个")
        println("未计算的图有$(length(jobs))个")
    end
    training_times = 1

    open(res_auc,"a") do f
        write(f,use_indicator)
        write(f,'\n')
    end

    open(res_aupr,"a") do f
        write(f,use_indicator)
        write(f,'\n')
    end

    # 对图进行运算
    for i in jobs
    #try
        t1 = time()
        network_path = joinpath(path, i)
        println("------>>")
        println(network_path)
        # 重新构造文件名
        run(network_path,0.9,3)
        t2 = time()
        println("t2-t1:", t2 - t1)
    #catch ex
        println("------<<这个网络不能用>>")
    end
    #end
end

lk()
