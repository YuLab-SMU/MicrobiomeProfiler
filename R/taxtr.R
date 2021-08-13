#' convertion of microne ncbi id and ScientificName
#'
#' @param Input a query vector of microbe ncbi ids or ScientificName
#' @param Type The Type of Input, should be "TaxId" or "ScientificName"
#' @param Level The taxon level of Input, only "species" and "genus" are accepted.
#' @return a dataframe
#' @export
#'
#' @examples
#' \dontrun{
#' taxtr(Input = c("2840314","2839514","2839126","2794228"), Type = "TaxId", Level = "genus")
#' }
taxtr <- function(Input, Type, Level){

    if(Level == "genus"){
        taxid2name <- taxid2genus
    }else{
        if(Level == "species"){
            taxid2name <- taxid2sp
        }else{
            stop(paste("Level parameter should be genus or species..."))
        }

    }

    res <- unique(as.data.frame(taxid2name[taxid2name[[Type]]%in% Input,]))

    n <- res[, 1] %>% unique %>% length
    if(! all(Input %in% taxid2name[[Type]])){
        warning(paste0(round(n/length(Input)*100, 2), "%"), " of input are fail to map...")

    }

    return(res)
}


