-module(ulang_test).
-include_lib("eunit/include/eunit.hrl").

compile(Text) ->
    case ulang:string(Text) of
        {ok,Ret,_} ->
            case ulang_yecc:parse(Ret) of
                {ok,Spec} ->
                    case compile:noenv_forms(Spec,[return]) of
                        {ok,Module,Binary,_} ->
                            {Module,Binary};
                        {error,What} ->
                            error:error(What)
                    end;
        {error,Reason} ->
                    erlang:error(Reason)
            end
    end.

load(Module,Binary) ->
    case code:load_binary(Module,Module,Binary) of
        {module,Module} ->
            ok;
        {error,What} ->
            erlang:error({"load error",What}) 
    end.    

module_test() ->
    {Module,Bin} = compile("module test\nexport [(f,1)]\nfn f(x)->{x}"),
    load(Module,Bin),
    ?assert(test:f(1) == 1).

noarg_fun_test() ->
    {Module,Bin} = compile("module test\nexport [(f,0)]\nfn f()->{1}"),
    load(Module,Bin),
    ?assert(test:f() == 1).

