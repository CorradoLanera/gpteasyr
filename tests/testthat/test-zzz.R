test_that("zzz works", {
  expect_message(ubep.gpt:::.onAttach()) |>
    suppressMessages()

  expect_silent(
    suppressPackageStartupMessages(ubep.gpt:::.onAttach())
  )
})

