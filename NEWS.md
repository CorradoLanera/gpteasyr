# gpteasyr 0.3.0

* Changed name and repo to 'CorradoLanera/gpteasyr'.

# gpteasyr 0.2.9

* Added `setup_py` function to setup python backend.
* update `README`

# gpteasyr 0.2.8

* Added `use_py` argument to `gpt_query`, `gpt_query_on_column`, and  `get_completion_from_messages`

# gpteasyr 0.2.7

* Added `closing` argument to `compose_usr_prompt`, `compose_prompt`, and `create_usr_data_prompter` functions, to allow add text at the very end of the prompt, i.e., after the embedded text.

# gpteasyr 0.2.5

* Added seed argument to `gpt_query`, `gpt_query_on_column`, and `get_completion_from_messages` functions.

# gpteasyr 0.2.4

* Now `create_usr_data_prompter` can accept a custom delimiter.
* Default delimiter changed from four quotes (`""""`) to three quotes (`"""`).

# gpteasyr 0.2.3

* `stream = FALSE` hard coded (for the moment) on `get_completion_from_messages`.
* column name for results in `gpt_query_on_columns` is now customizable.
* Now `gpt_query_on_columns` returns the original tibble with the column added
  to it, including an option `add` to return the result as a new tibble
  with a single column only (when `add = FALSE`).
* Add progress bar to `gpt_query_on_column` functions.

# gpteasyr 0.2.2

* hot-fix old calls to `match.arg(model)` in `gpt_query` and `gpt_query_on_column` functions.

# gpteasyr 0.2.1

* Add option to return NA when the API returns an error; this apply on `gpt_query` and `gpt_query_on_column` functions only (i.e., not to the base `get_completion_from_messages` function).

# gpteasyr 0.2.0

* Removed dependency from `{openai}` in favor of `{httr}` and `{jsonlite}` directly
* Now queries can be made to personalized endpoints.
* create_usr_data_prompter now works with empty characters (treated as NULL).
* Now compose_prompt_api correctly manage empty prompts.

# gpteasyr 0.1.1

* 100% coverage passed
* Activated all tests on CI

# gpteasyr 0.1.0

* All functions tested.
* Prompt compositors (i.e., `compose_prompt`, `compose_usr_prompt`, `compose_sys_prompt`, and `create_usr_data_prompter`) now always return a character vector (possibly of length 0).
* `query_gpt_on_column` now accepts `sys_prompt` and `usr_prompt` arguments to customize the user and system prompts. (fix #1)
* Changed functions names to more uniform. I.e., `compose_prompt_user` and `compose_prompt_system` now are called `compose_usr_prompt` and `compose_sys_prompt`; while `usr_msg` and `sys_msg` arguments now are called `usr_prompt` and `sys_prompt`.  (fix #2)
* Added `zzz.R` with startup messages checking for API keys.
* Update README with examples of usage.
* Setup development environment.
* Initial setup from CorradoLanera/gpt-template.
