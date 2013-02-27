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
-module(clifs).
-behaviour(gen_server).

-export([
    init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

-compile(export_all).

-record(clifs_state, {
            sock,
            roles =  [],
            static_chans = [],
            user_name
        }).

s() ->
    start_link().

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

% log in
log_in(UserName, PassWord) ->
    gen_server:cast(?MODULE, {log_in, UserName, PassWord}).

% shortcut
adm() ->
    gen_server:cast(?MODULE, {log_in, "admuser", "passwd"}).

% subscribe to module
subscribe(Modules) ->
    gen_server:cast(?MODULE, {subscribe, Modules}).

unsubscribe(Modules) ->
    gen_server:cast(?MODULE, {unsubscribe, Modules}).

% subscribe to module
subscribe_chan(Mod, Chan) ->
    gen_server:cast(?MODULE, {subscribe_chan, Mod, Chan}).

unsubscribe_chan(Mod, Chan) ->
    gen_server:cast(?MODULE, {unsubscribe_chan, Mod, Chan}).

add_v2_agent(Ip, Community) ->
    gen_server:cast(?MODULE, {add_v2_agent, Ip, Community}).

init([]) ->
    io:format("clifs starting..."),
    application:start(crypto),
    application:start(public_key),
    application:start(ssl),

    case ssl:connect("localhost", 4443, [binary, {packet, 2}], infinity) of
        {ok, S} -> 
            io:format("clifs started...\n"), 
            {ok, #clifs_state{sock = S}};
        Other   ->
            io:format("clifs error ~p~n",[Other]),
            error
    end.

handle_call(_R, _F, S) ->
    {noreply, S}.


%% TO SERVER
% ifsPDU
handle_cast({log_in, UserName, PassWord}, S) ->
    send_pdu({modIfPDU, {fromClient, {authResp, 
                {'AuthResp', UserName, PassWord}}}}, S),
    {noreply, S};

handle_cast({subscribe, Modules}, S) ->
    send_pdu({modIfPDU, {fromClient, {subscribe, Modules}}}, S),
    {noreply, S};

handle_cast({unsubscribe, Modules}, S) ->
    send_pdu({modIfPDU, {fromClient, {unsubscribe, Modules}}}, S),
    {noreply, S};

handle_cast({subscribe_chan, Module, Chan}, S) ->
    send_pdu({modIfPDU, {fromClient, 
        {subscribeChan, {'ChanId', Module, Chan}}}}, S),
    {noreply, S};

handle_cast({unsubscribe_chan, Module, Chan}, S) ->
    send_pdu({modIfPDU, {fromClient, 
        {unsubscribeChan, {'ChanId', Module, Chan}}}}, S),
    {noreply, S};

% snmpPDU
handle_cast({add_v2_agent, Ip, Community}, S) ->
    send_pdu({modEsnmpPDU, {fromClient, {registerV2Agent, 
        {'RegV2Agent', Ip, "default", Community, "default"}}}}, S),
    {noreply, S};


%% FROM SERVER
handle_cast({modIfPDU, {fromServer, {authReq, ldap}}}, S) ->
    {noreply, S};

handle_cast({modIfPDU, {fromServer, {authAck, 
        {'AuthAck', Roles, StaticChans}}}}, S) ->
    % subscribe to all static chans
    io:format("lllllllllllllllllllllaaaaaaaaaaaa~n"),
    lists:foreach(fun({_,X,_}) ->
        send_pdu({modIfPDU, {fromClient, {staticSubscribe, X}}}, S)
    end, StaticChans),
    {noreply, S#clifs_state{roles = Roles, static_chans = StaticChans}};


%% DEFAULT
handle_cast(Any, S) ->
    io:format("handle_cast ~p received ~p~n", [?LINE, Any]),
    {noreply, S}.


%% INFO
handle_info({ssl, _, BinPdu}, S) ->
    {ok, AsnPdu} = 'NmsPDU':decode('PDU', BinPdu),
    io:format("RECEIVED: ~p~n",[AsnPdu]),
    gen_server:cast(?MODULE, AsnPdu),
    {noreply, S};

handle_info(Info, S) ->
    io:format("handle_info~p~n",[Info]),
    {noreply, S}.

terminate(_R, _S) ->
    normal.

code_change(_O, S, _E) ->
    {ok, S}.


%% PRIVATE
send_pdu(PDU, S) ->
    {ok, B} = 'NmsPDU':encode('PDU', PDU),
    io:format("SENDING: ~p~n", [PDU]),
    ssl:send(S#clifs_state.sock, B).
