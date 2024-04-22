#' Create a prompt to OpenAI API
#'
#' Questa funzione è un semplice wrapper per comporre un prompt per le
#' API OpenAI a ChatGPT. Per la sua semplicità, per lo più didattica,
#' non considera alternanze successive di prompt nella chat ma solo
#' l'impostazione iniziale del sistema e il primo messaggio dell'utente.
#'
#' @details In genere, una conversazione è formattata con un messaggio
#' di sistema, seguito da messaggi alternati dell'utente e
#' dell'assistente.
#'
#' Il messaggio di sistema consente di impostare il comportamento
#' dell'assistente. Ad esempio, è possibile modificare la personalità
#' dell'assistente o fornire istruzioni specifiche sul comportamento da
#' tenere durante la conversazione. Tuttavia, il messaggio di sistema è
#' facoltativo e il comportamento del modello senza un messaggio di
#' sistema sarà probabilmente simile a quello di un messaggio generico
#' come "Sei un assistente utile".
#'
#' I messaggi dell'utente forniscono richieste o commenti a cui
#' l'assistente deve rispondere. I messaggi dell'assistente memorizzano
#' le risposte precedenti dell'assistente, ma possono anche essere
#' scritti dall'utente per fornire esempi del comportamento desiderato.
#'
#'
#' @param sys_prompt (chr) messaggio da usare per impostare il sistema
#' @param usr_prompt (chr) messaggio da usare come richiesta al sistema
#'   passata dall'utente
#'
#' @return (chr) una lista di due lista, la prima con il messaggio da
#'   usare per il prompt di impostazione del sistema di assistenza delle
#'   API, la seconda con il prompt di richiesta dell'utente.
#' @export
#'
#' @examples
#' msg_sys <- compose_sys_prompt(
#'   role = "Sei l'assistente di un docente universitario.",
#'   context = "
#'     Tu e lui state preparando un workshop sull'utilizzo di ChatGPT
#'     per biostatisitci ed epidemiologi."
#'  )
#'
#' msg_usr <- compose_usr_prompt(
#'   task = "
#'     Il tuo compito è trovare cosa dire per spiegare cosa sia una
#'     chat di ChatGPT agli studenti, considerando che potrebbe
#'     esserci qualcuno che non ne ha mai sentito parlare (e segue
#'     il worksho incuriosito dal titolo o dagli amici).",
#'   output = "
#'     Riporta un potenziale dialogo tra il docente e gli studenti
#'     che assolva ed esemplifichi lo scopo descritto.",
#'  style = "Usa un tono amichevole, colloquiale, ma preciso."
#' )
#'
#' compose_prompt_api(msg_sys, msg_usr)
#'
#'
compose_prompt_api <- function(sys_prompt = NULL, usr_prompt = NULL) {

  list(
    list(
      role = "system",
      content = sys_prompt %||% ""
    ),
    list(
      role = "user",
      content = usr_prompt %||% ""
    )
  )
}
