include("find_triangles.jl")
include("read_undir_txt.jl")
function data_reconstruction(data::AbstractString) #将输入进来的网络重构成三角形
    #data = "road-chesapeake_39_170.txt"
    network = load_example_data(data)
    matrix_network = find_triangles_1(network)
    all_triangles = find_triangles_2(matrix_network)
    triangles_list = []
    for i in 1:size(all_triangles)[2]
        triangle = []
        push!(triangles_list,[all_triangles[1,i],all_triangles[2,i],all_triangles[3,i]])
    end
    return triangles_list
end
