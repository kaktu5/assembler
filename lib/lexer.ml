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
  match String.length str with
  | 0 -> ( match (p, s) with None, None -> true | _ -> false)
  | len -> (
      let ( = ) = Base.Char.( = ) in
      match (p, s) with
      | None, None -> true
      | Some p', None -> str.[0] = p'
      | None, Some s' -> str.[len - 1] = s'
      | Some p', Some s' -> str.[0] = p' && str.[len - 1] = s')

let lex (cfg : Config.config) (str : string) : token list =
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