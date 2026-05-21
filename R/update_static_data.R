# This file contains functions to update static datasets like COG, SMPDB, HMDB.
# Disbiome might require manual download.

#' @importFrom utils download.file read.delim unzip read.csv
#' @importFrom gson gson
update_cog_data <- function() {
    message("Downloading COG data from NCBI...")
    cog_def_file <- tempfile()
    cog_fun_file <- tempfile()
    tryCatch({
        download.file("ftp://ftp.ncbi.nih.gov/pub/COG/COG2020/data/cog-20.def.tab", cog_def_file, quiet = TRUE)
        download.file("ftp://ftp.ncbi.nih.gov/pub/COG/COG2020/data/fun-20.tab", cog_fun_file, quiet = TRUE)
        
        d1 <- read.delim(cog_def_file, header=FALSE, sep="\t", quote="", stringsAsFactors=FALSE)
        d2 <- read.delim(cog_fun_file, header=FALSE, sep="\t", quote="", stringsAsFactors=FALSE)
        
        cats_list <- strsplit(d1$V2, "")
        lengths <- sapply(cats_list, length)
        gsid2gene_cat <- data.frame(
            gsid = unlist(cats_list),
            gene = rep(d1$V1, lengths),
            stringsAsFactors=FALSE
        )
        gsid2name_cat <- data.frame(gsid = d2$V1, name = d2$V3, stringsAsFactors=FALSE)
        
        cog_category <- gson::gson(gsid2gene = gsid2gene_cat,
                                   gsid2name = gsid2name_cat,
                                   species = "category",
                                   gsname = "COG",
                                   version = "COG2020",
                                   keytype = "cog",
                                   accessed_date = as.character(Sys.Date()))
        
        d1_pathway <- d1[d1$V5 != "", ]
        gsid2gene_path <- data.frame(gsid = d1_pathway$V5, gene = d1_pathway$V1, stringsAsFactors=FALSE)
        gsid2name_path <- data.frame(gsid = unique(d1_pathway$V5), name = unique(d1_pathway$V5), stringsAsFactors=FALSE)
        
        cog_pathway <- gson::gson(gsid2gene = gsid2gene_path,
                                  gsid2name = gsid2name_path,
                                  species = "pathway",
                                  gsname = "COG",
                                  version = "COG2020",
                                  keytype = "cog",
                                  accessed_date = as.character(Sys.Date()))
                                  
        return(list(cog_category = cog_category, cog_pathway = cog_pathway))
    }, error = function(e) {
        warning("Failed to update COG data: ", e$message)
        return(NULL)
    })
}

update_smpdb_hmdb_data <- function() {
    message("Downloading SMPDB data from smpdb.ca...")
    tmp <- tempfile()
    tryCatch({
        download.file("https://smpdb.ca/downloads/smpdb_metabolites.csv.zip", tmp, quiet = TRUE)
        unzip(tmp, exdir = tempdir())
        csv_file <- list.files(tempdir(), pattern = "smpdb_metabolites.csv", full.names = TRUE)[1]
        
        d <- read.csv(csv_file, stringsAsFactors=FALSE)
        
        # SMPDB gson
        # gsid: SMPDB ID, gene: Metabolite ID (PW_C...)
        gsid2gene_smpdb <- data.frame(gsid = d$SMPDB.ID, gene = d$Metabolite.ID, stringsAsFactors=FALSE)
        gsid2gene_smpdb <- gsid2gene_smpdb[gsid2gene_smpdb$gene != "", ]
        gsid2name_smpdb <- data.frame(gsid = d$SMPDB.ID, name = d$Pathway.Name, stringsAsFactors=FALSE)
        gsid2name_smpdb <- unique(gsid2name_smpdb)
        
        smpdb_gson <- gson::gson(gsid2gene = gsid2gene_smpdb,
                                 gsid2name = gsid2name_smpdb,
                                 species = "metabolite",
                                 gsname = "SMPDB",
                                 version = as.character(Sys.Date()),
                                 keytype = "metabolite_id",
                                 accessed_date = as.character(Sys.Date()))
                                 
        # HMDB gson
        # gsid: SMPDB ID, gene: HMDB ID
        gsid2gene_hmdb <- data.frame(gsid = d$SMPDB.ID, gene = d$HMDB.ID, stringsAsFactors=FALSE)
        gsid2gene_hmdb <- gsid2gene_hmdb[gsid2gene_hmdb$gene != "", ]
        
        hmdb_gson <- gson::gson(gsid2gene = gsid2gene_hmdb,
                                gsid2name = gsid2name_smpdb,
                                species = "metabolite",
                                gsname = "SMPDB",
                                version = as.character(Sys.Date()),
                                keytype = "hmdb_id",
                                accessed_date = as.character(Sys.Date()))
                                
        return(list(smpdb_gson = smpdb_gson, hmdb_gson = hmdb_gson))
    }, error = function(e) {
        warning("Failed to update SMPDB data: ", e$message)
        return(NULL)
    })
}
