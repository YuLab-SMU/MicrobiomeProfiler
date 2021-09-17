#' Metabolism enrichment analysis for microbiome data
#'
#' @param metabo_list a vector of metabolites in smpdb Metabolite.ID
#' @param pvalueCutoff adjusted pvalue cutoff on enrichment tests to report.
#' @param pAdjustMethod one of "holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "fdr", "none".
#' @param universe universe background genes. If missing, use SMPDB db.
#' @param minGSSize minimal size of genes annotated by KEGG term for testing.
#' @param maxGSSize maximal size of genes annotated for testing.
#' @param qvalueCutoff qvalue cutoff on enrichment tests to report.
#' @importFrom clusterProfiler enricher
#' @return A \code{enrichResult} instance.
#' @export
#' @examples
#'
#' smp <- enrichSMPDB(c("PW_C000164","PW_C000078","PW_C000040"))
#' head(smp)
#'
enrichSMPDB <- function(metabo_list,
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
                    TERM2GENE = smpdb_data[c("SMPDB.ID","Metabolite.ID")],
                    TERM2NAME = smpdb_data[c("SMPDB.ID","Pathway.Name")])
    if (is.null(res))
        return(res)

    res@ontology <- "Metabolite"
    res@organism <- "microbiome"

    return(res)
}
