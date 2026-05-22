test_that("external registry can resolve bundled and fixture datasets", {
    library(MicrobiomeProfiler)

    entry <- MicrobiomeProfiler:::mp_resolve_dataset("bugsigdb")
    expect_equal(entry$dataset, "bugsigdb")
    expect_true(grepl("manifest\\.json$", entry$manifest_url))

    fixture <- create_external_data_fixture()
    old_registry <- getOption("MicrobiomeProfiler.external_registry")
    options(MicrobiomeProfiler.external_registry = fixture$registry_path)
    on.exit(options(MicrobiomeProfiler.external_registry = old_registry), add = TRUE)

    fixture_entry <- MicrobiomeProfiler:::mp_resolve_dataset("bugsigdb")
    expect_equal(fixture_entry$dataset, "bugsigdb")
    expect_match(fixture_entry$manifest_url, "manifest\\.json$")
})


test_that("unknown external dataset fails clearly", {
    library(MicrobiomeProfiler)
    expect_error(
        MicrobiomeProfiler:::mp_resolve_dataset("missing_dataset"),
        "Unknown external dataset"
    )
})
