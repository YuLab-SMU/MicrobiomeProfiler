#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session ) {
    mod_GENEenrichment_server("GENEenrichment_ui_1")
    mod_MDenrichment_server("MDenrichment_ui_1")
    mod_Metaboenrichment_server("Metaboenrichment_ui_1")

}

