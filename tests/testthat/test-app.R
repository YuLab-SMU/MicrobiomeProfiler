library(MicrobiomeProfiler)

testServer(mod_KOenrichment_server, {
  session$genelist <- Rat_data
  expect_true(is.data.frame(output$dt))
})



testServer(mod_COGenrichment_server, {
  session$genelist <- Psoriasis_data
  expect_true(is.data.frame(output$dt))
})


testServer(mod_MDenrichment_server, {
  session$genelist <- microbiota_taxlist
  expect_true(is.data.frame(output$dt))
})
