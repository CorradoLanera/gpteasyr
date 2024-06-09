#' Create jsonl records
#'
#' This function creates a jsonl file from a tibble.
#'
#' @param prompt (list) The messages to be included in the jsonl record.
#' @param id (int) The id of the record.
#' @param model (chr, default = "gpt-3.5-turbo") The model to be used.
#' @param prefix (chr, default = "request-") The prefix of the custom id.
#' @param temperature (dbl) the temperature to use
#' @param max_tokens (dbl) the maximum number of tokens
#' @param seed (dbl) the seed to use
#'
#' @return (chr) The jsonl records.
#' @export
#'
#' @examples
#'   library(dplyr)
#'   library(purrr)
#'   library(stringr)
#'   library(gpteasyr)
#'
#'   db <- tibble(
#'     commenti = c(
#'       "Che barba, che noia!",
#'       "Un po' noioso, ma interessante",
#'       "Che bello, mi è piaciuto molto!"
#'     )
#'   )
#'
#'   role <- "Sei l'assistente di un docente universitario."
#'   context <- "State analizzando i commenti degli studenti dell'ultimo corso."
#'   task <- "Il tuo compito è capire se sono soddisfatti del corso."
#'   instructions <- "Analizza i commenti e decidi se sono soddisfatti o meno."
#'   output <- "Riporta 'soddisfatto' o 'insoddisfatto'."
#'   style <- "Non aggiungere nessun commento, restituisci solo ed
#'     esclusivamente la classificazione."
#'   examples <- "
#'   commento_1: 'Mi è piaciuto molto il corso; davvero interessante.'
#'   classificazione_1: 'soddisfatto'
#'   commento_2: 'Non mi è piaciuto per niente; una noia mortale'
#'   classificazione_2: 'insoddisfatto'
#'   "
#'
#'   sys_prompt <- compose_sys_prompt(role = role, context = context)
#'   usr_prompt <- compose_usr_prompt(
#'     task = task, instructions = instructions, output = output,
#'     style = style, examples = examples
#'   )
#'
#'   prompter <- create_usr_data_prompter(usr_prompt = usr_prompt)
#'
#'   res <- db |>
#'     mutate(
#'       id = row_number(),
#'       prompt = commenti |>
#'       map(
#'         \(x) compose_prompt_api(
#'           sys_prompt = sys_prompt,
#'           usr_prompt = prompter(x)
#'         )
#'       )
#'     )
#'
#'   jsonl_direct <- create_jsonl_records(res[["prompt"]], res[["id"]]) |>
#'     str_c(collapse = "\n")
#'
#'   jsonl_on_db <- res |>
#'     mutate(
#'       jsonl = create_jsonl_records(prompt, id)
#'     ) |>
#'     pull(jsonl) |>
#'     str_c(collapse = "\n")
#'
#'   identical(jsonl_on_db, jsonl_direct)
create_jsonl_records <- function(
  prompt,
  id = seq_along(prompt),
  model = "gpt-3.5-turbo",
  temperature = 0,
  max_tokens = NULL,
  seed = NULL,
  prefix = "request-"
) {
  checkmate::qassert(model, "S1")
  checkmate::qassert(prefix, "S1")
  stopifnot(
    `id and messages must have same lenght` =
      length(id) == length(prompt)
  )

  purrr::pmap_chr(
    list(prompt, id),
    \(x, y) {
      compose_jsonl_record(
        x,
        y,
        model = model,
        temperature = temperature,
        max_tokens = max_tokens,
        seed = seed,
        prefix = prefix
      )
    }
  )
}

compose_jsonl_record <- function(
  prompt,
  id,
  model,
  temperature = 0,
  max_tokens = NULL,
  seed = NULL,
  prefix = "request-"
) {
  body <- list(
    messages = prompt |>
      purrr::map(\(x) purrr::map(x, jsonlite::unbox)),
    model = jsonlite::unbox(model),
    temperature = jsonlite::unbox(temperature),
    max_tokens = jsonlite::unbox(max_tokens),
    seed = jsonlite::unbox(seed)
  )

  if (is.null(max_tokens)) {
    body[["max_tokens"]] <- NULL
  }

  if (is.null(seed)) {
    body[["seed"]] <- NULL
  }

  list(
    custom_id = stringr::str_c(prefix, id) |>
      jsonlite::unbox(),
    method = jsonlite::unbox("POST"),
    url = jsonlite::unbox("/v1/chat/completions"),
    body = body
  ) |>
    jsonlite::toJSON()
}


#' Write jsonl files
#'
#' This function writes jsonl files from a list of jsonl records.
#'
#' @param jsonl_records (list) A list of jsonl records.
#' @param dir_path (chr) The directory path where to write the jsonl files.
#' @param name_prefix (chr, default = "batch-input") The prefix of the jsonl files.
#' @param max_mb (numeric, default = 100) The maximum size of the jsonl files in MB.
#'
#' @return (invisible) The jsonl records.
#' @export
#'
#' @examples
#'   role <- "Sei l'assistente di un docente universitario."
#'   context <- "State analizzando i commenti degli studenti dell'ultimo corso."
#'   task <- "Il tuo compito è capire se sono soddisfatti del corso."
#'   instructions <- "Analizza i commenti e decidi se sono soddisfatti o meno."
#'   output <- "Riporta 'soddisfatto' o 'insoddisfatto'."
#'   style <- "Non aggiungere nessun commento, restituisci solo ed
#'      esclusivamente la classificazione."
#'   examples <- "
#'     commento_1: 'Mi è piaciuto molto il corso; davvero interessante.'
#'     classificazione_1: 'soddisfatto'
#'     commento_2: 'Non mi è piaciuto per niente; una noia mortale'
#'     classificazione_2: 'insoddisfatto'
#'     "
#'
#'   sys_prompt <- compose_sys_prompt(role = role, context = context)
#'   usr_prompt <- compose_usr_prompt(
#'     task = task, instructions = instructions, output = output,
#'     style = style, examples = examples
#'   )
#'
#'   prompter <- create_usr_data_prompter(usr_prompt = usr_prompt)
#'
#'   jsonl_on_db <- tibble::tibble(
#'     commenti = c(
#'       "Che barba, che noia!",
#'       "Un po' noioso, ma interessante",
#'       "Che bello, mi è piaciuto molto!"
#'     )
#'   ) |>
#'     dplyr::mutate(
#'       id = dplyr::row_number(),
#'       prompt = commenti |>
#'         purrr::map(
#'           \(x) compose_prompt_api(
#'             sys_prompt = sys_prompt,
#'             usr_prompt = prompter(x)
#'           )
#'         ),
#'       jsonl = create_jsonl_records(prompt, id)
#'     ) |>
#'     dplyr::pull(jsonl)
#'
#'   # eval
#'   temp_dir <- tempdir()
#'   write_jsonl_files(jsonl_on_db, temp_dir)
write_jsonl_files <- function(
  jsonl_records,
  dir_path,
  name_prefix = stringr::str_c(
    stringr::str_remove_all(Sys.time(), "\\D"),
    "_batch-input"
  ),
  max_mb = 100
) {
  checkmate::qassert(jsonl_records, "S+")
  checkmate::test_directory(dir_path, "rw")
  checkmate::qassert(name_prefix, "S1")
  checkmate::qassert(max_mb, "X1(0,)")

  max_size <- max_mb * 1e6


  sizes <- jsonl_records |> purrr::map_int(nchar)
  stopifnot(all(sizes < max_size))

  # use list to avoid copies on overwrites
  current <- list(jsonl_records)
  id <- 1L
  out_paths <- character()

  while (length(current[[1]]) > 0) {
    cum_sizes <- current[[1]] |>
      purrr::map_int(nchar) |>
      cumsum()
    last_to_take <- sum(cum_sizes < max_size) |> # max size/batch
      min(5e4) # max query/batch
    out_paths[id] <- file.path(
      dir_path,
      stringr::str_c(name_prefix, "-", id, ".jsonl")
    )
    current[[1]][seq_len(last_to_take)] |>
      stringr::str_c(collapse = "\n") |>
      writeLines(out_paths[[id]])
    current[[1]] <- current[[1]][-seq_len(last_to_take)]
    id <- id + 1L
  }

  invisible(out_paths)
}
