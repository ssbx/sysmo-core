% This file is part of "Enms" (http://sourceforge.net/projects/enms/)
% Copyright (C) 2012 <Sébastien Serre sserre.bx@gmail.com>
% 
% Enms is a Network Management System aimed to manage and monitor SNMP
% target, monitor network hosts and services, provide a consistent
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
-module(btracker_probe_nagios_compat).
-behaviour(beha_tracker_probe).
-include("../../include/tracker.hrl").

-export([
    exec/1,
    info/0
]).

exec({  
        #target{
            directory           = Dir
        } = Target, 
        #probe{
            name                = Name, 
            id                  = ProbeId,
            tracker_probe_conf  = #nagios_plugin{
                executable  = Exec,
                args        = Args
            }
        } = Probe
    }) ->
    FileName    = io_lib:format("~s-~.10B~s", [Name, ProbeId, ".stdout"]),
    StdoutFile  = filename:absname_join(Dir, FileName),

    Command = lists:foldl(fun({Flag, Value}, Acc) ->
        case is_list(Value) of
            true    ->
                lists:concat([Acc, " ", Flag, " ", Value]);
            false   ->
                lists:concat([Acc, " ", Flag, " ", get_val(Value, Target, Probe)])
        end
    end, Exec, Args),
    
    Id = self(),
    spawn(fun() ->
        process_flag(trap_exit, true),
        exec:run_link(Command, 
                [{stdout, StdoutFile}]),
        receive
            A -> Id ! A
        end
    end),

    receive
        {_, _, {exit_status, Val}} -> 
            case exec:status(Val) of
                {status, 0} ->
                    {'OK',          eval_nagout(StdoutFile)};
                {status, 1} ->
                    {'WARNING',     eval_nagout(StdoutFile)};
                {status, 2} ->
                    {'CRITICAL',    eval_nagout(StdoutFile)};
                {status, 3} ->
                    {'UNKNOWN',     eval_nagout(StdoutFile)};
                Any -> 
                    io:format("Unknown return status~p~n", [Any])
            end;
        Any ->
            io:format("Not an exit_status msg~p~n" , [Any])
    end.


info() ->
    {ok, "Nagios compat probe module"}.

% @private
get_val({target, {properties, ip}}, #target{properties = Props}, _) ->
    {ip, Val} = lists:keyfind(ip, 1, Props),
    tracker_misc:ip_format(v4_to_string, Val);

% @private
get_val({probe, timeout}, _, #probe{timeout = Timeout}) ->
    lists:flatten(io_lib:format("~.10B", [Timeout])).

% @private
eval_nagout(File) ->
    {ok, BinaryData}    = file:read_file(File),
    FullData            = erlang:binary_to_list(BinaryData),

    % separate text from perf data. foldr/3 to keep the TextOut order.
    {TextOut, PerfLines} = lists:foldr(fun(X, {TextOut, Perfs}) ->
        case string:tokens(X, "|") of
            [Text] ->
                {[Text | TextOut], Perfs};
            [Text, Perf] ->
                {[Text | TextOut], [Perf | Perfs]}
        end
    end, {[], []}, string:tokens(FullData, "\n")),

    % generate a list of perfs from lines
    PerfStringList = lists:foldl(fun(PerfLine, Acc) ->
        PerfsOnLine = string:tokens(PerfLine, " "),
        lists:append(PerfsOnLine, Acc)
    end, [], PerfLines),

    % generate [#nagios_perf_data{}]
    PerfDatas   = lists:foldl(fun(PerfElement, Acc) ->
        PerfDataList = string:tokens(PerfElement, ";"),
        case PerfDataList of
            [LabelValue, Warn, Crit, Min, Max] ->
                [Label, ValueUom]   = string:tokens(LabelValue, "="),
                {ok, {Value, Uom}}  = tracker_misc:extract_nag_uom(ValueUom),
                [#nagios_perf_data{
                    label   = Label,
                    uom     = Uom,
                    value   = to_number(Value),
                    warn    = to_number(Warn),
                    crit    = to_number(Crit),
                    min     = to_number(Min),
                    max     = to_number(Max)
                }   | Acc];
            [LabelValue, Warn, Crit, Min] ->
                [Label, ValueUom] = string:tokens(LabelValue, "="),
                {ok, {Value, Uom}}  = tracker_misc:extract_nag_uom(ValueUom),
                [#nagios_perf_data{
                    label   = Label,
                    uom     = Uom,
                    value   = to_number(Value),
                    warn    = to_number(Warn),
                    crit    = to_number(Crit),
                    min     = to_number(Min)
                }   | Acc];
            [LabelValue, Warn, Crit] ->
                [Label, ValueUom] = string:tokens(LabelValue, "="),
                {ok, {Value, Uom}}  = tracker_misc:extract_nag_uom(ValueUom),
                [#nagios_perf_data{
                    label   = Label,
                    uom     = Uom,
                    value   = to_number(Value),
                    warn    = to_number(Warn),
                    crit    = to_number(Crit)
                }   | Acc];
            [LabelValue, Warn] ->
                [Label, ValueUom] = string:tokens(LabelValue, "="),
                {ok, {Value, Uom}}  = tracker_misc:extract_nag_uom(ValueUom),
                [#nagios_perf_data{
                    label   = Label,
                    uom     = Uom,
                    value   = to_number(Value),
                    warn    = to_number(Warn) 
                }   | Acc];
            [LabelValue] ->
                [Label, ValueUom] = string:tokens(LabelValue, "="),
                {ok, {Value, Uom}}  = tracker_misc:extract_nag_uom(ValueUom),
                [#nagios_perf_data{
                    label   = Label,
                    uom     = Uom,
                    value   = to_number(Value)
                }   | Acc]
        end
    end, [], PerfStringList),

    #nagios_plugin_return{
        text_out        = TextOut,
        perfs           = PerfDatas,
        original_output = FullData
    }.

to_number(String) ->
    to_number(String, [list_to_float, list_to_integer]).

to_number(String, []) ->
    String;

to_number(String, [ToSomething | T]) ->
    case (catch erlang:ToSomething(String)) of
        {'EXIT', _} ->
            to_number(String, T);
        Other ->
            Other
    end.
