
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ubep.gpt

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![Codecov test
coverage](https://codecov.io/gh/UBESP-DCTV/ubep.gpt/branch/main/graph/badge.svg)](https://app.codecov.io/gh/UBESP-DCTV/ubep.gpt?branch=main)
[![R-CMD-check](https://github.com/UBESP-DCTV/ubep.gpt/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/UBESP-DCTV/ubep.gpt/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of `{ubep.gpt}` is to provide a basic/simple interface to
OpenAI’s GPT API. The package is designed to work with
dataframes/tibbles and to simplify the process of querying the API.

## Installation

You can install the development version of `{ubep.gpt}` like so:

``` r
remotes::install_github("UBESP-DCTV/ubep.gpt")
```

## Basic example

You can use the `query_gpt` function to query the GPT API. You can
decide if use GPT-3.5-turbo or GPT-4-turbo models. This function is
useful because mainly it iterate the query a decided number of times (10
by default) in case of error (often caused by server overload).

To use the function you need to compose a prompt. You can use the
`compose_prompt_api` function to compose the prompt. This function is
useful because it helps you to compose the prompt automatically adopting
the required API’s structure.

Once you have queried the API, you can extract the content of the
response using the `get_content` function. You can also extract the
tokens of the prompt and the response using the `get_tokens` function.

``` r
library(ubep.gpt)
#> Wellcome to ubep.gpt!
#> The OPENAI_API_KEY environment variable is set
#> You are ready to use the package `ubep.gpt`.
#> Just, double check if the key is the correct one.
#> REMIND: Never share your API key with others.
#>       Keep it safe and secure.
#>       If you think that your API key was compromised,
#>       you can regenerate it in the OpenAI-API website
#>       (https://platform.openai.com/api-keys).
#> Enjoy the package!
prompt <- compose_prompt_api(
  sys_prompt = "You are the assistant of a university professor.",
  usr_prompt = "Tell me about the last course you provided."
)
prompt
#> [[1]]
#> [[1]]$role
#> [1] "system"
#> 
#> [[1]]$content
#> [1] "You are the assistant of a university professor."
#> 
#> 
#> [[2]]
#> [[2]]$role
#> [1] "user"
#> 
#> [[2]]$content
#> [1] "Tell me about the last course you provided."

res <- query_gpt(
  prompt = prompt,
  model = "gpt-3.5-turbo",
  quiet = FALSE, # default TRUE
  max_try = 2, # default 10
  temperature = 1.5, # default 0 [0-2]
  max_tokens = 100 # default 1000
)
#> ℹ Total tries: 1.
#> ℹ Prompt token used: 29.
#> ℹ Response token used: 98.
#> ℹ Total token used: 127.

str(res)
#> List of 7
#>  $ id                : chr "chatcmpl-9JhfrcdjMBau5zKoFylZzto4Vt7MX"
#>  $ object            : chr "chat.completion"
#>  $ created           : int 1714483143
#>  $ model             : chr "gpt-3.5-turbo-0125"
#>  $ choices           :'data.frame':  1 obs. of  5 variables:
#>   ..$ index          : int 0
#>   ..$ logprobs       : logi NA
#>   ..$ finish_reason  : chr "stop"
#>   ..$ message.role   : chr "assistant"
#>   ..$ message.content: chr "The last course my professor provided was an advanced seminar on environmental policy and implementation. The c"| __truncated__
#>  $ usage             :List of 3
#>   ..$ prompt_tokens    : int 29
#>   ..$ completion_tokens: int 98
#>   ..$ total_tokens     : int 127
#>  $ system_fingerprint: chr "fp_3b956da36b"
get_content(res)
#> [1] "The last course my professor provided was an advanced seminar on environmental policy and implementation. The course discussed various approaches to crafting, implementing, and evaluating environmental policies at the local, regional, and global levels. The students delved into case studies of successful and unsuccessful policy initiatives, engaged in critical assessments of current environmental challenges, and developed practical skills in creating policy briefs and analysis documents. Overall, the course aimed to deepen students' understanding of the complexities and nuances involved in environmental policymaking processes."
get_tokens(res)
#> [1] 127
get_tokens(res, "prompt")
#> [1] 29
get_tokens(res, "all")
#>     prompt_tokens completion_tokens      total_tokens 
#>                29                98               127
```

## Easy prompt-assisted creation

You can use the `compose_sys_prompt` and `compose_usr_prompt` functions
to create the system and user prompts, respectively. These functions are
useful because they help you to compose the prompts following best
practices in composing prompt. In fact the arguments are just the main
components every prompt should have. They do just that, composing the
prompt for you juxtaposing the components in the right order.

``` r
sys_prompt <- compose_sys_prompt(
  role = "You are the assistant of a university professor.",
  context = "You are analyzing the comments of the students of the last course."
)
cat(sys_prompt)
#> You are the assistant of a university professor.
#> You are analyzing the comments of the students of the last course.

usr_prompt <- compose_usr_prompt(
  task = "Your task is to extract information from a text provided.",
  instructions = "You should extract the first and last words of the text.",
  output = "Return the first and last words of the text separated by a dash, i.e., `first - last`.",
  style = "Do not add any additional information, return only the requested information.",
  examples = "
    # Examples:
    text: 'This is an example text.'
    output: 'This - text'
    text: 'Another example text!!!'
    output: 'Another - text'",
  text = "Nel mezzo del cammin di nostra vita mi ritrovai per una selva oscura"
)
cat(usr_prompt)
#> Your task is to extract information from a text provided.
#> You should extract the first and last words of the text.
#> Return the first and last words of the text separated by a dash, i.e., `first - last`.
#> Do not add any additional information, return only the requested information.
#> 
#>     # Examples:
#>     text: 'This is an example text.'
#>     output: 'This - text'
#>     text: 'Another example text!!!'
#>     output: 'Another - text'
#> """
#> Nel mezzo del cammin di nostra vita mi ritrovai per una selva oscura
#> """

compose_prompt_api(sys_prompt, usr_prompt) |> 
  query_gpt() |> 
  get_content()
#> [1] "Nel - oscura"
```

## Querying a column of a dataframe

You can use the `query_gpt_on_column` function to query the GPT API on a
column of a dataframe. This function is useful because it helps you to
iterate the query on each row of the column and to compose the prompt
automatically adopting the required API’s structure. In this case, you
need to provide the components of the prompt creating the prompt
template, and the name of the column you what to embed in the template
as a “text” to query. All the prompt’s components are optional, so you
can provide only the ones you need: `role` and `context` compose the
system prompt, while `task`, `instructions`, `output`, `style`, and
`examples` compose the user prompt (they will be just juxtaposed in the
right order)

``` r
db <- data.frame(
  txt = c(
    "I'm very satisfied with the course; it was very interesting and useful.",
    "I didn't like it at all; it was deadly boring.",
    "The best course I've ever attended.",
    "The course was a waste of time.",
    "blah blah blah",
    "woow",
    "bim bum bam"
  )
)

# system
role <- "You are the assistant of a university professor."
context <- "You are analyzing the comments of the students of the last course."

# user
task <- "Your task is to understand if they are satisfied with the course."
instructions <- "Analyze the comments and decide if they are satisfied or not."
output <- "Report 'satisfied' or 'unsatisfied', in case of doubt or impossibility report 'NA'."
style <- "Do not add any comment, return only and exclusively one of the possible classifications."

examples <- "
  # Examples:
  text: 'I'm very satisfied with the course; it was very interesting and useful.'
  output: 'satisfied'
  text: 'I didn't like it at all; it was deadly boring.'
  output: 'unsatisfied'"

sys_prompt <- compose_sys_prompt(role = role, context = context)
usr_prompt <- compose_usr_prompt(
  task = task,
  instructions = instructions,
  output = output,
  style = style,
  examples = examples
)

db |>
 query_gpt_on_column(
   text_column = "txt",  # the name of the column containing the text to
                         # analyze after being embedded in the prompt.
   sys_prompt = sys_prompt,
   usr_prompt = usr_prompt,
   na_if_error = TRUE,  # dafault is FALSE, and in case of error the
                        # the error will be signaled and computation 
                        # stopped.
   .progress = FALSE  # default is TRUE, and progress bar will be shown.
 )
#>                                                                       txt
#> 1 I'm very satisfied with the course; it was very interesting and useful.
#> 2                          I didn't like it at all; it was deadly boring.
#> 3                                     The best course I've ever attended.
#> 4                                         The course was a waste of time.
#> 5                                                          blah blah blah
#> 6                                                                    woow
#> 7                                                             bim bum bam
#>       gpt_res
#> 1   satisfied
#> 2 unsatisfied
#> 3   satisfied
#> 4 unsatisfied
#> 5        <NA>
#> 6        <NA>
#> 7        <NA>
```

## Robust example with for loops and error handling

This example is useful for long computation in which errors from the
server-side can happened (maybe after days of querying). The following
script will save each result one-by one, so that in case of error the
evaluated results won’t be lost.

In case of any error, the error message(s) will be reported as a
warning, but it does not stop the computation. Moreover, re-executing
the loop will evaluate the queries only where they were failed or not
performed yet.

``` r
# This is a function that take a text and attach it at the end of the
# original provided prompt

# install.packages("depigner")
library(depigner) # for progress bar `pb_len()` and `tick()`
#> Welcome to depigner: we are here to un-stress you!
usr_prompter <- create_usr_data_prompter(usr_prompt)

n <- nrow(db)
db[["gpt_res"]] <- NA_character_

pb <- pb_len(n)
for (i in seq_len(n)) {
  if (checkmate::test_scalar_na(db[["gpt_res"]][[i]])) {
    db[["gpt_res"]][[i]] <- query_gpt(
      prompt = compose_prompt_api(
        sys_prompt = sys_prompt,
        usr_prompt = usr_prompter(db[["txt"]][[i]])
      ),
      na_if_error = TRUE
    ) |> 
      get_content()
  }
  tick(pb, paste("Row", i, "of", n))
}
#> 
#> evaluated: Row 7 of 7 [=============================] 100% in  2s [ETA:  0s]

db
#>                                                                       txt
#> 1 I'm very satisfied with the course; it was very interesting and useful.
#> 2                          I didn't like it at all; it was deadly boring.
#> 3                                     The best course I've ever attended.
#> 4                                         The course was a waste of time.
#> 5                                                          blah blah blah
#> 6                                                                    woow
#> 7                                                             bim bum bam
#>       gpt_res
#> 1   satisfied
#> 2 unsatisfied
#> 3   satisfied
#> 4 unsatisfied
#> 5        <NA>
#> 6        <NA>
#> 7        <NA>
```

## Base ChatGPT prompt creation (NOT for API)

You can use the `compose_prompt` function to create a prompt for
ChatGPT. This function is useful because it helps you to compose the
prompt following best practices in composing prompt. In fact the
arguments are just the main components every prompt should have. They do
just that, composing the prompt for you juxtaposing the components in
the right order. The result is suitable to be copy-pasted on ChatGPT,
not to be used with API calls, i.e., it cannot be used with the
`query_gpt` function!!

``` r
prompt <- compose_prompt(
  role = "You are the assistant of a university professor.",
  context = "You are analyzing the comments of the students of the last course.",
  task = "Your task is to extract information from a text provided.",
  instructions = "You should extract the first and last words of the text.",
  output = "Return the first and last words of the text separated by a dash, i.e., `first - last`.",
  style = "Do not add any additional information, return only the requested information.",
  examples = "
    # Examples:
    text: 'This is an example text.'
    output: 'This - text'
    text: 'Another example text!!!'
    output: 'Another - text'",
  text = "Nel mezzo del cammin di nostra vita mi ritrovai per una selva oscura"
)

cat(prompt)
#> You are the assistant of a university professor.
#> You are analyzing the comments of the students of the last course.
#> Your task is to extract information from a text provided.
#> You should extract the first and last words of the text.
#> Return the first and last words of the text separated by a dash, i.e., `first - last`.
#> Do not add any additional information, return only the requested information.
#> 
#>     # Examples:
#>     text: 'This is an example text.'
#>     output: 'This - text'
#>     text: 'Another example text!!!'
#>     output: 'Another - text'
#> """"
#> Nel mezzo del cammin di nostra vita mi ritrovai per una selva oscura
#> """"
```

<figure>
<img src="dev/img/gpt-example.png"
alt="https://chat.openai.com/share/394a008b-d463-42dc-9361-1bd745bcad6d" />
<figcaption aria-hidden="true"><a
href="https://chat.openai.com/share/394a008b-d463-42dc-9361-1bd745bcad6d"
class="uri">https://chat.openai.com/share/394a008b-d463-42dc-9361-1bd745bcad6d</a></figcaption>
</figure>

## Code of Conduct

Please note that the ubep.gpt project is released with a [Contributor
Code of
Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
