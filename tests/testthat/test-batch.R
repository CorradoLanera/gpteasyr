test_that("batch utils works", {
  skip_on_cran()
  skip_on_ci()
  skip_if_offline()

  # setup
  sys_prompt <- compose_sys_prompt("Sei un simpatico assistente.")
  usr_prompt <- compose_usr_prompt(
    "Racconta una barzelletta che termini col testo che segue:"
  )
  prompter <- create_usr_data_prompter(usr_prompt = usr_prompt)
  text <-  c(
      "Che barba, che noia!",
      "Un po' noioso, ma interessante",
      "Che bello, mi è piaciuto molto!"
    )

  jsonl_text <- text |>
    purrr::map(
      \(x) compose_prompt_api(
        sys_prompt = sys_prompt,
        usr_prompt = prompter(x)
      )
    ) |>
    create_jsonl_records()
  out_jsonl_path <- write_jsonl_files(jsonl_text, tempdir())

  # eval
  before_start_status <- batch_list()
  n <- nrow(before_start_status)

  batch_file_info <- batch_upload_file(out_jsonl_path)
  Sys.sleep(1)
  batch_job_info <- batch_file_info[["id"]] |>
    batch_create()
  Sys.sleep(1)
  batch_status <- batch_job_info[["id"]] |>
    batch_retrive_status()
  Sys.sleep(1)
  after_start_status <- batch_list()

  batch_cancelled <- batch_job_info[["id"]] |>
    batch_cancel()
  Sys.sleep(1)
  after_cancel_status <- batch_list()

  # expectations
  expect_tibble(before_start_status, nrows = n)
  nc <- sum(
    before_start_status[["status"]] %in% c("cancelled", "cancelling")
  )
  np <- sum(before_start_status[["status"]] == "in_progress")

  expect_tibble(batch_file_info, nrows = 1)
  expect_tibble(batch_job_info, nrows = 1)
  expect_tibble(batch_status, nrows = 1)

  expect_tibble(after_start_status, nrows = n + 1)
  expect_equal(
    sum(after_start_status[["status"]] %in% c("cancelled", "cancelling")),
    nc
  )
  expect_equal(
    sum(after_start_status[["status"]] == "in_progress"),
    np + 1
  )

  expect_tibble(batch_cancelled, nrows = 1)
  expect_tibble(after_cancel_status, nrows = n + 1)
  expect_equal(
    sum(after_cancel_status[["status"]] %in% c("cancelled", "cancelling")),
    nc + 1
  )
  expect_equal(sum(after_cancel_status[["status"]] == "in_progress"), np)

})
