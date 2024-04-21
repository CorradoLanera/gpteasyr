#' Create a prompt to ChatGPT
#'
#' This function is a simple wrapper to compose a good prompt for
#' ChatGPT. The output is nothing more than the juxtaposition on
#' separate lines of the various components (with the additional text
#' enclosed between the delimiters at the bottom of the prompt). So its
#' use is more focused and useful for remembering and getting used to
#' entering the components useful for a good prompt.
#'
#' @param role (chr) The role that ChatGPT should play
#' @param context (chr) The context behind the task required
#' @param task (chr) The tasks ChatGPT should assess
#' @param instructions (chr) Description of steps ChatGPT should follow
#' @param output (chr) The type/kind of output required
#' @param style (chr) The style ChatGPT should use in the output
#' @param examples (chr) Some examples of correct output
#' @param text (chr) Additional text to embed in the prompt
#' @param delimiter (chr) delimiters for the `text` to embed, a sequence
#'   of three identical symbols is suggested
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


#' Create a function to prompt the user for data
#'
#' This function create a function that can be used to prompt the user
#' for data in a specific context. Given the interested context, the
#' function created will accept a string of text as input and return the
#' complete prompt based on the desired context.
#'
#' @param task (chr) The task ChatGPT should assess
#' @param instructions (chr) Description of steps ChatGPT should follow
#' @param output (chr) The type/kind of output required
#' @param style (chr) The style ChatGPT should use in the output
#' @param examples (chr) Some examples of correct output
#'
#' @return (function) a function that can be used to prompt the user,
#'   accepting a string of text as input and returning the complete
#'   prompt based on the desired context.
#'
#' @export
#'
#' @examples
#' prompter <- create_usr_data_prompter(
#'   task = "Your task is to extract information from a text provided.",
#'   instructions = "
#'     You should extract the first and last words of the text.",
#'   output = "
#'     Return the first and last words of the text separated by a dash,
#'      i.e., `first - last`.",
#'   style = "
#'     Do not add any additional information, return only the requested
#'     information.",
#'   examples = "
#'     text: 'This is an example text.'
#'     output: 'This - text'
#'     text: 'Another example text!!!'
#'     output: 'Another - text'"
#' )
#' prompter("This is an example text.")
#' prompter("Another example text!!!")
#'
#' # You can also use it with a data frame to programmaically create
#' # prompts for each row of a data frame's column.
#' db <- data.frame(
#'   text = c("This is an example text.", "Another example text!!!")
#' )
#' db$text |> purrr::map_chr(prompter)
#'
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
