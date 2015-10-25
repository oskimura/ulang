Definitions.

INT        = [0-9]+
ATOM       = :[a-z_]+
VAR        = [a-z_]+
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
fn      : {token,{'fn', TokenLine}}.
let     : {token,{'let', TokenLine}}.
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



,             : {token, {',',  TokenLine}}.
{WHITESPACE}+ : skip_token.


%% String
"(\\x{H}+;|\\.|[^"])*" :
                    S = string:substr(TokenChars, 2, TokenLen - 2),
                {token,{string,TokenLine,S}}.



Erlang code.


to_atom(Chars) ->
    list_to_atom(Chars).





%% chars([$\\,$x,C|Cs0]) ->
%%     case hex_char(C) of
%%         true ->
%%             case base1([C|Cs0], 16, 0) of
%%                 {N,[$;|Cs1]} -> [N|chars(Cs1)];
%%                 _Other -> [escape_char($x)|chars([C|Cs0])]
%%          end;
%%         false -> [escape_char($x)|chars([C|Cs0])]
%%     end;
%% chars([$\\,C|Cs]) -> 
%%     [escape_char(C)|chars(Cs)];
%% chars([C|Cs]) -> 
%%     [C|chars(Cs)];
%% chars([]) -> 
%%     [].


%% escape_char($n) -> $\n;             %\n = LF
%% escape_char($r) -> $\r;             %\r = CR
%% escape_char($t) -> $\t;             %\t = TAB
%% escape_char($v) -> $\v;             %\v = VT
%% escape_char($b) -> $\b;             %\b = BS
%% escape_char($f) -> $\f;             %\f = FF
%% escape_char($e) -> $\e;             %\e = ESC
%% escape_char($s) -> $\s;             %\s = SPC
%% escape_char($d) -> $\d;             %\d = DEL
%% escape_char(C) -> C.
