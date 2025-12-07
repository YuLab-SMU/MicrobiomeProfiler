#' Microbe-Disease associations enrichment analysis
#'
#' @param microbe_list a vector of microbe ncbi tax ids.
#' @param pvalueCutoff adjusted pvalue cutoff on enrichment tests to report.
#' @param pAdjustMethod one of "holm", "hochberg", "hommel", "bonferroni",
#' "BH", "BY", "fdr", "none".
#' @param universe universe background genes. If missing, use disbiome as
#' default.
#' @param minGSSize minimal size of genes annotated by KEGG term for testing.
#' @param maxGSSize maximal size of genes annotated for testing.
#' @param qvalueCutoff qvalue cutoff on enrichment tests to report.
#' @importFrom enrichit ora_gson
#' @importFrom methods slot<-
#' @return A \code{enrichResult} instance.
#' @export
#' @examples
#'
#' data(microbiota_taxlist)
#' mda <- enrichMDA(microbiota_taxlist)
#' head(mda)
#'
enrichMDA <- function(microbe_list,
                      pvalueCutoff      = 0.05,
                      pAdjustMethod     = "BH",
                      universe          = NULL,
                      minGSSize         = 10,
                      maxGSSize         = 500,
                      qvalueCutoff      = 0.2) {
    res <- ora_gson(gene=microbe_list,
                    gson = disbiome_data2,
                    pvalueCutoff  = pvalueCutoff,
                    pAdjustMethod = pAdjustMethod,
                    universe      = universe,
                    minGSSize     = minGSSize,
                    maxGSSize     = maxGSSize,
                    qvalueCutoff  = qvalueCutoff)
    if (is.null(res))
        return(res)

    slot(res,"ontology") <- "Microbe"
    slot(res,"organism") <- "microbiome"
    return(res)
}

#' Microbe-Disease associations GSEA enrichment analysis
#'
#' @param microbe_list a vector of microbe ncbi tax ids with values.
#' @param nPerm number of permutations.
#' @param exponent exponent of weighting.
#' @param minGSSize minimal size of genes annotated by KEGG term for testing.
#' @param maxGSSize maximal size of genes annotated for testing.
#' @param pvalueCutoff pvalue cutoff on enrichment tests to report.
#' @param pAdjustMethod one of "holm", "hochberg", "hommel", "bonferroni",
#' "BH", "BY", "fdr", "none".
#' @param method one of "multilevel", "fgsea", "bioc".
#' @param adaptive whether to use adaptive permutation.
#' @param minPerm minimal number of permutations.
#' @param maxPerm maximal number of permutations.
#' @param pvalThreshold pvalue threshold for adaptive permutation.
#' @param verbose whether to show progress.
#' @importFrom enrichit gsea_gson
#' @importFrom methods slot<-
#' @return A \code{gseaResult} instance.
#' @export
gseMDA <- function(microbe_list,
                      nPerm             = 1000,
                      exponent          = 1,
                      minGSSize         = 10,
                      maxGSSize         = 500,
                      pvalueCutoff      = 0.05,
                      pAdjustMethod     = "BH",
                      method            = "multilevel",
                      adaptive          = FALSE,
                      minPerm           = 101,
                      maxPerm           = 100000,
                      pvalThreshold     = 0.1,
                      verbose           = TRUE) {
    res <- gsea_gson(geneList      = microbe_list,
                     gson          = disbiome_data2,
                     nPerm         = nPerm,
                     exponent      = exponent,
                     minGSSize     = minGSSize,
                     maxGSSize     = maxGSSize,
                     pvalueCutoff  = pvalueCutoff,
                     pAdjustMethod = pAdjustMethod,
                     method        = method,
                     adaptive      = adaptive,
                     minPerm       = minPerm,
                     maxPerm       = maxPerm,
                     pvalThreshold = pvalThreshold,
                     verbose       = verbose)
    if (is.null(res))
        return(res)

    slot(res,"ontology") <- "Microbe"
    slot(res,"organism") <- "microbiome"
    return(res)
}
