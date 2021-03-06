open Lexer
open Parser
open Types

(* Evaluation exceptions *)
exception Eval_exn of string
exception Not_function

let is_true x = 
  match x with
  | Boolean b -> b
  | _ -> true

let rec eval (sexpr: sexp) : value =

  let eval_binary_op (op: value) (operands: sexp list) : value =
    if (List.length operands != 2) then raise Incorrect_argument_count
    else begin
      match (List.map eval operands) with
      | [Number a; Number b] ->
        begin
          match op with
          | Plus -> Number (a + b)
          | Minus -> Number (a - b)
          | Multiply -> Number (a * b)
          | Divide -> Number (a / b)
          | Modulo -> Number (a mod b)
          | EQ -> Boolean (a = b)
          | NEQ -> Boolean (a <> b)
          | LT -> Boolean (a < b)
          | LTE -> Boolean (a <= b)
          | GT -> Boolean (a > b)
          | GTE -> Boolean (a >= b)
          | _ -> raise (Parser_exn "Type error")
        end
      | [Boolean a; Boolean b] ->
        begin
          match op with
          | AND -> Boolean (a && b)
          | OR -> Boolean (a || b)
          | _ -> raise (Parser_exn "Type error")
        end
      | _ -> raise Invalid_argument_types
    end in

  let eval_conditional (op: value) (operands: sexp list) : value =
    (* Lazy evaluation *)
    let predicate = eval (List.hd operands) in
    if (is_true predicate) then 
      (eval (List.hd (List.tl operands)))
    else (eval (List.hd (List.tl (List.tl operands)))) in

  let eval_car (op: value) (operands: sexp list) =
    match operands with
    | x::xs ->
      begin
        match eval x with
        | QuotedList(y::ys) -> y
        | _ -> raise Incorrect_argument_count
      end
    | _ -> raise Incorrect_argument_count in

  let eval_cdr (op: value) (operands: sexp list) =
    match operands with
    | x::xs ->
      begin
        match eval x with
        | QuotedList(y::ys) -> QuotedList(ys)
        | _ -> raise Incorrect_argument_count
      end
    | _ -> raise Incorrect_argument_count in

  let eval_cons (op: value) (operands: sexp list) =
    match operands with
    (* atom or list -> empty list *)
    | [head; List(Atom(Quote)::tail)] ->
      QuotedList((eval head)::(List.map eval tail))
    | [head; tail] ->
      begin
        match eval tail with
        | QuotedList(x) -> QuotedList((eval head)::x)
        | _ -> failwith "TBI"
      end
    | _ -> raise Incorrect_argument_count in

  let eval_keyword op operands =
    match op with 
    | Keyword "if" -> eval_conditional op operands
    | Keyword "car" -> eval_car op operands
    | Keyword "cdr" -> eval_cdr op operands
    | Keyword "cons" -> eval_cons op operands
    | Keyword "quote" -> 
      begin
        match operands with
        | [List s] -> QuotedList (List.map eval s)
        | [x] -> eval x
        | _ -> raise (Eval_exn "Cannot form quoted list")
      end 
   | _ -> raise (Eval_exn "Not a keyword") in

  match sexpr with
  | Atom x -> x
  | List x ->
    begin
      match x with
      | (List _)::_ -> raise Not_function
      | (Atom op)::operands ->
        begin
          match op with
          | Plus | Minus | Multiply | Divide | Modulo
          | EQ | NEQ | LT | LTE | GT | GTE
          | AND | OR -> eval_binary_op op operands
          | Keyword _ -> eval_keyword op operands
          | Quote -> QuotedList (List.map eval operands)
          | _ -> raise (Parser_exn ("Cannot parse operator: "^(string_of_value op)))
        end
      | [] -> raise (Parser_exn "List cannot be empty")
    end

let print_debug prelude s = print_endline ("DEBUG: "^prelude^s)
