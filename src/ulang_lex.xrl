Definitions.

INT        = [0-9]+
ATOM       = :[a-z_]+
VAR        = [a-z0-9_]+
CHAR       = [a-z0-9_]
WHITESPACE = [\s\t\n\r]

Rules.

module  : {token,{module,TokenLine}}.
export  : {token, {export,TokenLine}}.

fn      : {token,{'fn',TokenLine}}.
\+      : {token,{'op',TokenLine, to_atom(TokenChars)}}.
\-      : {token,{'op',TokenLine, to_atom(TokenChars)}}.
\*      : {token,{'op',TokenLine, to_atom(TokenChars)}}.
\/      : {token,{'op',TokenLine, to_atom(TokenChars)}}.
\=\=    : {token,{'op',TokenLine, to_atom(TokenChars)}}.
\<      : {token,{'op',TokenLine, to_atom(TokenChars)}}.
\>      : {token,{'op',TokenLine, to_atom(TokenChars)}}.
\<\=    : {token,{'op',TokenLine, to_atom(TokenChars)}}.
\>\=    : {token,{'op',TokenLine, to_atom(TokenChars)}}.
if      : {token,{'if',TokenLine}}.
while   : {token,{'while',TokenLine}}.
let     : {token,{'let', TokenLine}}.
\<\-    : {token,{'<-', TokenLine}}.
\"      : {token,{'\"', TokenLine}}.
\-\>    : {token,{'->', TokenLine}}.
\{      : {token,{'{', TokenLine}}.
\}      : {token,{'}', TokenLine}}.
;      : {token,{';', TokenLine}}.
if      : {token,{'if', TokenLine}}.
then      : {token,{'then', TokenLine}}.
else      : {token,{'else', TokenLine}}.
end     : {token,{'end', TokenLine}}.
 
{INT}         : {token, {int,  TokenLine, TokenChars}}.
{ATOM}        : {token, {atom, TokenLine, to_atom(TokenChars)}}.
{VAR}         : {token, {var,  TokenLine, to_atom(TokenChars)}}.
\[            : {token, {'[',  TokenLine}}.
\]            : {token, {']',  TokenLine}}.
\(            : {token, {'(',  TokenLine}}.
\)            : {token, {')',  TokenLine}}.
\.            : {token, {'.',  TokenLine}}.
,             : {token, {',',  TokenLine}}.
{WHITESPACE}+ : skip_token.

%% String
"(\\x{H}+;|\\.|[^"])*" :
                    S = string:substr(TokenChars, 2, TokenLen - 2),
                {token,{string,TokenLine,S}}.

Erlang code.

to_atom(Chars) ->
    list_to_atom(Chars).
