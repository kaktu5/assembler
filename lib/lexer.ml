open Base

type token =
  | GlobalLabel of string
  | LocalLabel of string
  | Instruction of string
  | Tmp of string

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
      | t when matches_ps ~p:'.' ~s:':' t ->
          LocalLabel (String.drop_prefix (String.drop_suffix t 1) 1)
      | t when matches_ps ~s:':' t -> GlobalLabel (String.drop_suffix t 1)
      | t when List.mem cfg.instructions t ~equal:String.equal -> Instruction t
      | _ -> Tmp token)

let token_to_sexpr token : string =
  match token with
  | LocalLabel str -> Printf.sprintf "(LocalLabel \"%s\")" str
  | GlobalLabel str -> Printf.sprintf "(GlobalLabel \"%s\")" str
  | Instruction str -> Printf.sprintf "(Instruction \"%s\")" str
  | Tmp str -> Printf.sprintf "(Tmp \"%s\")" str