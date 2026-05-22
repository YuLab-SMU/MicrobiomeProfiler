test_that("Disbiome external runtime supports remote-first enrichMDA", {
    library(MicrobiomeProfiler)

    fixture <- create_disbiome_fixture()
    cache_dir <- file.path(tempdir(), "MicrobiomeProfiler-disbiome-cache-test")
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

    gson_obj <- MicrobiomeProfiler:::mp_get_dataset("disbiome")
    expect_true(inherits(gson_obj, "GSON"))

    res <- MicrobiomeProfiler::enrichMDA(c("1224", "1236"), minGSSize = 1, maxGSSize = 10)
    expect_s4_class(res, class = "enrichResult")
})
