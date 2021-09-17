test_that("id convertion", {
    y1 <- MicrobiomeProfiler::taxtr(Input = c("Escherichia coli","Lactococcus lactis"), Type = "ScientificName", Level = "species")
    expect_length(y1,2)

})
