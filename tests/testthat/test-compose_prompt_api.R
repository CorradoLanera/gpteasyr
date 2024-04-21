test_that("compose_prompt_api works", {
  # setup
  role <- "role"
  context <- "context"
  task <- "task"
  instructions <- "instructions"

  sys_prompt <- compose_prompt_system(role = role, context = context)
  usr_prompt <- compose_prompt_user(
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
