//Animated Helicrashs for DayZ 1.7.6.1
//Compatibility and mods by cyrq
//Version 0.2
//Release Date: 05. April 2013
//Author: Grafzahl
//Thread-URL: http://opendayz.net/threads/animated-helicrashs-0-1-release.9084/

private["_useStatic","_crashDamage","_lootRadius","_preWaypoints","_preWaypointPos","_endTime","_startTime","_safetyPoint","_heliStart","_deadBody","_exploRange","_heliModel","_lootPos","_list","_craters","_dummy","_wp2","_wp3","_landingzone","_aigroup","_wp","_helipilot","_crash","_crashwreck","_smokerand","_staticcoords","_pos","_dir","_position","_num","_config","_itemType","_itemChance","_weights","_index","_iArray","_crashModel","_lootTable","_guaranteedLoot","_randomizedLoot","_frequency","_variance","_spawnChance","_spawnMarker","_spawnRadius","_item","_spawnFire","_permanentFire","_crashName","_sosCahnce","_sosRange"];

//_crashModel	= _this select 0;
//_lootTable	= _this select 1;
_guaranteedLoot = _this select 0;
_randomizedLoot = _this select 1;
_frequency	= _this select 2;
_variance	= _this select 3;
_spawnChance	= _this select 4;
_spawnMarker	= _this select 5;
_spawnRadius	= _this select 6;
_spawnFire	= _this select 7;
_fadeFire	= _this select 8;
_sosChance	= 60;
_sosRange	= 8000;

if(count _this > 9) then {
	_useStatic = _this select 9;
} else {
	_useStatic = false;
};

if(count _this > 10) then {
	_preWaypoints	= _this select 10;
} else {
	_preWaypoints = 1;
};

if(count _this > 11) then {
	_crashDamage = _this select 11;
} else {
	_crashDamage = 1;
};

diag_log(format["CRASHSPAWNER: Starting spawn logic for animated helicrashs - written by Grafzahl [SC:%1||PW:%2||CD:%3]", str(_useStatic), str(_preWaypoints), _crashDamage]);

while {true} do {
	private["_timeAdjust","_timeToSpawn","_spawnRoll","_crash","_hasAdjustment","_newHeight","_adjustedPos"];
	// Allows the variance to act as +/- from the spawn frequency timer
	_timeAdjust = round(random(_variance * 2) - _variance);
	_timeToSpawn = time + _frequency + _timeAdjust;

	//Random Heli-Type
	_heliModel = ["UH1H_DZ","Mi17_DZ","Chinook_CH47F","MV22"] call BIS_fnc_selectRandom;
	_plane = false;

	//Random-Startpositions, Adjust this for other Maps then Chernarus
	_heliStart = [[6986,-630,2000],[10450,-630,2000]] call BIS_fnc_selectRandom;

	//A Backup Waypoint, if not Chernarus, set some Coordinates far up in the north (behind all possible Crashsites)
	_safetyPoint = [0,16000,0];

	// Adjust Wreck and Range of Explosion if its a UH1H_DZ
	if(_heliModel == "UH1H_DZ") then {
		_crashModel = "UH1Wreck_DZ";
		_exploRange = 195;
		_lootRadius = 0.35;
	};

	// Adjust Wreck and Range of Explosion if its a Mi17_DZ
	if(_heliModel == "Mi17_DZ") then {
		_crashModel = "Mi8Wreck_DZ";
		_exploRange = 285;
		_lootRadius = 0.3;
	};
	
	// Adjust Wreck and Range of Explosion if its a MV22
	if(_heliModel == "MV22") then {
		_crashModel = "MV22Wreck_DZed";
		_exploRange = 360;
		_lootRadius = 0.4;
	};
	
	// Adjust Wreck and Range of Explosion if its a Chinook_CH47F
	if(_heliModel == "Chinook_CH47F") then {
		_crashModel = "Chinook_CH47FWreck_DZed";
		_exploRange = 360;
		_lootRadius = 0.45;
		_plane = true;
	};

	//Crash loot
	if (_crashModel == "Mi8Wreck_DZ") then {_lootTable = "HeliCrashEAST";};
	if (_crashModel == "MV22Wreck_DZed") then {_lootTable = "HeliCrashMED";};
	if (_crashModel == "UH1Wreck_DZ") then {_lootTable = "HeliCrashWEST";};	
	if (_crashModel == "Chinook_CH47FWreck_DZed") then {_lootTable = "HeliCrashUS";};

	_crashName	= getText (configFile >> "CfgVehicles" >> _heliModel >> "displayName");

	diag_log(format["CRASHSPAWNER: %1%2 chance to start a crashing %3 with loot table '%4' at %5", round(_spawnChance * 100), '%', _crashName, _lootTable, _timeToSpawn]);

	// Apprehensive about using one giant long sleep here given server time variances over the life of the server daemon
	while {time < _timeToSpawn} do {
		sleep 5;
	};

	_spawnRoll = random 1;

	// Percentage roll
	if (_spawnRoll <= _spawnChance) then {

		_position = [getMarkerPos _spawnMarker,0,_spawnRadius,10,0,2000,0] call BIS_fnc_findSafePos;

		diag_log(format["CRASHSPAWNER: %1 started flying from %2 to %3 NOW!(TIME:%4||LT:%5)", _crashName,  str(_heliStart), str(_position), round(time), _lootTable]);
		
		_startTime = time;
		
		//Only a Woman could crash a Heli this way...
		_aigroup = creategroup civilian;
		_helipilot = _aigroup createUnit ["SurvivorW2_DZ",[15435.778,15212.795,0],[],0,"FORM"];
		_helipilot setVariable["Sarge",1];

		//Spawn the AI-Heli flying in the air
		waitUntil {alive _helipilot};
		
		_crashwreck = createVehicle [_heliModel,_heliStart, [], 0, "FLY"];
		_helipilot setPos (getPos _crashwreck);
		_helipilot moveindriver _crashwreck;
		_helipilot assignAsDriver _crashwreck;

		//Make sure its not destroyed by the Hacker-Killing-Cleanup (Thanks to Sarge for the hint)
		_crashwreck setVariable["Sarge",1];
		_crashwreck setCombatMode "BLUE";
		_crashwreck engineOn true;
		_crashwreck lock true;
		if (_plane) then {
			_crashwreck flyInHeight 110;
			_crashwreck forceSpeed 100;
			_crashwreck setspeedmode "LIMITED";
		} else {
			_crashwreck flyInHeight 120;
			_crashwreck forceSpeed 110;
			_crashwreck setspeedmode "NORMAL";
		};

		//Create an Invisibile Landingpad at the Crashside-Coordinates
		_landingzone = createVehicle ["HeliHEmpty", [_position select 0, _position select 1,0], [], 0, "CAN_COLLIDE"];
		_landingzone setVariable["Sarge",1];

		sleep 0.5;

		if(_preWaypoints > 0) then {
			for "_x" from 1 to _preWaypoints do {
				_preWaypointPos = [getMarkerPos _spawnMarker,0,_spawnRadius,10,0,2000,0] call BIS_fnc_findSafePos;
				diag_log(format["CRASHSPAWNER: Adding Pre-POC-Waypoint #%1 on %2", _x,str(_preWaypointPos)]);
				_wp = _aigroup addWaypoint [_preWaypointPos, 0];
				_wp setWaypointType "MOVE";
				_wp setWaypointBehaviour "CARELESS";
			};
		};

		_wp2 = _aigroup addWaypoint [position _landingzone, 0];
		_wp2 setWaypointType "MOVE";
		_wp2 setWaypointBehaviour "CARELESS";

		//Even when the Heli flys to high, it will burn when reaching its Waypoint
		_wp2 setWaypointStatements ["true", "_crashwreck setdamage 1;"];

		//Adding a last Waypoint up in the North, so the Heli doesnt Hover at WP1 (OR2)
		//and would also come back to WP1 if somehow it doesnt explode.
		_wp3 = _aigroup addWaypoint [_safetyPoint, 0];
		_wp3 setWaypointType "CYCLE";
		_wp3 setWaypointBehaviour "CARELESS";

		//Get some more Speed when close to the Crashpoint and go on even if Heli died or hit the ground
		waituntil {(_crashwreck distance _position) <= 1000 || not alive _crashwreck || (getPosATL _crashwreck select 2) < 5 || (damage _crashwreck) >= _crashDamage};
		if (_plane) then {
			_crashwreck flyInHeight 100;
			_crashwreck forceSpeed 110;
			_crashwreck setspeedmode "LIMITED";
		} else {
			_crashwreck flyInHeight 110;
			_crashwreck forceSpeed 120;
			_crashwreck setspeedmode "NORMAL";
		};
		//BOOOOOOM!
			waituntil {(_crashwreck distance _position) <= _exploRange || not alive _crashwreck || (getPosATL _crashwreck select 2) < 5 || (damage _crashwreck) >= _crashDamage};
		if (_plane) then {
			_crashwreck setdamage 1;
			_crashwreck setfuel 0;
			_helipilot setdamage 1;
			_vel = velocity _crashwreck;
			_dir = direction _crashwreck;
			_speed = 100;
			_crashwreck setVelocity [(_vel select 0)-(sin _dir*_speed),(_vel select 1)-(cos _dir*_speed),(_vel select 2) - 30];
		} else {
			_crashwreck setHit ["mala vrtule", 1];
			_crashwreck setfuel 0;
			_ran15 = random 15;
			_crashwreck setVelocity [_ran15,_ran15,-25];
			_crashwreck setdamage .9;
			waitUntil{sleep 1; getpos _crashwreck select 2 <= 30};
			_helipilot setdamage 1;
			_crashwreck setVelocity [_ran15,_ran15,-20];
			waitUntil{sleep 1; getpos _crashwreck select 2 <= 10};
			_crashwreck setdamage 1;
		};
		waitUntil{sleep 1; getpos _crashwreck select 2 <= 5};
		diag_log(format["CRASHSPAWNER: %1 just exploded at %2! (In Water?: %3)", _crashName, str(getPosATL _crashwreck),str(surfaceIsWater getPos _crashwreck)]);
		//Get position of the helis wreck, but make sure its on the ground;
		_pos = [getpos _crashwreck select 0, getpos _crashwreck select 1,0];

		//saving the direction of the wreck(not used right now)
		_dir = getdir _crashwreck; 

		//Send Public Variable so every client can delete the craters around the new Wreck (musst be added in init.sqf)
		heliCrash = _pos;
		publicVariable "heliCrash";
		
		//Send SOS
		if ((_sosChance >= random 100) && !surfaceIsWater _pos) then {
		sendSOS = true;
		diag_log(format["CRASHSPAWNER: %1 will send a SOS signal!", _crashName]);
		} else {
		sendSOS = false;
		};
		
		dayzAnimCrash = [_pos,_heliModel,sendSOS,_sosRange];
		publicVariable "dayzAnimCrash";
		
		//Clean Up the Crashsite
		deletevehicle _crashwreck;
		deletevehicle _helipilot;
		deleteGroup _aigroup;
		deletevehicle _landingzone;

		//Animation is done, lets create the actual Crashside
		_crash = createVehicle [_crashModel, _pos, [], 0, "CAN_COLLIDE"];
		_crash setVariable["Sarge",1];
		
		_config = configFile >> "CfgVehicles" >> _crashModel >> "heightAdjustment";
        _hasAdjustment =  isNumber(_config);
        _newHeight = 0;
        if (_hasAdjustment) then {
           _newHeight = getNumber(_config);
        };	
		
		_adjustedPos = [(_pos select 0), (_pos select 1), _newHeight];
        _crash setPos _adjustedPos;

		// I don't think this is needed (you can't get "in" a crash), but it was in the original DayZ Crash logic
		dayz_serverObjectMonitor set [count dayz_serverObjectMonitor,_crash];

		_crash setVariable ["ObjectID",1,true];

		//Make it burn (or not)
		if (_spawnFire) then {
				PVDZ_obj_Fire = [_crash,3,time,false,_fadeFire];
                publicVariable "PVDZ_obj_Fire";
                _crash setvariable ["fadeFire",_fadeFire,true];
		};
 
		//Creating the Lootpiles outside of the _crashModel
		for "_x" from ((round(random _randomizedLoot)) + _guaranteedLoot) to 1 step -1  do {
		//Create loot
		_itemTypes = [] + getArray (configFile >> "CfgBuildingLoot" >> _lootTable >> "lootType");
		_CBLBase = dayz_CBLBase find _lootTable;
		_weights = dayz_CBLChances select _CBLBase;
		_cntWeights = count _weights;
		_index1 = floor(random _cntWeights);
		_index2 = _weights select _index1;
		_itemType = _itemTypes select _index2;
	 
		//Let the Loot spawn in a non-perfect circle around _crashModel
		_lootPos = [_pos, ((random 2) + (sizeOf(_crashModel) * _lootRadius)), random 360] call BIS_fnc_relPos;
		_item = [_itemType select 0, _itemType select 1, _lootpos, 1] call spawn_loot;
	 
		diag_log(format["CRASHSPAWNER: Loot spawn at '%2' with loot table '%3'. Loot = '%1'",_itemType, _lootPos, _lootTable]); 
	 
		// ReammoBox is preferred parent class here, as WeaponHolder wouldn't match MedBox0 and other such items.
		_nearby = _pos nearObjects ["ReammoBox", sizeOf(_crashModel)];
		{
			_x setVariable ["permaLoot",true];
		} forEach _nearBy;
	};

		//Adding 5 dead soldiers around the wreck, poor guys
		for "_x" from 1 to 5 do {
			_lootPos = [_pos, ((random 4)+3), random 360] call BIS_fnc_relPos;
			_deadBody = createVehicle[["Body1","Body2"] call BIS_fnc_selectRandom,_lootPos,[], 0, "CAN_COLLIDE"];
			_deadBody setDir (random 360);
		};
		_endTime = time - _startTime;
		diag_log(format["CRASHSPAWNER: Crash completed! Wreck near: %2 - Runtime: %1 Seconds || Distance from calculated POC: %3 meters", round(_endTime), (_pos call fa_coor2str), round(_position distance _crash)]); 
	};
};