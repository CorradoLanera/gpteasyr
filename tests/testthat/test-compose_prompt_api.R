test_that("compose_prompt_api works", {
  # setup
  role <- "role"
  context <- "context"
  task <- "task"
  instructions <- "instructions"

  sys_prompt <- compose_sys_prompt(role = role, context = context)
  usr_prompt <- compose_usr_prompt(
    task = task, instructions = instructions
  )

  # execution
  res <- compose_prompt_api(sys_prompt, usr_prompt)

  # expectation
  expect_list(res, "list", len = 2)
  expect_list(res[[1]], "character", len = 2)
  expect_list(res[[2]], "character", len = 2)
  expect_string(res[[1]][[1]])
  expect_string(res[[1]][[2]])
  expect_string(res[[2]][[1]])
  expect_string(res[[2]][[2]])
})

test_that("compose_prompt_api works on empty args", {
  # setup
  sys_prompt <- "sys"
  usr_prompt <- "usr"

  # execution
  res_usr_only <- compose_prompt_api(usr_prompt = usr_prompt)
  res_sys_only <- compose_prompt_api(sys_prompt = sys_prompt)
  compose_prompt_api() |>
    expect_error("Both sys and usr prompts are NULL or empty")

  run_usr_only <- query_gpt(res_usr_only)
  run_sys_only <- query_gpt(res_sys_only)

  # expectation
  expect_list(res_usr_only, "list", len = 1)
  expect_list(res_usr_only[[1]], "character", len = 2)
  expect_string(res_usr_only[[1]][[1]])
  expect_string(res_usr_only[[1]][[2]])

  expect_list(res_sys_only, "list", len = 1)
  expect_list(res_sys_only[[1]], "character", len = 2)
  expect_string(res_sys_only[[1]][[1]])
  expect_string(res_sys_only[[1]][[2]])


  expect_list(
    run_usr_only,
    c("character", "integer", "data.frame", "list"),
    len = 7
  )
  expect_string(get_content(run_usr_only))
  expect_integerish(get_tokens(run_usr_only, "all"), len = 3)

  expect_list(
    run_sys_only,
    c("character", "integer", "data.frame", "list"),
    len = 7
  )
  expect_string(get_content(run_sys_only))
  expect_integerish(get_tokens(run_sys_only, "all"), len = 3)
})
