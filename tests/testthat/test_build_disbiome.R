builder_env <- new.env(parent = globalenv())
sys.source(
    testthat::test_path("..", "..", "data-raw", "build_disbiome.R"),
    envir = builder_env
)


create_disbiome_builder_payload <- function() {
    list(
        experiments = data.frame(
            experiment_id = c(1, 2, 3, 4),
            disease_id = c(1, 1, 2, 3),
            organism_ncbi_id = c(1224, 1224, 1236, NA),
            stringsAsFactors = FALSE
        ),
        diseases = data.frame(
            disease_id = c(1, 2, 3),
            name = c("Autism", "Crohn's disease", "Missing mapping"),
            stage = c(NA, "new-onset", NA),
            stringsAsFactors = FALSE
        )
    )
}


test_that("normalize_disbiome_records removes invalid mappings and annotates stage", {
    payload <- create_disbiome_builder_payload()

    normalized <- builder_env$normalize_disbiome_records(
        experiments = payload$experiments,
        diseases = payload$diseases
    )

    expect_equal(nrow(normalized$gsid2gene), 2)
    expect_equal(sort(normalized$gsid2gene$gene), c("1224", "1236"))
    expect_equal(normalized$gsid2name$gsid, c("1", "2"))
    expect_equal(normalized$gsid2name$name, c("Autism", "Crohn's disease [new-onset]"))
})


test_that("build_disbiome_artifact writes manifest and gson artifact from payload", {
    payload <- create_disbiome_builder_payload()
    output_dir <- file.path(tempdir(), paste0("disbiome-builder-", Sys.getpid(), "-", as.integer(Sys.time())))

    fetch_json <- function(url, timeout = 300) {
        switch(
            url,
            experiment = payload$experiments,
            disease = payload$diseases,
            stop("Unexpected URL: ", url, call. = FALSE)
        )
    }

    result <- builder_env$build_disbiome_artifact(
        output_dir = output_dir,
        base_url = "https://example.org/datasets/disbiome/current",
        version = "test-version",
        experiment_url = "experiment",
        disease_url = "disease",
        fetch_json = fetch_json
    )

    expect_true(file.exists(result$artifact_file))
    expect_true(file.exists(file.path(output_dir, "manifest.json")))
    expect_type(result$manifest, "list")
    expect_equal(result$manifest$dataset, "disbiome")
    expect_equal(result$manifest$record_count, 2)
    expect_equal(result$manifest$artifact_files[[1]]$object_type, "gson")

    artifact <- readRDS(result$artifact_file)
    expect_true(inherits(artifact, "GSON"))
    expect_equal(nrow(methods::slot(artifact, "gsid2gene")), 2)
})
