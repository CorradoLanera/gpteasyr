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
  role = NULL, context = NULL, task = NULL, instructions = NULL,
  output = NULL, style = NULL, examples = NULL, text = NULL,
  delimiter = if (is.null(text)) NULL else '""""'
) {
  all_sys_null <- list(role, context) |>
    purrr::map_lgl(is.null) |>
    all()
  all_usr_null <- list(
    task, instructions, output, style, examples, text, delimiter
  ) |>
    purrr::map_lgl(is.null) |>
    all()

  msg_sys <- if (all_sys_null) {
    NULL
  } else {
    compose_sys_prompt(role, context)
  }
  msg_usr <- if (all_usr_null) {
    NULL
  } else {
    compose_usr_prompt(
      task, instructions, output, style, examples, text, delimiter
    )
  }
  stringr::str_c(msg_sys, msg_usr, sep = "\n")
}

#' Compose the ChatGPT System prompt
#'
#' @describeIn compose_prompt
#'
#' @return (chr) The complete system prompt
#' @export
#' @examples
#' if (FALSE) {
#'   msg_sys <- compose_sys_prompt(
#'     role = "Sei l'assistente di un docente universitario.",
#'     context = "
#'       Tu e lui state preparando un workshop sull'utilizzo di ChatGPT
#'       per biostatisitci ed epidemiologi."
#'  )
#' }
compose_sys_prompt <- function(
  role =  NULL,
  context = NULL
) {
  stringr::str_c(role, context, sep = "\n")
}

#' Compose the ChatGPT User prompt
#'
#' @describeIn compose_prompt
#'
#' @return (chr) The complete user prompt
#' @export
#' @examples
#'   msg_usr <- compose_usr_prompt(
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
compose_usr_prompt <- function(
  task = NULL, instructions = NULL, output = NULL, style = NULL,
  examples = NULL, text = NULL,
  delimiter = if (is.null(text)) NULL else '"""'
) {
  stringr::str_c(
    task,
    instructions,
    output,
    style,
    examples,
    delimiter,
    text,
    delimiter,
    sep = "\n"
  )

}


#' Create a function to prompt the user for data
#'
#' This function create a function that can be used to prompt the user
#' for data in a specific context. Given the interested context, the
#' function created will accept a string of text as input and return the
#' complete prompt based on the desired context.
#'
#' @param usr_prompt (chr) The user prompt to use as a template to which
#'   the text will be added.
#' @param delimiter (chr) delimiters for the `text` to embed, a sequence
#'   of four identical symbols is suggested.
#'
#' @return (function) a function that can be used to prompt the user,
#'   accepting a string of text as input and returning the complete
#'   prompt based on the desired context.
#'
#' @export
#'
#' @examples
#' usr_prmpt <- compose_prompt(
#'   role = "You are the assistant of a university professor.",
#'   context = "
#'     You are analyzing the comments of the students of the last course.",
#'   task = "Your task is to extract information from a text provided.",
#'   instructions = "
#'     You should extract the first and last words of the text.",
#'   output = "
#'     Return the first and last words of the text separated by a dash,
#'     i.e., `first - last`.",
#'   style = "
#'     Do not add any additional information,
#'     return only the requested information.",
#'   examples = "
#'       # Examples:
#'       text: 'This is an example text.'
#'       output: 'This - text'
#'       text: 'Another example text!!!'
#'       output: 'Another - text'"
#'   )
#' prompter <- create_usr_data_prompter(
#'   usr_prompt = usr_prmpt
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
    usr_prompt = NULL, delimiter = NULL
) {
  if (length(usr_prompt) == 0) {
    usr_prompt <- NULL
  }

  delimiter <- delimiter %||% '"""'
  function(text = NULL) {
    compose_usr_prompt(
      task = usr_prompt,
      text = text,
      delimiter = if (is.null(text)) NULL else delimiter
      )
  }
}
