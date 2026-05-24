test_that("eggNOG external runtime supports remote-first enrichment", {
    library(MicrobiomeProfiler)

    fixture <- create_eggnog_fixture()
    cache_dir <- file.path(tempdir(), "MicrobiomeProfiler-eggnog-cache-test")
    unlink(cache_dir, recursive = TRUE, force = TRUE)

    old_registry <- getOption("MicrobiomeProfiler.external_registry")
    old_cache <- getOption("MicrobiomeProfiler.cache_dir")
    options(
        MicrobiomeProfiler.external_registry = fixture$registry_path,
        MicrobiomeProfiler.cache_dir = cache_dir
    )
    on.exit({
        options(
            MicrobiomeProfiler.external_registry = old_registry,
            MicrobiomeProfiler.cache_dir = old_cache
        )
        unlink(cache_dir, recursive = TRUE, force = TRUE)
    }, add = TRUE)

    gson_obj <- MicrobiomeProfiler:::mp_get_dataset("eggnog")
    expect_true(inherits(gson_obj, "GSON"))

    ora <- MicrobiomeProfiler::enrichEggNOG(c("OG0001", "OG0002"), minGSSize = 1, maxGSSize = 10)
    expect_s4_class(ora, class = "enrichResult")

    geneList <- c(2, 1, -1)
    names(geneList) <- c("OG0001", "OG0002", "OG0003")
    gsea <- MicrobiomeProfiler::gseEggNOG(geneList, minGSSize = 1, maxGSSize = 10)
    expect_true(is.null(gsea) || methods::is(gsea, "gseaResult"))
})
