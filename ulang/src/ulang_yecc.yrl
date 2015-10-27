Nonterminals program module_exp functions function args arg while_exp let_exp  exp exps if_exp test_exp true_exp false_exp op_exp call_exp stmt list_exp tail_exp export_exp fundecs fundec.

Terminals '(' ')'  '->' '<-' '{' '}' '[' ']' '<' '>' '<=' '>=' ',' 'fn' 'let' 'if' 'then' 'else' 'module' ';' 'end' 'export' int atom char string var op.


Rootsymbol program.


program ->
    module_exp: [ '$1' ].

program ->
    module_exp exps: [ '$1' | '$2' ].

program ->
    module_exp export_exp exps: [ '$1', '$2' | '$3' ].


module_exp ->
    'module' var:
        {attribute, ?line('$2'),module, element(3,'$2')}.

export_exp ->
    'export' '[' fundecs ']' :
        {attribute,?line('$1'),export, '$3' }.

fundecs ->
    fundec : [ '$1' ].
fundecs ->
    fundec ',' fundecs :
        [ '$1', '$3' ].

fundec ->
    '(' var ',' int ')' :
        {element(3,'$2'), string_to_integer(element(3,'$4'))}.

    


functions ->
     function functions:
        [ '$1' | '$2' ].
functions ->
    function : ['$1'].

function ->
    'fn' var '(' args  ')' '->'  '{' exps '}' :
        {function,?line('$1'),element(3,'$2'), length('$4'),
         [{clause,?line('$1'),'$4',[],
           '$8'
          }]
        }.

function ->
    'fn' var '('  ')' '->'  '{' exps '}' :
        {function,?line('$1'),element(3,'$2'), 0,
         [{clause,?line('$1'),[],[],
           '$7'
          }]
        }.

args ->
    arg ',' args :
        [ '$1' | '$3' ].

args ->
    arg : [ '$1' ].

arg -> 
    var : '$1'.
           
exps ->
    exp :
        [ '$1' ].
exps ->
     exp ';' exps  :
        [ '$1' | '$3' ].
stmt ->
    '{' exps '}'.

exp ->
    function : '$1'.
exp ->
    let_exp : '$1'.
exp ->
    if_exp : '$1'.
exp ->
    op_exp : '$1'.
exp ->
    list_exp : '$1'.
exp ->
    call_exp : '$1'.
exp ->
    int : {integer, ?line('$1'), string_to_integer(element(3,'$1'))}.
exp ->
    string : '$1'.
exp ->
    var : '$1'.

let_exp ->
    'let' var '<-' exp :
        {'match', ?line('$1'), '$2', '$4'}.

if_exp ->
    'if' test_exp 'then' true_exp 'else' false_exp 'end':
        {'case', ?line('$1'), 
         '$2', 
         [{'clause', ?line('$3'), [{atom, ?line('$3'),'true'}],
           [],
           '$4'},
          {'clause', ?line('$5'), [{atom, ?line('$5'),'false'}],
           [],
           '$6'}]}.
test_exp ->
     exp  :  '$1' .
true_exp ->
     exps :  '$1' .
false_exp ->
     exps :  '$1' .


op_exp ->
    exp op exp :
        {op, ?line('$1'), element(3,'$2'), '$1', '$3' }.

call_exp ->
    var '(' ')':
        {call, ?line('$1'),var_to_atom('$1'),nil}.

call_exp ->
    var '(' exps ')' :
        {call, ?line('$1'),var_to_atom('$1'),'$3'}.

list_exp ->
    '[' ']': {nil, ?line('$1')}.
list_exp ->
    '[' exp tail_exp:
        {cons, ?line('$2'), '$2', '$3'}.
tail_exp ->
    ',' exp  tail_exp:
        {cons, ?line('$1'), '$2', '$3'}.
        
tail_exp ->
     ']':
        {nil, ?line('$1')}.
     


Erlang code.
-define(line(Tup), element(2, Tup)).
line(Tup)-> element(2, Tup).


string_to_integer(Str) ->
    case string:to_integer(Str) of
        {Code,_} ->
            Code
    end.
var_to_atom({var,Line,V}) ->
    {atom,Line,V}.
