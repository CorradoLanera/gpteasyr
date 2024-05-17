.onAttach <- function(...) {
  packageStartupMessage("Wellcome to ubep.gpt!")

  if (Sys.getenv("OPENAI_API_KEY") == "") {
    packageStartupMessage(
      "OPENAI_API_KEY environment variable is not set.\n"
    )
    packageStartupMessage(
      "it is required to use OpenAI APIs with `ubep.gpt`.\n"
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
      (https://platform.openai.com/api-keys).
      Remind to assign it to the correct project
      (i.e., NOT to the 'default' one).
      If you need to be added to the organization and/or to a project,
      please, contact your project's referent.\n\n"
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
      "You are ready to use the package `ubep.gpt`.\n"
    )
    packageStartupMessage(
      "Just, double check if the key is the correct one.\n\n"
    )
    packageStartupMessage(
      "REMIND: Never share your API key with others.
      Keep it safe and secure.
      If you think that your API key was compromised,
      you can regenerate it in the OpenAI-API website
      (https://platform.openai.com/api-keys).\n\n"
    )
    packageStartupMessage("Enjoy the package!\n")
  }
  packageStartupMessage(
    "If you like to use the python backend (working only for GPT's OpenAI requests!),\n",
    "setup the environmen first by executing:\n",
    usethis::ui_code("setup_py()"), "(default virtual environment name is 'r-gpt-venv').\n",
    "If you need to change the default name, run:\n",
    usethis::ui_code("setup_py(\"<your_custom_environment_name>\")")
  )

}
