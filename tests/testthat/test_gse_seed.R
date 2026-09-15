test_that("all GSEA entry points expose a seed argument defaulting to FALSE", {
    expect_equal(formals(MicrobiomeProfiler::gseKO)$seed, FALSE)
    expect_equal(formals(MicrobiomeProfiler::gseModule)$seed, FALSE)
    expect_equal(formals(MicrobiomeProfiler::gseCOG)$seed, FALSE)
    expect_equal(formals(MicrobiomeProfiler::gseMDA)$seed, FALSE)
    expect_equal(formals(MicrobiomeProfiler::gseMBKEGG)$seed, FALSE)
    expect_equal(formals(MicrobiomeProfiler::gseSMPDB)$seed, FALSE)
    expect_equal(formals(MicrobiomeProfiler::gseHMDB)$seed, FALSE)
    expect_equal(formals(MicrobiomeProfiler::gseEggNOG)$seed, FALSE)
})

test_that("GSEA entry points forward seed to enrichit::gsea_gson", {
    captured <- NULL
    local_mocked_bindings(
        gsea_gson = function(...) {
            captured <<- list(...)
            NULL
        },
        mp_disbiome_gson = function(...) structure(list(), class = "GSON"),
        mp_eggnog_gson = function(...) structure(list(), class = "GSON"),
        .package = "MicrobiomeProfiler"
    )

    gl <- c("K00001" = 2, "K00002" = 1, "K00003" = -1)

    MicrobiomeProfiler::gseKO(gl, seed = 11)
    expect_equal(captured$seed, 11)

    MicrobiomeProfiler::gseModule(gl, seed = 12)
    expect_equal(captured$seed, 12)

    cog <- c("COG0001" = 2, "COG0002" = 1, "COG0003" = -1)
    MicrobiomeProfiler::gseCOG(cog, dtype = "category", seed = 13)
    expect_equal(captured$seed, 13)

    mb <- c("C00019" = 2, "C00020" = 1, "C00022" = -1)
    MicrobiomeProfiler::gseMBKEGG(mb, seed = 14)
    expect_equal(captured$seed, 14)

    MicrobiomeProfiler::gseSMPDB(mb, seed = 15)
    expect_equal(captured$seed, 15)

    MicrobiomeProfiler::gseHMDB(
        c("HMDB0000001" = 2, "HMDB0000005" = 1, "HMDB0000008" = -1),
        seed = 16
    )
    expect_equal(captured$seed, 16)

    MicrobiomeProfiler::gseMDA(c("10090" = 2, "9606" = 1), seed = 17)
    expect_equal(captured$seed, 17)

    MicrobiomeProfiler::gseEggNOG(
        c("OG0001" = 2, "OG0002" = 1, "OG0003" = -1),
        seed = 18
    )
    expect_equal(captured$seed, 18)
})
