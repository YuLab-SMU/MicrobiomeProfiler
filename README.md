# Introduction

`MicrobiomeProfiler` is an R-shiny package based on `clusterProfiler`,
is user-friendly tool for functional enrichment analysis in microbiome
data (T Wu, et al., 2021).

# Installation

Installation via BiocManager:

    if (!require("BiocManager"))
        install.packages("BiocManager")
    BiocManager::install("MicrobiomeProfiler")

Or install `MicrobiomeProfiler` from github using devtools :

    ## Note that having installed clusterProfiler,config,DT,enrichplot,golem,magrittr,shiny,shinyWidgets,shinycustomloader,htmltools,ggplot2
    if (!requireNamespace("devtools", quietly=TRUE))
        install.packages("devtools")
    devtools::install_github("YuLab-SMU/MicrobiomeProfiler")

# Quick Guides

    library(MicrobiomeProfiler)
    run_MicrobiomeProfiler()

# Reference

+ T Wu<sup>#</sup>, E Hu<sup>#</sup>, S Xu, M Chen, P Guo, Z Dai, T Feng, L Zhou, W Tang, L Zhan, X Fu, S Liu, X Bo<sup>\*</sup>, **G Yu**<sup>\*</sup>. clusterProfiler 4.0: A universal enrichment tool for interpreting omics data. ***The Innovation***. 2021, 2(3):100141. doi: [10.1016/j.xinn.2021.100141](https://doi.org/10.1016/j.xinn.2021.100141)

