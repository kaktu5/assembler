open Base
open Sexplib.Std

type config = { instructions : string list; registers : string list }
[@@deriving sexp]

let parse (sexp : Sexplib.Sexp.t) =
  try config_of_sexp sexp
  with exn ->
    failwith
    @@ Printf.sprintf "Config error: %s\nInput: %s" (Exn.to_string exn)
    @@ Sexp.to_string sexp