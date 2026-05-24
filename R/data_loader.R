mp_validate_dataset_object <- function(object, object_type) {
    if (identical(object_type, "term2gene_bundle")) {
        required_fields <- c("dataset", "version", "term2gene", "term2name", "metadata")
        missing_fields <- required_fields[!vapply(required_fields,
                                                  function(x) !is.null(object[[x]]),
                                                  logical(1))]
        if (length(missing_fields)) {
            stop("Dataset object is missing required fields: ",
                 paste(missing_fields, collapse = ", "),
                 call. = FALSE)
        }

        if (!is.data.frame(object$term2gene) ||
            !all(c("term", "gene") %in% colnames(object$term2gene))) {
            stop("`term2gene` must be a data.frame with `term` and `gene` columns.",
                 call. = FALSE)
        }

        if (!is.data.frame(object$term2name) ||
            !all(c("term", "name") %in% colnames(object$term2name))) {
            stop("`term2name` must be a data.frame with `term` and `name` columns.",
                 call. = FALSE)
        }

        if (!is.data.frame(object$metadata) || !"term" %in% colnames(object$metadata)) {
            stop("`metadata` must be a data.frame with a `term` column.",
                 call. = FALSE)
        }

        return(invisible(TRUE))
    }

    if (identical(object_type, "gson")) {
        if (!inherits(object, "GSON")) {
            stop("Expected a `GSON` object for artifact type `gson`.",
                 call. = FALSE)
        }

        required_slots <- c("gsid2gene", "gsid2name", "species", "gsname",
                            "version", "accessed_date", "keytype")
        missing_slots <- required_slots[!required_slots %in% methods::slotNames(object)]
        if (length(missing_slots)) {
            stop("GSON object is missing required slots: ",
                 paste(missing_slots, collapse = ", "),
                 call. = FALSE)
        }

        return(invisible(TRUE))
    }

    stop("Unsupported artifact object type: ", object_type, call. = FALSE)
}


mp_load_dataset_file <- function(file, object_type) {
    object <- readRDS(file)
    mp_validate_dataset_object(object, object_type = object_type)
    object
}


mp_cache_dataset <- function(dataset, refresh = FALSE) {
    entry <- mp_resolve_dataset(dataset)
    manifest <- mp_fetch_manifest(entry$manifest_url)

    if (!identical(manifest$dataset, dataset)) {
        stop("Manifest dataset key does not match requested dataset: ", dataset,
             call. = FALSE)
    }

    if (!length(manifest$artifact_files)) {
        stop("Manifest does not contain any artifact files.", call. = FALSE)
    }

    version <- manifest$version
    dataset_dir <- mp_dataset_cache_path(dataset, version)
    dir.create(dataset_dir, recursive = TRUE, showWarnings = FALSE)

    manifest_path <- file.path(dataset_dir, "manifest.json")
    jsonlite::write_json(manifest, manifest_path, auto_unbox = TRUE, pretty = TRUE)

    artifact_paths <- vapply(
        manifest$artifact_files,
        function(artifact) mp_download_artifact(artifact, dataset_dir, refresh = refresh),
        character(1)
    )

    object_type <- manifest$artifact_files[[1]]$object_type
    if (is.null(object_type) || !nzchar(object_type)) {
        stop("Manifest artifact is missing `object_type`.", call. = FALSE)
    }

    object <- mp_load_dataset_file(artifact_paths[[1]], object_type = object_type)

    list(
        dataset = dataset,
        version = version,
        manifest = manifest,
        dataset_dir = dataset_dir,
        manifest_path = manifest_path,
        artifact_paths = unname(artifact_paths),
        object_type = object_type,
        object = object
    )
}


mp_get_dataset <- function(dataset, refresh = FALSE) {
    mp_cache_dataset(dataset = dataset, refresh = refresh)$object
}


mp_disbiome_gson <- function(refresh = FALSE) {
    tryCatch(
        suppressWarnings(mp_get_dataset("disbiome", refresh = refresh)),
        error = function(e) {
            message("Falling back to bundled Disbiome data: ", conditionMessage(e))
            disbiome_data2
        }
    )
}


mp_eggnog_gson <- function(refresh = FALSE) {
    tryCatch(
        suppressWarnings(mp_get_dataset("eggnog", refresh = refresh)),
        error = function(e) {
            stop("Failed to load eggNOG external dataset: ",
                 conditionMessage(e),
                 call. = FALSE)
        }
    )
}
