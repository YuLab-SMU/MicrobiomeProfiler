test_that("BugSigDB enrichment works with fixture-backed remote data", {
    library(MicrobiomeProfiler)

    fixture <- create_external_data_fixture()
    cache_dir <- file.path(tempdir(), "MicrobiomeProfiler-bugsigdb-test")
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

    x <- c("1224", "1236")
    res <- MicrobiomeProfiler::enrichBugSigDB(x, minGSSize = 1, maxGSSize = 10)
    expect_s4_class(res, class = "enrichResult")

    y <- c("not_in_bugsigdb")
    res2 <- MicrobiomeProfiler::enrichBugSigDB(y, minGSSize = 1, maxGSSize = 10)
    expect_equal(res2, NULL)
})
