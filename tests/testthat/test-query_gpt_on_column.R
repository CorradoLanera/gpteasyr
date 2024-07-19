test_that("query_gpt_on_column works", {
  # setup
  db <- tibble::tibble(
    foo = 1:2,
    commenti = c("commento1", "commento2")
  )
  role <- "role"
  context <- "context"
  task <- "task"
  instructions <- "instructions"
  output <- "output"
  style <- "style"
  examples <- "examples"
  model <- "gpt-4o-mini"
  quiet <- TRUE
  max_try <- 10
  temperature <- 0
  max_tokens <- 1000
  add <- TRUE
  simplify <- TRUE

  sys_prompt <- compose_sys_prompt(role = role, context = context)
  usr_prompt <- compose_usr_prompt(
    task = task, instructions = instructions, output = output,
    style = style, examples = examples
  )

  # execution
  res <- query_gpt_on_column(
    db = db,
    "commenti",
    sys_prompt = sys_prompt,
    usr_prompt = usr_prompt,
    model = model,
    quiet = quiet,
    max_try = max_try,
    temperature = temperature,
    max_tokens = max_tokens,
    add = add,
    simplify = simplify
  ) |>
    suppressMessages()

  res_not_simplified <- query_gpt_on_column(
    db = db,
    "commenti",
    sys_prompt = sys_prompt,
    usr_prompt = usr_prompt,
    model = model,
    quiet = quiet,
    max_try = max_try,
    temperature = temperature,
    max_tokens = max_tokens,
    add = add,
    simplify = FALSE
  ) |>
    suppressMessages()

  res_without_source_text <- query_gpt_on_column(
    db = db,
    "commenti",
    sys_prompt = sys_prompt,
    usr_prompt = usr_prompt,
    model = model,
    quiet = quiet,
    max_try = max_try,
    temperature = temperature,
    max_tokens = max_tokens,
    add = FALSE,
    simplify = simplify
  ) |>
    suppressMessages()

  # expectation
  expect_tibble(res, ncols = 3, nrows = 2)
  expect_tibble(res_not_simplified, ncols = 3, nrows = 2)
  expect_tibble(res_without_source_text, ncols = 1, nrows = 2)
})
