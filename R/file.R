#' Upload batch file
#'
#' @param jsonl_path (chr) path to a file to upload
#'
#' @return (tibble) information about the uploaded file
#'
#' @details For more information, see
#' - [batch documentation](https://platform.openai.com/docs/api-reference/batch).
#' - [file documentation](https://platform.openai.com/docs/api-reference/files).
#'
#' At the moment, 'gpteasyr' supports file upload for the batch API only.
#'
#' Your input file must be formatted as a
#'  [JSONL file](https://platform.openai.com/docs/api-reference/batch/request-input).
#'
#' The file can contain up to 50,000 requests, can be up to 100 MB in
#' size, and the size of all files uploaded by one organization can be
#' up to 100 GB.
#'
#'
#' @export
#' @family batches
#' @family files
#'
#' @examples
#'  sys_prompt <- compose_sys_prompt("You are a funny assistant.")
#'  usr_prompt <- compose_usr_prompt(
#'    "Tell me a joke ending in:"
#'  )
#'  prompter <- create_usr_data_prompter(usr_prompt = usr_prompt)
#'  text <-  c(
#'    "deadly boring!",
#'    "A bit boring, but interesting",
#'    "How nice, I loved it!"
#'  )
#'
#'  jsonl_text <- text |>
#'    purrr::map(
#'      \(x) {
#'        compose_prompt_api(
#'          sys_prompt = sys_prompt,
#'          usr_prompt = prompter(x)
#'        )
#'      }
#'    ) |>
#'    create_jsonl_records()
#'  out_jsonl_path <- write_jsonl_files(jsonl_text, tempdir())
#'
#' uploaded_file_info <- file_upload(out_jsonl_path)
#' file_delete(uploaded_file_info[["id"]])
file_upload <- function(jsonl_path, purpose = "batch") {
  checkmate::qassert(jsonl_path, "S1")

  if (purpose == "batch") {
    checkmate::assert_file_exists(jsonl_path, extension = "jsonl")
  }

  httr::POST(
    "https://api.openai.com/v1/files",
    httr::add_headers(
      "Authorization" = paste("Bearer", Sys.getenv("OPENAI_API_KEY"))
    ),
    body = list(
      purpose = purpose,
      file = httr::upload_file(jsonl_path)
    )
  ) |>
    parse_httr_response()
}




#' List uploaded file
#'
#' @param purpose (chr) Only return files with the given purpose. Can be
#'   omitted (i.e., NULL), "batch" or "batch_output".
#'
#' @return (tibble) information about the uploaded files
#' @export
#' @family files
#'
#' @examples
#' file_list()
#' file_list("batch")
#' file_list("batch_output")
file_list <- function(purpose = NULL) {
  if (!is.null(purpose)) {
    checkmate::qassert(purpose, "S1")
    purpose %in% c("batch", "batch_output")
  }

  httr::with_config(
    httr::timeout(600),
    httr::GET(
      # "http://httpbin.org/get",
      stringr::str_glue("https://api.openai.com/v1/files"),
      httr::add_headers(
        "Authorization" = paste("Bearer", Sys.getenv("OPENAI_API_KEY"))
      ),
      httr::content_type_json(),
      query = list(purpose = purpose)
    ) |>
      parse_httr_response()
  )[["data"]]
}



#' Retrieve file information
#'
#' @param file_id (chr) The id of the file to retrieve.
#'
#' @return
#' @export
#' @family files
#'
#' @examples
#'  sys_prompt <- compose_sys_prompt("You are a funny assistant.")
#'  usr_prompt <- compose_usr_prompt(
#'    "Tell me a joke ending in:"
#'  )
#'  prompter <- create_usr_data_prompter(usr_prompt = usr_prompt)
#'  text <-  c(
#'    "deadly boring!",
#'    "A bit boring, but interesting",
#'    "How nice, I loved it!"
#'  )
#'
#'  jsonl_text <- text |>
#'    purrr::map(
#'      \(x) {
#'        compose_prompt_api(
#'          sys_prompt = sys_prompt,
#'          usr_prompt = prompter(x)
#'        )
#'      }
#'    ) |>
#'    create_jsonl_records()
#'  out_jsonl_path <- write_jsonl_files(jsonl_text, tempdir())
#'
#' uploaded_file_info <- file_upload(out_jsonl_path)
#' files <- file_list()
#' file_info(files[["id"]][[1]])
#' file_delete(uploaded_file_info[["id"]])
file_info <- function(file_id) {
  httr::GET(
    stringr::str_glue(
      "https://api.openai.com/v1/files/{file_id}"
    ),
    httr::add_headers(
      "Authorization" = paste("Bearer", Sys.getenv("OPENAI_API_KEY"))
    ),
    httr::content_type_json()
  ) |>
    parse_httr_response()

}

#' Delete file
#'
#' @param file_id (chr) The id of the file to delete.
#'
#' @return (tibble) information about the deleted file
#' @export
#' @family files
#'
#' @examples
#'  sys_prompt <- compose_sys_prompt("You are a funny assistant.")
#'  usr_prompt <- compose_usr_prompt(
#'    "Tell me a joke ending in:"
#'  )
#'  prompter <- create_usr_data_prompter(usr_prompt = usr_prompt)
#'  text <-  c(
#'    "deadly boring!",
#'    "A bit boring, but interesting",
#'    "How nice, I loved it!"
#'  )
#'
#'  jsonl_text <- text |>
#'    purrr::map(
#'      \(x) {
#'        compose_prompt_api(
#'          sys_prompt = sys_prompt,
#'          usr_prompt = prompter(x)
#'        )
#'      }
#'    ) |>
#'    create_jsonl_records()
#'  out_jsonl_path <- write_jsonl_files(jsonl_text, tempdir())
#'
#' uploaded_file_info <- file_upload(out_jsonl_path)
#' file_delete(uploaded_file_info[["id"]])
file_delete <- function(file_id) {
  httr::DELETE(
    stringr::str_glue("https://api.openai.com/v1/files/{file_id}"),
    httr::add_headers(
      "Authorization" = paste("Bearer", Sys.getenv("OPENAI_API_KEY"))
    )
  ) |>
    parse_httr_response()
}

#' Retrieve file content
#'
#' @param file_id (chr) The id of the file to retrieve.
#' @param convert_json (lgl) If TRUE, convert the response to JSON.
#'
#' @return (chr) The content of the file.
#' @export
#' @family files
#'
#' @examples
#'  sys_prompt <- compose_sys_prompt("You are a funny assistant.")
#'  usr_prompt <- compose_usr_prompt("Tell me a joke ending in:")
#'  prompter <- create_usr_data_prompter(usr_prompt = usr_prompt)
#'  text <-  c(
#'    "deadly boring!",
#'    "A bit boring, but interesting",
#'    "How nice, I loved it!"
#'  )
#'
#'  jsonl_text <- text |>
#'    purrr::map(
#'      \(x) {
#'        compose_prompt_api(
#'          sys_prompt = sys_prompt,
#'          usr_prompt = prompter(x)
#'        )
#'      }
#'    ) |>
#'    create_jsonl_records()
#'  out_jsonl_path <- write_jsonl_files(jsonl_text, tempdir())
#'
#' uploaded_file_info <- file_upload(out_jsonl_path)
#' file_content <- file_retrieve(uploaded_file_info[["id"]])
#' file_delete(uploaded_file_info[["id"]])
file_retrieve <- function(file_id, convert_json = FALSE) {
  httr::GET(
    stringr::str_glue(
      "https://api.openai.com/v1/files/{file_id}/content"
    ),
    httr::add_headers(
      "Authorization" = paste("Bearer", Sys.getenv("OPENAI_API_KEY"))
    ),
    httr::content_type_json()
  ) |>
    parse_httr_response(convert_json = convert_json)
}
