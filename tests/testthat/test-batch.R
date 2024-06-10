test_that("batch utils works", {
  skip_on_cran()
  skip_if_offline()

  # setup
  sys_prompt <- compose_sys_prompt("You are a funny assistant.")
  usr_prompt <- compose_usr_prompt(
    "Tell me a joke ending in:"
  )
  prompter <- create_usr_data_prompter(usr_prompt = usr_prompt)
  text <-  c(
    "deadly boring!",
    "A bit boring, but interesting",
    "How nice, I loved it!"
  )

  jsonl_text <- text |>
    purrr::map(
      \(x) {
        compose_prompt_api(
          sys_prompt = sys_prompt,
          usr_prompt = prompter(x)
        )
      }
    ) |>
    create_jsonl_records()
  out_jsonl_path <- write_jsonl_files(jsonl_text, tempdir())

  # eval
  before_start_status <- batch_list()
  Sys.sleep(1)
  n <- nrow(before_start_status)

  batch_file_info <- file_upload(out_jsonl_path)
  batch_job_info <- batch_file_info[["id"]] |>
    batch_create()
  batch_status <- batch_job_info[["id"]] |>
    batch_status()
  after_start_status <- batch_list()
  Sys.sleep(1)

  batch_cancelled <- batch_job_info[["id"]] |>
    batch_cancel()
  after_cancel_status <- batch_list()
  Sys.sleep(1)

  # expectations
  expect_tibble(before_start_status)
  nc <- sum(
    before_start_status[["data"]][["status"]] %in%
      c("cancelled", "cancelling")
  )
  np <- sum(before_start_status[["data"]][["status"]] == "in_progress")

  expect_tibble(batch_file_info, nrows = 1)
  expect_tibble(batch_job_info, nrows = 1)
  expect_tibble(batch_status, nrows = 1)

  expect_tibble(after_start_status)
  expect_lte(
    sum(
      after_start_status[["data"]][["status"]] %in%
        c("cancelled", "cancelling")
    ),
    nc
  )
  expect_gte(
    sum(after_start_status[["data"]][["status"]] == "in_progress"),
    np
  )

  expect_tibble(batch_cancelled, nrows = 1)
  expect_tibble(after_cancel_status, min.rows = n)
  expect_gte(
    sum(after_cancel_status[["data"]][["status"]] %in%
          c("cancelled", "cancelling")),
    nc
  )
  expect_equal(
    sum(after_cancel_status[["data"]][["status"]] == "in_progress"),
    np
  )

})

test_that("batch_* works well on error input", {
  # setup
  wrong_input <- "foo"

  # eval
  batch_create(wrong_input) |>
    expect_error("API request failed")

  batch_status(wrong_input) |>
    expect_error("API request failed")

  batch_result(wrong_input) |>
    expect_error("API request failed")

  batch_cancel(wrong_input) |>
    expect_error("API request failed")
})
