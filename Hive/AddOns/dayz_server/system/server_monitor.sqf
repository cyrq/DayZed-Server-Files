private ["_date","_year","_month","_day","_hour","_minute","_date1","_hiveResponse","_key","_objectCount","_dir","_point","_i","_action","_dam","_selection","_wantExplosiveParts","_entity","_worldspace","_damage","_booleans","_rawData","_ObjectID","_class","_CharacterID","_inventory","_hitpoints","_fuel","_id","_objectArray","_script","_result","_outcome"];

[]execVM "\z\addons\dayz_server\system\s_fps.sqf"; //server monitor FPS (writes each ~181s diag_fps+181s diag_fpsmin*)
#include "\z\addons\dayz_server\compile\server_toggle_debug.hpp"

dayz_versionNo = getText(configFile >> "CfgMods" >> "DayZ" >> "version");
dayz_hiveVersionNo = getNumber(configFile >> "CfgMods" >> "DayZ" >> "hiveVersion");

waitUntil {initialized}; //means all the functions are now defined

diag_log "HIVE: Starting";

//Set the Time
_key = "CHILD:307:";
_result = _key call server_hiveReadWrite;
_outcome = _result select 0;
if(_outcome == "PASS") then {
	_date = _result select 1;
	_year = _date select 0;
	_month = _date select 1;
	 _day = _date select 2;
	_hour = _date select 3;
	_minute = _date select 4;
	//Force full moon nights
	_date1 = [2013,8,3,_hour,_minute];
		if(isDedicated) then {
			setDate _date1;
			dayzSetDate = _date1;
			dayz_storeTimeDate = _date1;
			publicVariable "dayzSetDate";
		};
	diag_log ("HIVE: Local Time set to " + str(_date1));
};
		
//Save Weather Data
_rain = drn_var_DynamicWeather_Rain;
_windx = drn_DynamicWeather_WindX;
_windz = drn_DynamicWeather_WindZ;
_overcast = overcast;
_fog = fog;

_rainkey = format ["CHILD:999:UPDATE `weather` SET `rain` = %1 LIMIT 1:[]:",_rain];
_rainkey call server_hiveWrite;
_windxkey = format ["CHILD:999:UPDATE `weather` SET `windx` = %1 LIMIT 1:[]:",_windx];
_windxkey call server_hiveWrite;
_windzkey = format ["CHILD:999:UPDATE `weather` SET `windz` = %1 LIMIT 1:[]:",_windz];
_windzkey call server_hiveWrite;
_overcastkey = format ["CHILD:999:UPDATE `weather` SET `overcast` = %1 LIMIT 1:[]:",_overcast];
_overcastkey call server_hiveWrite;
_fogkey = format ["CHILD:999:UPDATE `weather` SET `fog` = %1 LIMIT 1:[]:",_fog];
_fogkey call server_hiveWrite;
		
diag_log format["WEATHER: WEATHER DATA UPDATED: RAIN: %1, WINDX: %2, WINDZ: %3, OVERCAST %4, FOG: %5", _rain, _windx, _windz, _overcast, _fog];

waituntil{isNil "sm_done"}; // prevent server_monitor be called twice (bug during login of the first player)

if (isServer and isNil "sm_done") then {
        
//Stream in objects
_key = format["CHILD:302:%1:",dayZ_instance];
_result = _key call server_hiveReadWrite;
diag_log "HIVE: Request sent";
//Process result
_status = _result select 0;
_myArray = [];
	if (_status == "ObjectStreamStart") then {
		_val = _result select 1;
		//Stream Objects
		diag_log ("HIVE: Commence Object Streaming...");
		for "_i" from 1 to _val do {
			_result = _key call server_hiveReadWrite;
			_status = _result select 0;
			_myArray set [count _myArray,_result];
		};
		diag_log ("HIVE: Streamed " + str(_val) + " objects");
	};
_countr = 0;                
{
//Parse Array
_countr = _countr + 1;
                        
_action = 		_x select 0;
_idKey =		_x select 1;
_type =			if ((typeName (_x select 2)) == "STRING") then { _x select 2 };
_ownerID =		_x select 3;
_worldspace =	if ((typeName (_x select 4)) == "ARRAY") then { _x select 4 } else { [] };
_inventory =	if ((typeName (_x select 5)) == "ARRAY") then { _x select 5 } else { [] };
_hitPoints =	if ((typeName (_x select 6)) == "ARRAY") then { _x select 6 } else { [] };
_fuel =			if ((typeName (_x select 7)) == "SCALAR") then { _x select 7 } else { 0 };
_damage =		if ((typeName (_x select 8)) == "SCALAR") then { _x select 8 } else { 0.9 };        
_dir = 			floor(random(360));
_pos = 			getMarkerpos "respawn_west";
_wsDone = 		false;

if (count _worldspace >= 1 && {(typeName (_worldspace select 0)) == "SCALAR"}) then { 
	_dir = _worldspace select 0;
};
                        
if (count _worldspace == 2 && {(typeName (_worldspace select 1)) == "ARRAY"}) then { 
	_i = _worldspace select 1;
		if (count _i == 3 &&
		{(typeName (_i select 0)) == "SCALAR"} && 
		{(typeName (_i select 1)) == "SCALAR"} &&
		{(typeName (_i select 2)) == "SCALAR"}) then {
			_pos = _i;
			_wsDone = true;                        
		};
	};
                        
if (!_wsDone) then {
	_pos = [getMarkerPos "center",0,30,10,0,2000,0] call BIS_fnc_findSafePos;
		if (count _pos < 3) then { _pos = [_pos select 0,_pos select 1,0]; };
			diag_log ("MOVED OBJ: " + str(_idKey) + " of class " + _type + " to pos: " + str(_pos));
		};

if (_damage < 1) then {									 
	dayz_nonCollide = ["DomeTentStorage","TentStorage","CamoNet_DZ"];
	//Create it
	_object = createVehicle [_type, _pos, [], 0, if (_type in dayz_nonCollide) then {"NONE"} else {"CAN_COLLIDE"}];
	_object setVariable ["lastUpdate",time];
	// Don't set objects for deployables to ensure proper inventory updates
	if (_ownerID == "0") then {
		_object setVariable ["ObjectID", str(_idKey), true];
	} else {
		_object setVariable ["ObjectUID", _worldspace call dayz_objectUID2, true];
	};
	_object setVariable ["CharacterID", _ownerID, true];		 
	_object setdir _dir;
	_object setDamage _damage;
	//Dont add inventory for traps.
	if (!(_object isKindOf "TrapItems")) then {
		_cargo = _inventory;
		clearWeaponCargoGlobal  _object;
		clearMagazineCargoGlobal  _object;
		clearBackpackCargoGlobal  _object;         
		_config = ["CfgWeapons", "CfgMagazines", "CfgVehicles" ];
		{
		_magItemTypes = _x select 0;
		_magItemQtys = _x select 1;
		_i = _forEachIndex;
			{    
				if (_x == "Crossbow") then { _x = "Crossbow_DZ" };
				if (_x == "BoltSteel") then { _x = "WoodenArrow" };
				if (isClass(configFile >> (_config select _i) >> _x) &&
				getNumber(configFile >> (_config select _i) >> _x >> "stopThis") != 1) then {
					if (_forEachIndex < count _magItemQtys) then {
						switch (_i) do {
							case 0: { _object addWeaponCargoGlobal [_x,(_magItemQtys select _forEachIndex)]; };
							case 1: { _object addMagazineCargoGlobal [_x,(_magItemQtys select _forEachIndex)]; };
							case 2: { _object addBackpackCargoGlobal [_x,(_magItemQtys select _forEachIndex)]; };
						};
					};
				};
			} forEach _magItemTypes;
		} forEach _cargo;
	};
                                
	if (_object isKindOf "AllVehicles") then {
	{
		_selection = _x select 0;
		_dam = _x select 1;
			if (_selection in dayZ_explosiveParts and _dam > 0.8) then {
				_dam = 0.8
			};
		[_object,_selection,_dam] call fnc_veh_setFixServer;
	} forEach _hitpoints;
	_object setvelocity [0,0,1];
	_object setFuel _fuel;
	_object call fnc_veh_ResetEH;
	//Mounted Slots
	_object setVehicleInit format['
	this setVehicleVarname "%1";
	%1 = this;
	mounted_actions_init = if (isNil "mounted_actions_init") then { [] } else {mounted_actions_init};
	mounted_actions_init = mounted_actions_init + [%1];
	[%1] call mounted_add_actions;
	',_type];
	processInitCommands;
	_vehiclesTurrets = ["UH1H_DZ","UH1H_DZ2","Mi17_DZ","UAZ_MG_CDF_DZed","Offroad_DSHKM_Gue_DZed"];
	if (_type in _vehiclesTurrets) then {
		_turret = getArray (configFile >> "CfgVehicles" >> _type >> "Turrets" >> "MainTurret" >> "weapons");
		if ((count _turret) > 0) then {_turret = _turret select 0;};
		_mag = getArray (configFile >> "CfgWeapons" >> _turret >> "magazines");
		if ((count _mag) > 0) then {_mag = _mag select 0;};
		_size = getNumber (configFile >> "CfgMagazines" >> _mag >> "count");
		_rnd = round(random (_size - (_size / 2)));
		_percentage = (_rnd / _size);
		_object setVehicleAmmo _percentage;
		diag_log format ["HIVE: %1 AMMO (%2) HAS BEEN SET TO %3, WHICH IS %4 PERCENT OF MAX (%5)",_type,_mag,_rnd,(_percentage * 100),_size];
	};
	} else { 
	if (_type in SafeObjects) then {
		if (_object isKindOf "TentStorage" || _object isKindOf "CamoNet_DZ" || _object isKindOf "Land_A_tent" || _object isKindOf "StorageBox") then {
			_pos set [2,0];
			_object setPosATL _pos;
			_object addMPEventHandler ["MPKilled",{_this call vehicle_handleServerKilled;}];
		};                        
		if (_object isKindOf "TrapItems") then {
			_object setVariable ["armed", _inventory select 0, false];
		};
	} else {
		_damage = 1;
		_object setDamage _damage;
		diag_log format["OBJ: %1 - %2 REMOVED", _object,_damage];
	};
};
//Monitor the object
dayz_serverObjectMonitor set [count dayz_serverObjectMonitor,_object];
};
sleep 0.01;
} forEach _myArray;

createCenter civilian;
if (isDedicated) then {
	endLoadingScreen;
};

if (isDedicated) then {
	_id = [] execFSM "\z\addons\dayz_server\system\server_cleanup.fsm";
};

allowConnection = true;

nul = [
	4,        //Number of the guaranteed Loot-Piles at the Crashside
	1,        //Number of the random Loot-Piles at the Crashside 3+(1,2,3 or 4)
	1600,     //Fixed-Time (in seconds) between each start of a new Chopper
	400,      //Random time (in seconds) added between each start of a new Chopper
	0.8,        //Spawnchance of the Heli (1 will spawn all possible Choppers, 0.5 only 50% of them)
	'center', //Center-Marker for the Random-Crashpoints, for Chernarus this is a point near Stary
	5000,     //Radius in Meters from the Center-Marker in which the Choppers can crash and get waypoints
	true,     //Should the spawned crashsite burn (at night) & have smoke?
	false,    //Should the flames & smoke fade after a while?
	false,    //Use the Static-Crashpoint-Function? If true, you have to add Coordinates into server_spawnCrashSite.sqf
	2,        //Amount of Random-Waypoints the Heli gets before he flys to his Point-Of-Crash (using Static-Crashpoint-Coordinates if its enabled)
	0.8         //Amount of Damage the Heli has to get while in-air to explode before the POC. (0.0001 = Insta-Explode when any damage//bullethit, 1 = Only Explode when completly damaged)
	] spawn server_spawnCrashSite;
	
dayz_Plantspawner = [] spawn {
	[300] call server_plantSpawner;
};
	
[] spawn server_spawnVehicles;

// antiwallhack
call compile preprocessFileLineNumbers "\z\addons\dayz_server\compile\fa_antiwallhack.sqf";

sm_done = true;
publicVariable "sm_done";

// Trap loop
[] call {
	private ["_array","_array2","_array3","_script","_armed"];
	_array = str dayz_traps;
	_array2 = str dayz_traps_active;
	_array3 = str dayz_traps_trigger;

		while { true } do {
			if ((str dayz_traps != _array) || (str dayz_traps_active != _array2) || (str dayz_traps_trigger != _array3)) then {
				_array = str dayz_traps;
				_array2 = str dayz_traps_active;
				_array3 = str dayz_traps_trigger;
			
				diag_log "DEBUG: traps";
				diag_log format["dayz_traps (%2) -> %1", dayz_traps, count dayz_traps];
				diag_log format["dayz_traps_active (%2) -> %1", dayz_traps_active, count dayz_traps_active];
				diag_log format["dayz_traps_trigger (%2) -> %1", dayz_traps_trigger, count dayz_traps_trigger];
				diag_log "DEBUG: end traps";
			};

			{
				if (isNull _x) then {
					dayz_traps = dayz_traps - [_x];
				};

				_script = call compile getText (configFile >> "CfgVehicles" >> typeOf _x >> "script");
				_armed = _x getVariable ["armed", false];

				if (_armed) then {
					if !(_x in dayz_traps_active) then {
						["arm", _x] call _script;
					};
				} else {
					if (_x in dayz_traps_active) then {
						["disarm", _x] call _script;
					};
				};
			} forEach dayz_traps;
			sleep 1;
		};
	};
};