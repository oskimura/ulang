-module(compiler).
-export([file/1]).

file(File) ->
    case file:read_file(File) of
        {ok,Bin} ->
            case ulang:string(binary_to_list(Bin)) of
                {ok,Ret,_} ->
                    io:format("~p~n",[Ret]),
                    case ulang_yecc:parse(Ret) of
                        {ok,Spec} ->
                            io:format("~p~n",[Spec]),
                            case compile:noenv_forms(Spec,[return]) of
                                {ok,Module,Binary,Wornings} ->
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
