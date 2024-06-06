# packages --------------------------------------------------------
usethis::use_package("stringr")
usethis::use_package("usethis")
usethis::use_package("purrr")
usethis::use_package("tibble")
usethis::use_package("rlang")
usethis::use_package("httr")
usethis::use_package("jsonlite")
usethis::use_package("depigner", type = "Suggests")
usethis::use_package("dplyr", type = "Suggests")

usethis::use_tidy_description()


# functions -------------------------------------------------------

usethis::use_r("zzz")
usethis::use_r("query_gpt")
usethis::use_r("create_jsonl")
usethis::use_r("batch_retrive_status")

# tests -----------------------------------------------------------
usethis::use_test("compose_prompt")
usethis::use_test("create_jsonl")
