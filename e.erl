-module(e).
-compile(nowarn_export_all).
-compile(export_all).

% 100x more reads than writes

% pdict int 2x faster than pdict_categories (complex terms bad for hashing)
% pdict ints bad for multiple things, i.e. type refs, caching of operations etc.
% pdict ints fast, but out

pdict_int() ->
  {T, S} = timer:tc(fun() ->
  N = 10000000,
  [put(I, I) || I <- lists:seq(0, N div 100)],
  lists:foldl(fun(I, Sum) -> get(I div 100) + Sum end, 0, lists:seq(1, N)) end),
  io:format(user, "~p Sum: ~p~n", [T, S]).

pdict_categories() ->
  {T, S} = timer:tc(fun() ->
  N = 10000000,
  [put({ty_ref, I}, I) || I <- lists:seq(0, N div 100)],
  lists:foldl(fun(I, Sum) -> get({ty_ref, I div 100}) + Sum end, 0, lists:seq(1, N))
           end),
  io:format(user, "~p Sum: ~p~n", [T, S]).

ets() ->
  M = ets:new(t, [set]),
  {T, S} = timer:tc(fun() ->
  N = 10000000,
  [ets:insert(M, {I, I}) || I <- lists:seq(0, N div 100)],
  lists:foldl(fun(I, Sum) -> [{_,V}] = ets:lookup(M, I div 100), V + Sum end, 0, lists:seq(1, N))
           end),
  io:format(user, "~p Sum: ~p~n", [T, S]).

g() ->
  % HAMT
  M = #{},
  {T, S} = timer:tc(fun() ->
  N = 10000000,
  NewM = lists:foldl(fun(I, Map) -> Map#{I => I} end, M, lists:seq(0,N div 100)),
  lists:foldl(fun(I, Sum) -> #{(I div 100) := V} = NewM, V + Sum end, 0, lists:seq(1, N))
           end),
  io:format(user, "~p Sum: ~p~n", [T, S]).

g_indirect() ->
  % HAMT
  put(ty_ref, #{}),
  {T, S} = timer:tc(fun() ->
  N = 10000000,
  lists:foldl(fun(I, ok) -> put(ty_ref, (get(ty_ref))#{I => I}), ok end, ok, lists:seq(0,N div 100)),
  NewM = get(ty_ref),
  lists:foldl(fun(I, Sum) -> #{(I div 100) := V} = NewM, V + Sum end, 0, lists:seq(1, N))
           end),
  io:format(user, "~p Sum: ~p~n", [T, S]).

a2() ->
  M = ets:new(t, [set]),
  {T, S} = timer:tc(fun() ->
  N = 10000000,
  [ets:insert(M, {{ty_ref, I}, I}) || I <- lists:seq(0, N div 100)],
  lists:foldl(fun(I, Sum) -> [{_,V}] = ets:lookup(M, {ty_ref, I div 100}), V + Sum end, 0, lists:seq(1, N))
           end),
  io:format(user, "~p Sum: ~p~n", [T, S]).

b() ->
  {T, S} = timer:tc(fun() ->
  N = 10000000,
  [persistent_term:put(I, I) || I <- lists:seq(0, N div 100)],
  lists:foldl(fun(I, Sum) -> persistent_term:get(I div 100) + Sum end, 0, lists:seq(1, N))
           end),
  io:format(user, "~p Sum: ~p~n", [T, S]).
