#' Setup Python environment
#'
#' This function creates a virtual environment and installs the `openai`
#' package in it.
#'
#'
#' @param venv_name (chr, default "r-gpt-venv") The name of the virtual
#'   environment to be created.
#' @param ask (lgl, default `TRUE` if in interactive session, `FALSE
#'   otherwise`) If `TRUE`, the user is asked if they want to create the
#'   virtual environment.
#'
#' @return (lgl) `TRUE` if the virtual environment was created, `FALSE`
#'   otherwise.
#' @export
#'
#' @examples
#' if (FALSE) {
#'   library(ubep.gpt)
#'   setup_py()
#'
#'   prompt <- compose_prompt_api(
#'     sys_prompt = "You are the assistant of a university professor.",
#'     usr_prompt = "Tell me about the last course you provided."
#'   )
#'
#'   res <- query_gpt(
#'       prompt = prompt,
#'       use_py = TRUE
#'     ) |>
#'       get_content()
#'
#'    cat(res)
#' }
setup_py <- function(venv_name = "r-gpt-venv", ask = interactive()) {
  if (
    (!ask) ||
    usethis::ui_yeah(
      "Do you want to setup a ({venv_name}) python environment?"
    )
  ) {
    reticulate::virtualenv_create(venv_name, packages = "openai")
    reticulate::use_virtualenv(venv_name, required = TRUE)
    return(invisible(TRUE))
  }
  invisible(FALSE)
}
