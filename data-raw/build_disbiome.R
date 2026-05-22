build_disbiome_artifact <- function(
    output_dir = "build/external-data/disbiome/current",
    base_url = "https://yulab-smu.github.io/MicrobiomeProfiler/datasets/disbiome/current",
    version = format(Sys.Date(), "%Y-%m-%d")
) {
    pkgload::load_all(".")
    disbiome_gson <- get("disbiome_data2", envir = asNamespace("MicrobiomeProfiler"))

    if (!inherits(disbiome_gson, "GSON")) {
        stop("`disbiome_data2` is not a GSON object.", call. = FALSE)
    }

    dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

    artifact_file <- file.path(output_dir, "disbiome_gson.rds")
    saveRDS(disbiome_gson, artifact_file)

    manifest <- list(
        dataset = "disbiome",
        version = version,
        released_at = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
        source = "Disbiome",
        source_url = "https://disbiome.ugent.be/export",
        schema_version = "1.0.0",
        record_count = nrow(methods::slot(disbiome_gson, "gsid2gene")),
        artifact_files = list(list(
            name = basename(artifact_file),
            url = paste0(base_url, "/", basename(artifact_file)),
            sha256 = digest::digest(file = artifact_file, algo = "sha256",
                                    serialize = FALSE),
            size_bytes = unname(file.info(artifact_file)$size),
            object_type = "gson"
        ))
    )

    jsonlite::write_json(
        manifest,
        path = file.path(output_dir, "manifest.json"),
        auto_unbox = TRUE,
        pretty = TRUE
    )

    invisible(list(
        artifact_file = artifact_file,
        manifest = manifest
    ))
}
