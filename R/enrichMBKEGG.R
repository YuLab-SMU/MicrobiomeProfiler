#' Metabolism enrichment analysis for microbiome data
#'
#' @param metabo_list a vector of metabolites in KEGG.ID
#' @param pvalueCutoff adjusted pvalue cutoff on enrichment tests to report.
#' @param pAdjustMethod one of "holm", "hochberg", "hommel", "bonferroni",
#' "BH", "BY", "fdr", "none".
#' @param universe universe background genes. If missing, use KEGG as default.
#' @param minGSSize minimal size of genes annotated by KEGG term for testing.
#' @param maxGSSize maximal size of genes annotated for testing.
#' @param qvalueCutoff qvalue cutoff on enrichment tests to report.
#' @importFrom enrichit ora_gson
#' @importFrom methods slot<-
#' @return A \code{enrichResult} instance.
#' @export
#' @examples
#'
#' mblist3 <- c("C00019","C00020","C00022")
#' mb3 <- enrichMBKEGG(mblist3)
#' head(mb3)
#'
enrichMBKEGG <- function(metabo_list,
                       pvalueCutoff      = 0.05,
                       pAdjustMethod     = "BH",
                       universe          = NULL,
                       minGSSize         = 10,
                       maxGSSize         = 500,
                       qvalueCutoff      = 0.2) {

    res <- ora_gson(gene = metabo_list,
                    gson = cpd_gson,
                    pvalueCutoff  = pvalueCutoff,
                    pAdjustMethod = pAdjustMethod,
                    universe      = universe,
                    minGSSize     = minGSSize,
                    maxGSSize     = maxGSSize,
                    qvalueCutoff  = qvalueCutoff)
    if (is.null(res))
        return(res)

    slot(res,"ontology") <- "Metabolite"
    slot(res,"organism") <- "microbiome"

    return(res)
}

#' Metabolism GSEA enrichment analysis for microbiome data
#'
#' @param metabo_list a vector of metabolites in KEGG.ID with values
#' @param nPerm number of permutations.
#' @param exponent exponent of weighting.
#' @param minGSSize minimal size of genes annotated by KEGG term for testing.
#' @param maxGSSize maximal size of genes annotated for testing.
#' @param pvalueCutoff pvalue cutoff on enrichment tests to report.
#' @param pAdjustMethod one of "holm","hochberg","hommel","bonferroni","BH",
#' "BY","fdr","none".
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
gseMBKEGG <- function(metabo_list,
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

    res <- gsea_gson(geneList      = metabo_list,
                     gson          = cpd_gson,
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

    slot(res,"ontology") <- "Metabolite"
    slot(res,"organism") <- "microbiome"

    return(res)
}
