% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/file.R
\name{file_info}
\alias{file_info}
\title{Retrieve file information}
\usage{
file_info(file_id)
}
\arguments{
\item{file_id}{(chr) The id of the file to retrieve.}
}
\value{
(tibble) information about the file
}
\description{
Retrieve file information
}
\examples{
 sys_prompt <- compose_sys_prompt("You are a funny assistant.")
 usr_prompt <- compose_usr_prompt(
   "Tell me a joke ending in:"
 )
 prompter <- create_usr_data_prompter(usr_prompt = usr_prompt)
 text <-  c(
   "deadly boring!",
   "A bit boring, but interesting",
   "How nice, I loved it!"
 )

 jsonl_text <- text |>
   purrr::map(
     \(x) {
       compose_prompt_api(
         sys_prompt = sys_prompt,
         usr_prompt = prompter(x)
       )
     }
   ) |>
   create_jsonl_records()
 out_jsonl_path <- write_jsonl_files(jsonl_text, tempdir())

uploaded_file_info <- file_upload(out_jsonl_path)
files <- file_list()
file_info(files[["id"]][[1]])
file_delete(uploaded_file_info[["id"]])
}
\seealso{
Other files: 
\code{\link{file_delete}()},
\code{\link{file_list}()},
\code{\link{file_retrieve}()},
\code{\link{file_upload}()}
}
\concept{files}
