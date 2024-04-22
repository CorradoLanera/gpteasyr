test_that("query_gpt works", {
  # setup
  prompt <- compose_prompt_api(
    sys_prompt = compose_sys_prompt("role", "context"),
    usr_prompt = compose_usr_prompt("task", "output", "style")
  )

  # execution
  expect_message({
    res <- query_gpt(prompt, quiet = FALSE)
  }, "Total token used") |>
    suppressMessages()

  # expectation
  expect_list(res, c("character", "list"), len = 2)
  expect_string(get_content(res))
  expect_integerish(get_tokens(res), len = 1)
  expect_integerish(get_tokens(res, what = "prompt"), len = 1)
  expect_integerish(get_tokens(res, what = "completion"), len = 1)
  expect_integer(get_tokens(res, what = "all"), len = 3)
})

test_that("query_gpt restarts", {
  # setup
  prompt <- "prompt"

  # expectation
  try(query_gpt(prompt, max_try = 2, quiet = FALSE), silent = TRUE) |>
    expect_message("Max unsucessfully tries (2) reached", fixed = TRUE) |>
    suppressMessages()

  try(query_gpt(prompt, max_try = 2, quiet = FALSE), silent = TRUE) |>
    expect_message("Try: 2", fixed = TRUE) |>
    suppressMessages()

  query_gpt(prompt, max_try = 2, quiet = FALSE) |>
    suppressMessages() |>
    expect_error(regexp = "messages is not a list")
})

test_that("query_gpt throws error on unsupported models", {
  # setup
  prompt <- "prompt"
  model <- "abc"

  # expectation
  expect_error({
    query_gpt(prompt, model = model)
  }, regexp = "'arg' should be one of")
})
