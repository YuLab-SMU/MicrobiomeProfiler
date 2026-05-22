create_external_data_fixture <- function() {
    fixture_dir <- file.path(
        tempdir(),
        paste0("microbiomeprofiler-fixture-", Sys.getpid(), "-", as.integer(Sys.time()))
    )
    dir.create(fixture_dir, recursive = TRUE, showWarnings = FALSE)

    dataset <- list(
        dataset = "bugsigdb",
        version = "test-2026-05-22",
        term2gene = data.frame(
            term = c("sig_gut_obesity_up", "sig_gut_obesity_up", "sig_skin_healthy_up"),
            gene = c("1224", "1236", "9999"),
            stringsAsFactors = FALSE
        ),
        term2name = data.frame(
            term = c("sig_gut_obesity_up", "sig_skin_healthy_up"),
            name = c("obesity", "healthy skin"),
            stringsAsFactors = FALSE
        ),
        metadata = data.frame(
            term = c("sig_gut_obesity_up", "sig_skin_healthy_up"),
            condition = c("obesity", "healthy"),
            body_site = c("feces", "skin"),
            stringsAsFactors = FALSE
        )
    )

    artifact_path <- file.path(fixture_dir, "bugsigdb_signatures.rds")
    saveRDS(dataset, artifact_path)

    manifest <- list(
        dataset = "bugsigdb",
        version = dataset$version,
        released_at = "2026-05-22T00:00:00Z",
        source = "BugSigDB",
        source_url = "https://bugsigdb.org/",
        schema_version = "1.0.0",
        record_count = nrow(dataset$term2gene),
        artifact_files = list(list(
            name = basename(artifact_path),
            url = paste0("file:///", normalizePath(artifact_path, winslash = "/", mustWork = TRUE)),
            sha256 = digest::digest(file = artifact_path, algo = "sha256", serialize = FALSE),
            size_bytes = unname(file.info(artifact_path)$size),
            object_type = "term2gene_bundle"
        ))
    )

    manifest_path <- file.path(fixture_dir, "manifest.json")
    jsonlite::write_json(manifest, manifest_path, auto_unbox = TRUE, pretty = TRUE)

    registry <- list(
        datasets = list(
            bugsigdb = list(
                dataset = "bugsigdb",
                manifest_url = paste0(
                    "file:///",
                    normalizePath(manifest_path, winslash = "/", mustWork = TRUE)
                )
            )
        )
    )

    registry_path <- file.path(fixture_dir, "external_data_registry.json")
    jsonlite::write_json(registry, registry_path, auto_unbox = TRUE, pretty = TRUE)

    list(
        dir = fixture_dir,
        dataset = dataset,
        artifact_path = artifact_path,
        manifest = manifest,
        manifest_path = manifest_path,
        registry_path = registry_path
    )
}


create_disbiome_fixture <- function() {
    fixture_dir <- file.path(
        tempdir(),
        paste0("microbiomeprofiler-disbiome-fixture-", Sys.getpid(), "-", as.integer(Sys.time()))
    )
    dir.create(fixture_dir, recursive = TRUE, showWarnings = FALSE)

    gsid2gene <- data.frame(
        gsid = c("disease_a", "disease_a", "disease_b"),
        gene = c("1224", "1236", "9999"),
        stringsAsFactors = FALSE
    )
    gsid2name <- data.frame(
        gsid = c("disease_a", "disease_b"),
        name = c("disease a", "disease b"),
        stringsAsFactors = FALSE
    )
    gson_obj <- gson::gson(
        gsid2gene = gsid2gene,
        gsid2name = gsid2name,
        species = "microbiome",
        gsname = "Disbiome",
        version = "test-2026-05-22",
        keytype = "taxid",
        accessed_date = "2026-05-22"
    )

    artifact_path <- file.path(fixture_dir, "disbiome_gson.rds")
    saveRDS(gson_obj, artifact_path)

    manifest <- list(
        dataset = "disbiome",
        version = "test-2026-05-22",
        released_at = "2026-05-22T00:00:00Z",
        source = "Disbiome",
        source_url = "https://disbiome.ugent.be/export",
        schema_version = "1.0.0",
        record_count = nrow(gsid2gene),
        artifact_files = list(list(
            name = basename(artifact_path),
            url = paste0("file:///", normalizePath(artifact_path, winslash = "/", mustWork = TRUE)),
            sha256 = digest::digest(file = artifact_path, algo = "sha256", serialize = FALSE),
            size_bytes = unname(file.info(artifact_path)$size),
            object_type = "gson"
        ))
    )

    manifest_path <- file.path(fixture_dir, "manifest.json")
    jsonlite::write_json(manifest, manifest_path, auto_unbox = TRUE, pretty = TRUE)

    registry <- list(
        datasets = list(
            disbiome = list(
                dataset = "disbiome",
                manifest_url = paste0(
                    "file:///",
                    normalizePath(manifest_path, winslash = "/", mustWork = TRUE)
                )
            )
        )
    )

    registry_path <- file.path(fixture_dir, "external_data_registry.json")
    jsonlite::write_json(registry, registry_path, auto_unbox = TRUE, pretty = TRUE)

    list(
        dir = fixture_dir,
        artifact_path = artifact_path,
        manifest = manifest,
        manifest_path = manifest_path,
        registry_path = registry_path
    )
}
