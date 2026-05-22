#' BugSigDB enrichment analysis for microbiome data
#'
#' @param microbe_list a vector of microbe NCBI taxonomy ids.
#' @param pvalueCutoff adjusted pvalue cutoff on enrichment tests to report.
#' @param pAdjustMethod one of "holm", "hochberg", "hommel", "bonferroni",
#' "BH", "BY", "fdr", "none".
#' @param universe universe background microbes. If missing, use the BugSigDB
#' dataset background.
#' @param minGSSize minimal size of microbes annotated by a signature term for
#' testing.
#' @param maxGSSize maximal size of microbes annotated by a signature term for
#' testing.
#' @param qvalueCutoff qvalue cutoff on enrichment tests to report.
#' @param refresh whether to force a fresh download of the remote artifact.
#' @return An \code{enrichResult} instance.
#' @importFrom methods slot<-
#' @export
#' @examples
#' \dontrun{
#' taxa <- c("1224", "1236", "91347")
#' enrichBugSigDB(taxa)
#' }
enrichBugSigDB <- function(microbe_list,
                           pvalueCutoff = 0.05,
                           pAdjustMethod = "BH",
                           universe = NULL,
                           minGSSize = 10,
                           maxGSSize = 500,
                           qvalueCutoff = 0.2,
                           refresh = FALSE) {
    bugsigdb <- mp_get_dataset("bugsigdb", refresh = refresh)

    res <- clusterProfiler::enricher(
        gene = as.character(microbe_list),
        TERM2GENE = bugsigdb$term2gene,
        TERM2NAME = bugsigdb$term2name,
        pvalueCutoff = pvalueCutoff,
        pAdjustMethod = pAdjustMethod,
        universe = universe,
        minGSSize = minGSSize,
        maxGSSize = maxGSSize,
        qvalueCutoff = qvalueCutoff
    )

    if (is.null(res)) {
        return(res)
    }

    slot(res, "ontology") <- "BugSigDB"
    slot(res, "organism") <- "microbiome"
    res
}
