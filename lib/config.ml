open Base

type config = { instructions : string list }

let parse (sexp : Sexplib0.Sexp.t) =
  let open Sexplib.Sexp in
  match sexp with
  | List (Atom "instructions" :: ops) ->
      {
        instructions =
          List.map ops ~f:(function
            | Atom op -> op
            | _ -> failwith "Non-atom in instructions list");
      }
  | _ -> failwith "Invalid config format: expected (instructions ...)"