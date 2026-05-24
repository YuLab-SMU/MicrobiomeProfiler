test_that("gene_source_example_ids returns source-specific examples", {
    library(MicrobiomeProfiler)

    kegg_examples <- MicrobiomeProfiler:::gene_source_example_ids("KEGG")
    cog_examples <- MicrobiomeProfiler:::gene_source_example_ids("COG")
    eggnog_examples <- MicrobiomeProfiler:::gene_source_example_ids(
        "eggNOG",
        eggnog_loader = function(refresh = FALSE) {
            gson::gson(
                gsid2gene = data.frame(
                    gsid = c("map00010", "map00020"),
                    gene = c("OG0001", "OG0002"),
                    stringsAsFactors = FALSE
                ),
                gsid2name = data.frame(
                    gsid = c("map00010", "map00020"),
                    name = c("Glycolysis / Gluconeogenesis", "Citrate cycle"),
                    stringsAsFactors = FALSE
                ),
                species = "microbiome",
                gsname = "eggNOG KEGG",
                version = "test-version",
                keytype = "eggNOG_OG",
                accessed_date = "2026-05-24"
            )
        }
    )

    expect_true(length(kegg_examples) > 0)
    expect_true(all(grepl("^K", as.character(kegg_examples))))

    expect_true(length(cog_examples) > 0)
    expect_true(all(grepl("^[A-Z]", as.character(cog_examples))))

    expect_equal(eggnog_examples, c("OG0001", "OG0002"))
})


test_that("gene_source_example_ids falls back when eggNOG loader fails", {
    library(MicrobiomeProfiler)

    eggnog_examples <- MicrobiomeProfiler:::gene_source_example_ids(
        "eggNOG",
        eggnog_loader = function(refresh = FALSE) {
            stop("simulated network failure")
        }
    )

    expect_equal(eggnog_examples, c("OG0001", "OG0002", "OG0003"))
})
