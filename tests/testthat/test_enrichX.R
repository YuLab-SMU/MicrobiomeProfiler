test_that("test enrich function works", {
    library(MicrobiomeProfiler)
    data("Psoriasis_data")
    data("Rat_data")
    data("microbiota_taxlist")
    ko <- MicrobiomeProfiler::enrichKO(IPF)
    expect_s4_class(ko, class ="enrichResult")

    ko2 <- MicrobiomeProfiler::enrichKO(Psoriasis_data)
    expect_equal(ko2, NULL)

    cog <- MicrobiomeProfiler::enrichCOG(Psoriasis_data)
    expect_s4_class(cog, class ="enrichResult")

    cog2 <- MicrobiomeProfiler::enrichCOG(Rat_data)
    expect_equal(cog2, NULL)

    mda <- MicrobiomeProfiler::enrichMDA(microbiota_taxlist)
    expect_s4_class(mda,class ="enrichResult")


    mda2 <- MicrobiomeProfiler::enrichMDA(Psoriasis_data)
    expect_equal(mda2, NULL)


    y2 <- c("C00002","C00041","C00020")
    mb <- MicrobiomeProfiler::enrichSMPDB(mb_examplelist)
    expect_s4_class(mb, class ="enrichResult")

    mb2 <- MicrobiomeProfiler::enrichSMPDB(y2)
    expect_equal(mb2, NULL)

    mb3 <- MicrobiomeProfiler::enrichMBKEGG(y2)
    expect_s4_class(mb3,class ="enrichResult")

    mb4 <- MicrobiomeProfiler::enrichMBKEGG(mb_examplelist)
    expect_equal(mb4, NULL)

    y3 <- MicrobiomeProfiler::bitr_smpdb(mb_examplelist,
                                         from_Type = "Metabolite.ID",
                                         to_Type = "HMDB.ID")
    mb5 <- MicrobiomeProfiler::enrichHMDB(y3$HMDB.ID)
    expect_s4_class(mb5,class ="enrichResult")

    mb6 <- MicrobiomeProfiler::enrichHMDB(y3$Metabolite.ID)
    expect_equal(mb6, NULL)


})
