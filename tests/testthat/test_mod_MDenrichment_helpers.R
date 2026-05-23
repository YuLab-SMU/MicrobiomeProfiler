test_that("md_source_example_taxa returns source-specific example taxids", {
    library(MicrobiomeProfiler)

    dis_example_taxa <- MicrobiomeProfiler:::md_source_example_taxa("Disbiome")
    bugsigdb_example_taxa <- MicrobiomeProfiler:::md_source_example_taxa("BugSigDB")

    expect_true(length(dis_example_taxa) > 0)
    expect_true("1591" %in% as.character(dis_example_taxa))

    expect_equal(bugsigdb_example_taxa, c("1224", "1236"))
})
