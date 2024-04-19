#' Query the GPT model
#'
#' @param prompt (chr) the prompt to use
#' @param model (chr) the model to use
#' @param quiet (lgl) whether to print information
#' @param max_try (int) the maximum number of tries
#' @param temperature (dbl) the temperature to use
#' @param max_tokens (dbl) the maximum number of tokens
#'
#' @return (list) the result of the query
#' @export
#'
#' @examples
#' if (FALSE) {
#'  prompt <- compose_prompt_api(
#'    sys_msg = compose_prompt_system(
#'      role = "Sei l'assistente di un docente universitario.",
#'      context = "
#'        Tu e lui state preparando un workshop sull'utilizzo di ChatGPT
#'        per biostatisitci ed epidemiologi."
#'    ),
#'    usr_msg = compose_prompt_user(
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
  model = c("gpt-3.5-turbo", "gpt-4-turbo"),
  quiet = TRUE,
  max_try = 10,
  temperature = 0,
  max_tokens = 1000
) {
  model <- match.arg(model)
  done <- FALSE
  tries <- 0L
  while (!done && tries <= max_try) {
    tries[[1]] <- tries[[1]] + 1L
    if (tries > 1 && !quiet) {
      usethis::ui_info("Error: {res}.")
      usethis::ui_info("Try: {tries}...")
      Sys.sleep(0.2 * 2^tries)
    }
    res <- tryCatch({
      aux <- prompt |>
        get_completion_from_messages(
          model = model,
          temperature = temperature,
          max_tokens = max_tokens
        )
      done <- TRUE
      aux
    }, error = function(e) e)
  }

  if (tries > max_try) {
    usethis::ui_info("Max unsucessfully tries ({tries}) reached.")
    usethis::ui_stop("Last error: {res}")
  }

  if (!quiet) {
    usethis::ui_info("Tries: {tries}.")
    usethis::ui_info("Prompt token used: {get_tokens(res, 'prompt')}.")
    usethis::ui_info("Response token used: {get_tokens(res, 'completion')}.")
    usethis::ui_info("Total token used: {get_tokens(res)}.")
  }
  res
}



#' Compose the ChatGPT System prompt
#'
#' @param db (data.frame) the data to use
#' @param text_column (chr) the name of the column containing the text
#'   data
#' @param role (chr) the role of the assistant in the context
#' @param context (chr) the context of the assistant in the context
#' @param task (chr) the task to perform
#' @param instructions (chr) the instructions to follow
#' @param output (chr) the output required
#' @param style (chr) the style to use in the output
#' @param examples (chr) some examples of correct output
#' @param model (chr, default = "gpt-3.5-turbo") the model to use
#' @param quiet (lgl, default = TRUE) whether to print information
#' @param max_try (int, default = 10) the maximum number of tries
#' @param temperature (dbl, default = 0) the temperature to use
#' @param max_tokens (dbl, default = 1000) the maximum number of tokens
#' @param include_source_text (lgl, default = TRUE) whether to include
#'   the source text
#' @param simplify (lgl, default = TRUE) whether to simplify the output
#'
#' @return (tibble) the result of the query
#'
#' @importFrom rlang :=
#'
#' @export
#'
#' @examples
#' if (FALSE) {
#'
#'  db <- tibble(
#'    commenti = c(
#'      "Che barba, che noia!",
#'      "Un po' noioso, ma interessante",
#'      "Che bello, mi è piaciuto molto!"
#'    )
#'  )
#'
#'  role <- "Sei l'assistente di un docente universitario."
#'  context <- "State analizzando i commenti degli studenti dell'ultimo corso."
#'  task <- "Il tuo compito è capire se sono soddisfatti del corso."
#'  instructions <- "Analizza i commenti e decidi se sono soddisfatti o meno."
#'  output <- "Riporta 'soddisfatto' o 'insoddisfatto'."
#'  style <- "Non aggiungere nessun commento, restituisci solo ed
#'    esclusivamente la classificazione."
#'  examples <- "
#'  commento_1: 'Mi è piaciuto molto il corso; davvero interessante.'
#'  classificazione_1: 'soddisfatto'
#'  commento_2: 'Non mi è piaciuto per niente; una noia mortale'
#'  classificazione_2: 'insoddisfatto'
#'  "
#'  res <- db |>
#'   query_gpt_on_column(
#'     "commenti",
#'     role = role,
#'     context = context,
#'     task = task,
#'     instructions = instructions,
#'     output = output,
#'     style = style,
#'     examples = examples
#'   )
#'  res
#' }
query_gpt_on_column <- function(
  db,
  text_column,
  role = role,
  context = context,
  task = task,
  instructions = instructions,
  output = output,
  style = style,
  examples = examples,
  model = c("gpt-3.5-turbo", "gpt-4-turbo"),
  quiet = TRUE,
  max_try = 10,
  temperature = 0,
  max_tokens = 1000,
  include_source_text = TRUE,
  simplify = TRUE
) {
  model <- match.arg(model)

  sys_prompt <- compose_prompt_system(
    role = role,
    context = context
  )

  usr_data_prompter <- create_usr_data_prompter(
    task = task,
    instructions = instructions,
    output = output,
    style = style,
    examples = examples
  )

  gpt_answers <- db[[text_column]] |>
    purrr::map(\(txt) {
      usr_prompt <- usr_data_prompter(txt)
      prompt <- compose_prompt_api(sys_prompt, usr_prompt)
      query_gpt(
        prompt = prompt,
        model = model,
        quiet = quiet,
        max_try = max_try,
        temperature = temperature,
        max_tokens = max_tokens
      )
    })

  answers <- if (simplify) {
    purrr::map_chr(gpt_answers, get_content)
  } else {
    gpt_answers
  }

  if (include_source_text) {
    tibble::tibble(
      {{text_column}} := db[[text_column]],
      gpt_res = answers
    )
  } else {
    tibble::tibble(gpt_res = answers)
  }
}
