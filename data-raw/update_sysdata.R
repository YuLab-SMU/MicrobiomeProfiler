# data-raw/update_sysdata.R
library(pkgload)
pkgload::load_all()

# Load current sysdata into a specific environment
sysdata_env <- new.env()
load("R/sysdata.rda", envir = sysdata_env)

# Function to safely update
safe_update <- function(name, func, ...) {
    message(sprintf("Updating %s...", name))
    tryCatch({
        res <- func(...)
        if(!is.null(res)) {
            sysdata_env[[name]] <- res
            message(sprintf("Successfully updated %s", name))
        }
    }, error = function(e) {
        warning(sprintf("Failed to update %s: %s", name, e$message))
    })
}

# Update KEGG related gson objects using package's internal functions
safe_update("ko_gson", gson_KO)
safe_update("ec_gson", gson_enzyme)
safe_update("cpd_gson", gson_cpd)
safe_update("module_gson.KO", gson_module, db="ko")
safe_update("module_gson.ec", gson_module, db="enzyme")

# Update COG data
cog_data <- update_cog_data()
if (!is.null(cog_data)) {
    sysdata_env$cog_category <- cog_data$cog_category
    sysdata_env$cog_pathway <- cog_data$cog_pathway
    message("Successfully updated COG data")
}

# Update SMPDB and HMDB data
smpdb_data <- update_smpdb_hmdb_data()
if (!is.null(smpdb_data)) {
    sysdata_env$smpdb_gson <- smpdb_data$smpdb_gson
    sysdata_env$hmdb_gson <- smpdb_data$hmdb_gson
    message("Successfully updated SMPDB/HMDB data")
}

# Note: Disbiome does not offer a direct stable data download URL for automated scripts.
# To update `disbiome_data2`, please download the export file manually from 
# https://disbiome.ugent.be/export and update it here.

# Save back to R/sysdata.rda
message("Saving R/sysdata.rda...")
save(list = ls(sysdata_env), envir = sysdata_env, file = "R/sysdata.rda", compress = "xz")
message("Update completed.")