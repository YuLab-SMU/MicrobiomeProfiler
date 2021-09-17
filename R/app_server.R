#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session ) {
    mod_KOenrichment_server("KOenrichment_ui_1")
    mod_COGenrichment_server("COGenrichment_ui_1")
    mod_MDenrichment_server("MDenrichment_ui_1")
    mod_Metaboenrichment_server("Metaboenrichment_ui_1")

}

