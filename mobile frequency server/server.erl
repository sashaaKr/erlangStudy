-module(server).
-export([start/0, init/0]).

start() ->
    register(frequency, spawn(server, init, [])).

init() ->
    loop({get_freguencies(), []}).

get_freguencies() -> 
    [10, 11, 12, 13, 14, 15].

allocate({[Freq|Free], Allocated}, Pid) -> {{Free, [{Freq, Pid}|Allocated]}, {ok, Freq}};
    allocate({[], Allocated}, _Pid) -> {{[], Allocated}, {error, no_frequency}}.

deallocate({Free, Allocated}, Freq) ->
    NewAllocated=lists:keydelete(Freq, 1, Allocated),
    {[Freq|Free], NewAllocated}.

loop(Frequencies) -> 
    receive
        {request, From, allocate} ->
            {NewFrequencies, Reply} = allocate(Frequencies, From),
            From ! {reply, Reply},
            loop(NewFrequencies);

        {request, From, {deallocate, Freq}} ->
            NewFrequencies = deallocate(Frequencies, Freq),
            From ! {reply, ok},
            loop(NewFrequencies);

        {stop, From} ->
             From ! {reply, ok}
    end.