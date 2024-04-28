## CTRL + SHIFT + D: update project documentation
spelling::spell_check_package()
## spelling::update_wordlist()

devtools::build_readme()


lintr::lint_package()

## CTRL + SHIFT + T: run all project's tests
## CTRL + SHIFT + E: run all CRAN tests
covr::package_coverage()
covr::codecov()

usethis::use_version()
