#' Upload batch file
#'
#' @param jsonl_path (chr) path to jsonl file to upload
#'
#' @return
#' @export
#'
#' @examples
#' batch_file_info <- here::here("abc123.jsonl") |>
#'   batch_upload_file()
#' batch_file_info
batch_upload_file <- function(jsonl_path) {
  checkmate::qassert(jsonl_path, "S1")
  checkmate::assert_file_exists(jsonl_path, extension = "jsonl")

  httr::POST(
    "https://api.openai.com/v1/files",
    httr::add_headers(
      "Authorization" = paste("Bearer", Sys.getenv("OPENAI_API_KEY"))
    ),
    body = list(
      purpose = "batch",
      file = httr::upload_file(jsonl_path)
    )
  ) |>
    parse_httr_response()
}


#' Create batch
#'
#' @param input_file_id (chr) id of the input file
#'
#' @return
#' @export
#'
#' @examples
#' batch_create("file-abc123")
#'
#' batch_file_info <- here::here("abc123.jsonl") |>
#'   batch_upload_file()
#' batch_job_info <- batch_file_info[["id"]] |>
#'   batch_create()
#' batch_job_info
batch_create <- function(input_file_id) {
  checkmate::qassert(input_file_id, "S1")

  httr::POST(
    "https://api.openai.com/v1/batches",
    httr::add_headers(
      "Authorization" = paste("Bearer", Sys.getenv("OPENAI_API_KEY"))
    ),
    httr::content_type_json(),
    encode = "json",
    body = list(
      input_file_id = input_file_id,
      endpoint = "/v1/chat/completions",
      completion_window = "24h"
    )
  ) |>
    parse_httr_response()
}


#' Retrieve batch status
#'
#' This function retrieves the status of a batch.
#'
#' @param batch_id (chr) the batch id to check
#'
#' @return
#' @export
#'
#' @examples
#' batch_retrive_status("batch_abc123")
#'
#' batch_file_info <- here::here("abc123.jsonl") |>
#'   batch_upload_file()
#' batch_job_info <- batch_file_info[["id"]] |>
#'   batch_create()
#' batch_status <- batch_job_info[["id"]] |>
#'   batch_retrive_status()
#' batch_status
batch_retrive_status <- function(batch_id = "") {
  checkmate::qassert(batch_id, "S1")

  httr::GET(
    stringr::str_glue("https://api.openai.com/v1/batches/{batch_id}"),
    httr::add_headers(
      "Authorization" = paste("Bearer", Sys.getenv("OPENAI_API_KEY"))
    ),
    httr::content_type_json()
  ) |>
    parse_httr_response()
}



#' Cancel batch job
#'
#' @param batch_id  (chr) the batch id to cancel
#'
#' @return
#' @export
#'
#' @examples
#' batch_cancel("batch_abc123")
#'
#' batch_file_info <- here::here("abc123.jsonl") |>
#'   batch_upload_file()
#' batch_job_info <- batch_file_info[["id"]] |>
#'   batch_create()
#' batch_cancelled <- batch_job_info[["id"]] |>
#'   batch_cancel()
#' batch_cancelled
batch_cancel <- function(batch_id) {
  checkmate::qassert(batch_id, "S1")

  httr::POST(
    stringr::str_glue(
      "https://api.openai.com/v1/batches/{batch_id}/cancel"
    ),
    httr::add_headers(
      "Authorization" = paste("Bearer", Sys.getenv("OPENAI_API_KEY"))
    ),
    httr::content_type_json()
  ) |>
    parse_httr_response()
}


#' List all batches
#'
#' @param n (int)
#'
#' @return
#' @export
#'
#' @examples
#' a <- batch_list()
#' batch_list(2)
#' batch_list(Inf)
batch_list <- function(n = 10) {
  checkmate::qassert(n, "X1(0,]")

  httr::GET(
    stringr::str_glue("https://api.openai.com/v1/batches?limit={n}"),
    httr::add_headers(
      "Authorization" = paste("Bearer", Sys.getenv("OPENAI_API_KEY"))
    ),
    httr::content_type_json(),
    encode = "json"
  ) |>
    parse_httr_response()
}


#' Retrieve batch results
#'
#' @param batch_id  (chr) id of the output file from the Batch object
#'
#' @return
#' @export
#'
#' @examples
#'
#' batch_file_info <- here::here("abc123.jsonl") |>
#'   batch_upload_file()
#' batch_job_info <- batch_file_info[["id"]] |>
#'   batch_create()
#' batch_status <- batch_job_info[["id"]]
#'   batch_retrive_status()
#' result <- batch_status[["output_file_id"]] |>
#'   batch_retreive_results()
batch_retreive_results <- function(output_file_id) {
  file_id <- if (!is.na(output_file_id)) {
    output_file_id
  } else {
    batch_status[["error_file_id"]]
  }


 response <-  httr::GET(
    stringr::str_glue(
      "https://api.openai.com/v1/files/{file_id}/content"
    ),
    httr::add_headers(
      "Authorization" = paste("Bearer", Sys.getenv("OPENAI_API_KEY"))
    ),
    httr::content_type_json()
  ) |>
    parse_httr_response(convert_json = FALSE) |>
    split_results()
}

split_results <- function(response) {
  response |>
    stringr::str_trim() |>
    stringr::str_split("\\n") |>
    purrr::list_c() |>
    purrr::map(\(x) {
      x |>
        jsonlite::fromJSON() |>
        purrr::map(\(x) x %||% NA)
    })
}

parse_httr_response <- function(response, convert_json = TRUE) {
  parsed <- response |>
    httr::content(as = "text", encoding = "UTF-8")

  if (httr::http_error(response)) {
    err <- parsed[["error"]]
    err <- if (is.character(err)) err else err[["message"]]
    stringr::str_c(
      "API request failed [",
      httr::status_code(response),
      "]:\n\n",
      err
    ) |>
      usethis::ui_stop()
  }

  if (convert_json) {
    parsed |>
      jsonlite::fromJSON() |>
      purrr::map(\(x) x %||% NA) |>
      purrr::list_flatten() |>
      tibble::as_tibble()
  } else {
    parsed
  }
}

# response_list_to_tibble <- function(resp) {
#   if (is.data.frame(resp)) return(
#     tibble::as_tibble(resp) |>
#       purrr::map(\(x) x %||% NA)
#   )
#
#   resp |>
#     purrr::map(\(x) x %||% NA) |>
#     purrr::list_flatten() |>
#     tibble::as_tibble()
# }


# results_to_tibble <- function(response) {
#   parsed <- response |>
#     httr::content(as = "text", encoding = "UTF-8") |>
#     stringr::str_trim() |>
#     stringr::str_split("\\n") |>
#     purrr::flatten_chr() |>
#     purrr::map(
#       \(x) jsonlite::fromJSON(x) |>
#         response_list_to_tibble() |>
#         dplyr::mutate(body = purrr::map(body, response_list_to_tibble))
#     ) |>
#     purrr::list_rbind()
#
#   if (httr::http_error(response)) {
#     err <- parsed[["error"]]
#     err <- if (is.character(err)) err else err[["message"]]
#     stringr::str_c(
#       "API request failed [",
#       httr::status_code(response),
#       "]:\n\n",
#       err
#     ) |>
#       usethis::ui_stop()
#   }
#   parsed
# }
