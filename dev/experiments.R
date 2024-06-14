batch_id <- "batch_eh23pqnpVq4ZMov2lVVtTNC5" # with errors
# batch_id <- "batch_1CWjWxLMdJWrN9lAm7BcpSk9"
batch_output(batch_id) |>
  purrr::map_dfr(
    \(x) {
      x |>
      stringr::str_remove_all("```(json\\n)?") |>
      jsonlite::fromJSON() |>
      purrr::map(\(res) purrr::pluck(res, "response")) |>
      tibble::as_tibble()
    }
  )

batch_error(batch_id)


batch_status(batch_id)[["output_file_id"]] |>
  batch_result(FALSE) |>
  purrr::map(\(x) purrr::flatten(x)) |>
  purrr::map(\(x) tibble::tibble(batch = x$id, record = x$custom_id, res = x$body$choices$message$content)) |>
  str(3)
