build_bugsigdb_artifact <- function(
    output_dir = "build/external-data/bugsigdb/current",
    base_url = "https://yulab-smu.github.io/MicrobiomeProfiler/datasets/bugsigdb/current",
    version = format(Sys.Date(), "%Y-%m-%d")
) {
    if (!requireNamespace("bugsigdbr", quietly = TRUE)) {
        stop("Package `bugsigdbr` is required to build BugSigDB artifacts.",
             call. = FALSE)
    }

    dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

    bsdb <- bugsigdbr::importBugSigDB(cache = FALSE)
    signatures <- bugsigdbr::getSignatures(bsdb)
    signatures <- signatures[lengths(signatures) > 0]

    if (!length(signatures)) {
        stop("No BugSigDB signatures were retrieved.", call. = FALSE)
    }

    term2gene <- do.call(
        rbind,
        lapply(names(signatures), function(term) {
            data.frame(
                term = term,
                gene = as.character(signatures[[term]]),
                stringsAsFactors = FALSE
            )
        })
    )
    term2gene <- unique(term2gene)

    term_keys <- if ("Signature page name" %in% colnames(bsdb)) {
        bsdb[["Signature page name"]]
    } else {
        names(signatures)
    }

    term_labels <- if ("Condition" %in% colnames(bsdb)) {
        bsdb[["Condition"]]
    } else {
        term_keys
    }

    term2name <- unique(data.frame(
        term = term_keys,
        name = term_labels,
        stringsAsFactors = FALSE
    ))
    term2name <- term2name[!is.na(term2name$term) & nzchar(term2name$term), ]
    term2name$name[is.na(term2name$name) | !nzchar(term2name$name)] <- term2name$term[
        is.na(term2name$name) | !nzchar(term2name$name)
    ]

    metadata_columns <- intersect(
        c("Signature page name", "Condition", "Body site",
          "Host species", "Abundance in Group 1"),
        colnames(bsdb)
    )
    metadata <- unique(bsdb[, metadata_columns, drop = FALSE])
    colnames(metadata)[colnames(metadata) == "Signature page name"] <- "term"
    if (!"term" %in% colnames(metadata)) {
        metadata <- data.frame(term = names(signatures), stringsAsFactors = FALSE)
    }

    artifact <- list(
        dataset = "bugsigdb",
        version = version,
        term2gene = term2gene,
        term2name = term2name,
        metadata = metadata
    )

    artifact_file <- file.path(output_dir, "bugsigdb_signatures.rds")
    saveRDS(artifact, artifact_file)

    manifest <- list(
        dataset = "bugsigdb",
        version = version,
        released_at = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
        source = "BugSigDB",
        source_url = "https://bugsigdb.org/",
        schema_version = "1.0.0",
        record_count = nrow(term2gene),
        artifact_files = list(list(
            name = basename(artifact_file),
            url = paste0(base_url, "/", basename(artifact_file)),
            sha256 = digest::digest(file = artifact_file, algo = "sha256",
                                    serialize = FALSE),
            size_bytes = unname(file.info(artifact_file)$size),
            object_type = "term2gene_bundle"
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
