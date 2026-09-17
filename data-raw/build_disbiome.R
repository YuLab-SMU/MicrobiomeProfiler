## Thin loader. The implementation lives in `R/build_disbiome.R` so that it
## ships with the package and is covered by `tests/testthat/test_build_disbiome.R`.
##
## Run from the package root (see `.github/workflows/update_external_data.yml`):
##
##   Rscript -e 'source("data-raw/build_disbiome.R");
##   build_disbiome_artifact(output_dir = "...", base_url = "...")'

pkgload::load_all(quiet = TRUE)
