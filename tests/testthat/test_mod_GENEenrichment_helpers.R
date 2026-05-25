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


test_that("gene_source_example_text returns ranked eggNOG GSEA examples", {
    library(MicrobiomeProfiler)

    example_text <- MicrobiomeProfiler:::gene_source_example_text(
        "eggNOG",
        analysis_mode = "GSEA",
        eggnog_loader = function(refresh = FALSE) {
            gson::gson(
                gsid2gene = data.frame(
                    gsid = c("map00010", "map00020", "map00030"),
                    gene = c("OG0001", "OG0002", "OG0003"),
                    stringsAsFactors = FALSE
                ),
                gsid2name = data.frame(
                    gsid = c("map00010", "map00020", "map00030"),
                    name = c("A", "B", "C"),
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

    expect_match(example_text, "OG0001\\s+2.5")
    expect_match(example_text, "OG0003\\s+0.8")
})


test_that("parse_ranked_gene_list parses and sorts ranked input", {
    library(MicrobiomeProfiler)

    gene_list <- MicrobiomeProfiler:::parse_ranked_gene_list(
        "OG0002\t1.5\nOG0001 2.5\nOG0003,-0.8"
    )

    expect_equal(names(gene_list), c("OG0001", "OG0002", "OG0003"))
    expect_equal(unname(gene_list), c(2.5, 1.5, -0.8))
})


test_that("parse_ranked_gene_list rejects malformed input", {
    library(MicrobiomeProfiler)

    expect_error(
        MicrobiomeProfiler:::parse_ranked_gene_list("OG0001\nOG0002 1.5"),
        "identifier and a numeric score"
    )
    expect_error(
        MicrobiomeProfiler:::parse_ranked_gene_list("OG0001 not_a_number"),
        "valid numeric score"
    )
})


test_that("gene_input_placeholder switches for eggNOG GSEA", {
    library(MicrobiomeProfiler)

    expect_match(
        MicrobiomeProfiler:::gene_input_placeholder("eggNOG", "GSEA"),
        "OG0001 2.5"
    )
    expect_match(
        MicrobiomeProfiler:::gene_input_placeholder("eggNOG", "ORA"),
        "OG0001"
    )
    expect_match(
        MicrobiomeProfiler:::gene_input_placeholder("KEGG", "ORA"),
        "K03430"
    )
})


test_that("gene_analysis_supports_universe disables universe for eggNOG GSEA", {
    library(MicrobiomeProfiler)

    expect_false(MicrobiomeProfiler:::gene_analysis_supports_universe("eggNOG", "GSEA"))
    expect_true(MicrobiomeProfiler:::gene_analysis_supports_universe("eggNOG", "ORA"))
    expect_true(MicrobiomeProfiler:::gene_analysis_supports_universe("KEGG", "ORA"))
})
