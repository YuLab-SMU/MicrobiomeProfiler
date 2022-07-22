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
#' @importFrom clusterProfiler enricher
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
                       universe,
                       minGSSize         = 10,
                       maxGSSize         = 500,
                       qvalueCutoff      = 0.2) {

    cpd <- cpd_gson
    res <- enricher(gene = metabo_list,
                    pvalueCutoff  = pvalueCutoff,
                    pAdjustMethod = pAdjustMethod,
                    universe      = universe,
                    minGSSize     = minGSSize,
                    maxGSSize     = maxGSSize,
                    qvalueCutoff  = qvalueCutoff,
                    TERM2GENE = slot(cpd,"gsid2gene"),
                    TERM2NAME = slot(cpd,"gsid2name"))
    if (is.null(res))
        return(res)

    slot(res,"ontology") <- "Metabolite"
    slot(res,"organism") <- "microbiome"

    return(res)
}
