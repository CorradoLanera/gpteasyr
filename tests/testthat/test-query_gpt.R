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
  expect_list(
    res,
    c("character", "integer", "data.frame", "list"),
    len = 7
    )
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
    expect_error(regexp = "is not of type 'array' - 'messages'")
})

test_that("na_if_error works", {
  # setup
  prompt <- "prompt"

  # execution
  expect_warning({
    res <- query_gpt(prompt, max_try = 1, na_if_error = TRUE)
  }, "is not of type 'array' - 'messages'") |>
    suppressMessages()

  # expectation
  expect_scalar_na(res)
  expect_string(get_content(res), na.ok = TRUE)
  expect_integerish(get_tokens(res), len = 1)
  expect_integerish(get_tokens(res, what = "prompt"), len = 1)
  expect_integerish(get_tokens(res, what = "completion"), len = 1)
  expect_integer(get_tokens(res, what = "all"), len = 3)
})


test_that("query_gpt without or empty sys_prompt works", {
  # setup
  messages <- compose_prompt_api(usr_prompt = "usr")

  # execution
  res <- get_completion_from_messages(
    messages,
    endpoint = "http://93.44.129.9:4321/v1/chat/completions",
    model = "lmstudio-community/Meta-Llama-3-8B-Instruct-GGUF"
  )

  # expectation
  expect_list(
    res, c("character", "integer", "data.frame", "list")
  )
  expect_string(get_content(res))
  expect_integerish(get_tokens(res), len = 1)
  expect_integerish(get_tokens(res, what = "prompt"), len = 1)
  expect_integerish(get_tokens(res, what = "completion"), len = 1)
  expect_integer(get_tokens(res, what = "all"), len = 3)
})
