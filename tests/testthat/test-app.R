test_that("multiplication works", {
  expect_s4_class(enrichKO(IPF), class ="enrichResult")
  expect_s4_class(enrichSMPDB(mb_examplelist), class ="enrichResult")
})
