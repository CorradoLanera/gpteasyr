# ubep.gpt (development version)

* Changed functions names to more uniform. I.e., `compose_prompt_user` and `compose_prompt_system` now are called `compose_usr_prompt` and `compose_sys_prompt`; while `usr_msg` and `sys_msg` arguments now are called `usr_prompt` and `sys_prompt`.  (fix #2)
* Added zzz.R with startup messages checking for API keys.
* Update README with examples of usage.
* Setup development environment.
* Initial setup from CorradoLanera/gpt-template.
