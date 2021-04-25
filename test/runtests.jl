using OutlierDetectionData
using Test

@testset "ODDS" begin
    # Write your tests here.
    names = ODDS.list()

    # make sure that all files are downloaded
    ODDS.download.(names, force_accept=true)

    for name in names
        X, y = ODDS.read(name)

        @test ndims(y) == 1 # make sure that the labels are a vector
        @test ndims(X) == 2 # all ODDS datasets are two-dimensional
        @test size(X, 2) < size(X, 1) # row-wise obs; there should always be more instances than features in ODDS
        @test sum(y .== 1) > sum(y .== -1) # there should always be more inliers than outliers
        @test sum(y .== 1) + sum(y .== -1) == length(y) # no other elements than inliers and outliers
    end
end
