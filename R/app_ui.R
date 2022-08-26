#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic
    fluidPage(
      fixedPage(
          tags$style(HTML("
                      .tabbable > .nav > li > a {background-color:#ecf4f4;
                      color:#5e616d;width:auto;font-weight:bold;
                      font-family: 'Times New Roman', Times, serif;
                      font-size: 18px;text-align: center;
                      padding:10px 20px;margin:0px;}
                      .shiny-notification {position:fixed;
                                           top: calc(20%);
                                           left: calc(50%);}

                      ")),
          tabsetPanel(
            tabPanel("Gene enrichment analysis",
                     fixedPage(id = "p2",
                              tags$style(
                              HTML(' #p2 {background-color: white;
                                          box-shadow:0px 0px 0px #c6d5d7;}')),
                              fixedRow(
                                column(3,
                                    tags$div(
                                    mod_GENEenrichment_ui("GENEenrichment_ui_1"),
                                    style = "color:#42464c;
                                                font-family:'Times New Roman',
                                                Times, serif;")),
                                column(9,
                                    splitLayout(
                                    tags$div(
                                    mod_GENEenrichment_ui2("GENEenrichment_ui_1"),
                                    style = "color:#42464c;
                                    font-family:'Times New Roman',
                                    Times, serif;")),
                                    tags$hr(),
                                    tags$div(
                                    mod_GENEenrichment_ui3("GENEenrichment_ui_1"),
                                    style = "color:#42464c;
                                    font-family:'Times New Roman',
                                    Times, serif;")
                                                     )
                              )#closed fixedRow

                              )),
            tabPanel("Microbe-Disease enrichment analysis",
                     fixedPage(id = "p3",
                               tags$style(HTML(' #p3
                                               {background-color: white;
                                            box-shadow:0px 0px 0px #c6d5d7;}')),
                               fixedRow(
                                 column(3,
                                      tags$div(
                                      mod_MDenrichment_ui("MDenrichment_ui_1"),
                                      style = "color:#42464c;
                                      font-family:'Times New Roman',
                                      Times, serif;")),
                                 column(9,splitLayout(
                                   tags$div(
                                     mod_MDenrichment_ui2("MDenrichment_ui_1"),
                                     style = "color:#42464c;
                                              font-family:'Times New Roman',
                                              Times, serif;")),
                                     tags$hr(),
                                     tags$div(
                                     mod_MDenrichment_ui3("MDenrichment_ui_1"),
                                     style = "color:#42464c;
                                     font-family:'Times New Roman',
                                     Times,serif;")
                                 )
                               )


                     )),
            tabPanel("Metabo-Pathway analysis",
                    fixedPage(id = "p4",
                              tags$style(HTML(' #p4 {background-color: white;
                                            box-shadow:0px 0px 0px #c6d5d7;}')),
                            fixedRow(
                            column(3,
                              tags$div(
                              mod_Metaboenrichment_ui("Metaboenrichment_ui_1"),
                                         style = "color:#42464c;
                                         font-family:'Times New Roman',
                                         Times, serif;")),
                                column(9,
                                splitLayout(
                                tags$div(
                              mod_Metaboenrichment_ui2("Metaboenrichment_ui_1"),
                                        style = "color:#42464c;
                                                 font-family:'Times New Roman',
                                                 Times, serif;")),
                                tags$hr(),
                                tags$div(
                              mod_Metaboenrichment_ui3("Metaboenrichment_ui_1"),
                                style = "color:#42464c;
                                font-family:'Times New Roman', Times, serif;")
                                )
                              )


            )))


      ) #close fixedpage
    ) #close fillpage
    )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function(){

  add_resource_path(
    'www', app_sys('app/www')
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys('app/www'),
      app_title = 'shiny-MicrobiomeProfiler'
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}

