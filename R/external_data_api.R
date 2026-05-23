#' List configured external datasets
#'
#' @param include_remote whether to fetch remote manifests and include remote
#' version metadata.
#' @return A data.frame describing configured datasets and cache status.
#' @export
available_datasets <- function(include_remote = FALSE) {
    registry <- mp_external_registry()$datasets
    dataset_names <- names(registry)

    remote_info <- lapply(dataset_names, function(dataset) {
        if (!isTRUE(include_remote)) {
            return(list(
                remote_available = NA,
                remote_version = NA_character_,
                released_at = NA_character_
            ))
        }

        tryCatch(
            {
                manifest <- mp_fetch_manifest(registry[[dataset]]$manifest_url)
                list(
                    remote_available = TRUE,
                    remote_version = manifest$version %||% NA_character_,
                    released_at = manifest$released_at %||% NA_character_
                )
            },
            error = function(e) {
                list(
                    remote_available = FALSE,
                    remote_version = NA_character_,
                    released_at = NA_character_
                )
            }
        )
    })

    cached_info <- lapply(dataset_names, function(dataset) {
        dataset_root <- mp_dataset_cache_path(dataset)
        version_dirs <- if (dir.exists(dataset_root)) {
            dirs <- list.dirs(dataset_root, recursive = FALSE, full.names = TRUE)
            basename(dirs)
        } else {
            character(0)
        }

        list(
            cached = length(version_dirs) > 0,
            cached_versions = paste(version_dirs, collapse = ", ")
        )
    })

    data.frame(
        dataset = dataset_names,
        manifest_url = vapply(registry, `[[`, character(1), "manifest_url"),
        cached = vapply(cached_info, `[[`, logical(1), "cached"),
        cached_versions = vapply(cached_info, `[[`, character(1), "cached_versions"),
        remote_available = vapply(remote_info, `[[`, logical(1), "remote_available"),
        remote_version = vapply(remote_info, `[[`, character(1), "remote_version"),
        released_at = vapply(remote_info, `[[`, character(1), "released_at"),
        stringsAsFactors = FALSE
    )
}


#' Download an external dataset into the local cache
#'
#' @param dataset dataset key registered in the external data registry.
#' @param refresh whether to force a fresh download even if a valid cached
#' artifact already exists.
#' @return A list with cache metadata for the downloaded dataset.
#' @export
download_dataset <- function(dataset, refresh = FALSE) {
    cached <- mp_cache_dataset(dataset = dataset, refresh = refresh)
    cached$object <- NULL
    cached
}


#' Summarize the local external data cache
#'
#' @param dataset optional dataset key. If omitted, return all cached datasets.
#' @return A data.frame with one row per cached dataset version.
#' @export
dataset_cache_info <- function(dataset = NULL) {
    if (is.null(dataset)) {
        datasets <- names(mp_external_registry()$datasets)
    } else {
        mp_resolve_dataset(dataset)
        datasets <- dataset
    }

    rows <- lapply(datasets, function(dataset_name) {
        dataset_root <- mp_dataset_cache_path(dataset_name)
        if (!dir.exists(dataset_root)) {
            return(NULL)
        }

        version_dirs <- list.dirs(dataset_root, recursive = FALSE, full.names = TRUE)
        lapply(version_dirs, function(version_dir) {
            manifest_path <- file.path(version_dir, "manifest.json")
            manifest <- if (file.exists(manifest_path)) {
                jsonlite::fromJSON(manifest_path, simplifyVector = FALSE)
            } else {
                NULL
            }

            files <- list.files(version_dir, recursive = TRUE, full.names = TRUE)
            files <- files[file.info(files)$isdir %in% FALSE]
            size_bytes <- if (length(files)) {
                sum(file.info(files)$size, na.rm = TRUE)
            } else {
                0
            }

            data.frame(
                dataset = dataset_name,
                version = basename(version_dir),
                cached = TRUE,
                object_type = if (!is.null(manifest$artifact_files[[1]]$object_type)) {
                    manifest$artifact_files[[1]]$object_type
                } else {
                    NA_character_
                },
                artifact_count = if (!is.null(manifest$artifact_files)) {
                    length(manifest$artifact_files)
                } else {
                    0L
                },
                size_bytes = unname(size_bytes),
                cache_dir = normalizePath(version_dir, winslash = "/", mustWork = FALSE),
                manifest_path = normalizePath(manifest_path, winslash = "/", mustWork = FALSE),
                stringsAsFactors = FALSE
            )
        })
    })

    rows <- unlist(rows, recursive = FALSE)
    if (!length(rows)) {
        return(data.frame(
            dataset = character(0),
            version = character(0),
            cached = logical(0),
            object_type = character(0),
            artifact_count = integer(0),
            size_bytes = numeric(0),
            cache_dir = character(0),
            manifest_path = character(0),
            stringsAsFactors = FALSE
        ))
    }

    do.call(rbind, rows)
}


#' Remove cached external dataset artifacts
#'
#' @param dataset optional dataset key. If omitted, remove all cached datasets.
#' @return Invisibly returns \code{TRUE} when cache removal completes.
#' @export
clear_dataset_cache <- function(dataset = NULL) {
    datasets_root <- file.path(mp_cache_dir(), "datasets")
    if (!dir.exists(datasets_root)) {
        return(invisible(TRUE))
    }

    if (is.null(dataset)) {
        unlink(datasets_root, recursive = TRUE, force = TRUE)
        return(invisible(TRUE))
    }

    mp_resolve_dataset(dataset)
    unlink(file.path(datasets_root, dataset), recursive = TRUE, force = TRUE)
    invisible(TRUE)
}


`%||%` <- function(x, y) {
    if (is.null(x) || (is.character(x) && !length(x))) {
        y
    } else {
        x
    }
}
