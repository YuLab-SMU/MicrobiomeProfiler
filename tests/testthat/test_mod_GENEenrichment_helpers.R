## Fixture: a small pathway (12 genes, inside the app's 10..500 window) plus a
## larger pathway used as the GSEA background.
make_eggnog_example_gson <- function() {
    gson::gson(
        gsid2gene = data.frame(
            gsid = c(rep("map00010", 12), rep("map00020", 30)),
            gene = c(sprintf("Fg%02d@131567|A-1", 1:12),
                     sprintf("Bg%02d@131567|B-2", 1:30)),
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


test_that("gene_source_example_ids returns source-specific examples", {
    library(MicrobiomeProfiler)

    kegg_examples <- MicrobiomeProfiler:::gene_source_example_ids("KEGG")
    cog_examples <- MicrobiomeProfiler:::gene_source_example_ids("COG")
    eggnog_examples <- MicrobiomeProfiler:::gene_source_example_ids(
        "eggNOG",
        eggnog_loader = function(refresh = FALSE) make_eggnog_example_gson()
    )

    expect_true(length(kegg_examples) > 0)
    expect_true(all(grepl("^K", as.character(kegg_examples))))

    expect_true(length(cog_examples) > 0)
    expect_true(all(grepl("^[A-Z]", as.character(cog_examples))))

    ## the eggNOG example covers a whole pathway inside the analysis window
    expect_length(eggnog_examples, 12)
    expect_true(all(grepl("^Fg", eggnog_examples)))
})


test_that("gene_source_example_ids returns nothing instead of fake IDs", {
    library(MicrobiomeProfiler)

    eggnog_examples <- MicrobiomeProfiler:::gene_source_example_ids(
        "eggNOG",
        eggnog_loader = function(refresh = FALSE) {
            stop("simulated network failure")
        }
    )

    ## a broken loader must not be papered over with placeholder identifiers
    expect_length(eggnog_examples, 0)
})


test_that("gene_source_example_ids ignores pathways outside the size window", {
    library(MicrobiomeProfiler)

    eggnog_examples <- MicrobiomeProfiler:::gene_source_example_ids(
        "eggNOG",
        eggnog_loader = function(refresh = FALSE) {
            gson::gson(
                gsid2gene = data.frame(
                    gsid = rep("map00010", 3),
                    gene = c("Fg01@131567|A-1", "Fg02@131567|A-1", "Fg03@131567|A-1"),
                    stringsAsFactors = FALSE
                ),
                gsid2name = data.frame(
                    gsid = "map00010",
                    name = "Tiny pathway",
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

    ## a pathway too small to pass minGSSize must not be advertised as an example
    expect_length(eggnog_examples, 0)
})


test_that("gene_source_example_text returns ranked eggNOG GSEA examples", {
    library(MicrobiomeProfiler)

    example_text <- MicrobiomeProfiler:::gene_source_example_text(
        "eggNOG",
        analysis_mode = "GSEA",
        eggnog_loader = function(refresh = FALSE) make_eggnog_example_gson()
    )

    expect_true(nzchar(example_text))
    expect_false(grepl("OG[0-9]+", example_text))

    gene_list <- MicrobiomeProfiler:::parse_ranked_gene_list(example_text)

    ## foreground pathway + background from another pathway
    expect_length(gene_list, 32)
    expect_true(all(grepl("^Fg", names(gene_list)[1:12])))
    expect_true(all(grepl("^Bg", names(gene_list)[13:32])))
    expect_true(all(gene_list[1:12] > 0))
    expect_true(all(gene_list[13:32] < 0))
    expect_equal(unname(gene_list[1]), 4)
    expect_equal(unname(gene_list[32]), -4)
})


test_that("gene_source_example_text is empty when no example can be built", {
    library(MicrobiomeProfiler)

    example_text <- MicrobiomeProfiler:::gene_source_example_text(
        "eggNOG",
        analysis_mode = "GSEA",
        eggnog_loader = function(refresh = FALSE) {
            stop("simulated network failure")
        }
    )

    expect_identical(example_text, "")
})


test_that("parse_ranked_gene_list parses and sorts ranked input", {
    library(MicrobiomeProfiler)

    gene_list <- MicrobiomeProfiler:::parse_ranked_gene_list(
        "Fg02@131567|A-1\t1.5\nFg01@131567|A-1 2.5\nFg03@131567|A-1,-0.8"
    )

    expect_equal(names(gene_list), c("Fg01@131567|A-1", "Fg02@131567|A-1", "Fg03@131567|A-1"))
    expect_equal(unname(gene_list), c(2.5, 1.5, -0.8))
})


test_that("parse_ranked_gene_list rejects malformed input", {
    library(MicrobiomeProfiler)

    expect_error(
        MicrobiomeProfiler:::parse_ranked_gene_list("Fg01@131567|A-1\nFg02@131567|A-1 1.5"),
        "identifier and a numeric score"
    )
    expect_error(
        MicrobiomeProfiler:::parse_ranked_gene_list("Fg01@131567|A-1 not_a_number"),
        "valid numeric score"
    )
})


test_that("gene_input_placeholder switches for eggNOG GSEA", {
    library(MicrobiomeProfiler)

    expect_match(
        MicrobiomeProfiler:::gene_input_placeholder("eggNOG", "GSEA"),
        "2\\.5"
    )
    expect_match(
        MicrobiomeProfiler:::gene_input_placeholder("eggNOG", "ORA"),
        "@"
    )
    expect_match(
        MicrobiomeProfiler:::gene_input_placeholder("KEGG", "ORA"),
        "K03430"
    )

    ## placeholders must not advertise identifiers that do not exist in eggNOG
    expect_false(grepl("OG[0-9]+",
                       MicrobiomeProfiler:::gene_input_placeholder("eggNOG", "ORA")))
    expect_false(grepl("OG[0-9]+",
                       MicrobiomeProfiler:::gene_input_placeholder("eggNOG", "GSEA")))
})


test_that("gene_analysis_supports_universe disables universe for eggNOG GSEA", {
    library(MicrobiomeProfiler)

    expect_false(MicrobiomeProfiler:::gene_analysis_supports_universe("eggNOG", "GSEA"))
    expect_true(MicrobiomeProfiler:::gene_analysis_supports_universe("eggNOG", "ORA"))
    expect_true(MicrobiomeProfiler:::gene_analysis_supports_universe("KEGG", "ORA"))
})
