#' KO enrichment for microbiome data
#'
#' @param gene a vector of K gene id (e.g. K00001) or EC id (e.g. 1.1.1.27).
#' @param pvalueCutoff adjusted pvalue cutoff on enrichment tests to report.
#' @param pAdjustMethod one of "holm","hochberg","hommel","bonferroni","BH",
#' "BY","fdr","none".
#' @param universe universe background genes. If missing, use all K genes.
#' @param minGSSize minimal size of genes annotated by KEGG term for testing.
#' @param maxGSSize maximal size of genes annotated for testing.
#' @param qvalueCutoff qvalue cutoff on enrichment tests to report.
#' @importFrom enrichit ora_gson
#' @importFrom methods slot<-
#' @return A \code{enrichResult} instance.
#' @export
#' @examples
#'
#'   data(Rat_data)
#'   ko <- enrichKO(Rat_data)
#'   head(ko)
#'
enrichKO <- function(gene,
                     pvalueCutoff      = 0.05,
                     pAdjustMethod     = "BH",
                     universe          = NULL,
                     minGSSize         = 10,
                     maxGSSize         = 500,
                     qvalueCutoff      = 0.2) {
    
    if (all(grepl("^K", gene))){
        use.gson <- ko_gson
    }else{
        use.gson <- ec_gson 
    }

    res <- ora_gson(gene,
                    gson = use.gson,
                    pvalueCutoff  = pvalueCutoff,
                    pAdjustMethod = pAdjustMethod,
                    universe      = universe,
                    minGSSize     = minGSSize,
                    maxGSSize     = maxGSSize,
                    qvalueCutoff  = qvalueCutoff)
    if (is.null(res))
        return(res)

    slot(res,"ontology") <- "KEGG"
    slot(res,"organism") <- "microbiome"

    return(res)
}

#' KO GSEA enrichment for microbiome data
#'
#' @param geneList a vector of K gene id (e.g. K00001) or EC id (e.g. 1.1.1.27) with values.
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
gseKO <- function(geneList,
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
    
    if (all(grepl("^K", names(geneList)))){
        use.gson <- ko_gson
    }else{
        use.gson <- ec_gson 
    }

    res <- gsea_gson(geneList,
                     gson          = use.gson,
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

    slot(res,"ontology") <- "KEGG"
    slot(res,"organism") <- "microbiome"

    return(res)
}




