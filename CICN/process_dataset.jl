function process_dataset()
    # 读取输入文件
    path =  "E:\\桌面\\new_datasets\\data_process\\datasets\\"
    outpath =  "E:\\桌面\\new_datasets\\data_process\\output\\"
    jobs = readdir(path)

    for i in jobs
        lines = readlines(path*i)
        processed_lines = []
        for line in lines
            # 拆分每行的数据
            parts = split(line)
            # 删除第三列
            #deleteat!(parts, 3)

            # 交换第一列和第二列的位置
            new_line = join([parts[1], parts[2]], " ")

            # 检查第一列和第二列的值是否相等，如果相等则跳过当前行
            if parts[1] == parts[2]
                continue
            end
            # 添加到处理后的行列表
            push!(processed_lines, new_line)
        end
        unique!(processed_lines)
        #sort!(processed_lines)
        sort!(processed_lines, by=x->(parse(Int, split(x)[1]), parse(Int, split(x)[2])))
        #以下代码对每个数值加1
        # for i in 1:length(processed_lines)
        #     parts = split(processed_lines[i])
        #     parts[1] = string(parse(Int, parts[1]) - 1)
        #     parts[2] = string(parse(Int, parts[2]) - 1)
        #     processed_lines[i] = join(parts, " ")
        # end


        f = replace(outpath*i*".txt",".mtx"=>"")
        open(f, "w") do file
            for line in processed_lines
                println(file, line)
            end
        end

    end

end

# 示例用法
#input_file = "E:\\桌面\\new_datasets\\data_process\\input.txt"
#output_file = "E:\\桌面\\new_datasets\\data_process\\output.txt"
process_dataset()
