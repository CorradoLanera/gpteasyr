#' Get completion from chat messages
#'
#' @param messages (list) in the following format: `⁠list(list("role" =
#'   "user", "content" = "Hey! How old are you?")` (see:
#'   https://platform.openai.com/docs/api-reference/chat/create#chat/create-model)
#' @param model (chr, default = "gpt-3.5-turbo") a length one character
#'   vector indicating the model to use (see:
#'   <https://platform.openai.com/docs/models/continuous-model-upgrades>)
#' @param temperature (dbl, default = 0) a value between 0 (most
#'   deterministic answer) and 2 (more random). (see:
#'   https://platform.openai.com/docs/api-reference/chat/create#chat/create-temperature)
#' @param max_tokens (dbl, default = 500) a value greater than 0. The
#'   maximum number of tokens to generate in the chat completion. (see:
#'   https://platform.openai.com/docs/api-reference/chat/create#chat/create-max_tokens)
#' @param quiet (lgl, default = FALSE) whether to suppress messages
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
#'   msg_sys <- compose_prompt_system(
#'     role = "Sei l'assistente di un docente universitario.",
#'     context = "
#'       Tu e lui state preparando un workshop sull'utilizzo di ChatGPT
#'       per biostatisitci ed epidemiologi.",
#'   )
#'
#'   msg_usr <- compose_prompt_user(
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
#'   res <- get_completion_from_messages(prompt, "4-turbo")
#'   answer <- get_content(res)
#'   token_used <- get_tokens(res) # 957
#' }
get_completion_from_messages <- function(
  messages,
  model = c("gpt-3.5-turbo", "gpt-4-turbo"),
  temperature = 0,
  max_tokens = 1000,
  quiet = FALSE
) {

  model <- match.arg(model)
  model <- switch(model,
    "gpt-3.5-turbo" = "gpt-3.5-turbo",
    "gpt-4-turbo" = "gpt-4-1106-preview"
  )

  get_chat_completion <- if (quiet) {
    \(...) openai::create_chat_completion(...) |>
      suppressMessages()
  } else {
    openai::create_chat_completion
  }

  res <- get_chat_completion(
    model = model,
    messages = messages,
    temperature = temperature,
    max_tokens = max_tokens,
  )

  list(
    content = res[["choices"]][["message.content"]],
    tokens = res[["usage"]]
  )
}


#' Get content of a chat completion
#'
#' @param completion the output of a `get_completion_from_messages` call
#' @describeIn get_completion_from_messages
#'
#' @return (chr) the output message returned by the assistant
#' @export
get_content <- function(completion) {
  completion[["content"]]
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

  if (what == "all") {
    completion[["tokens"]] |> unlist()
  } else {
    completion[["tokens"]][[paste0(what, "_tokens")]]
  }
}