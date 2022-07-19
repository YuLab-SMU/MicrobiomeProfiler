
kegg_rest <- getFromNamespace("kegg_rest","clusterProfiler")


##' download KO annotation of the latest version of KEGG pathway and stored in a 'GSON' object
##'
##'
##' @title gson_KO
##' @return a 'GSON' object
##' @importFrom gson gson
##' @importFrom stats na.omit setNames
##' @importFrom magrittr %<>%
##' @export
##' @examples
##'
##' ko_gson <- gson_KO()
##'
gson_KO <- function() {
    k1 <- kegg_rest("https://rest.kegg.jp/link/ko/pathway")
    k1[,1] %<>% gsub("[^:]+:", "", .)
    k1[,2] %<>% gsub("[^:]+:", "", .)
    k1 <- k1[grep("map",k1[,1]),]
    k2  <- kegg_rest("https://rest.kegg.jp/list/pathway")
    k2[,1] %<>% gsub("path:","",.)
    gsid2gene <- setNames(k1, c("gsid", "gene"))
    gsid2name <- setNames(k2, c("gsid", "name"))
    y <- readLines("https://rest.kegg.jp/info/ko")
    version <- sub("\\w+\\s+", "", y[grep('Release', y)])
    gson(gsid2gene = gsid2gene,
         gsid2name = gsid2name,
         species = "KEGG Orthology",
         gsname = "KEGG",
         version = version,
         accessed_date = as.character(Sys.Date()))
}



#' download compound annotation of the latest version of KEGG pathway and stored in a 'GSON' object
#'
#' @title gson_cpd
#' @return a 'GSON' object
#' @importFrom gson gson
#' @importFrom stats na.omit setNames
#' @export
#'
#' @examples
#'
#' cpd_gson <- gson_cpd()
#'
gson_cpd <- function(){
    k1 <- kegg_rest("https://rest.kegg.jp/link/cpd/pathway")
    k1[,1] %<>% gsub("[^:]+:", "", .)
    k1[,2] %<>% gsub("[^:]+:", "", .)
    k1 <- k1[grep("map",k1[,1]),]
    k2  <- kegg_rest("https://rest.kegg.jp/list/pathway")
    k2[,1] %<>% gsub("path:","",.)
    gsid2gene <- setNames(k1, c("gsid", "gene"))
    gsid2name <- setNames(k2, c("gsid", "name"))
    y <- readLines("https://rest.kegg.jp/info/ko")
    version <- sub("\\w+\\s+", "", y[grep('Release', y)])
    gson(gsid2gene = gsid2gene,
         gsid2name = gsid2name,
         species = "KEGG Orthology",
         gsname = "KEGG",
         version = version,
         accessed_date = as.character(Sys.Date()))
}






