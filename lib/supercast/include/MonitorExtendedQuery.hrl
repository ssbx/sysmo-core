%% Generated by the Erlang ASN.1 compiler version:3.0.1
%% Purpose: Erlang record definitions for each named and unnamed
%% SEQUENCE and SET, and macro definitions for each value
%% definition,in module MonitorExtendedQuery



-ifndef(_MONITOREXTENDEDQUERY_HRL_).
-define(_MONITOREXTENDEDQUERY_HRL_, true).

-record('IpInfo',{
version, stringVal}).

-record('SnmpElementInfoQuery',{
ip, port, timeout, snmpVer, community, v3SecLevel, v3User, v3AuthAlgo, v3AuthKey, v3PrivAlgo, v3PrivKey}).

-record('SnmpElementCreateQuery',{
ip, port, timeout, snmpVer, community, v3SecLevel, v3User, v3AuthAlgo, v3AuthKey, v3PrivAlgo, v3PrivKey, ifSelection}).

-record('QueryProbeForce',{
foo, bar}).

-record('QueryProbeSuspend',{
foo, bar}).

-record('QueryProbeStart',{
foo, bar}).

-record('QueryProbeDelete',{
probe}).

-record('ExtendedQueryFromClient',{
queryId, query}).

-record('SnmpSystemInfo',{
sysDescr, sysObjectId, sysUpTime, sysContact, sysName, sysLocation, sysServices, sysORLastChange}).

-record('SnmpInterfaceInfo',{
ifIndex, ifDescr, ifType, ifMTU, ifSpeed, ifPhysAddress, ifAdminStatus, ifOperStatus, ifLastChange}).

-record('ExtendedQueryFromServer',{
queryId, status, lastPdu, reply}).

-endif. %% _MONITOREXTENDEDQUERY_HRL_