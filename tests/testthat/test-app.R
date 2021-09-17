test_that("enrich function works", {
  library(MicrobiomeProfiler)
  ko <- MicrobiomeProfiler::enrichKO(IPF)
  expect_s4_class(ko, class ="enrichResult")
  cog <- MicrobiomeProfiler::enrichCOG(cog_20$V1[1:50])
  expect_s4_class(cog, class ="enrichResult")
  mda <- MicrobiomeProfiler::enrichSMPDB(mb_examplelist)
  expect_s4_class(mda, class ="enrichResult")
  mb <- MicrobiomeProfiler::enrichMDA(disbiome_data$organism_ncbi_id[1:50])
  expect_s4_class(mb,class ="enrichResult")
  mblist3 <- MicrobiomeProfiler::bitr_smpdb(mb_examplelist,
                                            from_Type = "Metabolite.ID",
                                            to_Type = "KEGG.ID")
  mb3 <- MicrobiomeProfiler::enrichMBKEGG(mblist3$KEGG.ID)
  expect_s4_class(mb3,class ="enrichResult")

})
