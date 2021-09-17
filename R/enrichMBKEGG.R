#' Metabolism enrichment analysis for microbiome data
#'
#' @param metabo_list a vector of metabolites in KEGG.ID
#' @param pvalueCutoff adjusted pvalue cutoff on enrichment tests to report.
#' @param pAdjustMethod one of "holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "fdr", "none".
#' @param universe universe background genes. If missing, use KEGG as default.
#' @param minGSSize minimal size of genes annotated by KEGG term for testing.
#' @param maxGSSize maximal size of genes annotated for testing.
#' @param qvalueCutoff qvalue cutoff on enrichment tests to report.
#' @importFrom clusterProfiler enricher
#' @return A \code{enrichResult} instance.
#' @export
#' @examples
#'
#' mblist3 <- bitr_smpdb(c("PW_C000164","PW_C000078","PW_C000040"),
#' from_Type = "Metabolite.ID",to_Type = "KEGG.ID")
#' mb3 <- enrichMBKEGG(mblist3$KEGG.ID)
#' head(mb3)
#'
enrichMBKEGG <- function(metabo_list,
                       pvalueCutoff      = 0.05,
                       pAdjustMethod     = "BH",
                       universe,
                       minGSSize         = 10,
                       maxGSSize         = 500,
                       qvalueCutoff      = 0.2) {
    res <- enricher(gene = metabo_list,
                    pvalueCutoff  = pvalueCutoff,
                    pAdjustMethod = pAdjustMethod,
                    universe      = universe,
                    minGSSize     = minGSSize,
                    maxGSSize     = maxGSSize,
                    qvalueCutoff  = qvalueCutoff,
                    TERM2GENE = cpd2kegg[c("map","cpd")],
                    TERM2NAME = ko2pathway[c("pathway","description")])
    if (is.null(res))
        return(res)

    res@ontology <- "Metabolite"
    res@organism <- "microbiome"

    return(res)
}
