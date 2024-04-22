test_that("compose_prompt works", {
  # setup
  role <- "role"
  context <- "context"
  task <- "task"
  instructions <- "instructions"
  output <- "output"
  style <- "style"
  examples <- "examples"
  text <- "text"

  # execution
  res <- compose_prompt(
    role = role, context = context,
    task = task, instructions = instructions, output = output,
    style = style, examples = examples, text = text
  )
  res_empty <- compose_prompt()
  res_text_only <- compose_prompt(text = text)
  res_no_text <- compose_prompt(
    role = role, context = context,
    task = task, instructions = instructions, output = output,
    style = style, examples = examples
  )

  # expectation
  expect_string(res, n.chars = 67)
  expect_character(res_empty, len = 0)
  expect_string(res_text_only, n.chars = 14)
  expect_string(res_no_text, n.chars = 52)
})

test_that("compose_sys_prompt works", {
  # setup
  role <- "role"
  context <- "context"

  # execution
  res <- compose_sys_prompt(role = role, context = context)
  res_role <- compose_sys_prompt(role = role)
  res_context <- compose_sys_prompt(context = context)
  res_none <- compose_sys_prompt()
  res_empty_role <- compose_sys_prompt(role = "")
  res_empty_context <- compose_sys_prompt(context = "")
  res_empties <- compose_sys_prompt(role = "", context = "")

  # expectation
  expect_string(res, n.chars = 12)
  expect_string(res_role, n.chars = 4)
  expect_string(res_context, n.chars = 7)
  expect_character(res_none, len = 0)
  expect_string(res_empty_role, n.chars = 0)
  expect_string(res_empty_context, n.chars = 0)
  expect_string(res_empties, n.chars = 1)
})

test_that("compose_usr_prompt works", {
  # setup
  task <- "task"
  instructions <- "instructions"
  output <- "output"
  style <- "style"
  examples <- "examples"
  text <- "text"

  # execution
  res <- compose_usr_prompt(
    task = task, instructions = instructions, output = output,
    style = style, examples = examples, text = text
  )
  res_no_text <- compose_usr_prompt(
    task = task, instructions = instructions, output = output,
    style = style, examples = examples
  )
  res_empty <- compose_usr_prompt()
  res_task_only <- compose_usr_prompt(task = task)

  # expectation
  expect_string(res)
  expect_string(res_no_text)
  expect_character(res_empty, len = 0)
  expect_string(res_task_only, n.chars = 4)
})

test_that("create_usr_data_prompter works", {
  # setup
  task <- "task"
  instructions <- "instructions"
  output <- "output"
  style <- "style"
  examples <- "examples"

  usr_prompt <- compose_usr_prompt(
    task = task, instructions = instructions, output = output,
    style = style, examples = examples
  )

  # execution
  res <- create_usr_data_prompter(usr_prompt)
  prompt <- res("text")
  prompt_no_text <- res()
  res_empty <- create_usr_data_prompter()
  prompt_text_only <- res_empty(text = "text")
  prompt_full_empty <- res_empty()

  # expectation
  expect_function(res)
  expect_string(prompt)
  expect_string(prompt_no_text)
  expect_string(prompt_text_only, n.chars = 14)
  expect_character(prompt_full_empty, len = 0)
})

