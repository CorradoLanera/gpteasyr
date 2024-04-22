test_that("query_gpt works", {
  skip_on_ci()
  skip_on_cran()

  # setup
  prompt <- compose_prompt_api(
    sys_prompt = compose_sys_prompt("role", "context"),
    usr_prompt = compose_usr_prompt("task", "output", "style")
  )

  # execution
  res <- query_gpt(prompt)

  # expectation
  expect_list(res, c("character", "list"), len = 2)
  expect_string(get_content(res))
  expect_integerish(get_tokens(res), len = 1)
  expect_integerish(get_tokens(res, what = "prompt"), len = 1)
  expect_integerish(get_tokens(res, what = "completion"), len = 1)
  expect_integer(get_tokens(res, what = "all"), len = 3)
})
