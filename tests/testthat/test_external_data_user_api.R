test_that("available_datasets reports registry entries and cache state", {
    library(MicrobiomeProfiler)

    bug_fixture <- create_external_data_fixture()
    dis_fixture <- create_disbiome_fixture()
    registry_path <- create_registry_fixture(list(
        bugsigdb = list(
            dataset = "bugsigdb",
            manifest_url = paste0(
                "file:///",
                normalizePath(bug_fixture$manifest_path, winslash = "/", mustWork = TRUE)
            )
        ),
        disbiome = list(
            dataset = "disbiome",
            manifest_url = paste0(
                "file:///",
                normalizePath(dis_fixture$manifest_path, winslash = "/", mustWork = TRUE)
            )
        )
    ))

    cache_dir <- file.path(tempdir(), "MicrobiomeProfiler-user-api-cache")
    unlink(cache_dir, recursive = TRUE, force = TRUE)

    old_registry <- getOption("MicrobiomeProfiler.external_registry")
    old_cache <- getOption("MicrobiomeProfiler.cache_dir")
    options(
        MicrobiomeProfiler.external_registry = registry_path,
        MicrobiomeProfiler.cache_dir = cache_dir
    )
    on.exit({
        options(
            MicrobiomeProfiler.external_registry = old_registry,
            MicrobiomeProfiler.cache_dir = old_cache
        )
        unlink(cache_dir, recursive = TRUE, force = TRUE)
    }, add = TRUE)

    info <- available_datasets()
    expect_true(all(c("bugsigdb", "disbiome") %in% info$dataset))
    expect_false(any(info$cached))

    remote_info <- available_datasets(include_remote = TRUE)
    expect_true(all(remote_info$remote_available))
    expect_true(all(nzchar(remote_info$remote_version)))
})


test_that("download_dataset and dataset_cache_info describe cached artifacts", {
    library(MicrobiomeProfiler)

    fixture <- create_external_data_fixture()
    cache_dir <- file.path(tempdir(), "MicrobiomeProfiler-user-api-download")
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

    downloaded <- download_dataset("bugsigdb")
    expect_equal(downloaded$dataset, "bugsigdb")
    expect_true(file.exists(downloaded$manifest_path))
    expect_equal(downloaded$object_type, "term2gene_bundle")

    cache_info <- dataset_cache_info("bugsigdb")
    expect_equal(nrow(cache_info), 1)
    expect_equal(cache_info$dataset, "bugsigdb")
    expect_equal(cache_info$artifact_count, 1)
    expect_true(cache_info$size_bytes > 0)
})


test_that("clear_dataset_cache removes one dataset or the whole cache", {
    library(MicrobiomeProfiler)

    bug_fixture <- create_external_data_fixture()
    dis_fixture <- create_disbiome_fixture()
    registry_path <- create_registry_fixture(list(
        bugsigdb = list(
            dataset = "bugsigdb",
            manifest_url = paste0(
                "file:///",
                normalizePath(bug_fixture$manifest_path, winslash = "/", mustWork = TRUE)
            )
        ),
        disbiome = list(
            dataset = "disbiome",
            manifest_url = paste0(
                "file:///",
                normalizePath(dis_fixture$manifest_path, winslash = "/", mustWork = TRUE)
            )
        )
    ))

    cache_dir <- file.path(tempdir(), "MicrobiomeProfiler-user-api-clear")
    unlink(cache_dir, recursive = TRUE, force = TRUE)

    old_registry <- getOption("MicrobiomeProfiler.external_registry")
    old_cache <- getOption("MicrobiomeProfiler.cache_dir")
    options(
        MicrobiomeProfiler.external_registry = registry_path,
        MicrobiomeProfiler.cache_dir = cache_dir
    )
    on.exit({
        options(
            MicrobiomeProfiler.external_registry = old_registry,
            MicrobiomeProfiler.cache_dir = old_cache
        )
        unlink(cache_dir, recursive = TRUE, force = TRUE)
    }, add = TRUE)

    download_dataset("bugsigdb")
    download_dataset("disbiome")
    expect_true(nrow(dataset_cache_info()) >= 2)

    clear_dataset_cache("bugsigdb")
    remaining <- dataset_cache_info()
    expect_false("bugsigdb" %in% remaining$dataset)
    expect_true("disbiome" %in% remaining$dataset)

    clear_dataset_cache()
    expect_equal(nrow(dataset_cache_info()), 0)
})
