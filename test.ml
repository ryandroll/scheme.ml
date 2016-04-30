module EvalTests = struct

  let interpret = Eval.interpret

  module Basic = struct
    let operations () =
      Alcotest.(check string) "positive integer" "3" (interpret "3");
      Alcotest.(check string) "negative integer" "-3" (interpret "-3");
      Alcotest.(check string) "empty list" "()" (interpret "'()");
      Alcotest.(check string) "true" "#t" (interpret "#t");
      Alcotest.(check string) "false" "#f" (interpret "#f");
      Alcotest.(check string) "list with one element" "(1)" (interpret "'(1)");
      Alcotest.(check string) "list with two elements" "(1 2)" (interpret "'(1 2)");
      Alcotest.(check string) "list with nested elements" "((1 2) 3)" (interpret "'('(1 2) 3)");
      Alcotest.(check string) "extra spaces are okay" "(1 2 3)" (interpret "'(1  2  3)");
  end

  module Arithmetic = struct
    let operations () =
      begin
        Alcotest.(check string) "addition of two numbers" "3" (interpret "(+ 1 2)");
        Alcotest.(check string) "subtraction of a number from another number" "2" (interpret "(- 3 1)");
        Alcotest.(check string) "Division with no remainder" "2" (interpret "(/ 4 2)");
        Alcotest.(check string) "Division with remainder" "2" (interpret "(/ 5 2)");
        Alcotest.(check string) "Multiplication" "10" (interpret "(* 5 2)");
        Alcotest.(check string) "Modulo" "1" (interpret "(% 5 2)");
        Alcotest.(check string) "Composed operations" "1" (interpret "(- (+ (* 2 (/ 4 2)) (- 2 3)) (% 5 3))")
      end
  end

  module LogicalConnectives = struct
    let conjunction () = 
      begin
        Alcotest.(check string) "Conjunction TT" "#t" (interpret "(and #t #t)");
        Alcotest.(check string) "Conjunction TF" "#f" (interpret "(and #t #f)");
        Alcotest.(check string) "Conjunction FT" "#f" (interpret "(and #f #t)");
        Alcotest.(check string) "Conjunction FF" "#f" (interpret "(and #f #f)")
      end

    let disjunction () = 
      begin
        Alcotest.(check string) "Disjunction TT" "#t" (interpret "(or #t #t)");
        Alcotest.(check string) "Disjunction TF" "#t" (interpret "(or #t #f)");
        Alcotest.(check string) "Disjunction FT" "#t" (interpret "(or #f #t)");
        Alcotest.(check string) "Disjunction FF" "#f" (interpret "(or #f #f)");
      end
  end

  module Conditional = struct
    let operations () = 
      begin
        Alcotest.(check string) "if <" "4" (interpret "(if (< 1 2) 4 5)");
        Alcotest.(check string) "if >" "2" (interpret "(if (> 1 2) (* 2 2) (/ 5 2))");
        Alcotest.(check string) "if =" "2" (interpret "(if (= 1 2) (* 2 2) (/ 5 2))");
        Alcotest.(check string) "if \\=" "4" (interpret "(if (\\= 1 2) (* 2 2) (/ 5 2))");
        Alcotest.(check string) "if >=" "2" (interpret "(if (>= 1 2) (* 2 2) (/ 5 2))");
        Alcotest.(check string) "if <=" "4" (interpret "(if (<= 1 2) (* 2 2) (/ 5 2))");
      end
  end

  module List = struct
    let operations () = 
      begin
        Alcotest.(check string) "car of quoted list" "1" (interpret "(car '(1 2 3))");
        Alcotest.(check string) "car of quoted list" "'a" (interpret "(car '('a 'b 'c))");
        Alcotest.(check string) "car of quoted list" "'c" (interpret "(car '('c 3 'a 'b))");
        Alcotest.(check string) "car of quoted list with quoted list as head" "(1 2)" (interpret "(car '('(1 2) 3 'a 'b))");
        Alcotest.(check string) "car should return head of list with one element" "1" (interpret "(car '(1))");
        Alcotest.(check string) "cdr should return tail of list with 3 elements" "(2 3)" (interpret "(cdr '(1 2 3))");
        Alcotest.(check string) "cdr should return tail of list with 2 elements" "(3)" (interpret "(cdr '(2 3))");
        Alcotest.(check string) "cdr should return empty list as tail of list with 1 element" "()" (interpret "(cdr '(3))");
        Alcotest.(check string) "cons of one number with empty list" "(1)" (interpret "(cons 1 '())");
        Alcotest.(check string) "cons of result of expression with empty list" "(3)" (interpret "(cons (+ 1 2) '())");
        Alcotest.(check string) "cons of quoted list with empty list" "((1 2))" (interpret "(cons '(1 2) '())");
        Alcotest.(check string) "cons of number with non-empty list" "(1 2 3)" (interpret "(cons 1 '(2 3))");
        Alcotest.(check string) "cons of number with nested non-empty list" "(1 (1 1) 2)" (interpret "(cons 1 '('(1 1) 2))");
        (* Alcotest.(check string) "cdr should return empty list as tail of list with no element" "()" (interpret "(cdr '())"); *)
      end

    let quoted () =
      begin
        Alcotest.(check string) "Quoted list prevents evaluation" "(+ 1 2)" (interpret "'(+ 1 2)");
      end
  end

end

let () =
  Alcotest.run "All tests" [
    "Eval tests", [
      "Language basic syntax", `Quick, EvalTests.Basic.operations;
      "Arithmetic operations", `Quick, EvalTests.Arithmetic.operations;
      "Logical conjunctions", `Quick, EvalTests.LogicalConnectives.conjunction;
      "Logical disjunctions", `Quick, EvalTests.LogicalConnectives.disjunction;
      "Conditionals", `Quick, EvalTests.Conditional.operations;
      "List", `Quick, EvalTests.List.operations;
      "Quoted list", `Quick, EvalTests.List.quoted;
    ]
  ]
