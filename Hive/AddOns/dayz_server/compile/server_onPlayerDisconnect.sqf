#include "\z\addons\dayz_server\compile\server_toggle_debug.hpp"
private ["_playerObj","_myGroup","_playerUID","_playerPos","_playerName"];
_playerUID = _this select 0;
_playerName = _this select 1;
_playerObj = nil;
_playerPos = [];
{
	if ((getPlayerUID _x) == _playerUID) exitWith { _playerObj = _x; _playerPos = getPosATL _playerObj;};
} forEach 	playableUnits;

if (isNil "_playerObj") exitWith {
	diag_log format["Player %1 isNil. Probably dead while disconnecting", _this];
};

if (!isNull _playerObj) then {

#ifdef LOGIN_DEBUG
	_characterID = _playerObj getVariable["characterID", "?"];
	_lastDamage = _playerObj getVariable["noatlf4",0];
	_lastDamage = round(diag_ticktime - _lastDamage);
	_notInCombat = _playerObj getVariable["NotInCombat",false];
	_isDead = _playerObj getVariable["processedDeath", 0];
	_hasFlashlight = "ItemFlashlightReduse" in weapons _playerObj;
	_debug = getMarkerpos "respawn_west";
	_distance = _debug distance (getPosATL _playerObj);
	_inDebug = if (_distance < 2000) then { true } else { false };
	_charDir = _character getVariable["lastDir",direction _playerObj];
	_charPos = _character getVariable["lastPos",getPosATL _playerObj];
	
	if (_hasFlashlight) then {
	diag_log format["Player %1 (%2) %3 had a Flashlight attached - deleting!", _playerObj,_playerUID,_characterID];
	_nearbyFlashlights = (getPosATL _playerObj) nearObjects ["pzn_NoSearchLight", 5];
	{deletevehicle _x;} forEach _nearbyFlashlights;
	};
	
	if (_isDead != 0) then {
	diag_log format["Player %1 (%2) %3 logged off - Dead!", _playerObj,_playerUID,_characterID];
	} else {
	diag_log format["Player UID#%1 CID#%2 %3 as %4, logged off at %5%6", 
	getPlayerUID _playerObj, _characterID, _playerObj call fa_plr2str, typeOf _playerObj, 
	(getPosATL _playerObj) call fa_coor2str,
	if ((_lastDamage > 5 AND {(_lastDamage < 30)}) AND {((alive _playerObj) AND {(_playerObj distance (getMarkerpos "respawn_west") >= 2000)})}) then {" while in combat ("+str(_lastDamage)+" seconds left)"} else {""}
	];};
	
	//Update Vehicle
	if (vehicle _playerObj != _playerObj) then {
		_playerObj action ["eject", vehicle _playerObj];
	};
	
	[_playerObj,nil,true,_charDir,_charPos] call server_playerSync;
	
	if (alive _playerObj) then {
	
	if (((!_inDebug) AND (!_notInCombat)) OR ((!_inDebug) AND ((_lastDamage > 5) AND (_lastDamage < 30)))) then {	
		diag_log format["DISCOBOT: Player %1 (%2) %3 In Combat! Spawning Bot!", _playerObj,_playerUID,_characterID];
#endif
		[_playerObj,_playerUID,_characterID,30,_charDir,_charPos] spawn disco_playerMorph;
	} else {
		_myGroup = group _playerObj;
		deleteVehicle _playerObj;
		deleteGroup _myGroup;
		};
	};
	{ [_x,"gear"] call server_updateObject } foreach 
		(nearestObjects [_playerPos, dayzed_updateObjects, 10]);
};