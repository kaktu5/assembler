open Base

type token =
  | GlobalLabel of string
  | LocalLabel of string
  | Instruction of string
  | Register of string
  | GlobalIdent of string
  | LocalIdent of string
[@@deriving sexp]

let matches_ps ?(p : char option) ?(s : char option) (str : string) : bool =
  match not @@ String.is_empty str with
  | true -> (
      let strp = str.[0] in
      let strs = str.[String.length str - 1] in
      match (p, s) with
      | None, None -> true
      | Some p', None -> Char.equal strp p'
      | None, Some s' -> Char.equal strs s'
      | Some p', Some s' -> Char.equal strp p' && Char.equal strs s')
  | _ -> ( match (p, s) with None, None -> true | _ -> false)

let lex (cfg : Config.config) (str : string) : token list =
  let _ = cfg in
  let tokens =
    String.split_on_chars str ~on:[ ' '; '\t'; '\n' ]
    |> List.filter ~f:(fun token -> not @@ String.is_empty token)
  in
  List.map tokens ~f:(fun token ->
      match token with
      | token when matches_ps ~p:'.' ~s:':' token ->
          LocalLabel (String.drop_prefix (String.drop_suffix token 1) 1)
      | token when matches_ps ~s:':' token ->
          GlobalLabel (String.drop_suffix token 1)
      | token when List.mem cfg.instructions token ~equal:String.equal ->
          Instruction token
      | token when List.mem cfg.registers token ~equal:String.equal ->
          Register token
      | token when matches_ps ~p:'.' token -> LocalIdent token
      | _ -> GlobalIdent token)