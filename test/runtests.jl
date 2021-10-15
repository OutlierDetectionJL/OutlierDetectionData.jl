using OutlierDetectionData
using OutlierDetection: CLASS_NORMAL, CLASS_OUTLIER
using Test

function test_tabular_dataset(dataset)
    names = dataset.list()
    always_accept = "DATADEPS_ALWAYS_ACCEPT" => true

    for name in names
        @info "Testing $name"
        X, y = withenv(() -> dataset.load(name), always_accept)
        @test ndims(y) == 1 # make sure that the labels are a vector
        @test ndims(X) == 2 # all tabular datasets are two-dimensional
         # no other elements than inliers and outliers
        @test sum(y .== CLASS_NORMAL) + sum(y .== CLASS_OUTLIER) == length(y)
    end
end

@testset "Tabular datasets" begin
    test_tabular_dataset(ODDS)
    test_tabular_dataset(ELKI)
end

@testset "Use prefix to list datasets" begin
    # empty prefix should return all datasets
    @test ODDS.list() == ODDS.list("")
    @test ELKI.list() == ELKI.list("")

    # prefix should return datasets that start with the prefix
    odds_starting_with_s = ["satellite", "satimage-2", "shuttle", "smtp", "speech"]
    odds_starting_with_sat = ["satellite", "satimage-2"]
    @test ODDS.list("s") == odds_starting_with_s
    @test ODDS.list("sat") == odds_starting_with_sat
    @test length(ELKI.list("Annthyroid_")) == 84 # there are 84 datasets starting with "Annthyroid_"
end
