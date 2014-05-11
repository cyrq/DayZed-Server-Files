private["_unit"];
_unit = _this select 0;
_nearby = (getPosATL _unit) nearEntities ["CAManBase",300];
#include "\z\addons\dayz_server\compile\server_toggle_debug.hpp"

#ifdef SERVER_DEBUG
if ({isPlayer _x} count (_nearby) > 0) then {
	_owner = _nearby select 0;
	PVDZ_Server_changeOwner = [_unit, _owner];
	publicVariableServer "PVDZ_Server_changeOwner";
} else {
	deleteVehicle _unit;
	//diag_log ("CLEANUP: DELETE UNCONTROLLED ZOMBIE: " + (typeOf _unit) + " OF: " + str(_unit) );
	#endif
};