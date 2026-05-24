#' eggNOG-based KEGG pathway enrichment for microbiome data
#'
#' @param gene a vector of eggNOG orthologous group identifiers.
#' @param pvalueCutoff adjusted pvalue cutoff on enrichment tests to report.
#' @param pAdjustMethod one of "holm", "hochberg", "hommel", "bonferroni",
#' "BH", "BY", "fdr", "none".
#' @param universe background eggNOG orthologous groups. If missing, use the
#' eggNOG dataset background.
#' @param minGSSize minimal size of pathway gene sets for testing.
#' @param maxGSSize maximal size of pathway gene sets for testing.
#' @param qvalueCutoff qvalue cutoff on enrichment tests to report.
#' @param refresh whether to force a fresh download of the remote eggNOG
#' artifact.
#' @return An \code{enrichResult} instance.
#' @importFrom enrichit ora_gson
#' @importFrom methods slot<-
#' @export
#' @examples
#' \dontrun{
#' og <- c("OG0001", "OG0002", "OG0003")
#' enrichEggNOG(og, minGSSize = 1)
#' }
enrichEggNOG <- function(gene,
                         pvalueCutoff = 0.05,
                         pAdjustMethod = "BH",
                         universe = NULL,
                         minGSSize = 10,
                         maxGSSize = 500,
                         qvalueCutoff = 0.2,
                         refresh = FALSE) {
    gson_obj <- mp_eggnog_gson(refresh = refresh)

    res <- ora_gson(
        as.character(gene),
        gson = gson_obj,
        universe = universe,
        pvalueCutoff = pvalueCutoff,
        pAdjustMethod = pAdjustMethod,
        minGSSize = minGSSize,
        maxGSSize = maxGSSize,
        qvalueCutoff = qvalueCutoff
    )

    if (is.null(res)) {
        return(res)
    }

    slot(res, "ontology") <- "eggNOG"
    slot(res, "organism") <- "microbiome"
    res
}


#' GSEA with eggNOG-based KEGG pathway annotations
#'
#' @param geneList order ranked geneList.
#' @param exponent weight of each step.
#' @param minGSSize minimal size of each geneSet for analyzing.
#' @param maxGSSize maximal size of genes annotated for testing.
#' @param pvalueCutoff pvalue Cutoff.
#' @param pAdjustMethod one of "holm", "hochberg", "hommel", "bonferroni",
#' "BH", "BY", "fdr", "none".
#' @param refresh whether to force a fresh download of the remote eggNOG
#' artifact.
#' @return A \code{gseaResult} instance.
#' @importFrom enrichit gsea_gson
#' @export
#' @examples
#' \dontrun{
#' geneList <- c(2.5, 1.2, -1.8)
#' names(geneList) <- c("OG0001", "OG0002", "OG0003")
#' gseEggNOG(geneList, minGSSize = 1)
#' }
gseEggNOG <- function(geneList,
                      exponent = 1,
                      minGSSize = 10,
                      maxGSSize = 500,
                      pvalueCutoff = 0.05,
                      pAdjustMethod = "BH",
                      refresh = FALSE) {
    gson_obj <- mp_eggnog_gson(refresh = refresh)

    res <- gsea_gson(
        geneList = geneList,
        exponent = exponent,
        gson = gson_obj,
        minGSSize = minGSSize,
        maxGSSize = maxGSSize,
        pvalueCutoff = pvalueCutoff,
        pAdjustMethod = pAdjustMethod
    )

    if (is.null(res)) {
        return(res)
    }

    slot(res, "ontology") <- "eggNOG"
    slot(res, "organism") <- "microbiome"
    res
}
