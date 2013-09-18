-module(crypto_sha_mac).

-export([parse_transform/2]).

parse_transform(Forms, _Options) ->
  application:load(crypto),
  crypto:start(),
  case erlang:function_exported(crypto, hmac, 3) of
    true ->
      Forms;
    false ->
      io:format("Rewriting crypto:hmac/3 calls with crypto_sha_mac parse transform~n", []),
      lists:map(fun rewrite/1, Forms)
  end.

rewrite(Function={function, _, _, _, Clauses}) ->
  setelement(5, Function, recursive_rewrite(Clauses));
rewrite(Form) ->
  Form.

recursive_rewrite(Terms) when is_list(Terms) ->
  lists:map(fun recursive_rewrite/1, Terms);
recursive_rewrite({call, L1, {remote, L2, {atom, L3, crypto}, {atom, L4, hmac}}, [{atom, _, sha} | Args]}) ->
  {call, L1, {remote, L2, {atom, L3, crypto}, {atom, L4, sha_mac}}, Args};
recursive_rewrite(Term) when is_tuple(Term) ->
  [Type, Line | Elements] = tuple_to_list(Term),
  list_to_tuple([Type, Line | lists:map(fun recursive_rewrite/1, Elements)]);
recursive_rewrite(Term) ->
  Term.
