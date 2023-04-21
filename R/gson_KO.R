
kegg_rest <- getFromNamespace("kegg_rest","clusterProfiler")


##' download KO annotation of the latest version of KEGG pathway and stored in a 'GSON' object
##'
##'
##' @title gson_KO
##' @return a 'GSON' object
##' @importFrom gson gson
##' @importFrom stats na.omit setNames
##' @importFrom magrittr %<>%
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
         keytype = "kegg_orthology",
         accessed_date = as.character(Sys.Date()))
}



#' download compound annotation of the latest version of KEGG pathway and stored in a 'GSON' object
#'
#' @title gson_cpd
#' @return a 'GSON' object
#' @importFrom gson gson
#' @importFrom stats na.omit setNames
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
         species = "KEGG Compound",
         gsname = "KEGG",
         version = version,
         keytype = "kegg_compound",
         accessed_date = as.character(Sys.Date()))
}

#' download compound annotation of the latest version of KEGG Module and stored in a 'GSON' object
#'
#' @title gson_module
#' @param db ko or enzyme
#' @return a 'GSON' object
gson_module <- function(db='ko'){
    k1 <- kegg_rest(paste0("https://rest.kegg.jp/link/",db, "/module"))
    k1[,1] %<>% gsub("[^:]+:", "", .)
    k1[,2] %<>% gsub("[^:]+:", "", .)
    k2 <- kegg_rest("https://rest.kegg.jp/list/module")
    colnames(k1) <- c("gsid", "gene")
    colnames(k2) <- c("gsid", "name")
    y <- readLines(paste0("https://rest.kegg.jp/info/", db))
    version <- sub("\\w+\\s+", "", y[grep('Release', y)])
    gson(gsid2gene = k1,
         gsid2name = k2,
         species = "KEGG Compound",
         gsname = "KEGGModule",
         version = version,
         keytype = "kegg_compound",
         accessed_date = as.character(Sys.Date()))

}

#' download compound annotation of the latest version of KEGG pathway to enzyme and stored in a 'GSON' object
#'
#' @title gson_enzyme
#' @return a 'GSON' object
gson_enzyme <- function(){
    k1 <- kegg_rest("https://rest.kegg.jp/link/enzyme/pathway")
    k1[,1] %<>% gsub("[^:]+:", "", .)
    k1[,2] %<>% gsub("[^:]+:", "", .)
    k1 <- k1[grep("map",k1[,1]),]
    k2 <- kegg_rest("https://rest.kegg.jp/list/pathway")
    colnames(k1) <- c("gsid", "gene")
    colnames(k2) <- c("gsid", "name")
    y <- readLines("https://rest.kegg.jp/info/enzyme")
    version <- sub("\\w+\\s+", "", y[grep('Release', y)])
    gson(gsid2gene = k1,
         gsid2name = k2,
         species = "KEGG Enzyme",
         gsname = "KEGG",
         version = version,
         keytype = "kegg_enzyme",
         accessed_date = as.character(Sys.Date()))

}
