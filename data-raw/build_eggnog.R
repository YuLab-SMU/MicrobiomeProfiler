download_eggnog_og_info <- function(
    url = "https://eggnogdb.org/public/eggnog7/e7.og_info_kegg_go.tsv.gz",
    destfile = tempfile(fileext = ".tsv.gz"),
    timeout = 600
) {
    old_timeout <- getOption("timeout")
    options(timeout = max(timeout, old_timeout))
    on.exit(options(timeout = old_timeout), add = TRUE)

    utils::download.file(url, destfile = destfile, mode = "wb", quiet = TRUE)
    destfile
}


fetch_kegg_pathway_map <- function(
    link_url = "https://rest.kegg.jp/link/pathway/ko",
    list_url = "https://rest.kegg.jp/list/pathway",
    timeout = 300
) {
    old_timeout <- getOption("timeout")
    options(timeout = max(timeout, old_timeout))
    on.exit(options(timeout = old_timeout), add = TRUE)

    ko2pathway <- utils::read.delim(
        link_url,
        header = FALSE,
        sep = "\t",
        quote = "",
        stringsAsFactors = FALSE
    )
    pathway_names <- utils::read.delim(
        list_url,
        header = FALSE,
        sep = "\t",
        quote = "",
        stringsAsFactors = FALSE
    )

    colnames(ko2pathway) <- c("ko", "gsid")
    colnames(pathway_names) <- c("gsid", "name")

    ko2pathway$ko <- sub("^ko:", "", ko2pathway$ko)
    ko2pathway$gsid <- sub("^path:", "", ko2pathway$gsid)
    pathway_names$gsid <- sub("^path:", "", pathway_names$gsid)

    list(
        ko2pathways = split(ko2pathway$gsid, ko2pathway$ko),
        gsid2name = unique(pathway_names)
    )
}


parse_eggnog_kos <- function(field) {
    if (is.null(field) || is.na(field) || !nzchar(field)) {
        return(character())
    }

    kos <- strsplit(field, ";", fixed = TRUE)[[1]]
    kos <- sub("\\|.*$", "", kos)
    unique(kos[grepl("^K\\d+$", kos)])
}


build_eggnog_pathway_table <- function(
    eggnog_file,
    ko2pathways,
    chunk_size = 50000
) {
    con <- gzfile(eggnog_file, open = "rt")
    on.exit(close(con), add = TRUE)

    chunks <- list()
    chunk_id <- 0L

    repeat {
        lines <- readLines(con, n = chunk_size, warn = FALSE)
        if (!length(lines)) {
            break
        }

        chunk_terms <- character()
        chunk_genes <- character()

        for (line in lines) {
            fields <- strsplit(line, "\t", fixed = TRUE)[[1]]
            if (length(fields) < 7L || !nzchar(fields[1]) || startsWith(fields[1], "#")) {
                next
            }

            kos <- parse_eggnog_kos(fields[7])
            if (!length(kos)) {
                next
            }

            pathways <- unique(unlist(ko2pathways[kos], use.names = FALSE))
            if (!length(pathways)) {
                next
            }

            chunk_terms <- c(chunk_terms, pathways)
            chunk_genes <- c(chunk_genes, rep(fields[1], length(pathways)))
        }

        if (!length(chunk_terms)) {
            next
        }

        chunk_id <- chunk_id + 1L
        chunks[[chunk_id]] <- data.frame(
            gsid = chunk_terms,
            gene = chunk_genes,
            stringsAsFactors = FALSE
        )
    }

    if (!length(chunks)) {
        stop("No eggNOG OG to KEGG pathway mappings were constructed.", call. = FALSE)
    }

    unique(do.call(rbind, chunks))
}


build_eggnog_gson <- function(
    eggnog_file,
    kegg_map,
    version = format(Sys.Date(), "%Y-%m-%d"),
    accessed_date = format(Sys.Date(), "%Y-%m-%d"),
    chunk_size = 50000
) {
    gsid2gene <- build_eggnog_pathway_table(
        eggnog_file = eggnog_file,
        ko2pathways = kegg_map$ko2pathways,
        chunk_size = chunk_size
    )
    gsid2name <- unique(kegg_map$gsid2name)
    gsid2name <- gsid2name[gsid2name$gsid %in% gsid2gene$gsid, , drop = FALSE]

    gson::gson(
        gsid2gene = gsid2gene,
        gsid2name = gsid2name,
        species = "microbiome",
        gsname = "eggNOG KEGG",
        version = version,
        keytype = "eggNOG_OG",
        accessed_date = accessed_date
    )
}


build_eggnog_artifact <- function(
    output_dir = "build/external-data/eggnog/current",
    base_url = "https://yulab-smu.github.io/MicrobiomeProfiler/datasets/eggnog/current",
    version = paste0("eggNOG7-", format(Sys.Date(), "%Y-%m-%d")),
    eggnog_url = "https://eggnogdb.org/public/eggnog7/e7.og_info_kegg_go.tsv.gz",
    timeout = 600,
    chunk_size = 50000,
    eggnog_file = NULL,
    fetch_kegg_map = fetch_kegg_pathway_map
) {
    if (is.null(eggnog_file)) {
        eggnog_file <- download_eggnog_og_info(
            url = eggnog_url,
            timeout = timeout
        )
    }

    kegg_map <- fetch_kegg_map(timeout = timeout)
    eggnog_gson <- build_eggnog_gson(
        eggnog_file = eggnog_file,
        kegg_map = kegg_map,
        version = version,
        chunk_size = chunk_size
    )

    dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

    artifact_file <- file.path(output_dir, "eggnog_kegg_gson.rds")
    saveRDS(eggnog_gson, artifact_file)

    manifest <- list(
        dataset = "eggnog",
        version = version,
        released_at = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
        source = "eggNOG 7",
        source_url = eggnog_url,
        schema_version = "1.0.0",
        record_count = nrow(methods::slot(eggnog_gson, "gsid2gene")),
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
