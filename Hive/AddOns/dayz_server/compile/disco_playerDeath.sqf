private["_object","_source","_method","_key","_playerID","_characterID","_playerName"];

_object = _this select 0;
_source = _this select 1;
_method = _this select 2;
_playerName = _object getVariable["BotName","unknown"];
_playerID = _object getVariable["playerID",0]; 
_characterID = _object getVariable["characterID",0];

if (!isNull _source) then {
	if (_source != player) then {
		_canHitFree = _object getVariable ["freeTarget",false];
		_isBandit = (_object getVariable["humanity",0]) <= -2000;
		_wait = 0;
		_humanity = 0;
		if (!_canHitFree and !_isBandit) then {
			_myKills = -1 max (1 - (_object getVariable ["humanKills",0]) / 7);
			_humanity = -2000 * _myKills;
			if (_humanity > 0) then { _wait = 300; };
			_kills = _source getVariable ["humanKills",0];
			_source setVariable ["humanKills",(_kills + 1),true];
		} else {
			_killsV = _source getVariable ["banditKills",0];
			_source setVariable ["banditKills",(_killsV + 1),true];
			_wait = 0;
		};
		if (!_canHitFree and !_isBandit and (_humanity != 0)) then {
			PVDZ_send = [_source,"Humanity",[_source,_humanity,_wait]];
			publicVariableServer "PVDZ_send";
		};
	};
};

_object removeAllEventHandlers "HandleDamage";
_object setDamage 1;
_object switchmove "AmovPercMstpSnonWnonDnon";

_id = [_object,20,true,getPosATL _object] call player_alertZombies;
_id = [_characterID,0,_object,_playerID,_playerName] spawn server_playerDied;

_object setVariable["USEC_isDead",true,true];
_object setVariable ["deathType",_method,true];

PVDZ_Server_Simulation = [_object, false];
publicVariableServer "PVDZ_Server_Simulation";