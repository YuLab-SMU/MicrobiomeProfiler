test_that("external dataset can be downloaded into cache and loaded", {
    library(MicrobiomeProfiler)

    fixture <- create_external_data_fixture()
    cache_dir <- file.path(tempdir(), "MicrobiomeProfiler-cache-test")
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

    object <- MicrobiomeProfiler:::mp_get_dataset("bugsigdb")
    expect_equal(object$dataset, "bugsigdb")
    expect_true(all(c("term", "gene") %in% colnames(object$term2gene)))

    cached_artifact <- file.path(
        cache_dir,
        "datasets",
        "bugsigdb",
        fixture$dataset$version,
        "bugsigdb_signatures.rds"
    )
    expect_true(file.exists(cached_artifact))
    expect_true(MicrobiomeProfiler:::mp_validate_artifact(
        cached_artifact,
        fixture$manifest$artifact_files[[1]]$sha256
    ))
})
