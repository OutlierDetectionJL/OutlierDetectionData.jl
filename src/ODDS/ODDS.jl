module ODDS
    using DataFrames: DataFrame, convert
    using DataDeps
    using MAT

    export list, load

    const _meta = [
        (
        name = "annthyroid",
        md5 = "17a1012d005f2179eca3b87c0028eb5ca807794b359c33fa1f8ca5ac846c514f",
        url = "https://www.dropbox.com/s/aifk51owxbogwav/annthyroid.mat?dl=1"
        ),
        (
        name = "arrhythmia",
        md5 =  "e4d47e499591ae31e5d7f0cd983367092353eac240f48e14c9b36457edb3460d",
        url =  "https://www.dropbox.com/s/lmlwuspn1sey48r/arrhythmia.mat?dl=1"
        ),
        (
        name = "breastw",
        md5 =  "a2e3f7c7f61ddde87c4373f0c0539de996227b9659c70b3c227948ebf0c6062b",
        url =  "https://www.dropbox.com/s/g3hlnucj71kfvq4/breastw.mat?dl=1"
        ),
        (
        name = "cardio",
        md5 =  "5e568b6a73711012c481fa6cc984ab9c68e9a4fa44d6aeb3b43efa381c3f695b",
        url =  "https://www.dropbox.com/s/galg3ihvxklf0qi/cardio.mat?dl=1"
        ),
        (
        name = "cover",
        md5 =  "39acf6da4d31f08c2c28dc047249d8cd8ccd9d6fc299d9b5a08874ac92290c98",
        url =  "https://www.dropbox.com/s/awx8iuzbu8dkxf1/cover.mat?dl=1"
        ),
        (
        name = "ecoli",
        md5 =  "76886bf14f549680450a0720c58b461db965f8b762a5ab4d165c03bbdcb355fc",
        url =  "https://www.dropbox.com/s/f38mquv0g08xxgp/ecoli.mat?dl=1"
        ),
        (
        name = "glass",
        md5 =  "2c506e6e1e2ca1e82a905d10a90773151ff812c4bd969c71a12db5b2bb6e7921",
        url =  "https://www.dropbox.com/s/iq3hjxw77gpbl7u/glass.mat?dl=1"
        ),
        (
        name = "http",
        md5 = "81d689cfec5407305ab98cd26794e2cefb3aef5a521bf9c59744107aabcaed7e",
        url = "https://www.dropbox.com/s/iy9ucsifal754tp/http.mat?dl=1"
        ),
        (
        name = "ionosphere",
        md5 =  "8ac5dfa6f47db4acdfe10615489b7f7dd015d79d5b381ce641e72baca3cfefb0",
        url =  "https://www.dropbox.com/s/lpn4z73fico4uup/ionosphere.mat?dl=1"
        ),
        (
        name = "letter",
        md5 =  "f4a229b0e2a6b0c9157ce27fa760bcbac0f948cd690b2f5d51c120e5450f2195",
        url =  "https://www.dropbox.com/s/rt9i95h9jywrtiy/letter.mat?dl=1"
        ),
        (
        name = "lympho",
        md5 =  "031b907ecb50347720b08b38f8139d05635adeca9335a064d89d5569c27a5834",
        url =  "https://www.dropbox.com/s/ag469ssk0lmctco/lympho.mat?dl=1"
        ),
        (
        name = "mnist",
        md5 =  "9479e221f236684c09f3e11c7ad124725d34ecd301b9450425e8b113368413a6",
        url =  "https://www.dropbox.com/s/n3wurjt8v9qi6nc/mnist.mat?dl=1"
        ),
        (
        name = "musk",
        md5 =  "50bbf414caceb66cfe6f6b1eb7c1ff7c6eb1e6d87173f7bb597ba55cd3dc5493",
        url =  "https://www.dropbox.com/s/we6aqhb0m38i60t/musk.mat?dl=1"
        ),
        (
        name = "optdigits",
        md5 =  "30c664cd6f3740a173277a27cd1028d471b06f0835a9902c9712749cec58c1c4",
        url =  "https://www.dropbox.com/s/w52ndgz5k75s514/optdigits.mat?dl=1"
        ),
        (
        name = "pendigits",
        md5 =  "7bc32ac83b3d583443acea8b1342a54aaa59eaedb9996af405322f473f3c22bc",
        url =  "https://www.dropbox.com/s/1x8rzb4a0lia6t1/pendigits.mat?dl=1"
        ),
        (
        name = "pima",
        md5 =  "b6a5be8d548b9293d6958beceb1c77055591714d25d40d957eba87808456468f",
        url =  "https://www.dropbox.com/s/mvlwu7p0nyk2a2r/pima.mat?dl=1"
        ),
        (
        name = "satellite",
        md5 =  "6feac3112b9c14e1c3e60afc437f2f3d29dc1000119c9f950c628078778d6aa0",
        url =  "https://www.dropbox.com/s/dpzxp8jyr9h93k5/satellite.mat?dl=1"
        ),
        (
        name = "satimage-2",
        md5 =  "95c37a07cea2cb201f6900d14f521510e10b6b2f0074c06ac46d3157440ec67b",
        url =  "https://www.dropbox.com/s/hckgvu9m6fs441p/satimage-2.mat?dl=1"
        ),
        (
        name = "shuttle",
        md5 =  "b6e396c92354d5dcf5036901e36dc58e2913f2d1a5e138c35a2bedf9c69db899",
        url =  "https://www.dropbox.com/s/mk8ozgisimfn3dw/shuttle.mat?dl=1"
        ),
        (
        name = "thyroid",
        md5 =  "49155d7861b977e90808faf68343ff67a67f63090c2744d514dbb67ac68e7e33",
        url =  "https://www.dropbox.com/s/bih0e15a0fukftb/thyroid.mat?dl=1"
        ),
        (
        name = "vertebral",
        md5 =  "84b50b055f118f54b5c976650ccd284ab7c1adee822f8b3eb517c7e2c890d15e",
        url =  "https://www.dropbox.com/s/5kuqb387sgvwmrb/vertebral.mat?dl=1"
        ),
        (
        name = "vowels",
        md5 =  "51d5397bad1ceeda22b7cd44fd58125c5d603c9c2edb53aa59933330e259ac7b",
        url =  "https://www.dropbox.com/s/pa26odoq6atq9vx/vowels.mat?dl=1"
        ),
        (
        name = "wbc",
        md5 =  "afe6b26953cc196b9a480318c903e0edef22529c2f61bd02082438c6e70630a7",
        url =  "https://www.dropbox.com/s/ebz9v9kdnvykzcb/wbc.mat?dl=1"
        )
    ]

    list() = [name for (name, _, _) in _meta]
    to_name(dataset::AbstractString) = "odds-$dataset"

    function load(dataset::AbstractString)
        @assert dataset in list()

        dep = @datadep_str to_name(dataset)
        data = MAT.matread("$dep/$dataset.mat")
        X = DataFrame(data["X"], :auto);
        y = ifelse.(data["y"][:,1] .== 0, 1, -1);
        X, y
    end

    function __init__()
        for (name, md5, url) in _meta
            register(DataDep(
                to_name(name),
                """Dataset: $name
                Collection: Outlier Detection DataSets (ODDS)
                Authors: Shebuti Rayana
                Website: http://odds.cs.stonybrook.edu""",
                url,
                md5
            ))
        end
    end
end
