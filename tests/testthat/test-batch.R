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
  batch_job_info <- batch_file_info[["id"]] |>
    batch_create()
  batch_status <- batch_job_info[["id"]] |>
    batch_retrive_status()
  after_start_status <- batch_list()

  batch_cancelled <- batch_job_info[["id"]] |>
    batch_cancel()
  after_cancel_status <- batch_list()

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
