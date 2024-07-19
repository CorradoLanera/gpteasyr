.onAttach <- function(...) {
  packageStartupMessage("Wellcome to `{gpteasyr}`!")

  if (Sys.getenv("OPENAI_API_KEY") == "") {
    packageStartupMessage(
      "OPENAI_API_KEY environment variable is not set.\n"
    )
    packageStartupMessage(
      "it is required to use OpenAI APIs with `{gpteasyr}`.\n"
    )
    packageStartupMessage(
      "To set the OPENAI_API_KEY environment variable,
      you can call {usethis::ui_code('usethis::edit_r_environ(\"project\")')},
      and add the line {usethis::ui_code('OPENAI_API_KEY=<your_api_key>')}.\n\n"
    )
    packageStartupMessage(
      "REMIND:
      Never share your API key with others.
      Keep it safe and secure.
      If you need an API key, you can generate it in the OpenAI-API website
      (https://platform.openai.com/api-keys), or contact your 'GPT's admin'.
      Remind to generate it within the correct (your) project!
      (I.e., usually, NOT to the 'default' one.)
      If you need to be added to the organization and/or to a project,
      please, contact your GPT's admin.\n\n"
    )

    packageStartupMessage(
      "Please, set the OPENAI_API_KEY environment variable with your key.\n"
    )
    packageStartupMessage("And than, restart your R session.\n")
  } else {
    packageStartupMessage(
      "The OPENAI_API_KEY environment variable is set\n"
    )
    packageStartupMessage(
      "You are ready to use the package `{gpteasyr}`.\n"
    )
    packageStartupMessage(
      "Just, double check if the key is the correct one.\n\n"
    )
    packageStartupMessage(
      "REMIND: Never share your API key with others.
      Keep it safe and secure.
      If you think that your API key was compromised,
      you can regenerate it in the OpenAI-API website
      (https://platform.openai.com/api-keys), or contacting your GPT's admin.
      \n"
    )
    packageStartupMessage("Enjoy GPT with `{gpteasyr}`!\n")
  }
}
