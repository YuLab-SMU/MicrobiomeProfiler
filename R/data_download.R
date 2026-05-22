mp_is_remote_resource <- function(path) {
    grepl("^(https?|file)://", path)
}


mp_sha256 <- function(file) {
    digest::digest(file = file, algo = "sha256", serialize = FALSE)
}


mp_download_file <- function(url, destfile) {
    dir.create(dirname(destfile), recursive = TRUE, showWarnings = FALSE)

    if (file.exists(destfile)) {
        file.remove(destfile)
    }

    if (!mp_is_remote_resource(url) && file.exists(url)) {
        ok <- file.copy(url, destfile, overwrite = TRUE)
        if (!ok) {
            stop("Failed to copy local file: ", url, call. = FALSE)
        }
        return(invisible(destfile))
    }

    utils::download.file(url, destfile = destfile, mode = "wb", quiet = TRUE)
    invisible(destfile)
}


mp_fetch_manifest <- function(manifest_url) {
    manifest_file <- tempfile(fileext = ".json")
    on.exit(unlink(manifest_file), add = TRUE)

    mp_download_file(manifest_url, manifest_file)
    manifest <- jsonlite::fromJSON(manifest_file, simplifyVector = FALSE)

    required_fields <- c("dataset", "version", "artifact_files")
    missing_fields <- required_fields[!vapply(required_fields,
                                              function(x) !is.null(manifest[[x]]),
                                              logical(1))]
    if (length(missing_fields)) {
        stop("Manifest is missing required fields: ",
             paste(missing_fields, collapse = ", "),
             call. = FALSE)
    }

    manifest
}


mp_validate_artifact <- function(file, sha256) {
    if (!file.exists(file)) {
        return(FALSE)
    }

    identical(mp_sha256(file), sha256)
}


mp_download_artifact <- function(artifact, dest_dir, refresh = FALSE) {
    required_fields <- c("name", "url", "sha256")
    missing_fields <- required_fields[!vapply(required_fields,
                                              function(x) !is.null(artifact[[x]]) &&
                                                  nzchar(artifact[[x]]),
                                              logical(1))]
    if (length(missing_fields)) {
        stop("Artifact entry is missing required fields: ",
             paste(missing_fields, collapse = ", "),
             call. = FALSE)
    }

    destfile <- file.path(dest_dir, artifact$name)
    if (!refresh && mp_validate_artifact(destfile, artifact$sha256)) {
        return(destfile)
    }

    mp_download_file(artifact$url, destfile)
    if (!mp_validate_artifact(destfile, artifact$sha256)) {
        unlink(destfile)
        stop("Checksum validation failed for artifact: ", artifact$name,
             call. = FALSE)
    }

    destfile
}
