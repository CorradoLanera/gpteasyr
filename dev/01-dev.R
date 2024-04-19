# packages --------------------------------------------------------
usethis::use_package("glue")
usethis::use_package("openai")
usethis::use_package("usethis")
usethis::use_package("purrr")
usethis::use_package("tibble")
usethis::use_package("rlang")

usethis::use_tidy_description()


# functions -------------------------------------------------------

usethis::use_r("zzz")
usethis::use_r("query_gpt")

# tests -----------------------------------------------------------
usethis::use_test("compose_prompt")
