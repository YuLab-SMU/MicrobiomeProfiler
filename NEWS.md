# MicrobiomeProfiler 1.19.2

+ stop advertising placeholder `OG0001`-style identifiers for `eggNOG` (2026-09-15, Tue)
  - the `Example` button now builds its input from the published eggNOG
    artifact instead of hard-coded fixture IDs, and uses a complete KEGG
    pathway that fits the analysis window, so the generated example really
    produces a non-empty enrichment result
  - the `GSEA` example also carries background identifiers from outside the
    pathway, without which the permutation p-values cannot be computed
  - when the eggNOG artifact cannot be loaded the app reports the problem
    instead of filling the input with identifiers that cannot be analysed
  - guard against an `NA` condition while the universe selector has not
    rendered yet
+ expose an explicit `seed` argument on all GSEA entry points — `gseKO()`,
  `gseModule()`, `gseCOG()`, `gseMDA()`, `gseMBKEGG()`, `gseSMPDB()`,
  `gseHMDB()` and `gseEggNOG()` — forwarded to `enrichit::gsea_gson()`
  (2026-08-15, Fri)
  - set it to a number (or TRUE for a fixed default seed) to get identical GSEA
    results across runs, FALSE (default) draws a fresh seed on each run;
    `set.seed()` before the call still works
  - `pvalueCutoff` is applied to both `pvalue` and `p.adjust` inside
    `enrichit::gsea_gson()` (requires enrichit >= 0.2.2), matching the historical
    clusterProfiler/DOSE double-filtering behavior

# MicrobiomeProfiler 1.19.1

+ setup GitHub Actions workflow for automated internal data updates (KEGG, COG, SMPDB, HMDB, Disbiome) (2026-05-21, Thu)
+ support shinyserver (2026-05-21, Thu, #3)
+ import clusterProfiler to prevent R check error (2026-05-21, Thu)

# MicrobiomeProfiler 1.18.0

+ Bioconductor RELEASE_3_23 (2026-04-29, Wed)

# MicrobiomeProfiler 1.17.1

+ use 'enrichit' as engine for enrichment analysis (2025-12-07, Sun)

# MicrobiomeProfiler 1.16.0

+ Bioconductor RELEASE_3_22 (2025-11-01, Sat)

# MicrobiomeProfiler 1.14.0

+ Bioconductor RELEASE_3_21 (2025-04-17, Thu)

# MicrobiomeProfiler 1.10.1

+ Bioconductor RELEASE_3_20 (2024-10-30, Wed)

# MicrobiomeProfiler 1.11.1

+ support gson for PubChem Pathway (2024-08-16, Fri, #6)

# MicrobiomeProfiler 1.10.0

+ Bioconductor RELEASE_3_19 (2024-05-15, Wed)

# MicrobiomeProfiler 1.8.0

+ Bioconductor RELEASE_3_18 (2023-10-25, Wed)

# MicrobiomeProfiler 1.7.1

+ Change maintainer from Meijun to Guangchuang
