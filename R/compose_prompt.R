#' Create a prompt to ChatGPT
#'
#' Questa funzione è un semplice wrapper per comporre un buon prompt per
#' ChatGPT. L'output non è altro che la giustapposizione su righe separate delle
#' varie componenti (con il testo addizionale racchiuso tra i delimitatori in
#' fondo al prompt). Dunque il suo utilizzo è più che altro focalizzato è utile
#' per ricordare e prendere l'abitudine di inserire le componenti utili per un
#' buon prompt.
#'
#' @param role (chr) The role that ChatGPT should play
#' @param context (chr) The context behind the task required
#' @param task (chr) The tasks ChatGPT should assess
#' @param instructions (chr) Description of steps ChatGPT should follow
#' @param output (chr) The type/kind of output required
#' @param style (chr) The style ChatGPT should use in the output
#' @param examples (chr) Some examples of correct output
#' @param text (chr) Additional text to embed in the prompt
#' @param delimiter (chr) delimiters for the `text` to embed, a sequence of
#'   three identical symbols is suggested
#'
#' @return (chr) the glue of all the prompts components
#' @export
#'
#' @examples
#' if (FALSE) {
#'   compose_prompt(
#'     role = "Sei l'assistente di un docente universitario.",
#'     context = "
#'       Tu e lui state preparando un workshop sull'utilizzo di ChatGPT
#'       per biostatisitci ed epidemiologi.",
#'     task = "
#'       Il tuo compito è trovare cosa dire per spiegare cosa sia una
#'       chat di ChatGPT agli studenti, considerando che potrebbe
#'       esserci qualcuno che non ne ha mai sentito parlare (e segue
#'       il worksho incuriosito dal titolo o dagli amici).",
#'     output = "
#'       Riporta un potenziale dialogo tra il docente e gli studenti
#'       che assolva ed esemplifichi lo scopo descritto.",
#'    style = "Usa un tono amichevole, colloquiale, ma preciso."
#'  )
#' }
compose_prompt <- function(
  role = "", context = "", task = "", instructions = "", output = "",
  style = "", examples = "", text = "",
  delimiter = if (text == "") "" else '""""'
) {
  msg_sys <- compose_prompt_system(role, context)
  msg_usr <- compose_prompt_user(
    task, instructions, output, style, examples, text, delimiter
  )
  glue::glue(
    "
    {msg_sys}
    {msg_usr}
    "
  )
}

#' Compose the ChatGPT System prompt
#'
#' @describeIn compose_prompt
#'
#' @return (chr) The complete system prompt
#' @export
#' @examples
#' if (FALSE) {
#'   msg_sys <- compose_prompt_system(
#'     role = "Sei l'assistente di un docente universitario.",
#'     context = "
#'       Tu e lui state preparando un workshop sull'utilizzo di ChatGPT
#'       per biostatisitci ed epidemiologi."
#'  )
#' }
compose_prompt_system <- function(role = "", context = "") {
  glue::glue("
    {role}
    {context}
  ")
}

#' Compose the ChatGPT User prompt
#'
#' @describeIn compose_prompt
#'
#' @return (chr) The complete user prompt
#' @export
#' @examples
#' if (FALSE) {
#'   msg_usr <- compose_prompt_user(
#'     task = "
#'       Il tuo compito è trovare cosa dire per spiegare cosa sia una
#'       chat di ChatGPT agli studenti, considerando che potrebbe
#'       esserci qualcuno che non ne ha mai sentito parlare (e segue
#'       il worksho incuriosito dal titolo o dagli amici).",
#'     output = "
#'       Riporta un potenziale dialogo tra il docente e gli studenti
#'       che assolva ed esemplifichi lo scopo descritto.",
#'    style = "Usa un tono amichevole, colloquiale, ma preciso."
#'  )
#' }
compose_prompt_user <- function(
  task = "", instructions = "", output = "", style = "", examples = "",
  text = "", delimiter = if (text == "") "" else '""""'
) {
  glue::glue("
    {task}
    {instructions}
    {output}
    {style}
    {examples}

    {delimiter}
    {text}
    {delimiter}
  ")
}


create_usr_data_prompter <- function(
  task = "", instructions = "", output = "", style = "", examples = ""
) {
  function(text) {
    compose_prompt_user(
      task = task, instructions = instructions, output = output,
      style = style, examples = examples, text = text
    )
  }
}
