fetch_disbiome_json <- function(url, timeout = 300) {
    old_timeout <- getOption("timeout")
    options(timeout = max(timeout, old_timeout))
    on.exit(options(timeout = old_timeout), add = TRUE)

    tryCatch(
        jsonlite::fromJSON(url, simplifyVector = TRUE),
        error = function(e) {
            stop(
                "Failed to fetch Disbiome payload from `", url, "`: ",
                conditionMessage(e),
                call. = FALSE
            )
        }
    )
}


normalize_disbiome_records <- function(experiments, diseases) {
    experiments <- as.data.frame(experiments, stringsAsFactors = FALSE)
    diseases <- as.data.frame(diseases, stringsAsFactors = FALSE)

    required_experiment_columns <- c("disease_id", "organism_ncbi_id")
    missing_experiment_columns <- setdiff(required_experiment_columns, colnames(experiments))
    if (length(missing_experiment_columns)) {
        stop(
            "Disbiome experiment payload is missing required columns: ",
            paste(missing_experiment_columns, collapse = ", "),
            call. = FALSE
        )
    }

    if (!"disease_id" %in% colnames(diseases)) {
        stop("Disbiome disease payload is missing required column: disease_id",
             call. = FALSE)
    }
    if (!"name" %in% colnames(diseases)) {
        stop("Disbiome disease payload is missing required column: name",
             call. = FALSE)
    }

    gsid2gene <- unique(data.frame(
        gsid = as.character(experiments$disease_id),
        gene = as.character(experiments$organism_ncbi_id),
        stringsAsFactors = FALSE
    ))
    gsid2gene <- gsid2gene[
        !is.na(gsid2gene$gsid) &
            nzchar(gsid2gene$gsid) &
            !is.na(gsid2gene$gene) &
            nzchar(gsid2gene$gene),
        ,
        drop = FALSE
    ]

    gsid2name <- unique(data.frame(
        gsid = as.character(diseases$disease_id),
        name = as.character(diseases$name),
        stringsAsFactors = FALSE
    ))
    if ("stage" %in% colnames(diseases)) {
        stage <- as.character(diseases$stage)
        has_stage <- !is.na(stage) & nzchar(stage)
        gsid2name$name[has_stage] <- sprintf("%s [%s]", gsid2name$name[has_stage], stage[has_stage])
    }
    gsid2name <- gsid2name[
        !is.na(gsid2name$gsid) &
            nzchar(gsid2name$gsid) &
            !is.na(gsid2name$name) &
            nzchar(gsid2name$name),
        ,
        drop = FALSE
    ]

    # Keep only diseases that have at least one mapped NCBI taxid.
    gsid2name <- gsid2name[gsid2name$gsid %in% gsid2gene$gsid, , drop = FALSE]

    list(
        gsid2gene = gsid2gene,
        gsid2name = gsid2name
    )
}


build_disbiome_gson <- function(experiments, diseases, version = format(Sys.Date(), "%Y-%m-%d")) {
    normalized <- normalize_disbiome_records(experiments, diseases)

    if (!nrow(normalized$gsid2gene)) {
        stop("No valid Disbiome disease-taxon mappings were retrieved.", call. = FALSE)
    }

    gson::gson(
        gsid2gene = normalized$gsid2gene,
        gsid2name = normalized$gsid2name,
        species = "microbiome",
        gsname = "Disbiome",
        version = version,
        keytype = "taxid",
        accessed_date = format(Sys.Date(), "%Y-%m-%d")
    )
}


build_disbiome_artifact <- function(
    output_dir = "build/external-data/disbiome/current",
    base_url = "https://yulab-smu.github.io/MicrobiomeProfiler/datasets/disbiome/current",
    version = format(Sys.Date(), "%Y-%m-%d"),
    experiment_url = "https://disbiome.ugent.be:8080/experiment",
    disease_url = "https://disbiome.ugent.be:8080/disease",
    fetch_json = fetch_disbiome_json,
    timeout = 300
) {
    experiments <- fetch_json(experiment_url, timeout = timeout)
    diseases <- fetch_json(disease_url, timeout = timeout)
    disbiome_gson <- build_disbiome_gson(
        experiments = experiments,
        diseases = diseases,
        version = version
    )

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
