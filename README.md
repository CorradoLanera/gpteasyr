
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ubep.gpt

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![Codecov test
coverage](https://codecov.io/gh/UBESP-DCTV/ubep.gpt/branch/main/graph/badge.svg)](https://app.codecov.io/gh/UBESP-DCTV/ubep.gpt?branch=main)
[![R-CMD-check](https://github.com/UBESP-DCTV/ubep.gpt/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/UBESP-DCTV/ubep.gpt/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of `{ubep.gpt}` is to provide a simple interface to OpenAI’s
GPT API. The package is designed to work with dataframes/tibbles and to
simplify the process of querying the API.

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
#> • POST the query
#> ✔ POST the query
#> • Parse the response
#> ✔ Parse the response
#> • Check whether request failed and return parsed
#> ✔ Check whether request failed and return parsed
#> ℹ Tries: 1.
#> ℹ Prompt token used: 29.
#> ℹ Response token used: 100.
#> ℹ Total token used: 129.

str(res)
#> List of 2
#>  $ content: chr "Our last course focused on the topic of Digital Marketing in the Age of Social Media. It covered various aspect"| __truncated__
#>  $ tokens :List of 3
#>   ..$ prompt_tokens    : int 29
#>   ..$ completion_tokens: int 100
#>   ..$ total_tokens     : int 129
get_content(res)
#> [1] "Our last course focused on the topic of Digital Marketing in the Age of Social Media. It covered various aspects of online marketing such as social media strategies, content creation, paid advertising, email marketing, and search engine optimization. The course combined theoretical knowledge with hands-on practical experience such as creating social media campaigns and analyzing digital marketing analytics data. Students also had the opportunity to work on a real-world project for a local business, implementing the skills they learned throughout the course. Overall, it was a well-re"
get_tokens(res)
#> [1] 129
get_tokens(res, "prompt")
#> [1] 29
get_tokens(res, "all")
#>     prompt_tokens completion_tokens      total_tokens 
#>                29               100               129
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
sys_prompt
#> [1] "You are the assistant of a university professor.\nYou are analyzing the comments of the students of the last course."

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
usr_prompt
#> [1] "Your task is to extract information from a text provided.\nYou should extract the first and last words of the text.\nReturn the first and last words of the text separated by a dash, i.e., `first - last`.\nDo not add any additional information, return only the requested information.\n\n    # Examples:\n    text: 'This is an example text.'\n    output: 'This - text'\n    text: 'Another example text!!!'\n    output: 'Another - text'\n\"\"\"\"\nNel mezzo del cammin di nostra vita mi ritrovai per una selva oscura\n\"\"\"\""

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
   "txt",
   sys_prompt = sys_prompt,
   usr_prompt = usr_prompt,
 )
#> # A tibble: 7 × 2
#>   txt                                                                    gpt_res
#>   <chr>                                                                  <chr>  
#> 1 I'm very satisfied with the course; it was very interesting and usefu… satisf…
#> 2 I didn't like it at all; it was deadly boring.                         unsati…
#> 3 The best course I've ever attended.                                    satisf…
#> 4 The course was a waste of time.                                        unsati…
#> 5 blah blah blah                                                         <NA>   
#> 6 woow                                                                   <NA>   
#> 7 bim bum bam                                                            <NA>
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
compose_prompt(
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
#> [1] "You are the assistant of a university professor.\nYou are analyzing the comments of the students of the last course.\nYour task is to extract information from a text provided.\nYou should extract the first and last words of the text.\nReturn the first and last words of the text separated by a dash, i.e., `first - last`.\nDo not add any additional information, return only the requested information.\n\n    # Examples:\n    text: 'This is an example text.'\n    output: 'This - text'\n    text: 'Another example text!!!'\n    output: 'Another - text'\n\"\"\"\"\nNel mezzo del cammin di nostra vita mi ritrovai per una selva oscura\n\"\"\"\""
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
