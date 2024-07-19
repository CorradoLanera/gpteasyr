#' Get completion from chat messages
#'
#' @param messages (list) in the following format: `⁠list(list("role" =
#'   "user", "content" = "Hey! How old are you?")` (see:
#'   https://platform.openai.com/docs/api-reference/chat/create#chat/create-model)
#' @param model (chr, default = "gpt-4o-mini") a length one character
#'   vector indicating the model to use (see:
#'   <https://platform.openai.com/docs/models/continuous-model-upgrades>)
#' @param temperature (dbl, default = 0) a value between 0 (most
#'   deterministic answer) and 2 (more random). (see:
#'   https://platform.openai.com/docs/api-reference/chat/create#chat/create-temperature)
#' @param max_tokens (dbl, default = 500) a value greater than 0. The
#'   maximum number of tokens to generate in the chat completion. (see:
#'   https://platform.openai.com/docs/api-reference/chat/create#chat/create-max_tokens)
#' @param endpoint (chr, default =
#'   "https://api.openai.com/v1/chat/completions", i.e. the OpenAI API)
#'   the endpoint to use for the request.
#' @param seed (chr, default = NULL) a string to seed the random number
#' @param use_py (lgl, default = FALSE) whether to use python or not
#'
#' @details For argument description, please refer to the [official
#'   documentation](https://platform.openai.com/docs/api-reference/chat/create).
#'
#'   Lower values for temperature result in more consistent outputs,
#'   while higher values generate more diverse and creative results.
#'   Select a temperature value based on the desired trade-off between
#'   coherence and creativity for your specific application. Setting
#'   temperature to 0 will make the outputs mostly deterministic, but a
#'   small amount of variability will remain.
#'
#' @return (list) of two element: `content`, which contains the chr
#'   vector of the response, and `tokens`, which is a list of number of
#'   tokens used for the request (`prompt_tokens`), answer
#'   (`completion_tokens`), and overall (`total_tokens`, the sum of the
#'   other two)
#'
#' @export
#'
#' @examples
#' if (FALSE) {
#'   prompt <- list(
#'     list(
#'       role = "system",
#'       content = "you are an assistant who responds succinctly"
#'     ),
#'     list(
#'       role = "user",
#'       content = "Return the text: 'Hello world'."
#'     )
#'   )
#'   res <- get_completion_from_messages(prompt)
#'   answer <- get_content(res) # "Hello world."
#'   token_used <- get_tokens(res) # 30
#' }
#'
#' if (FALSE) {
#'   msg_sys <- compose_sys_prompt(
#'     role = "Sei l'assistente di un docente universitario.",
#'     context = "
#'       Tu e lui state preparando un workshop sull'utilizzo di ChatGPT
#'       per biostatisitci ed epidemiologi."
#'   )
#'
#'   msg_usr <- compose_usr_prompt(
#'     task = "
#'       Il tuo compito è trovare cosa dire per spiegare cosa sia una
#'       chat di ChatGPT agli studenti, considerando che potrebbe
#'       esserci qualcuno che non ne ha mai sentito parlare (e segue
#'       il worksho incuriosito dal titolo o dagli amici).",
#'     output = "
#'       Riporta un potenziale dialogo tra il docente e gli studenti
#'       che assolva ed esemplifichi lo scopo descritto.",
#'     style = "Usa un tono amichevole, colloquiale, ma preciso."
#'   )
#'
#'   prompt <- compose_prompt_api(msg_sys, msg_usr)
#'   res <- get_completion_from_messages(prompt, "gpt-4-turbo")
#'   answer <- get_content(res)
#'   token_used <- get_tokens(res)
#' }
get_completion_from_messages <- function(
  messages,
  model = "gpt-4o-mini",
  temperature = 0,
  max_tokens = NULL,
  endpoint = "https://api.openai.com/v1/chat/completions",
  seed = NULL,
  use_py = FALSE
) {
  stopifnot(
    `At the moment, python can be used with openai API only` = !use_py ||
      endpoint == "https://api.openai.com/v1/chat/completions"
  )

  seed <- if (is.null(seed)) seed else as.integer(seed)
  max_tokens <- if (is.null(max_tokens)) {
    max_tokens
  } else {
    as.integer(max_tokens)
  }



  if (use_py) {
    openai <- reticulate::import("openai")
    client <- openai$OpenAI()

    client$chat$completions$create(
      messages = messages,
      model = model,
      temperature = temperature,
      max_tokens = max_tokens,
      seed = seed
    )$to_json() |>
      jsonlite::fromJSON() |>
      tryCatch(error = \(e) usethis::ui_stop(e))
  } else {
    response <- httr::POST(
      endpoint,
      httr::add_headers(
        "Authorization" = paste("Bearer", Sys.getenv("OPENAI_API_KEY"))
      ),
      httr::content_type_json(),
      encode = "json",
      body = list(
        model = model,
        messages = messages,
        temperature = temperature,
        max_tokens = max_tokens,
        stream = FALSE, # hard coded for the moment
        seed = seed
      )
    )

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
    parsed
  }
}


#' Get content of a chat completion
#'
#' @param completion the output of a `get_completion_from_messages` call
#' @describeIn get_completion_from_messages
#'
#' @return (chr) the output message returned by the assistant
#' @export
get_content <- function(completion) {
  if (all(is.na(completion))) return(NA_character_)

  if ("message" %in% names(completion[["choices"]])) {
    completion[["choices"]][["message"]][["content"]]
  } else {
    completion[["choices"]][["message.content"]]
  }

}

#' Get the number of token of a chat completion
#'
#' @param completion the number of tokens used for output of a
#'   `get_completion_from_messages` call
#' @param what (chr) one of "total" (default), "prompt", "completion",
#'   or "all"
#' @describeIn get_completion_from_messages
#'
#' @return (int) number of token used in completion for prompt or
#'   completion part, or overall (total)
#' @export
get_tokens <- function(
  completion,
  what = c("total", "prompt", "completion", "all")
) {

  what <- match.arg(what)

  if (all(is.na(completion))) {
    completion <- list()
    completion[["usage"]] <- list(
      total_tokens = NA_integer_,
      prompt_tokens = NA_integer_,
      completion_tokens = NA_integer_
    )
  }
  if (what == "all") {
    completion[["usage"]] |> unlist()
  } else {
    completion[["usage"]][[paste0(what, "_tokens")]]
  }
}
