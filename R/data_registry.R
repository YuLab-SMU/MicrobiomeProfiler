mp_external_registry <- function() {
    registry_path <- getOption("MicrobiomeProfiler.external_registry", default = NULL)
    if (is.null(registry_path) || !nzchar(registry_path)) {
        registry_path <- system.file("extdata", "external_data_registry.json",
                                     package = "MicrobiomeProfiler")
    }

    if (!nzchar(registry_path) || !file.exists(registry_path)) {
        stop("Cannot find external data registry.", call. = FALSE)
    }

    registry <- jsonlite::fromJSON(registry_path, simplifyVector = FALSE)
    if (is.null(registry$datasets) || !length(registry$datasets)) {
        stop("External data registry does not contain any dataset entries.",
             call. = FALSE)
    }

    registry
}


mp_resolve_dataset <- function(dataset) {
    if (missing(dataset) || !nzchar(dataset)) {
        stop("`dataset` must be a non-empty string.", call. = FALSE)
    }

    entry <- mp_external_registry()$datasets[[dataset]]
    if (is.null(entry)) {
        stop("Unknown external dataset: ", dataset, call. = FALSE)
    }

    required_fields <- c("dataset", "manifest_url")
    missing_fields <- required_fields[!vapply(required_fields,
                                              function(x) !is.null(entry[[x]]) &&
                                                  nzchar(entry[[x]]),
                                              logical(1))]
    if (length(missing_fields)) {
        stop("Dataset registry entry is missing required fields: ",
             paste(missing_fields, collapse = ", "),
             call. = FALSE)
    }

    entry
}
