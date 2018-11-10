-module(compiler).
-export([file/1,
         compile/1,
         eval/2,
         repl/0,
         execute/1,
         command/1,
         command/2]).

call_with_read_file(File,Fun) ->
    case file:read_file(File) of
        {ok,Bin} ->
            Fun(Bin);
        _ ->
            erlang:error("file read error")
    end.

lexer(String) ->
    case ulang_lex:string(String) of
        {ok,Ret,_} ->
            io:format("lexer:~p~n",[Ret]),
            Ret;
        {error,Reason,_} ->
            erlang:error({"lex error",Reason});
        _ ->
            erlang:error("lex error")
    end.

parser(LexedText) ->
    case ulang_yecc:parse(LexedText) of
        {ok,Spec} ->
            io:format("parser:~p~n",[Spec]),
            Spec;
        {error,Reason} ->
            erlang:error({"parse error",Reason});
        _ ->
            erlang:error("parse error")
    end.

compiler(ParsedAst) ->
    case compile:noenv_forms(ParsedAst,[return]) of
        {ok,Module,Binary,Warnings} ->
            {Module,Binary,Warnings};
        error ->
            erlang:error({"compile errord"});
        {error,Error,Warning} ->
            erlang:error({"compile error",Error,Warning})
    end.
    
loader({Module,Binary,Warnings}) ->
    io:format("m:~s~nw:~p~n",[Module,Warnings]),
    case code:load_binary(Module,Module,Binary) of
        {module,Module} ->
            Module;
        {error,What} ->
            erlang:error({"load error",What}) 
    end.

save_beam(Module,Binary) ->
    case file:open(atom_to_list(Module) ++ ".beam",[write,binary]) of
        {ok,Dev} ->
            io:format("binret:~p",[Binary]),
            file:write(Dev,Binary),
            file:close(Dev);
        {error,Reason} ->
            erlang:error({"file error",Reason})
    end.

file(File) ->
    call_with_read_file(File,
                        fun(Bin) ->
                                Lexed = lexer(binary_to_list(Bin)),
                                AST = parser(Lexed),
                                Compiled = compiler(AST),
                                loader(Compiled)
                        end).
   

compile(File) ->
    call_with_read_file(File,
                        fun(Bin) ->
                                Lexed = lexer(binary_to_list(Bin)),
                                AST = parser(Lexed),
                                {Module,Binary,_} = compiler(AST),
                                save_beam(Module,Binary)
                        end).

eval(Bin,Env) ->
    Lexed = lexer(Bin),
    AST = parser(Lexed),
    try erl_eval:exprs(AST, Env, none,none) of
        {value, Value, NewBind} ->
            {Value,NewBind}
    catch
        Class:Exception ->
            erlang:error({"eval error",{Class,Exception}})
    end.

repl() ->
    Env = erl_eval:bindings(erl_eval:new_bindings()),
    repl(Env).
repl(Env) ->
    Expr = io:get_line("$ "),
    {Val,NEnv}= eval(Expr,Env),
    io:format("#~p~n",[Val]),
    repl(NEnv).

execute(File) ->
    Env = erl_eval:bindings(erl_eval:new_bindings()),
    execute(File,Env).

execute(File,Env) ->
    case file:read_file(File) of
        {ok,Bin} ->
            try eval(binary_to_list(Bin),Env) of
                {Val,_} ->
                    io:format("~p~n",[Val])
            catch
                {error,Reason} ->
                    erlang:error({"parse error",Reason})
            end;
        _ ->
            erlang:error("file read error")
    end.

command(File) ->
    command(File,[]).
command(File,Args) ->
    Module = file(File),
    Module:main(Args).
