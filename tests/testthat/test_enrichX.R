test_that("test enrich function works", {
    library(MicrobiomeProfiler)
    ko <- MicrobiomeProfiler::enrichKO(IPF)
    expect_s4_class(ko, class ="enrichResult")


    data("Psoriasis_data")
    cog <- MicrobiomeProfiler::enrichCOG(Psoriasis_data)
    expect_s4_class(cog, class ="enrichResult")

    data("microbiota_taxlist")
    mda <- MicrobiomeProfiler::enrichMDA(microbiota_taxlist)
    expect_s4_class(mda,class ="enrichResult")

    mb <- MicrobiomeProfiler::enrichSMPDB(mb_examplelist)
    expect_s4_class(mb, class ="enrichResult")

    y2 <- c("C00002","C00041","C00020")
    mb3 <- MicrobiomeProfiler::enrichMBKEGG(y2)
    expect_s4_class(mb3,class ="enrichResult")

    y3 <- MicrobiomeProfiler::bitr_smpdb(mb_examplelist,
                                         from_Type = "Metabolite.ID",
                                         to_Type = "HMDB.ID")
    mb4 <- MicrobiomeProfiler::enrichHMDB(y3$HMDB.ID)
    expect_s4_class(mb4,class ="enrichResult")





})
