.onAttach <- function(...) {
  usethis::ui_info("Wellcome to ubep.gpt!")

  if (Sys.getenv("OPENAI_API_sKEY") == "") {
    usethis::ui_info("OPENAI_API_KEY environment variable is not set.")
    usethis::ui_info(
      "it is required to use OpenAI APIs with `ubep.gpt`.")
    usethis::ui_info(
      "To set the OPENAI_API_KEY environment variable,
      you can call {usethis::ui_code('usethis::edit_r_environ(\"project\")')},
      and add the line {usethis::ui_code('OPENAI_API_KEY=<your_api_key>')}."
    )
    usethis::ui_info(
      "REMIND:
      Never share your API key with others.
      Keep it safe and secure.
      If you need an API key, you can generate it in the OpenAI-API website
      (https://platform.openai.com/api-keys).
      Remind to assign it to the correct project
      (i.e., NOT to the 'default' one).
      If you need to be added to the organization and/or to a project,
      please, contact your project's referent."
    )

    usethis::ui_todo(
      "Please, set the OPENAI_API_KEY environment variable with your OpenAI API key."
    )
    usethis::ui_todo("And than, restart your R session.")
  } else {
    usethis::ui_info("The OPENAI_API_KEY environment variable is set")
    usethis::ui_info("You are ready to use the package `ubep.gpt`.")
    usethis::ui_todo("Just, double check if the key is the correct one.")
    usethis::ui_info(
      "REMIND: Never share your API key with others.
      Keep it safe and secure.
      If you think that your API key was compromised,
      you can regenerate it in the OpenAI-API website
      (https://platform.openai.com/api-keys)."
    )
    usethis::ui_done("Enjoy the package!")
  }
}
