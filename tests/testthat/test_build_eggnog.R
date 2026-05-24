builder_env <- new.env(parent = globalenv())
sys.source(
    testthat::test_path("..", "..", "data-raw", "build_eggnog.R"),
    envir = builder_env
)


create_eggnog_builder_file <- function() {
    file <- tempfile(fileext = ".tsv.gz")
    con <- gzfile(file, open = "wt")
    writeLines(
        c(
            paste(
                "OG0001", "fam1", "2", "5", "3", "a,b,c", "K00001|50;K00002|25", "sym1|50;sym2|25", "GO:0001|1",
                sep = "\t"
            ),
            paste(
                "OG0002", "fam2", "2", "5", "3", "d,e,f", "K00002|80", "sym2|80", "",
                sep = "\t"
            ),
            paste(
                "OG0003", "fam3", "2", "5", "3", "g,h,i", "", "", "",
                sep = "\t"
            )
        ),
        con = con
    )
    close(con)
    file
}


test_that("parse_eggnog_kos extracts valid KEGG identifiers", {
    kos <- builder_env$parse_eggnog_kos("K00001|50;K00002|10;not_a_ko|5")
    expect_equal(kos, c("K00001", "K00002"))
    expect_equal(builder_env$parse_eggnog_kos(""), character())
})


test_that("build_eggnog_artifact constructs GSON from eggNOG OG annotations", {
    eggnog_file <- create_eggnog_builder_file()
    output_dir <- file.path(tempdir(), paste0("eggnog-builder-", Sys.getpid(), "-", as.integer(Sys.time())))

    fetch_kegg_map <- function(timeout = 300) {
        list(
            ko2pathways = list(
                K00001 = c("map00010"),
                K00002 = c("map00010", "map00020")
            ),
            gsid2name = data.frame(
                gsid = c("map00010", "map00020"),
                name = c("Glycolysis / Gluconeogenesis", "Citrate cycle"),
                stringsAsFactors = FALSE
            )
        )
    }

    result <- builder_env$build_eggnog_artifact(
        output_dir = output_dir,
        base_url = "https://example.org/datasets/eggnog/current",
        version = "test-version",
        eggnog_file = eggnog_file,
        chunk_size = 2,
        fetch_kegg_map = fetch_kegg_map
    )

    expect_true(file.exists(result$artifact_file))
    expect_true(file.exists(file.path(output_dir, "manifest.json")))
    expect_equal(result$manifest$dataset, "eggnog")
    expect_equal(result$manifest$artifact_files[[1]]$object_type, "gson")

    artifact <- readRDS(result$artifact_file)
    expect_true(inherits(artifact, "GSON"))
    expect_equal(sort(unique(methods::slot(artifact, "gsid2gene")$gene)), c("OG0001", "OG0002"))
    expect_true(all(c("map00010", "map00020") %in% methods::slot(artifact, "gsid2gene")$gsid))
})
