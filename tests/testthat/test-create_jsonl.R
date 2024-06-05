test_that("create_jsonl works", {
  # setup
  role <- "Sei l'assistente di un docente universitario."
  context <- "State analizzando i commenti degli studenti dell'ultimo corso."
  task <- "Il tuo compito è capire se sono soddisfatti del corso."
  instructions <- "Analizza i commenti e decidi se sono soddisfatti o meno."
  output <- "Riporta 'soddisfatto' o 'insoddisfatto'."
  style <- "Non aggiungere nessun commento, restituisci solo ed
   esclusivamente la classificazione."
  examples <- "
  commento_1: 'Mi è piaciuto molto il corso; davvero interessante.'
  classificazione_1: 'soddisfatto'
  commento_2: 'Non mi è piaciuto per niente; una noia mortale'
  classificazione_2: 'insoddisfatto'
  "

  sys_prompt <- compose_sys_prompt(role = role, context = context)
  usr_prompt <- compose_usr_prompt(
   task = task, instructions = instructions, output = output,
   style = style, examples = examples
  )

  prompter <- create_usr_data_prompter(usr_prompt = usr_prompt)

  db <- tibble::tibble(
    commenti = c(
      "Che barba, che noia!",
      "Un po' noioso, ma interessante",
      "Che bello, mi è piaciuto molto!"
    )
  ) |>
    dplyr::mutate(
      id = dplyr::row_number(),
      prompt = commenti |>
        purrr::map(
          \(x) compose_prompt_api(
            sys_prompt = sys_prompt,
            usr_prompt = prompter(x)
          )
        )
    )

  # eval
  jsonl_on_db <- db |>
    dplyr::mutate(
      jsonl = create_jsonl_records(prompt, id)
    ) |>
    dplyr::pull(jsonl)

  jsonl_json <- jsonl_on_db[[1]] |>
    jsonlite::fromJSON()

  # expectations
  qexpect(jsonl_on_db, "S3")

  jsonl_json |>
    expect_list(
      types = c("character", "list"),
      any.missing = FALSE,
      len = 4
    )
  names(jsonl_json) |>
    expect_names(identical.to = c("custom_id", "method", "url", "body"))
})


test_that("write_jsonl_files", {
  role <- "Sei l'assistente di un docente universitario."
  context <- "State analizzando i commenti degli studenti dell'ultimo corso."
  task <- "Il tuo compito è capire se sono soddisfatti del corso."
  instructions <- "Analizza i commenti e decidi se sono soddisfatti o meno."
  output <- "Riporta 'soddisfatto' o 'insoddisfatto'."
  style <- "Non aggiungere nessun commento, restituisci solo ed
   esclusivamente la classificazione."
  examples <- "
  commento_1: 'Mi è piaciuto molto il corso; davvero interessante.'
  classificazione_1: 'soddisfatto'
  commento_2: 'Non mi è piaciuto per niente; una noia mortale'
  classificazione_2: 'insoddisfatto'
  "

  sys_prompt <- compose_sys_prompt(role = role, context = context)
  usr_prompt <- compose_usr_prompt(
    task = task, instructions = instructions, output = output,
    style = style, examples = examples
  )

  prompter <- create_usr_data_prompter(usr_prompt = usr_prompt)

  jsonl_on_db <- tibble::tibble(
    commenti = c(
      "Che barba, che noia!",
      "Un po' noioso, ma interessante",
      "Che bello, mi è piaciuto molto!"
    )
  ) |>
    dplyr::mutate(
      id = dplyr::row_number(),
      prompt = commenti |>
        purrr::map(
          \(x) compose_prompt_api(
            sys_prompt = sys_prompt,
            usr_prompt = prompter(x)
          )
        ),
      jsonl = create_jsonl_records(prompt, id)
    ) |>
    dplyr::pull(jsonl)

  # eval
  temp_dir <- tempdir()
  write_jsonl_files(jsonl_on_db, temp_dir)


  # expectations
  jsonl_path <- file.path(temp_dir, "batch-input-1.jsonl")
  expect_file_exists(jsonl_path)
  expect_list(
    {
      jsonl_json <- readLines(jsonl_path)[[1]] |>
        jsonlite::fromJSON()
    },
    types = c("character", "list"),
    any.missing = FALSE,
    len = 4
  )
  names(jsonl_json) |>
    expect_names(identical.to = c("custom_id", "method", "url", "body"))
})


test_that("compose_jsonl_record works", {
  # setup
  messages <- compose_prompt_api(
    compose_sys_prompt(
      role = "Sei l'assistente di un docente universitario.",
      context = "State analizzando i commenti degli studenti dell'ultimo corso."
    ),
    compose_usr_prompt(
      task = "Il tuo compito è capire se sono soddisfatti del corso.",
      instructions = "Analizza i commenti e decidi se sono soddisfatti o meno.",
      output = "Riporta 'soddisfatto' o 'insoddisfatto'.",
      style = "Non aggiungere nessun commento, restituisci solo ed
   esclusivamente la classificazione.",
      examples = "
  commento_1: 'Mi è piaciuto molto il corso; davvero interessante.'
  classificazione_1: 'soddisfatto'
  commento_2: 'Non mi è piaciuto per niente; una noia mortale'
  classificazione_2: 'insoddisfatto'
  "
    )
  )

  # eval
  res <- compose_jsonl_record(messages, id = 1, model = "gpt-3.5-turbo")

  # expectation
  expect_list(
    {jsonl_json <- jsonlite::fromJSON(res)},
    types = c("character", "list"),
    any.missing = FALSE,
    len = 4
  )
  names(jsonl_json) |>
    expect_names(identical.to = c("custom_id", "method", "url", "body"))
})
