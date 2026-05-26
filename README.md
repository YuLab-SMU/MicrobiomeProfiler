# MicrobiomeProfiler

`MicrobiomeProfiler` is an R package and Shiny application for functional
enrichment analysis in microbiome studies. It builds on the
`clusterProfiler` ecosystem and provides both interactive and programmatic
workflows for common microbiome annotation tasks.

The package now supports a hybrid data-delivery model:

- Stable built-in resources remain available in the package.
- Larger or fast-moving annotation resources are distributed from GitHub
  Pages and downloaded on demand.
- Remote datasets can be cached locally and refreshed independently from
  the package release cycle.

## What It Supports

`MicrobiomeProfiler` currently supports:

- KEGG enrichment and GSEA for microbiome gene profiles
- COG enrichment and GSEA
- eggNOG-based KEGG pathway enrichment and GSEA
- Microbe-disease enrichment with Disbiome
- Microbial signature enrichment with BugSigDB
- Metabolite pathway enrichment with HMDB and SMPDB
- Interactive Shiny exploration with tables, dotplots, and barplots

## Installation

Install the release version from Bioconductor:

```r
if (!requireNamespace("BiocManager", quietly = TRUE)) {
    install.packages("BiocManager")
}
BiocManager::install("MicrobiomeProfiler")
```

Or install the development version from GitHub:

```r
if (!requireNamespace("remotes", quietly = TRUE)) {
    install.packages("remotes")
}
remotes::install_github("YuLab-SMU/MicrobiomeProfiler")
```

## Launch The Shiny App

```r
library(MicrobiomeProfiler)
run_MicrobiomeProfiler()
```

The Shiny interface currently provides:

- `Gene enrichment analysis`
  - KEGG
  - COG
  - eggNOG
  - eggNOG ORA and GSEA modes in the same page
- `Microbe disease/signature enrichment`
  - Disbiome
  - BugSigDB
- `Metabo-Pathway analysis`

For `eggNOG` GSEA in the app, provide one ranked item per line, for example:

```text
OG0001 2.5
OG0002 1.5
OG0003 -0.8
```

## Programmatic Usage

### KEGG And COG

```r
library(MicrobiomeProfiler)

data(Rat_data)
ko_res <- enrichKO(Rat_data)

data(Psoriasis_data)
cog_res <- enrichCOG(Psoriasis_data, dtype = "pathway")
```

### eggNOG

```r
library(MicrobiomeProfiler)

og <- c(
    "Collectrin@131567|A-1*",
    "Collectrin@7711|C-2",
    "Collectrin@75365|II-17"
)

ora_res <- enrichEggNOG(og, minGSSize = 1, maxGSSize = 500)

# GSEA expects a named ranked numeric vector of real eggNOG OG IDs.
geneList <- c(2.5, 1.5, -0.8)
names(geneList) <- og
```

### Microbe-Disease And Signature Enrichment

```r
library(MicrobiomeProfiler)

data("microbiota_taxlist", package = "MicrobiomeProfiler")

bugsigdb_res <- enrichBugSigDB(microbiota_taxlist)
mda_res <- enrichMDA(microbiota_taxlist)
```

## External Data Delivery

Some annotation resources are distributed from the package GitHub Pages site
instead of being bundled directly in the source tarball. This keeps package
size under control and allows annotation artifacts to be refreshed
independently.

Current external datasets include:

- `bugsigdb`
- `disbiome`
- `eggnog`

Inspect configured datasets:

```r
library(MicrobiomeProfiler)

available_datasets()
available_datasets(include_remote = TRUE)
```

Pre-download data into the local cache:

```r
download_dataset("bugsigdb")
download_dataset("disbiome")
download_dataset("eggnog")
```

Refresh or inspect cache state:

```r
download_dataset("eggnog", refresh = TRUE)

dataset_cache_info()
dataset_cache_info("eggnog")

clear_dataset_cache("eggnog")
```

Runtime behavior:

- `enrichBugSigDB()` downloads BugSigDB artifacts on demand.
- `enrichEggNOG()` and `gseEggNOG()` download eggNOG artifacts on demand.
- `enrichMDA()` and `gseMDA()` use remote-first Disbiome data and fall back to
  bundled internal data if the remote source is unavailable.

## Documentation

See the package vignette for a broader introduction:

- [Introduction to MicrobiomeProfiler](vignettes/MicrobiomeProfiler.Rmd)

## Reference

- T Wu<sup>#</sup>, E Hu<sup>#</sup>, S Xu, M Chen, P Guo, Z Dai, T Feng,
  L Zhou, W Tang, L Zhan, X Fu, S Liu, X Bo<sup>*</sup>,
  **G Yu**<sup>*</sup>. clusterProfiler 4.0: A universal enrichment tool for
  interpreting omics data. *The Innovation*. 2021, 2(3):100141.
  doi: [10.1016/j.xinn.2021.100141](https://doi.org/10.1016/j.xinn.2021.100141)

