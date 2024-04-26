# ubep.gpt (development version)

* create_usr_data_prompter now works with empty characters (treated as NULL).
* Now compose_prompt_api correctly manage empty prompts.

# ubep.gpt 0.1.1

* 100% coverage passed
* Activated all tests on CI

# ubep.gpt 0.1.0

* All functions tested.
* Prompt compositors (i.e., `compose_prompt`, `compose_usr_prompt`, `compose_sys_prompt`, and `create_usr_data_prompter`) now always return a character vector (possibly of length 0).
* `query_gpt_on_column` now accepts `sys_prompt` and `usr_prompt` arguments to customize the user and system prompts. (fix #1)
* Changed functions names to more uniform. I.e., `compose_prompt_user` and `compose_prompt_system` now are called `compose_usr_prompt` and `compose_sys_prompt`; while `usr_msg` and `sys_msg` arguments now are called `usr_prompt` and `sys_prompt`.  (fix #2)
* Added `zzz.R` with startup messages checking for API keys.
* Update README with examples of usage.
* Setup development environment.
* Initial setup from CorradoLanera/gpt-template.
