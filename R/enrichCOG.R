#' COG enrichment analysis for microbiome data
#'
#' @param gene a vector of COG ids.
#' @param gson gson object.
#' @param dtype one of "category", "pathway"
#' @param pvalueCutoff adjusted pvalue cutoff on enrichment tests to report.
#' @param pAdjustMethod one of "holm","hochberg","hommel","bonferroni","BH",
#' "BY","fdr","none".
#' @param universe universe background genes. If missing,use the all COGs.
#' @param minGSSize minimal size of genes annotated by KEGG term for testing.
#' @param maxGSSize maximal size of genes annotated for testing.
#' @param qvalueCutoff qvalue cutoff on enrichment tests to report.
#' @importFrom clusterProfiler enricher
#' @return A \code{enrichResult} instance.
#' @export
#' @examples
#'
#' data(Psoriasis_data)
#' cog <- enrichCOG(Psoriasis_data,dtype="category")
#'
enrichCOG <- function(gene,
                      gson,
                      dtype,
                      pvalueCutoff      = 0.05,
                      pAdjustMethod     = "BH",
                      universe,
                      minGSSize         = 10,
                      maxGSSize         = 500,
                     qvalueCutoff      = 0.2) {
    if(missing(gson)){
        if(dtype == "category"){
            cog <- cog_category
        } else if(dtype == "pathway"){
            cog <- cog_pathway
        } else{
            stop("dtype should be category or pathway")
        }
    } else if(inherits(gson, "GSON")){
        cog <- gson
    } else{
        stop("gson should be a GSON object")
    }
    res <- enricher(gene,
                    pvalueCutoff  = pvalueCutoff,
                    pAdjustMethod = pAdjustMethod,
                    universe      = universe,
                    minGSSize     = minGSSize,
                    maxGSSize     = maxGSSize,
                    qvalueCutoff  = qvalueCutoff,
                    TERM2GENE = slot(cog,"gsid2gene"),
                    TERM2NAME = slot(cog,"gsid2name"))
    if (is.null(res))
        return(res)

    slot(res,"ontology") <- "COG"
    slot(res,"organism") <- "microbiome"

    return(res)
}

