test_that("get_completion_from_messages works", {
  skip_on_ci()
  skip_on_cran()

  # setup
  model <- "gpt-3.5-turbo"
  messages <- compose_prompt_api(
    sys_prompt = compose_sys_prompt(
      role = "role",
      context = "context"
    ),
    usr_prompt = compose_usr_prompt(
      task = "task",
      instructions = "instructions"
    )
  )

  # execution
  res <- get_completion_from_messages(
    model = model,
    messages = messages
  )

  # expectation
  expect_list(res, c("character", "list"), len = 2)
  expect_string(get_content(res))
  expect_integerish(get_tokens(res))
  expect_integerish(get_tokens(res, what = "prompt"))
  expect_integerish(get_tokens(res, what = "completion"))
  expect_integerish(get_tokens(res, what = "completion"))
})
