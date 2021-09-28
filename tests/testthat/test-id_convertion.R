test_that("id convertion", {
    y1 <- MicrobiomeProfiler::bitr_smpdb(c("HMDB0000538","HMDB0000161","HMDB0000045"),
               from_Type = "HMDB.ID",to_Type = "ChEBI.ID")
    expect_length(y1,2)

})
