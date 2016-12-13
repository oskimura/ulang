-module(compiler).
-export([file/1,
         compile/1,
         eval/2,
         repl/0]).

file(File) ->
    case file:read_file(File) of
        {ok,Bin} ->
            case ulang:string(binary_to_list(Bin)) of
                {ok,Ret,_} ->
                    io:format("lexer:~p~n",[Ret]),
                    case ulang_yecc:parse(Ret) of
                        {ok,Spec} ->
                            io:format("parser:~p~n",[Spec]),
                            case compile:noenv_forms(Spec,[return]) of
                                {ok,Module,Binary,Warnings} ->
                                    io:format("m:~s~nw:~p~n",[Module,Warnings]),
                                    case code:load_binary(Module,Module,Binary) of
                                        {module,Module} ->
                                            Bin;
                                        {error,What} ->
                                            erlang:error({"load error",What}) 
                                    end;
                                 error ->
                                    erlang:error({"compile errord"});
                                {error,Error,Warning} ->
                                    erlang:error({"compile error",Error,Warning})
                                end;
                        {error,Reason} ->
                            erlang:error({"parse error",Reason});
                        _ ->
                            erlang:error("parse error")
                    end;
                {error,Reason,_} ->
                    erlang:error({"lex error",Reason});
                _ ->
                    erlang:error("lex error")
            end;
        _ ->
            erlang:error("file read error")
    end.



compile(File) ->
    case file:read_file(File) of
        {ok,Bin} ->
            case ulang:string(binary_to_list(Bin)) of
                {ok,Ret,_} ->
                    io:format("~p~n",[Ret]),
                    case ulang_yecc:parse(Ret) of
                        {ok,Spec} ->
                            io:format("~p~n",[Spec]),
                            case compile:noenv_forms(Spec,[return]) of
                                {ok,Module,Binary,Warnings} ->
                                    case file:open(Module,[write,binary]) of
                                        {ok,Dev} ->
                                            io:format("binret:~p",[Binary]),
                                            file:write(Dev,Binary),
                                            file:close(Dev);
                                        {error,Reason} ->
                                            erlang:error({"file error",Reason})
                                    end;
                                error ->
                                    erlang:error({"compile errord"});
                                {error,Error,Warning} ->
                                    erlang:error({"compile error",Error,Warning})

                            
                                end;
                        {error,Reason} ->
                            erlang:error({"parse error",Reason});
                        _ ->
                            erlang:error("parse error")
                    end;
                {error,Reason,_} ->
                    erlang:error({"lex error",Reason});
                _ ->
                    erlang:error("lex error")
            end;
        _ ->
            erlang:error("file read error")
    end.


eval(Bin,Env) ->
    case ulang:string(Bin) of
                {ok,Ret,_} ->
                    io:format("~p~n",[Ret]),
                    case ulang_yecc:parse(Ret) of
                        {ok,Spec} ->
                            io:format("~p~n",[Spec]),
                            try erl_eval:exprs(Spec, Env, none,none) of
                                {value, Value, NewBind} ->
                                    {Value,NewBind}
                            catch
                                Class:Exception ->
                                    erlang:error({"eval error",{Class,Exception}})
                                end;
                        {error,Reason} ->
                            erlang:error({"parse error",Reason});
                        _ ->
                            erlang:error("parse error")
                    end;
        {error,Reason,_} ->
            erlang:error({"lex error",Reason});
        _ ->
            erlang:error("lex error")
    end.


repl() ->
    Env = erl_eval:bindings(erl_eval:new_bindings()),
    repl(Env).
repl(Env) ->
    Expr = io:get_line("$ "),
    {Val,NEnv}= eval(Expr,Env),
    io:format("#~p~n",[Val]),
    repl(NEnv).
