test_that("zzz works on empty API_KEY", {
  withr::local_envvar(
    list(OPENAI_API_KEY = "")
  )
  expect_message(ubep.gpt:::.onAttach(), regexp = "is not set") |>
    suppressMessages()

  expect_silent(
    suppressPackageStartupMessages(ubep.gpt:::.onAttach())
  )
})

test_that("zzz works with API_KEY set", {
  withr::local_envvar(
    list(OPENAI_API_KEY = "sk-8aZp")
  )
  expect_message(ubep.gpt:::.onAttach(), regexp = "is set") |>
    suppressMessages()

  expect_silent(
    suppressPackageStartupMessages(ubep.gpt:::.onAttach())
  )
})
