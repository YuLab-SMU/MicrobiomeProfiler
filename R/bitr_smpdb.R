#' convert metabolite IDs
#'
#' You can choose one id type as input and convert to other id type
#'
#' @param mbid query vector of metabolite ids
#' @param from_Type input id type, character
#' @param to_Type output id type, character
#' @return a dataframe
#' @importFrom magrittr %>%
#' @importFrom magrittr %<>%
#' @export
#'
#' @examples
#'
#' bitr_smpdb(c("HMDB0000538","HMDB0000161","HMDB0000045"),
#' from_Type = "HMDB.ID",to_Type = "ChEBI.ID")
#'
bitr_smpdb <- function(mbid,from_Type, to_Type){
    idmap <- smpdb_data
    ids <- c("Metabolite.ID","Metabolite.Name",
             "HMDB.ID","KEGG.ID","ChEBI.ID","DrugBank.ID")
    mgs<- c("should be one of these type: Metabolite.ID, Metabolite.Name,
            HMDB.ID, KEGG.ID, ChEBI.ID, DrugBank.ID")
    mbid %<>% as.character %>% unique
    if(! from_Type %in% ids){
        stop("from_Type ",mgs)
    }
    if(! to_Type %in% ids){
        stop("to_Type ",mgs)
    }
    res <- unique(as.data.frame(idmap[idmap[[from_Type]] %in% mbid,
                                      c(from_Type,to_Type)]))

    n <- res[, 1] %>% unique %>% length
    if(! all(mbid %in% idmap[[from_Type]])){
        warning(round(n/length(mbid)*100, 2),"%",
                " of input IDs are fail to map...")
    }

    return(res)
}


