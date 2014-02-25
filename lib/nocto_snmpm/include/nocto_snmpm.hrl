-define(LOG2(X), io:format("{~p, ~p}: DEBUG: ~p~n", [?MODULE, ?LINE, X])).

-define(SNMPM_USER,         "nocto_snmpm_user").
-define(BULK_MAX_REP,       64).

% MIB2 System tree
-define(OID_SYS_DESCR,      [1,3,6,1,2,1,1,1,0]).
-define(OID_SYS_OBJECT_ID,  [1,3,6,1,2,1,1,2,0]).
-define(OID_SYS_UPTIME,     [1,3,6,1,2,1,1,3,0]).
-define(OID_SYS_CONTACT,    [1,3,6,1,2,1,1,4,0]).
-define(OID_SYS_NAME,       [1,3,6,1,2,1,1,5,0]).
-define(OID_SYS_LOCATION,   [1,3,6,1,2,1,1,6,0]).
-define(OID_SYS_SERVICES,   [1,3,6,1,2,1,1,7,0]).

-record(mib2_system, {
    sys_descr,
    sys_object_id,
    sys_uptime,
    sys_contact,
    sys_name,
    sys_location,
    sys_services
}).

% MIB2 Interface tree
-define(OID_IF_NUMBER,      [1,3,6,1,2,1,2,1]).
-define(OID_IF_TABLE,       [1,3,6,1,2,1,2,2]).
-define(OID_IF_INDEX,       [1,3,6,1,2,1,2,2,1,1]).
-define(OID_IF_DESCR,       [1,3,6,1,2,1,2,2,1,2]).
-define(OID_IF_TYPE,        [1,3,6,1,2,1,2,2,1,3]).
-define(OID_IF_MTU,         [1,3,6,1,2,1,2,2,1,4]).
-define(OID_IF_SPEED,       [1,3,6,1,2,1,2,2,1,5]).
-define(OID_IF_PHYS_ADDRESS,[1,3,6,1,2,1,2,2,1,6]).
-define(OID_IF_ADMIN_STATUS,[1,3,6,1,2,1,2,2,1,7]).
-define(OID_IF_OPER_STATUS ,[1,3,6,1,2,1,2,2,1,8]).
-define(OID_IF_LAST_CHANGE ,[1,3,6,1,2,1,2,2,1,9]).
