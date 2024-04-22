#' Compose the ChatGPT System prompt
#'
#' @param db (data.frame) the data to use
#' @param text_column (chr) the name of the column containing the text
#'   data
#' @param sys_prompt (chr) the system prompt to use
#' @param usr_prompt (chr) the user prompt to use
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
#'
#'  sys_prompt <- compose_sys_prompt(role = role, context = context)
#'  usr_prompt <- compose_usr_prompt(
#'    task = task, instructions = instructions, output = output,
#'    style = style, examples = examples
#'  )
#'  res <- db |>
#'   query_gpt_on_column(
#'     "commenti", sys_prompt = sys_prompt, usr_prompt = usr_prompt
#'   )
#'  res
#' }
query_gpt_on_column <- function(
    db,
    text_column,
    sys_prompt = "",
    usr_prompt = "",
    model = c("gpt-3.5-turbo", "gpt-4-turbo"),
    quiet = TRUE,
    max_try = 10,
    temperature = 0,
    max_tokens = 1000,
    include_source_text = TRUE,
    simplify = TRUE
) {
  model <- match.arg(model)

  usr_data_prompter <- create_usr_data_prompter(usr_prompt = usr_prompt)

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
