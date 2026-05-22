mp_cache_dir <- function() {
    cache_dir <- getOption(
        "MicrobiomeProfiler.cache_dir",
        default = tools::R_user_dir("MicrobiomeProfiler", which = "cache")
    )

    if (!dir.exists(cache_dir)) {
        dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
    }

    normalizePath(cache_dir, winslash = "/", mustWork = FALSE)
}


mp_dataset_cache_path <- function(dataset, version = NULL) {
    cache_path <- file.path(mp_cache_dir(), "datasets", dataset)
    if (!is.null(version) && nzchar(version)) {
        cache_path <- file.path(cache_path, version)
    }

    cache_path
}


mp_registry_cache_path <- function() {
    file.path(mp_cache_dir(), "registry")
}
