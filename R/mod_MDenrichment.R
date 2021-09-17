#' MDenrichment UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @examples  mod_MDenrichment_ui("MDenrichment_ui")
mod_MDenrichment_ui <- function(id,label = "Input: Microbe NCBI Taxid list",
                                universelist = list("disbiome",
                                "customer_defined_universe")){
  ns <- NS(id)
  tagList(
    tags$div(
      textAreaInput(ns("genelist"),label=label,
                    placeholder = "1591\n853\n39491\n..."),
      numericInput(ns("pvalue"),"p value cutoff", value = 0.05),
      conditionalPanel(
        condition = "input.smoother == ture",
        selectInput(ns("padjustmethod"),"p Adjust Method:",
                    list("BH", "holm", "hochberg", "hommel",
                         "bonferroni", "BY", "fdr", "none"),selected = "BH")),
      numericInput(ns("qvalue"),"p Ajusted value cutoff",value = 0.05),
      conditionalPanel(
        condition = "input.smoother == ture",
        selectInput(ns("Universe"),"Select Universe Gene Set:",
                    universelist, selected = universelist[1])
      ),
      uiOutput(ns("background1")),
      tags$br(),
      actionButton(ns("btn"), label = "Submit",
                   style="background:#6fa6d6;color:white;
                   border: none;text-align: center;font-size: 16px;
                   font-family: 'Times New Roman', Times, serif;"),
      actionButton(ns("ex"), "Example",
                   style="background:#57c3c2;color:white;
                   border: none;text-align: center;font-size: 16px;
                   font-family: 'Times New Roman', Times, serif;"),
      actionButton(ns("clean"),"Clean",
                   style="background:#44b5ce;color:white;
                   border: none;text-align: center;font-size: 16px;
                   font-family: 'Times New Roman', Times, serif;"),

    )
  )
}


#' MDenrichment UI Function II
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @importFrom DT DTOutput datatable renderDT JS
#' @examples  mod_MDenrichment_ui2("MDenrichment_ui")
mod_MDenrichment_ui2 <- function(id){
  ns <- NS(id)
  tagList(
    tags$div(shinycustomloader::withLoader(DT::DTOutput(ns("dt")),
                                           loader = "loader10"),
             style = "height:320px;"),
    # verbatimTextOutput(ns("selectedRows")),
    tags$br(),
    actionButton(ns("update"),"Update",
                 style="background:#dd89c1;color:white;
                 border: none;text-align: center;font-size: 16px;
                 font-family: 'Times New Roman', Times, serif;"),
    helpText("Tip: If you want to show your interested terms,
             just choose the rows and then click the Update button.")


  )
}

#' MDenrichment UI Function III
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @importFrom shinycustomloader withLoader
#' @importFrom shinyWidgets colorPickr
#' @examples  mod_MDenrichment_ui3("MDenrichment_ui")
mod_MDenrichment_ui3 <- function(id){
  ns <- NS(id)
  tagList(
    tabsetPanel(
      tabPanel("Dotplot",
               splitLayout(cellWidths = c("70%","30%"),
                           tags$div(
                             shinycustomloader::withLoader(
                               uiOutput(ns("dotplot_ui")),loader = "dnaspin")),
                           tags$div(
                             conditionalPanel(
                               condition = "input.smoother == ture",
                               selectInput(ns("format"),"Format",
                                           list("pdf", "jpg", "png", "tiff"),
                                           selected = "pdf")),
                             numericInput(ns("dpi"),"Dpi",
                                          value = 300,step = 100),
                             numericInput(ns("w"),"Width",value = 500,
                                          min = 300, max = 2000,step = 50),
                             numericInput(ns("h"),"Height",value = 350,
                                          min = 300,max = 2000,step = 50),
                             tags$table(
                               tags$tr(
                                 tags$td(tags$label("Color1: ")),
                                 tags$td(shinyWidgets::colorPickr(
                                   ns("lowcolor"),label=NULL,
                                   "#D150A7",width=6))

                               ),
                               tags$tr(
                                 tags$td(tags$label("Color2: ")),
                                 tags$td(shinyWidgets::colorPickr(
                                   ns("highcolor"),label=NULL,
                                   "#46bac2", width=6))
                               )
                             ), # color set for dotplot
                             downloadButton(ns("downdotPolt"),"Download")
                           )
               )
      ),
      tabPanel("Barplot",
               splitLayout(cellWidths = c("70%","30%"),
                           tags$div( shinycustomloader::withLoader(
                             uiOutput(ns("barplot_ui")),loader = "dnaspin")),
                           tags$div(
                             conditionalPanel(
                               condition = "input.smoother == ture",
                               selectInput(ns("format2"),"Format",
                                           list("pdf", "jpg", "png", "tiff"),
                                           selected = "pdf")),
                             numericInput(ns("dpi2"),"Dpi",
                                          value = 300,step = 10),
                             numericInput(ns("w2"),"Width",
                                          value = 600,step = 10),
                             numericInput(ns("h2"),"Height",
                                          value = 500,step = 10),
                             tags$table(
                               tags$tr(
                                 tags$td(tags$label("Color1: ")),
                                 tags$td(shinyWidgets::colorPickr(
                                   ns("lowcolor2"),label=NULL,
                                   "#D150A7",width=6))

                               ),
                               tags$tr(
                                 tags$td(tags$label("Color2: ")),
                                 tags$td(shinyWidgets::colorPickr(
                                   ns("highcolor2"),label=NULL,
                                   "#46bac2", width=6))
                               )
                             ), # color set for barplot
                             downloadButton(ns("downbarPolt"),"Download")
                           )

               )
      )
    )
  )
}





#' MDenrichment Server Functions
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @importFrom ggplot2 scale_color_gradient
#' @importFrom ggplot2 scale_fill_gradient
#' @importFrom ggplot2 guides
#' @importFrom ggplot2 guide_colorbar
#' @importFrom enrichplot dotplot
#' @importFrom ggplot2 ggsave
#' @importFrom graphics barplot
#' @importFrom utils data
mod_MDenrichment_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    ID <- NULL
    geneID <- NULL
    GeneRatio <- NULL
    BgRatio <- NULL
    observeEvent(input$ex,{
      updateTextAreaInput(session, "genelist",
                          value = paste0(disbiome_data$organism_ncbi_id[1:50],
                                         collapse = "\n"))
    })
    observeEvent(input$clean,{
      updateTextAreaInput(session, "genelist", value = "")
      output$dotPlot <- NULL
      output$barPlot <- NULL
      output$dt <- NULL

    })

    observe({
      if (input$Universe == "customer_defined_universe") {
        output$background1 <- renderUI({
          ns <- session$ns
          textAreaInput(ns("universelist1"), "Input: Customer Defined Universe",
                        placeholder = "1591\n853\n39491\n...")

        })
      } else {
        output$background1 <- renderUI({
          NULL
        })
      }
    })

    observeEvent(
      input$btn,{
        gene_list <- reactive({
          validate(
            need(!is.null(input$genelist), c("Input is empty."))
          )
          unlist(strsplit(input$genelist, split = "\\s"))
        })

        mda_universe_list <- reactive({
          validate(
            need(!is.null(input$universelist1), c("Universelist is empty."))
          )
          unlist(strsplit(input$universelist1, split = "\\s"))
        })

        if (input$Universe == "disbiome"){
          kk <- isolate(
            enrichMDA(microbe_list = gene_list(),
                      pvalueCutoff = input$pvalue,
                      pAdjustMethod = input$padjustmethod,
                      minGSSize = 10,
                      maxGSSize = 500,
                      qvalueCutoff =input$qvalue)
          )

        }

        else{

          if (input$Universe == "customer_defined_universe"){
            kk <- isolate(
              enrichMDA(microbe_list = gene_list(),
                        pvalueCutoff = input$pvalue,
                        pAdjustMethod = input$padjustmethod,
                        minGSSize = 10,
                        maxGSSize = 500,
                        universe = mda_universe_list(),
                        qvalueCutoff =input$qvalue)
            )
          }

        }

        if(!is.null(kk)){
          dat <- as.data.frame(kk)
          dat$ROWID <- paste0("row-", seq_len(nrow(dat)))
          rowNames <- TRUE # whether to show row names in the table
          colIndex <- as.integer(rowNames)

          output$dt <- DT::renderDT({
            validate(
              need(sum(kk$p.adjust < 0.05) != 0,"No significant results!")
            )
            dtable <- DT::datatable(
              dat, rownames = rowNames,
              extensions = "Select",
              callback = DT::JS(
                "function distinct(value, index, self){
                return self.indexOf(value) === index;
              }",
              "var dt = table.table().node();",
              "var tblID = $(dt).closest('.datatables').attr('id');",
              "var inputName = tblID + '_rows_selected2'",
              "var selected = [];",
              "$(dt).selectable({",
              "  distance : 10,",
              "  selecting: function(evt, ui){",
              "    $(this).find('tbody tr').each(function(i){",
              "      if($(this).hasClass('ui-selecting')){",
              "        var row = table.row(':eq(' + i + ')')",
              "        row.select();",
              "        var rowIndex = parseInt(row.id().split('-')[1]);",
              "        selected.push(rowIndex);",
              "        selected = selected.filter(distinct);",
              "        Shiny.setInputValue(inputName, selected);",
              "      }",
              "    });",
              "  }",
              "}).on('dblclick', function(){table.rows().deselect();});",
              "table.on('click', 'tr', function(){",
              "  var row = table.row(this);",
              "  if(!$(this).hasClass('selected')){",
              "    var rowIndex = parseInt(row.id().split('-')[1]);",
              "    var index = selected.indexOf(rowIndex);",
              "    if(index > -1){",
              "       selected.splice(index, 1);",
              "    }",
              "  }",
              "  Shiny.setInputValue(inputName, selected);",
              "});"
              ),
              selection = "multiple",
              options = list(
                rowId = JS(sprintf("function(data){return data[%d];}",
                                   ncol(dat)-1L+colIndex)),
                columnDefs = list( # hide the ROWID column
                  list(visible = FALSE, targets = ncol(dat)-1L+colIndex)
                ),lengthMenu = c(5, 10), pageLength = 5,
                scrollY="220px"
              )
            )
            dep <- htmltools::htmlDependency("jqueryui", "1.12.1",
                                             "www/shared/jqueryui",
                                             script = "jquery-ui.min.js",
                                             package = "shiny")
            dtable$dependencies <- c(dtable$dependencies, list(dep))
            dtable
          }, server = FALSE)

          selectedRows <- reactive({
            unique(
              c(input[["dt_rows_selected"]], input[["dt_rows_selected2"]])
            )
          })

          output[["selectedRows"]] <- renderText({
            selectedRows()
          })

          output$dotPlot <- renderPlot({

            if(input$update == 0){
              validate(
                need(sum(kk$p.adjust < 0.05) != 0,"No significant results!")
              )
              dotplot(kk) +
                scale_color_gradient(low=input$lowcolor,high=input$highcolor) +
                guides(color = guide_colorbar(reverse = TRUE))
            } else{
              validate(need(selectedRows() != "",
                            "Please select one row at least."))
              dotplot(kk,showCategory=kk[selectedRows(),]$Description) +
                scale_color_gradient(low=input$lowcolor,high=input$highcolor) +
                guides(color = guide_colorbar(reverse = TRUE))

            }
          })

          output$barPlot <- renderPlot({
            if(input$update == 0){
              validate(
                need(sum(kk$p.adjust < 0.05) != 0,"No significant results!")
              )
              barplot(kk) +
                scale_fill_gradient(low=input$lowcolor2,high=input$highcolor2) +
                guides(color = guide_colorbar(reverse = TRUE))
            } else{
              output$barPlot <- renderPlot({
                validate(need(selectedRows() != "",
                              "Please select one row at least."))
                barplot(kk,showCategory=kk[selectedRows(),]$Description) +
                  scale_fill_gradient(low=input$lowcolor2,
                                      high=input$highcolor2) +
                  guides(color = guide_colorbar(reverse = TRUE))
              })
            }
          })

          output$dotplot_ui <- renderUI({
            ns <- session$ns
            plotOutput(ns("dotPlot"),width = paste0(input$w, "px"),
                       height = paste0(input$h, "px"))

          })

          output$barplot_ui <- renderUI({
            ns <- session$ns
            plotOutput(ns("barPlot"),width = paste0(input$w, "px"),
                       height = paste0(input$h, "px"))
          })

          output$downdotPolt <- downloadHandler(
            filename = function(){
              paste0("Dotplot_",Sys.Date(),".",input$format)
            },
            content = function(file){
              if(input$update == 0){
                dotplot(kk) +
                  scale_color_gradient(low=input$lowcolor,
                                       high=input$highcolor) +
                  guides(color = guide_colorbar(reverse = TRUE))
                ggplot2::ggsave(file, width = input$w/72,
                                height = input$h/72, dpi = input$dpi)
              } else{
                dotplot(kk,showCategory=kk[selectedRows(),]$Description) +
                  scale_color_gradient(low=input$lowcolor,
                                       high=input$highcolor) +
                  guides(color = guide_colorbar(reverse = TRUE))
                ggplot2::ggsave(file, width = input$w/72,
                                height = input$h/72, dpi = input$dpi)
              }
            }
          )

          output$downbarPolt <- downloadHandler(
            filename = function(){
              paste0("Barplot_",Sys.Date(),".",input$format2)
            },
            content = function(file){
              if(input$update == 0){
                barplot(kk) + scale_fill_gradient(low=input$lowcolor2,
                                                  high=input$highcolor2) +
                  guides(color = guide_colorbar(reverse = TRUE))
                ggplot2::ggsave(file, width = input$w2/72,
                                height = input$h2/72, dpi = input$dpi2)
              } else{
                barplot(kk,showCategory=kk[selectedRows(),]$Description) +
                  scale_fill_gradient(low=input$lowcolor2,
                                      high=input$highcolor2) +
                  guides(color = guide_colorbar(reverse = TRUE))
                ggplot2::ggsave(file, width = input$w2/72,
                                height = input$h2/72, dpi = input$dpi2)
              }

            }
          )
        }else{
          # output[["selectedRows"]] <- renderText({
          #   "Inputlist is empty."
          # })
          if(!is.null(input$genelist)){
            showNotification("There is no significant result.
                             Please check the input.",duration = 0)
          }
        }


      })

  })
}

## To be copied in the UI
# mod_MDenrichment_ui("MDenrichment_ui_1")

## To be copied in the server
# mod_MDenrichment_server("MDenrichment_ui_1")
