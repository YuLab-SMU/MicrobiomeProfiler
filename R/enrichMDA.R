#' Microbe-Disease associations enrichment analysis
#'
#' @param microbe_list a vector of microbe ncbi tax ids.
#' @param pvalueCutoff adjusted pvalue cutoff on enrichment tests to report.
#' @param pAdjustMethod one of "holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "fdr", "none".
#' @param universe universe background genes. If missing, use disbiome as default.
#' @param minGSSize minimal size of genes annotated by KEGG term for testing.
#' @param maxGSSize maximal size of genes annotated for testing.
#' @param qvalueCutoff qvalue cutoff on enrichment tests to report.
#' @importFrom clusterProfiler enricher
#' @return A \code{enrichResult} instance.
#' @export
enrichMDA <- function(microbe_list,
                      pvalueCutoff      = 0.05,
                      pAdjustMethod     = "BH",
                      universe,
                      minGSSize         = 10,
                      maxGSSize         = 500,
                      qvalueCutoff      = 0.2) {
    res <- enricher(gene=microbe_list,
                    pvalueCutoff  = pvalueCutoff,
                    pAdjustMethod = pAdjustMethod,
                    universe      = universe,
                    minGSSize     = minGSSize,
                    maxGSSize     = maxGSSize,
                    qvalueCutoff  = qvalueCutoff,
                    TERM2GENE = disbiome_data[c("meddra_id",
                                                "organism_ncbi_id")],
                    TERM2NAME = disbiome_data[c("meddra_id","disease_name")])
    if (is.null(res))
        return(res)

    res@ontology <- "Microbe"
    res@organism <- "microbiome"
    return(res)
}
