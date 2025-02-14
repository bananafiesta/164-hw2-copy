open Printf
open S_exp

(* A `value` is the runtime value of an expression.
 *)
type value
  = Num of int
  | Bool of bool
  | Char of char

(* `display_value v` returns a string representation of the runtime value `v`.
 *)
let display_value : value -> string =
  fun v ->
    begin match v with
      | Num x ->
          sprintf "%d" x

      | Bool b ->
          if b then "true" else "false"

      | Char c ->
        (match c with
            | ' ' -> "\\#space"
            | '\n' -> "\\#newline"
            | _ -> sprintf "\\#%c" c

        )
    
    end

(* `interp_primitive prim arg` tries to evaluate the primitive operation named
 * by `prim` on the argument `arg`. If the operation is ill-typed, or if `prim`
 * does not refer to a valid primitive operation, it returns `None`.
 *)
let interp_primitive : string -> value -> value option =
  fun prim arg ->
    begin match (prim, arg) with
      | ("add1", Num x) ->
          Some (Num (x + 1))

      | ("sub1", Num x) ->
          Some (Num (x - 1))

      | ("zero?", Num 0) ->
          Some (Bool true)

      | ("zero?", _) ->
          Some (Bool false)

      | ("num?", Num _) ->
          Some (Bool true)

      | ("num?", _) ->
          Some (Bool false)

      | ("not", Bool false) ->
          Some (Bool true)

      | ("not", _) ->
          Some (Bool false)

      | ("char?", Char _) -> 
        Some (Bool true)
    
      | ("char?", _) ->
        Some (Bool false)

      | ("char->num", Char c) -> 
        Some (Num (Char.code c))

      | ("num->char", Num x) ->
        Some (Char (Char.chr x))

      | _ ->
          None
    end

(* `interp_expr e` tries to evaluate the s_expression `e`, producing a value.
 * If `e` isn't a valid expression, it raises an error.
 *)
let rec interp_expr : s_exp -> value =
  fun e ->
    begin match e with
      | Num x ->
          Num x

      | Sym "true" ->
          Bool true

      | Sym "false" ->
          Bool false

      | Chr c -> 
        Char c

      | Lst [Sym f; arg] ->
          begin match interp_primitive f (interp_expr arg) with
            | Some v ->
                v

            | None ->
                raise (Error.Stuck e)
          end

      | e ->
          raise (Error.Stuck e)
    end

(* `interp e` evaluates the s_expression `e` using `interp_expr`, then formats
 * the result as a string.
 *)
let interp : s_exp -> string =
  fun e ->
    e
      |> interp_expr
      |> display_value
