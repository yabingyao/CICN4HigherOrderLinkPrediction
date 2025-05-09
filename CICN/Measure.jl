# using PyCall
# @pyimport sklearn.metrics as skm
function AUC(scores::Dict{Tuple,Float64},measure_parameter::Dict{String,Any})
    positive_key = measure_parameter["positive_key"]
    negitive_key = measure_parameter["negitive_key"]
    n = 100000
    n1 = 0
    n11 = 0
    for i in 1:n
        pk = positive_key[rand(1:length(positive_key))]
        nk = negitive_key[rand(1:length(negitive_key))]
        if scores[Tuple(pk)] > scores[Tuple(nk)]
            n1 += 1
        elseif scores[Tuple(pk)] == scores[Tuple(nk)]
            n11 += 1
        end
    end
    AUC = (n1 + 0.5*n11) / n
    return AUC
end

#
# function AUC(scores, measure_parameter)
#     positive_keys = measure_parameter["positive_key"]
#     n = length(scores)
#     y_true = BitVector(undef, n)
#     y_scores = Vector{Float64}(undef, n)
#     # 提取得分和标签
#     i = 1
#     for key in keys(scores)
#         if [key[1],key[2]] in positive_keys
#             y_true[i] = true
#             y_scores[i] = scores[key]
#         else
#             y_true[i] = false
#             y_scores[i] = scores[key]
#         end
#         i += 1
#     end
#     fpr, tpr, _ = skm.roc_curve(y_true, y_scores)
#     auc = skm.auc(fpr, tpr)
#     return auc
# end

# function Precision(scores,measure_parameter)
#     positive_key = measure_parameter["positive_key"]
#     L = measure_parameter["TopL"]
#     sorted_tuples = sort(collect(scores), by = x -> x[2], rev = true)
#     top_L = [collect(i[1]) for i in sorted_tuples[1:L]]
#     proesion = length(intersect(top_L,positive_key))/L
#     return proesion
# end
#
# function TOPR(scores, measure_parameter)
#     Top = 0
#     score = 0
#     positive_keys = measure_parameter["positive_key"]
#     TopR = measure_parameter["TopR"]
#     key_sort = sort(collect(keys(scores)), by=x -> scores[x], rev=true)
#     top25 = key_sort[1:50]
#     for i in 1:TopR
#         a = top25[i]
#         b = []
#         push!(b,a[1])
#         push!(b,a[2])
#         if in(b, positive_keys)
#             Top += 1
#         end
#     end
#     score = Top / TopR
#     return score
# end

# function AUPR(scores, measure_parameter)
#     positive_keys = measure_parameter["positive_key"]
#     n = length(scores)
#     y_true = BitVector(undef, n)
#     y_scores = Vector{Float64}(undef, n)
#     # 提取得分和标签
#     i = 1
#     for key in keys(scores)
#         if [key[1],key[2]] in positive_keys
#             y_true[i] = true
#             y_scores[i] = scores[key]
#         else
#             y_true[i] = false
#             y_scores[i] = scores[key]
#         end
#         i += 1
#     end
#     precision, recall, _ = skm.precision_recall_curve(y_true, y_scores)
#     aupr = skm.auc(recall, precision)
#     return aupr
# end

#
function AUPR(scores, measure_parameter)
    positive_keys = measure_parameter["positive_key"]
    n = length(scores)
    y_true = BitVector(undef, n)
    y_scores = Vector{Float64}(undef, n)
    # 提取得分和标签
    i = 1
    for key in keys(scores)
        if [key[1],key[2]] in positive_keys
            y_true[i] = true
            y_scores[i] = scores[key]
        else
            y_true[i] = false
            y_scores[i] = scores[key]
        end
        i += 1
    end
    # 按照得分从高到低排序
    sorted_labels = y_true[sortperm(y_scores, rev=true)]
    # 初始化变量
    tp = 0  # 正例被正确预测的数量
    tp_fp = 0  # 模型预测的正例总数量
    precision = Float64[]  # 精确率列表
    recall = Float64[]  # 召回率列表
    sizehint!(precision, n)
    sizehint!(recall, n)
    aupr = 0.0  # AUPR
    last_recall = 0.0
    last_precision = 1.0
    sorted_labels_sum = sum(sorted_labels)
    # 计算召回率、精确率和AUPR
    for label in sorted_labels
        tp_fp += 1
        if label == true
            tp += 1
        end
        current_recall = tp / sorted_labels_sum
        current_precision = tp / tp_fp
        push!(recall, current_recall)
        push!(precision, current_precision)
        aupr += (current_recall - last_recall) * (current_precision + last_precision) / 2
        last_recall = current_recall
        last_precision = current_precision
    end
    return aupr
end
