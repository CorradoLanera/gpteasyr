#' Query the GPT model
#'
#' @param prompt (chr) the prompt to use
#' @param model (chr) the model to use
#' @param quiet (lgl) whether to print information
#' @param max_try (int) the maximum number of tries
#' @param temperature (dbl) the temperature to use
#' @param max_tokens (dbl) the maximum number of tokens
#' @param endpoint (chr, default =
#'   "https://api.openai.com/v1/chat/completions", i.e. the OpenAI API)
#'   the endpoint to use for the request.
#' @param na_if_error (lgl) whether to return NA if an error occurs
#'
#' @return (list) the result of the query
#' @export
#'
#' @examples
#' if (FALSE) {
#'  prompt <- compose_prompt_api(
#'    sys_prompt = compose_sys_prompt(
#'      role = "Sei l'assistente di un docente universitario.",
#'      context = "
#'        Tu e lui state preparando un workshop sull'utilizzo di ChatGPT
#'        per biostatisitci ed epidemiologi."
#'    ),
#'    usr_prompt = compose_usr_prompt(
#'      task = "
#'        Il tuo compito è trovare cosa dire per spiegare cosa sia una
#'        chat di ChatGPT agli studenti, considerando che potrebbe
#'        esserci qualcuno che non ne ha mai sentito parlare (e segue
#'        il worksho incuriosito dal titolo o dagli amici).",
#'      output = "
#'        Riporta un potenziale dialogo tra il docente e gli studenti
#'        che assolva ed esemplifichi lo scopo descritto.",
#'      style = "Usa un tono amichevole, colloquiale, ma preciso."
#'    )
#'  )
#'  res <- query_gpt(prompt)
#'  get_content(res)
#'  get_tokens(res)
#' }
query_gpt <- function(
  prompt,
  model = "gpt-3.5-turbo",
  temperature = 0,
  max_tokens = NULL,
  endpoint = "https://api.openai.com/v1/chat/completions",
  max_try = 10,
  quiet = TRUE,
  na_if_error = FALSE
) {
  model <- match.arg(model)
  done <- FALSE
  tries <- 0L
  while (!done && tries < max_try) {
    tries[[1]] <- tries[[1]] + 1L
    if (tries > 1 && !quiet) {
      usethis::ui_info("{res}.")
      usethis::ui_info("Try: {tries}...")
      Sys.sleep(0.2 * 2^tries)
    }
    res <- tryCatch({
      aux <- prompt |>
        get_completion_from_messages(
          model = model,
          temperature = temperature,
          max_tokens = max_tokens,
          endpoint = endpoint
        )
      done <- TRUE
      aux
    }, error = function(e) e)
  }

  if (tries == max_try && !done) {
    signal <- if (na_if_error) {
      usethis::ui_warn
    } else {
      usethis::ui_stop
    }
    usethis::ui_info("Max unsucessfully tries ({tries}) reached.")
    signal("Last {res}")
    return(NA)
  }

  if (!quiet) {
    usethis::ui_info("Total tries: {tries}.")
    usethis::ui_info("Prompt token used: {get_tokens(res, 'prompt')}.")
    usethis::ui_info("Response token used: {get_tokens(res, 'completion')}.")
    usethis::ui_info("Total token used: {get_tokens(res)}.")
  }
  res
}
