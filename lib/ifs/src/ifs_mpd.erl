% This file is part of "Enms" (http://sourceforge.net/projects/enms/)
% Copyright (C) 2012 <Sébastien Serre sserre.bx@gmail.com>
% 
% Enms is a Network Management System aimed to manage and monitor SNMP
% targets, monitor network hosts and services, provide a consistent
% documentation system and tools to help network professionals
% to have a wide perspective of the networks they manage.
% 
% Enms is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% Enms is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with Enms.  If not, see <http://www.gnu.org/licenses/>.
% @private
-module(ifs_mpd).
-behaviour(gen_server).
-include("../include/ifs.hrl").

-export([
    init/1,
    handle_call/3, 
    handle_cast/2, 
    handle_info/2, 
    terminate/2, 
    code_change/3
]).

-export([
    start_link/1,
    client_subscribtion/2,
    handle_msg/1,
    dump/0
]).

%-record(chan_element, {
    %mod,
    %chans,
    %callback
%}).
%%-------------------------------------------------------------
%% API
%%-------------------------------------------------------------
% @private
start_link(AccessControlMod) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, AccessControlMod, []).

client_subscribtion(Chan, ClientState) ->
    % TODO verify if the client is allowed (see the state) then..
    % now once a client subscribe to any channel he will receive everything
    Chan ! {ifs_subscribe, ClientState},
    gen_server:cast(?MODULE, {new_subscriber, ClientState}),
    true.

handle_msg(Msg) ->
    % TODO send the message only to the subscribed and allowed clients. Now
    % send every messages to every clients.
    gen_server:call(?MODULE, {send, Msg}).

dump() ->
    gen_server:call(?MODULE, dump).
%%-------------------------------------------------------------
%% GEN_SERVER CALLBACKS
%%-------------------------------------------------------------
init(Args) ->
    io:format("~p     jjjjjjjjjj ~p~n", [?MODULE, Args]),
    {ok, []}.

handle_call(dump, _F, S) ->
    {reply, S, S};

handle_call({send, Msg}, _F, S) ->
    lists:foreach(fun(#client_state{module = CMod} = ClientState) ->
        spawn(fun() -> CMod:send(ClientState, Msg) end)
    end, S),
    {reply, S, S};

handle_call(_R, _F, S) ->
    io:format("handle_call ~p~p~n", [?MODULE, _R]),
    {reply, error, S}.

% CAST
handle_cast({new_subscriber, ClientState}, S) ->
    {noreply, [ClientState | S]};

handle_cast(_R, S) ->
    io:format("handle_cast ~p~p~n", [?MODULE, _R]),
    {noreply, S}.

% OTHER
handle_info(_I, S) ->
    {noreply, S}.

terminate(_R, _S) ->
    normal.

code_change(_O, S, _E) ->
    {ok, S}.
