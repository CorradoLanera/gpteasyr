% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/query_gpt.R
\name{query_gpt}
\alias{query_gpt}
\title{Query the GPT model}
\usage{
query_gpt(
  prompt,
  model = "gpt-4o-mini",
  temperature = 0,
  max_tokens = NULL,
  endpoint = "https://api.openai.com/v1/chat/completions",
  max_try = 10,
  quiet = TRUE,
  na_if_error = FALSE,
  seed = NULL,
  use_py = FALSE
)
}
\arguments{
\item{prompt}{(chr) the prompt to use}

\item{model}{(chr) the model to use}

\item{temperature}{(dbl) the temperature to use}

\item{max_tokens}{(dbl) the maximum number of tokens}

\item{endpoint}{(chr, default =
"https://api.openai.com/v1/chat/completions", i.e. the OpenAI API)
the endpoint to use for the request.}

\item{max_try}{(int) the maximum number of tries}

\item{quiet}{(lgl) whether to print information}

\item{na_if_error}{(lgl) whether to return NA if an error occurs}

\item{seed}{(chr, default = NULL) a string to seed the random number}

\item{use_py}{(lgl, default = FALSE) whether to use python or not}
}
\value{
(list) the result of the query
}
\description{
Query the GPT model
}
\examples{
if (FALSE) {
 prompt <- compose_prompt_api(
   sys_prompt = compose_sys_prompt(
     role = "Sei l'assistente di un docente universitario.",
     context = "
       Tu e lui state preparando un workshop sull'utilizzo di ChatGPT
       per biostatisitci ed epidemiologi."
   ),
   usr_prompt = compose_usr_prompt(
     task = "
       Il tuo compito è trovare cosa dire per spiegare cosa sia una
       chat di ChatGPT agli studenti, considerando che potrebbe
       esserci qualcuno che non ne ha mai sentito parlare (e segue
       il worksho incuriosito dal titolo o dagli amici).",
     output = "
       Riporta un potenziale dialogo tra il docente e gli studenti
       che assolva ed esemplifichi lo scopo descritto.",
     style = "Usa un tono amichevole, colloquiale, ma preciso."
   )
 )
 res <- query_gpt(prompt)
 get_content(res)
 get_tokens(res)
}
}
