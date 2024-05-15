test_that("get_completion_from_messages works", {
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
  ) |>
    suppressMessages()

  # expectation
  expect_list(
    res,
    c("character", "integer", "data.frame", "list", "NULL"),
    len = 7
  )
  expect_string(get_content(res))
  expect_integerish(get_tokens(res))
  expect_integerish(get_tokens(res, what = "prompt"))
  expect_integerish(get_tokens(res, what = "completion"))
  expect_integerish(get_tokens(res, what = "completion"))
})

test_that("get_completion_from_messages works w/ py", {
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
    messages = messages,
    use_py = TRUE
  ) |>
    suppressMessages()

  # expectation
  expect_list(
    res,
    c("character", "integer", "data.frame", "list", "NULL"),
    len = 7
  )
  expect_string(get_content(res))
  expect_integerish(get_tokens(res))
  expect_integerish(get_tokens(res, what = "prompt"))
  expect_integerish(get_tokens(res, what = "completion"))
  expect_integerish(get_tokens(res, what = "completion"))
})

test_that("seed works", {
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
  res_1 <- get_completion_from_messages(
    model = model,
    messages = messages,
    seed = 123
  ) |>
    get_content() |>
    suppressMessages()

  res_2 <- get_completion_from_messages(
    model = model,
    messages = messages,
    seed = 123
  ) |>
    get_content() |>
    suppressMessages()

  # expectation
  expect_equal(res_1, res_2)
})
