# Set options here
options(golem.app.prod = FALSE) # TRUE = production mode, FALSE = development mode

# Detach all loaded packages and clean your environment
golem::detach_all_attached()
# rm(list=ls(all.names = TRUE))

# Document and reload your package
golem::document_and_reload()

# Run the application
run_app()

devtools::load_all()
devtools::document()
usethis::use_build_ignore(c("Makefile", "README.md", "README.Rmd", "CONDUCT.md", ".Rproj.user", ".Rproj","myapp"))
devtools::check()
devtools::build()

# get path to example package
pkg_path <- system.file()

library(goodpractice)
# run gp() on it
g <- gp("D:/yulab/enrichMicrobiomepkg/v2/MicrobiomeProfiler")
