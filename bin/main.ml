open Base
module Config = Assembler.Config
module Lexer = Assembler.Lexer

let () =
  let config_path = (Sys.get_argv ()).(1) in
  let config =
    match In_channel.with_open_text config_path In_channel.input_all with
    | ok -> Config.parse @@ Sexplib.Sexp.of_string ok
    | exception Sys_error msg -> failwith ("Failed to read file: " ^ msg)
  in
  let path = (Sys.get_argv ()).(2) in
  let result =
    match In_channel.with_open_text path In_channel.input_all with
    | ok -> Lexer.lex config ok
    | exception Sys_error msg -> failwith ("Failed to read file: " ^ msg)
  in
  Stdio.print_endline
    (result |> List.map ~f:Lexer.token_to_sexpr |> String.concat ~sep:"\n")