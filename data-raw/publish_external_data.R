publish_external_data <- function(
    source_root = "build/external-data",
    gh_pages_dir = "build/gh-pages"
) {
    datasets_src <- normalizePath(source_root, winslash = "/", mustWork = TRUE)
    dir.create(gh_pages_dir, recursive = TRUE, showWarnings = FALSE)
    gh_pages_dir <- normalizePath(gh_pages_dir, winslash = "/", mustWork = TRUE)

    datasets_dest <- file.path(gh_pages_dir, "datasets")
    dir.create(datasets_dest, recursive = TRUE, showWarnings = FALSE)

    dataset_dirs <- list.dirs(datasets_src, recursive = FALSE, full.names = TRUE)
    if (!length(dataset_dirs)) {
        stop("No external datasets were found under source_root.", call. = FALSE)
    }

    for (dataset_dir in dataset_dirs) {
        dest_dir <- file.path(datasets_dest, basename(dataset_dir))
        if (dir.exists(dest_dir)) {
            unlink(dest_dir, recursive = TRUE, force = TRUE)
        }
        ok <- file.copy(dataset_dir, datasets_dest, recursive = TRUE)
        if (!ok) {
            stop("Failed to publish dataset directory: ", basename(dataset_dir),
                 call. = FALSE)
        }
    }

    manifest_files <- list.files(
        datasets_dest,
        pattern = "manifest\\.json$",
        recursive = TRUE,
        full.names = TRUE
    )

    index <- lapply(manifest_files, function(path) {
        manifest <- jsonlite::fromJSON(path, simplifyVector = FALSE)
        list(
            dataset = manifest$dataset,
            version = manifest$version,
            released_at = manifest$released_at,
            manifest_path = gsub("^.*?/datasets/", "datasets/", path)
        )
    })

    jsonlite::write_json(
        list(datasets = index),
        path = file.path(gh_pages_dir, "index.json"),
        auto_unbox = TRUE,
        pretty = TRUE
    )

    latest <- setNames(index, vapply(index, `[[`, character(1), "dataset"))
    jsonlite::write_json(
        list(datasets = latest),
        path = file.path(gh_pages_dir, "latest.json"),
        auto_unbox = TRUE,
        pretty = TRUE
    )

    invisible(list(
        datasets = dataset_dirs,
        manifests = manifest_files
    ))
}
