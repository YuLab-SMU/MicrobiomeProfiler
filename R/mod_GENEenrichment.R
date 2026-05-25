#' Gene enrichment UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#' @param label parameters for input ui
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @importFrom DT DTOutput datatable renderDT JS
#' @importFrom ggplot2 scale_color_gradient
#' @importFrom ggplot2 scale_fill_gradient
#' @importFrom enrichplot dotplot
#' @examples mod_COGenrichment_ui("COGenrichment_ui")
mod_GENEenrichment_ui <- function(id,label = "Input: Gene list"){
  ns <- NS(id)
  tagList(
    tags$div(
        conditionalPanel(
            condition = "input.smoother == true",
            selectInput(ns("type"),"ID Type",list("KEGG","COG","eggNOG"),
                        selected = "KEGG")
        ),
      uiOutput(ns("analysis_mode_ui")),
      textAreaInput(ns("genelist"),label=label,
                    placeholder = "K03430\nK01569\n..."),
      uiOutput(ns("input_help")),
      numericInput(ns("pvalue"),"p adjusted value cutoff", value = 0.05),
      conditionalPanel(
        condition = "input.smoother == true",
        selectInput(ns("padjustmethod"),"p Adjust Method:",
                    list("BH", "holm", "hochberg", "hommel",
                         "bonferroni", "BY", "fdr", "none"),selected = "BH")),
      numericInput(ns("qvalue"),"q value cutoff",value = 0.05),
      uiOutput(ns("backset")),
      conditionalPanel(
          condition = "input.smoother == true",
          selectInput(ns("Universe"),"Select Universe Gene Set:",
                      list("Default",
                           # "human_gut2014",
                           # "human_gut2016",
                           # "human_skin",
                           # "human_vagina",
                           "customer_defined_universe"),
                      selected = "Default"),

      ),
      #uiOutput(ns("universe")),

      uiOutput(ns("background1")),
      tags$br(),
      actionButton(ns("btn"), label = "Submit",
                   style="background:#6fa6d6;color:white;
                   border: none;text-align: center;font-size: 16px;
                   font-family: 'Times New Roman', Times, serif;"),
      actionButton(ns("ex"), "Example",style="background:#57c3c2;
                   color:white;border: none;text-align: center;
                   font-size: 16px;
                   font-family: 'Times New Roman', Times, serif;"),
      actionButton(ns("clean"),"Clean",style="background:#44b5ce;
                   color:white;border: none;text-align: center;
                   font-size: 16px;
                   font-family: 'Times New Roman', Times, serif;"),

    )
  )
}

#' COGenrichment UI Function II
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @importFrom DT DTOutput datatable renderDT JS
#' @importFrom ggplot2 scale_color_gradient
#' @importFrom ggplot2 scale_fill_gradient
#' @importFrom enrichplot dotplot
#' @examples mod_COGenrichment_ui2("COGenrichment_ui")
mod_GENEenrichment_ui2 <- function(id){
  ns <- NS(id)
  tagList(
    tags$div(shinycustomloader::withLoader(DT::DTOutput(ns("dt")),
                                           loader = "loader10"),
             style = "height:320px;"),
    # verbatimTextOutput(ns("selectedRows")),
    tags$br(),
    actionButton(ns("update"),"Update",
                 style="background:#dd89c1;color:white;
                 border: none;text-align: center;
                 font-size: 16px;
                 font-family: 'Times New Roman', Times, serif;"),
    helpText("Tip: If you want to show your interested terms,
             just choose the rows and then click the Update button.")


  )
}

#' COGenrichment UI Function III
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
#' @importFrom ggplot2 scale_color_gradient
#' @importFrom ggplot2 scale_fill_gradient
#' @importFrom enrichplot dotplot
#' @importFrom ggplot2 ggsave
#' @examples mod_COGenrichment_ui3("COGenrichment_ui")
mod_GENEenrichment_ui3 <- function(id){
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
                               condition = "input.smoother == true",
                               selectInput(ns("format"),"Format",
                                           list("pdf", "jpg", "png", "tiff"),
                                           selected = "pdf")),
                             numericInput(
                               ns("dpi"),"Dpi",value = 300,step = 100),
                             numericInput(ns("w"),"Width",
                                          value = 500, min = 300,
                                          max = 2000,step = 50),
                             numericInput(ns("h"),"Height",
                                          value = 350, min = 300,
                                          max = 2000,step = 50),
                             tags$table(
                               tags$tr(
                                 tags$td(tags$label("Color1 ")),
                                 tags$td(
                                   shinyWidgets::colorPickr(ns("lowcolor"),
                                  label=NULL, "#D150A7",width=6))

                               ),
                               tags$tr(
                                 tags$td(tags$label("Color2 ")),
                                 tags$td(
                                   shinyWidgets::colorPickr(ns("highcolor"),
                                              label=NULL, "#46bac2", width=6))
                               )
                             ), # color set
                             downloadButton(ns("downdotPolt"),"Download")
                           )
               )
      ),
      tabPanel("Barplot",
               splitLayout(cellWidths = c("70%","30%"),
                           tags$div(
                             shinycustomloader::withLoader(
                               uiOutput(ns("barplot_ui")),loader = "dnaspin")),
                           tags$div(
                             conditionalPanel(
                               condition = "input.smoother == true",
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
                                 tags$td(tags$label("Color1 ")),
                                 tags$td(shinyWidgets::colorPickr(
                                   ns("lowcolor2"),label=NULL,
                                   "#D150A7",width=6))

                               ),
                               tags$tr(
                                 tags$td(tags$label("Color2 ")),
                                 tags$td(shinyWidgets::colorPickr(
                                   ns("highcolor2"),label=NULL,
                                   "#46bac2", width=6))
                               )
                             ), #color set for barplot
                             downloadButton(ns("downbarPolt"),"Download")
                           )

               )
      )
    )
  )
}





#' COGenrichment Server Functions
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @importFrom ggplot2 scale_color_gradient
#' @importFrom ggplot2 scale_fill_gradient
#' @importFrom ggplot2 guides
#' @importFrom ggplot2 guide_colorbar
#' @importFrom enrichplot dotplot
#' @importFrom graphics barplot
#' @importFrom utils data
gene_source_example_ids <- function(source_db, eggnog_loader = mp_eggnog_gson) {
    if (identical(source_db, "KEGG")) {
        return(IPF)
    }

    if (identical(source_db, "COG")) {
        return(unique(cog_example))
    }

    if (identical(source_db, "eggNOG")) {
        example_ids <- tryCatch(
            {
                eggnog_obj <- suppressWarnings(eggnog_loader(refresh = FALSE))
                head(unique(as.character(methods::slot(eggnog_obj, "gsid2gene")$gene)), 10)
            },
            error = function(e) {
                c("OG0001", "OG0002", "OG0003")
            }
        )

        example_ids <- unique(example_ids[!is.na(example_ids) & nzchar(example_ids)])
        return(example_ids)
    }

    character()
}


gene_source_example_text <- function(source_db,
                                     analysis_mode = "ORA",
                                     eggnog_loader = mp_eggnog_gson) {
    analysis_mode <- toupper(analysis_mode)

    if (identical(source_db, "eggNOG") && identical(analysis_mode, "GSEA")) {
        example_ids <- gene_source_example_ids(
            source_db = source_db,
            eggnog_loader = eggnog_loader
        )
        example_ids <- head(example_ids, 5)
        example_scores <- c(2.5, 1.5, 0.8, -0.8, -1.6)[seq_along(example_ids)]
        return(paste(example_ids, example_scores, sep = "\t", collapse = "\n"))
    }

    paste0(
        gene_source_example_ids(source_db = source_db, eggnog_loader = eggnog_loader),
        collapse = "\n"
    )
}


parse_ranked_gene_list <- function(text) {
    lines <- unlist(strsplit(text, split = "\n", fixed = TRUE))
    lines <- trimws(lines)
    lines <- lines[nzchar(lines)]

    if (!length(lines)) {
        stop("Input is empty.", call. = FALSE)
    }

    fields <- strsplit(lines, "[,[:space:]]+")
    if (any(lengths(fields) < 2L)) {
        stop("Each line must contain an identifier and a numeric score.", call. = FALSE)
    }

    ids <- vapply(fields, `[[`, character(1), 1)
    scores <- suppressWarnings(as.numeric(vapply(fields, `[[`, character(1), 2)))

    if (any(is.na(scores))) {
        stop("Each ranked entry must include a valid numeric score.", call. = FALSE)
    }

    stats::setNames(sort(scores, decreasing = TRUE), ids[order(scores, decreasing = TRUE)])
}

mod_GENEenrichment_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    ID <- NULL
    geneID <- NULL
    GeneRatio <- NULL
    BgRatio <- NULL
    current_analysis_mode <- reactive({
        if (identical(input$type, "eggNOG") && identical(input$analysis_mode, "GSEA")) {
            "GSEA"
        } else {
            "ORA"
        }
    })
    output$analysis_mode_ui <- renderUI({
        if (!identical(input$type, "eggNOG")) {
            return(NULL)
        }

        selectInput(
            ns("analysis_mode"),
            "Analysis Type",
            list("ORA", "GSEA"),
            selected = "ORA"
        )
    })
    output$input_help <- renderUI({
        if (identical(current_analysis_mode(), "GSEA")) {
            helpText("GSEA input format: one eggNOG OG and one numeric score per line, e.g. OG0001 2.5. Universe and q value cutoff are ignored in this mode.")
        } else {
            helpText("Input one identifier per line.")
        }
    })
    observeEvent(input$ex,{
        example_ids <- gene_source_example_text(
            source_db = input$type,
            analysis_mode = current_analysis_mode()
        )
        updateTextAreaInput(session, "genelist",
                            value = example_ids)
    })
    observeEvent(input$clean,{
        updateTextAreaInput(session, "genelist", value = "")
        output$dotPlot <- NULL
        output$barPlot <- NULL
        output$dt <- NULL
    })
    observe({
        if (input$type == "KEGG") {
            output$backset <- renderUI({
                ns <- session$ns
                tagList(
                    selectInput(ns("backgroundset"),"Select Background Set:",
                                list("KEGG"), selected = "KEGG")

                )
            })
        } else if(input$type == "COG"){
            output$backset <- renderUI({
                ns <- session$ns
                tagList(
                    selectInput(ns("backgroundset"),"Select Background Set:",
                                list("COG_category","COG_pathway"),
                                selected = "COG_category")
                )
            })
        } else if(input$type == "eggNOG"){
            output$backset <- renderUI({
                ns <- session$ns
                tagList(
                    selectInput(ns("backgroundset"),"Select Background Set:",
                                list("eggNOG_KEGG"),
                                selected = "eggNOG_KEGG")
                )
            })
        }
    })

    observe({
      if (input$Universe == "customer_defined_universe") {
        output$background1 <- renderUI({
          ns <- session$ns
          tagList(
            textAreaInput(ns("universelist1"), "Input: Customer Defined Universe",
                          placeholder = "K03430\nK01569\n...")
          )

        })
      } else {
        output$background1 <- renderUI({
          NULL
        })
      }
    })

    observeEvent(
      input$btn,{

        output$dotPlot <- NULL
        output$barPlot <- NULL
        output$dt <- NULL

        gene_list <- reactive({
          validate(
            need(!is.null(input$genelist), c("Input is empty."))
          )
          unlist(strsplit(input$genelist, split = "\\s"))
        })
        ranked_gene_list <- reactive({
          validate(
            need(!is.null(input$genelist) && nzchar(trimws(input$genelist)), c("Input is empty."))
          )
          parse_ranked_gene_list(input$genelist)
        })

        ko_universe_list <- reactive({
          validate(
            need(!is.null(input$universelist1), c("Universelist is empty."))
          )
          unlist(strsplit(input$universelist1, split = "\\s"))
        })

        if(input$type == "KEGG"){
            if (input$Universe == "Default"){
                kk <- isolate(
                    enrichKO(gene = gene_list(),
                             pvalueCutoff = input$pvalue,
                             pAdjustMethod = input$padjustmethod,
                             minGSSize = 10,
                             maxGSSize = 500,
                             qvalueCutoff =input$qvalue)
                )

            } else if(input$Universe == "customer_defined_universe"){
                kk <- isolate(
                    enrichKO(gene = gene_list(),
                             pvalueCutoff = input$pvalue,
                             pAdjustMethod = input$padjustmethod,
                             minGSSize = 10,
                             maxGSSize = 500,
                             universe = ko_universe_list(),
                             qvalueCutoff =input$qvalue)
                )
            } #else {
            #     universe_geneset <- get(input$Universe)
            #     kk <- isolate(
            #         enrichKO(gene = gene_list(),
            #                  pvalueCutoff = input$pvalue,
            #                  pAdjustMethod = input$padjustmethod,
            #                  minGSSize = 10,
            #                  maxGSSize = 500,
            #                  universe = universe_geneset,
            #                  qvalueCutoff =input$qvalue)
            #     )
            # }

        } else if(input$type == "COG"){
            if (input$backgroundset == "COG_category" ){
              if(input$Universe == "Default"){
                kk <- isolate(
                  enrichCOG(gene = gene_list(),
                            dtype = "category",
                            pvalueCutoff = input$pvalue,
                            pAdjustMethod = input$padjustmethod,
                            minGSSize = 10,
                            maxGSSize = 500,
                            qvalueCutoff =input$qvalue)
                ) }
              else{
                  if(input$Universe == "customer_defined_universe"){
                    kk <- isolate(
                      enrichCOG(gene = gene_list(),
                                dtype = "category",
                                pvalueCutoff = input$pvalue,
                                pAdjustMethod = input$padjustmethod,
                                minGSSize = 10,
                                maxGSSize = 500,
                                universe = ko_universe_list(),
                                qvalueCutoff =input$qvalue)
                    )
                  }
                }



            } else if (input$backgroundset == "COG_pathway" ){
                if(input$Universe == "Default"){
                  kk <- isolate(
                    enrichCOG(gene = gene_list(),
                              dtype = "pathway",
                              pvalueCutoff = input$pvalue,
                              pAdjustMethod = input$padjustmethod,
                              minGSSize = 10,
                              maxGSSize = 500,
                              qvalueCutoff =input$qvalue)
                  )
                } else{
                  if(input$Universe == "customer_defined_universe"){
                    kk <- isolate(
                      enrichCOG(gene = gene_list(),
                                dtype = "pathway",
                                pvalueCutoff = input$pvalue,
                                pAdjustMethod = input$padjustmethod,
                                minGSSize = 10,
                                maxGSSize = 500,
                                universe = ko_universe_list(),
                                qvalueCutoff =input$qvalue)
                    )
                  }
                }

              }

        } else if(input$type == "eggNOG"){
            if (current_analysis_mode() == "GSEA") {
                kk <- isolate(
                    gseEggNOG(geneList = ranked_gene_list(),
                              exponent = 1,
                              minGSSize = 10,
                              maxGSSize = 500,
                              pvalueCutoff = input$pvalue,
                              pAdjustMethod = input$padjustmethod)
                )
            } else {
                if(input$Universe == "Default"){
                    kk <- isolate(
                        enrichEggNOG(gene = gene_list(),
                                     pvalueCutoff = input$pvalue,
                                     pAdjustMethod = input$padjustmethod,
                                     minGSSize = 10,
                                     maxGSSize = 500,
                                     qvalueCutoff = input$qvalue)
                    )
                } else if(input$Universe == "customer_defined_universe"){
                    kk <- isolate(
                        enrichEggNOG(gene = gene_list(),
                                     pvalueCutoff = input$pvalue,
                                     pAdjustMethod = input$padjustmethod,
                                     minGSSize = 10,
                                     maxGSSize = 500,
                                     universe = ko_universe_list(),
                                     qvalueCutoff = input$qvalue)
                    )
                }
            }

        } else{
            kk <- NULL
        }



        if(nrow(as.data.frame(kk)) != 0){
          dat <- as.data.frame(kk)
          dat$ROWID <- paste0("row-", seq_len(nrow(dat)))
          rowNames <- TRUE # whether to show row names in the table
          colIndex <- as.integer(rowNames)

          output$dt <- DT::renderDT({
            req(!is.null(dat))
            # validate(
            #   need(sum(kk$p.adjust < 0.05) != 0,"No significant results!")
            # )
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
              # validate(
              #   need(sum(kk$p.adjust < 0.05) != 0,"No significant results!")
              # )
              dotplot(kk) +
              ggplot2::scale_color_gradient(low=input$lowcolor,
                                            high=input$highcolor) +
                guides(color = guide_colorbar(reverse = TRUE))
            } else{
              validate(need(selectedRows() != "",
                            "Please select one row at least."))
              dotplot(kk,showCategory=kk[selectedRows(),]$Description)+
                scale_color_gradient(low=input$lowcolor,high=input$highcolor) +
                guides(color = guide_colorbar(reverse = TRUE))

            }
          })

          output$barPlot <- renderPlot({
            if(input$update == 0){
              # validate(
              #   need(sum(kk$p.adjust < 0.05) != 0,"No significant results!")
              # )
              barplot(kk) +
                scale_fill_gradient(low=input$lowcolor2,high=input$highcolor2)+
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
                barplot(kk) +
                  scale_fill_gradient(low=input$lowcolor2,
                                      high=input$highcolor2) +
                  guides(color = guide_colorbar(reverse = TRUE))
                ggplot2::ggsave(file, width = input$w2/72, height = input$h2/72,
                                dpi = input$dpi2)
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
          if(!is.null(input$genelist)){
            showNotification("There is no significant result.
                             Please check the input.",duration = 0)
          }
        }

      })

  })
}


