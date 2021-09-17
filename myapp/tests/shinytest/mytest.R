app <- ShinyDriver$new("../../")
app$snapshotInit("mytest")

app$snapshot()

app$setInputs(`examplemodule1-button` = "click")
app$setInputs(`examplemodule1-button` = "click")
app$snapshot()
