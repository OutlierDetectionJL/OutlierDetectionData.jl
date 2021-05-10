using OutlierDetectionData
using Test

function test_tabular_dataset(dataset)
    names = dataset.list()

    for name in names
        print(name)
        X, y = with_accept(() -> dataset.load(name))
        @test ndims(y) == 1 # make sure that the labels are a vector
        @test ndims(X) == 2 # all tabular datasets are two-dimensional
        @test sum(y .== 1) > sum(y .== -1) # there should always be more inliers than outliers
        @test sum(y .== 1) + sum(y .== -1) == length(y) # no other elements than inliers and outliers
    end
end

@testset "Tabular datasets" begin
    test_tabular_dataset(ODDS)
    test_tabular_dataset(ELKI)
end
