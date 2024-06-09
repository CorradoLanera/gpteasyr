#' Upload batch file
#'
#' @param jsonl_path (chr) path to jsonl file to upload
#'
#' @return (tibble) information about the uploaded file
#'
#' @details
#' For more information, see the
#' [OpenAI API documentation](https://platform.openai.com/docs/api-reference/batch).
#'
#'
#' @export
#' @family batch
#'
#' @examples
#' if (FALSE) {
#'   batch_file_info <- batch_upload_file("abc123.jsonl")
#'   batch_file_info
#' }
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
#' @return (tibble) information about the created batch
#'
#' @details
#' For more information, see the
#' [OpenAI API documentation](https://platform.openai.com/docs/api-reference/batch).
#'
#' @export
#' @family batch
#'
#' @examples
#' if (FALSE) {
#'   batch_create("file-abc123")
#'
#'   batch_file_info <- batch_upload_file("abc123.jsonl")
#'   batch_job_info <- batch_file_info[["id"]] |>
#'     batch_create()
#'   batch_job_info
#' }
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
#' @return (tibble) information about the batch status
#'
#' @details
#' For more information, see the
#' [OpenAI API documentation](https://platform.openai.com/docs/api-reference/batch).
#'
#'
#' @details
#' For more information, see the
#' [OpenAI API documentation](https://platform.openai.com/docs/api-reference/batch).
#'
#' @export
#' @family batch
#'
#' @examples
#' if (FALSE) {
#'   batch_status("batch_abc123")
#'
#'   batch_file_info <- batch_upload_file("abc123.jsonl")
#'   batch_job_info <- batch_file_info[["id"]] |>
#'     batch_create()
#'   batch_status <- batch_job_info[["id"]] |>
#'     batch_status()
#'   batch_status
#' }
batch_status <- function(batch_id = "") {
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
#' @return (tibble) information about the cancelled batch
#'
#' @details
#' For more information, see the
#' [OpenAI API documentation](https://platform.openai.com/docs/api-reference/batch).
#'
#' @export
#' @family batch
#'
#' @examples
#' if (FALSE) {
#'   batch_cancel("batch_abc123")
#'
#'   batch_file_info <- batch_upload_file("abc123.jsonl")
#'   batch_job_info <- batch_file_info[["id"]] |>
#'     batch_create()
#'   batch_cancelled <- batch_job_info[["id"]] |>
#'     batch_cancel()
#'   batch_cancelled
#' }
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
#' @param n (int) number of batches to retrieve
#'
#' @return (tibble) information about the batches
#'
#' @details
#' For more information, see the
#' [OpenAI API documentation](https://platform.openai.com/docs/api-reference/batch).
#'
#' @export
#' @family batch
#'
#' @examples
#' if (FALSE) {
#'   batch_list()
#'   batch_list(2)
#'   batch_list(Inf)
#' }
batch_list <- function(n = 10) {
  checkmate::qassert(n, "X1(0,]")

  httr::with_config(
    httr::timeout(600),
    httr::GET(
      stringr::str_glue("https://api.openai.com/v1/batches?limit={n}"),
      httr::add_headers(
        "Authorization" = paste("Bearer", Sys.getenv("OPENAI_API_KEY"))
      ),
      httr::content_type_json(),
      encode = "json"
    ) |>
      parse_httr_response()
  )
}


#' Retrieve batch results
#'
#' @param output_file_id (chr) the output file id as returned by the
#'   batch status.
#' @param simplify (lgl, default TRUE) whether to simplify the output,
#'   i.e. return only the response body as for single standard
#'   completions (the default), or the full response.
#'
#'
#' @details
#' For more information, see the
#' [OpenAI API documentation](https://platform.openai.com/docs/api-reference/batch).
#'
#' @return (list) if simplify is TRUE, a list of the batch results;
#'   otherwise, a list of the full responses.
#'
#' @export
#' @family batch
#'
#' @examples
#' if (FALSE) {
#'   batch_file_info <- batch_upload_file("abc123.jsonl")
#'   batch_job_info <- batch_file_info[["id"]] |>
#'     batch_create()
#'   batch_status <- batch_job_info[["id"]] |>
#'     batch_status()
#'
#'   # once the batch is completed
#'   results <- batch_status[["output_file_id"]] |>
#'     batch_result()
#'   res <- results |>
#'     purrr::map_chr(get_content)
#'   res
#'
#'   full_results <- batch_status[["output_file_id"]] |>
#'     batch_result(simplify = FALSE)
#'   str(full_results, 2)
#'   full_res <- full_results |>
#'     purrr::map_chr(\(x) get_content(x[["response"]][["body"]]))
#'   full_res
#'
#'   identical(res, full_res)
#' }
batch_result <- function(output_file_id, simplify = TRUE) {

  httr::GET(
    stringr::str_glue(
      "https://api.openai.com/v1/files/{output_file_id}/content"
    ),
    httr::add_headers(
      "Authorization" = paste("Bearer", Sys.getenv("OPENAI_API_KEY"))
    ),
    httr::content_type_json()
  ) |>
    parse_httr_response(convert_json = FALSE) |>
    split_results(simplify = simplify)
}

split_results <- function(response, simplify = TRUE) {
  response |>
    stringr::str_trim() |>
    stringr::str_split("\\n") |>
    purrr::list_c() |>
    purrr::map(\(x) {
      x |>
        jsonlite::fromJSON() |>
        purrr::map(\(x) x %||% NA) |>
        (\(x) if (simplify) purrr::pluck(x, "response", "body") else x)()
    })
}

parse_httr_response <- function(response, convert_json = TRUE) {
  parsed <- response |>
    httr::content(as = "text", encoding = "UTF-8") |>
    jsonlite::fromJSON()

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
      purrr::map(\(x) x %||% NA) |>
      purrr::list_flatten() |>
      tibble::as_tibble()
  } else {
    parsed
  }
}
