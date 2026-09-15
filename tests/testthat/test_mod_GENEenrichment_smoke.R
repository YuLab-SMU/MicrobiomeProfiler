## Offline smoke test for the eggNOG ORA/GSEA wiring of the gene enrichment module.
##
## `updateTextAreaInput()` is not reflected back into `input` by
## `shiny::testServer()`, so the Example -> Submit round trip is covered by
## driving the very helpers the `Example` button calls (see the last test).

smoke_eggnog_fixture <- function(refresh = FALSE) {
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


seed_gene_inputs <- function(session, analysis_mode = "ORA") {
    session$setInputs(
        type = "eggNOG",
        analysis_mode = analysis_mode,
        pvalue = 0.05,
        padjustmethod = "BH",
        qvalue = 0.05,
        Universe = "Default",
        backgroundset = "eggNOG_KEGG",
        update = 0,
        lowcolor = "#D150A7",
        highcolor = "#46bac2",
        lowcolor2 = "#D150A7",
        highcolor2 = "#46bac2",
        format = "pdf",
        format2 = "pdf",
        dpi = 300,
        dpi2 = 300,
        w = 500,
        h = 350,
        w2 = 600,
        h2 = 500
    )
}


test_that("gene enrichment UI exposes eggNOG next to KEGG and COG", {
    library(MicrobiomeProfiler)

    ui <- paste(as.character(MicrobiomeProfiler:::mod_GENEenrichment_ui("smoke")),
                collapse = "")

    expect_match(ui, "eggNOG")
    expect_match(ui, "KEGG")
    expect_match(ui, "COG")
})


test_that("eggNOG switches between ORA and GSEA input modes", {
    library(MicrobiomeProfiler)

    with_mocked_bindings(
        shiny::testServer(MicrobiomeProfiler:::mod_GENEenrichment_server, {
            seed_gene_inputs(session, "ORA")

            mode_ui <- paste(as.character(output$analysis_mode_ui), collapse = "")
            expect_match(mode_ui, "ORA")
            expect_match(mode_ui, "GSEA")

            ## ORA: one identifier per line, universe and q value available
            ora_placeholder <- paste(as.character(output$genelist_ui), collapse = "")
            expect_match(ora_placeholder, "@")
            expect_false(grepl("2\\.5", ora_placeholder))
            expect_false(is.null(output$universe_ui))
            expect_false(is.null(output$qvalue_ui))
            expect_match(paste(as.character(output$backset), collapse = ""),
                         "eggNOG_KEGG")

            seed_gene_inputs(session, "GSEA")

            ## GSEA: ranked input, universe and q value are not applicable
            gsea_placeholder <- paste(as.character(output$genelist_ui), collapse = "")
            expect_match(gsea_placeholder, "2\\.5")
            expect_null(output$universe_ui)
            expect_null(output$qvalue_ui)
            expect_match(paste(as.character(output$input_help), collapse = ""),
                         "one numeric score per line")
        }),
        mp_eggnog_gson = smoke_eggnog_fixture,
        .package = "MicrobiomeProfiler"
    )
})


test_that("clicking Example in eggNOG mode does not error", {
    library(MicrobiomeProfiler)

    with_mocked_bindings(
        shiny::testServer(MicrobiomeProfiler:::mod_GENEenrichment_server, {
            seed_gene_inputs(session, "ORA")
            expect_no_error(session$setInputs(ex = 1))

            seed_gene_inputs(session, "GSEA")
            expect_no_error(session$setInputs(ex = 1))
        }),
        mp_eggnog_gson = smoke_eggnog_fixture,
        .package = "MicrobiomeProfiler"
    )
})


test_that("the eggNOG example is analysable in both ORA and GSEA", {
    library(MicrobiomeProfiler)

    ## this is the exact path the Example -> Submit buttons drive
    with_mocked_bindings({
        ora_ids <- MicrobiomeProfiler:::gene_source_example_ids("eggNOG")
        expect_gt(length(ora_ids), 0)

        ora <- enrichEggNOG(ora_ids, minGSSize = 10, maxGSSize = 500,
                            qvalueCutoff = 0.05)
        expect_false(is.null(ora))
        expect_gt(nrow(as.data.frame(ora)), 0)

        gsea_text <- MicrobiomeProfiler:::gene_source_example_text("eggNOG", "GSEA")
        expect_true(nzchar(gsea_text))

        ranked <- MicrobiomeProfiler:::parse_ranked_gene_list(gsea_text)
        gse <- gseEggNOG(ranked, minGSSize = 10, maxGSSize = 500, seed = TRUE)
        expect_false(is.null(gse))
        expect_gt(nrow(as.data.frame(gse)), 0)
    },
    mp_eggnog_gson = smoke_eggnog_fixture,
    .package = "MicrobiomeProfiler")
})
