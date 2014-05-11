/*
server_spawnVehicles.sqf
Author: cyrq (cyrq1337@gmail.com).
Made for DayZed: http://dayzed.eu
 
Thanks to DayZ Epoch for the positioning code: http://epochmod.com/
 
You can use, modify and distribute this without any permissions.
Give credit where credit is due.
 
Description: Spawns Vehicles with random Damage, Loot and Position around the map.
Uses the 999 Call to insert them into the DB.
*/
private ["_point","_position","_lootTable","_itemTypes","_weights","_cntWeights","_itemType","_array","_totaldam","_dam","_selection","_data","_temp","_result","_status","_hitpoints","_fuel","_key","_cars","_vehicle","_isAir","_isShip","_dir","_isTooMany","_veh","_num","_allCfgLoots","_roll","_chance","_maxCars","_maxMBikes","_maxBikes","_maxHelis","_maxPlanes","_maxShips","_maxVehicles","_mapArea","_roadList","_buildingList","_findCars","_findMBikes","_findBikes","_findHelis","_findPlanes","_findShips","_allVehicles","_freeSlots","_index","_uniqueID","_typeObj","_posObj","_dirObj","_freeSlotCounter","_Cars","_MBikes","_Bikes","_Helis","_Planes","_Ships","_vehiclePool"];

//Make sure it runs via Server
if (!isDedicated) exitWith {};

diag_log format ["DAYZED VEHICLE SPAWNER: Initializing..."];

//% Chance to spawn vehicles
_roll = round(random 100);
_chance = if (_roll <= 40) then {true} else {false};

//Exit if roll less then 40
if (!_chance) exitWith { diag_log format ["DAYZED VEHICLE SPAWNER: Chance was %1. Needed <= 40. Not spawning any vehicles!",_roll];};

//Basic Defines - Limits and Values
_maxCars = 20;
_maxMBikes = 5;
_maxBikes = 15;
_maxHelis = 2;
_maxPlanes = 2;
_maxShips = 6;
_maxVehicles = 50;

//Center - Novy
_point = getMarkerpos "center";
//Not completly sure about this one, but let's leave it @ 6500 for now
_mapArea = 6500;
//Let's get all the roads in Chernarus
_roadList = _point nearRoads _mapArea;
//Let's get all the buildings in Chernarus. Very demanding, but runs only @ server start
_buildingList = [];
{
if (isClass (configFile >> "CfgBuildingLoot" >> (typeOf _x))) then {
	_buildingList set [count _buildingList,_x];
};
} forEach (_point nearObjects ["Building",_mapArea]);

//Let's find all Vehicle types on the Map. Pretty shitty method but I'm a n00b.
_findCars = (_point) nearObjects ["Car",20000];
_findMBikes = (_point) nearObjects ["Motorcycle",20000];
_findBikes = (_point) nearObjects ["Bicycle",20000];
_findHelis = (_point) nearObjects ["Helicopter",20000];
_findPlanes = (_point) nearObjects ["Plane",20000];
_findShips = (_point) nearObjects ["Ship",20000];
//Let's sum it up
_allVehicles = count (_findCars + _findMBikes + _findBikes + _findHelis + _findPlanes + _findShips);
//Simple math to find out how many vehicles we can spawn
_freeSlots = (_maxVehicles - _allVehicles);
//Don't always spawn the max ammount of available slots
_freeSlotCounter = round (random _freeSlots);

//Available Vehicles
_Cars = ["ATV_CZ_EP1","Skoda","SkodaBlue","SkodaGreen","SkodaRed","Lada1","Lada2","Lada1_TK_CIV_EP1","LadaLM","Volha_1_TK_CIV_EP1","Volha_2_TK_CIV_EP1","VolhaLimo_TK_CIV_EP1","car_hatchback","car_sedan","S1203_TK_CIV_EP1","hilux1_civil_1_open","hilux1_civil_3_open","hilux1_civil_2_covered","UAZ_RU","UAZ_Unarmed_TK_CIV_EP1","UAZ_Unarmed_UN_EP1","UAZ_CDF","UAZ_Unarmed_TK_EP1","HMMWV_DZ","SUV_DZ","SUV_DZed","BAF_Offroad_W","LandRover_TK_CIV_EP1","BTR40_DZed","UAZ_MG_CDF_DZed","Offroad_DSHKM_Gue_DZed","Ural_CDF","UralCivil","UralCivil2","Ural_UN_EP1","Kamaz_DZed","V3S_Civ","VWGolf","Ikarus","Ikarus_TK_CIV_EP1","Tractor","tractorOld"];
_MBikes = ["M1030","Old_moto_TK_Civ_EP1","TT650_Civ","TT650_TK_EP1"];
_Bikes = ["Old_bike_TK_CIV_EP1","MMT_Civ"];
_Helis = ["UH1H_DZ","UH1H_DZ2","MH6J_DZ","Mi17_DZ","Mi17_Civilian"];
_Planes = ["AN2_DZ","CSJ_GyroP","CSJ_GyroCover"];
_Ships = ["Fishing_Boat","PBX","Smallboat_1"];
_vehiclePool = _Cars + _MBikes + _Bikes + _Helis + _Planes + _Ships;

//Show how many vehicles on map
if (_allVehicles > 0) then {
	diag_log format ["DAYZED VEHICLE SPAWNER: Vehicles found: %1 || Cars: %2 || MBikes: %3 || Bikes: %4 || Helis: %5 || Planes: %6 || Ships: %7",_allVehicles, count _findCars, count _findMBikes, count _findBikes, count _findHelis, count _findPlanes, count _findShips];
};

//If all vehicles exceeds _maxVehicles exit script 
if (_allVehicles >= _maxVehicles) exitWith {
	diag_log format ["DAYZED VEHICLE SPAWNER: Vehicles Limit of %1 reached! Not Spawning!",_maxVehicles];
};

//Check if limits reached
if ((count _findCars) >= _maxCars) then {
	diag_log format ["DAYZED VEHICLE SPAWNER: Max Car Count (%1) Reached! [%2] removed from pool!",_maxCars,_Cars];
	_vehiclePool = _vehiclePool - _Cars;
};

if ((count _findMBikes) >= _maxMBikes) then {
	diag_log format ["DAYZED VEHICLE SPAWNER: Max MBikes Count (%1) Reached! [%2] removed from pool!",_maxMBikes,_MBikes];
	_vehiclePool = _vehiclePool - _MBikes;
};

if ((count _findBikes) >= _maxBikes) then {
	diag_log format ["DAYZED VEHICLE SPAWNER: Max Bikes Count (%1) Reached! [%2] removed from pool!",_maxBikes,_Bikes];
	_vehiclePool = _vehiclePool - _Bikes;
};

if ((count _findHelis) >= _maxHelis) then {
	diag_log format ["DAYZED VEHICLE SPAWNER: Max Heli Count (%1) Reached! [%2] removed from pool!",_maxHelis,_Helis];
	_vehiclePool = _vehiclePool - _Helis;
};

if ((count _findPlanes) >= _maxPlanes) then {
	diag_log format ["DAYZED VEHICLE SPAWNER: Max Plane Count (%1) Reached! [%2] removed from pool!",_maxPlanes,_Planes];
	_vehiclePool = _vehiclePool - _Planes;
};

if ((count _findShips) >= _maxShips) then {
	diag_log format ["DAYZED VEHICLE SPAWNER: Max Ship Count (%1) Reached! [%2] removed from pool!",_maxShips,_Ships];
	_vehiclePool = _vehiclePool - _Ships;
};

//If Free slot's available then spawn
if (_freeSlots > 0) then {
diag_log format ["DAYZED VEHICLE SPAWNER: %1 Free Vehicle Slots Available! Spawning %2 Vehicles!!",_freeSlots, _freeSlotCounter];
	while {_freeSlotCounter > 0} do {
			if (_freeSlotCounter > 0 ) then {
				diag_log format ["DAYZED VEHICLE SPAWNER: %1 Free Vehicle Slots Left. Continuing...",_freeSlotCounter];
			} else {
				diag_log format ["DAYZED VEHICLE SPAWNER: %1 Free Vehicle Slots Left. Stopping...",_freeSlotCounter];
			};
			waitUntil{!isNil "BIS_fnc_selectRandom"};
			_vehicle = _vehiclePool call BIS_fnc_selectRandom;
			//Check if selected vehicle by BIS_fnc_selectRandom is a Plane or Heli.
			//This is important so we won't have more then allowed Planes/Helis on the Map in one script run.
			//Other classes are not crucial since it's nearly impossible to exceed their limit in one run.
			//Since nearObjects is pretty demanding we'll focus only on those two.
			if (_vehicle isKindOf "Helicopter") then {
				if ((count ((_point) nearObjects ["Helicopter",20000])) >= _maxHelis) then {
					_vehiclePool = _vehiclePool - _Helis;
					waitUntil{!isNil "BIS_fnc_selectRandom"};
					_vehicle = _vehiclePool call BIS_fnc_selectRandom;
					diag_log format ["DAYZED VEHICLE SPAWNER: Max Heli Count (%1) Reached! [%2] removed from pool!",_maxHelis,_Helis];
				};
			};
			if (_vehicle isKindOf "Plane") then {
				if ((count ((_point) nearObjects ["Plane",20000])) >= _maxPlanes) then {	
					_vehiclePool = _vehiclePool - _Planes;
					waitUntil{!isNil "BIS_fnc_selectRandom"};
					_vehicle = _vehiclePool call BIS_fnc_selectRandom;
					diag_log format ["DAYZED VEHICLE SPAWNER: Max Plane Count (%1) Reached! [%2] removed from pool!",_maxPlanes,_Planes];
				};
			};				
			_isAir = _vehicle isKindOf "Air";
			_isShip = _vehicle isKindOf "Ship";
			//If vehicle is a Ship or Heli/Plane don't spawn it in ridiculous positions
			if (_isShip OR _isAir) then {
				if (_isShip) then {
					//Spawn Boats anywhere around coast on water
					waitUntil{!isNil "BIS_fnc_findSafePos"};
					_position = [_point,0,_mapArea,10,1,2000,1] call BIS_fnc_findSafePos;
					//diag_log("DEBUG: Spawning Boat near coast " + str(_position));
				} else {
					//Spawn air anywhere that is flat
					waitUntil{!isNil "BIS_fnc_findSafePos"};
					_position = [_point,0,_mapArea,10,0,2000,0] call BIS_fnc_findSafePos;
					//diag_log("DAYZED VEHICLE SPAWNER: Spawning Heli/Plane anywhere flat " + str(_position));
				};
			} else {
				//Spawn Cars around buildings and 50% near roads
				if((random 1) > 0.5) then {
					waitUntil{!isNil "BIS_fnc_selectRandom"};
					_position = _roadList call BIS_fnc_selectRandom;
					_position = _position modelToWorld [0,0,0];
					waitUntil{!isNil "BIS_fnc_findSafePos"};
					_position = [_position,0,10,10,0,2000,0] call BIS_fnc_findSafePos;
					//diag_log("DAYZED VEHICLE SPAWNER: Spawning Vehicle near road " + str(_position));
				} else {
					waitUntil{!isNil "BIS_fnc_selectRandom"};
					_position = _buildingList call BIS_fnc_selectRandom;
					_position = _position modelToWorld [0,0,0];
					waitUntil{!isNil "BIS_fnc_findSafePos"};
					_position = [_position,0,40,5,0,2000,0] call BIS_fnc_findSafePos;
					//diag_log("DAYZED VEHICLE SPAWNER: Spawning Vehicle around building " + str(_position));

				};
			};
			//Sometimes BIS_fnc_findSafePos fails to find height so only proceed when 2 values present
			if ((count _position) == 2) then { 
				//Check if something is around
				_isTooMany = (_position) nearObjects ["AllVehicles",50];
				//If another Vehicle is in 50m raddious then don't spawn
				if ((count _isTooMany) > 0) exitWith { diag_log ("DAYZED VEHICLE SPAWNER: Too many vehicles at " + str(_position));};

				//Create Vehicle 
				_veh = createVehicle [_vehicle, _position, [], 0, "CAN_COLLIDE"];
				//Set it's position and direction
				_dir = round(random 180);
				_veh setdir _dir;
				_veh setpos _position;	
				//Clear Defaul cargo defined in ArmA config Files
				clearWeaponCargoGlobal _veh;
				clearMagazineCargoGlobal _veh;		
				//Add MPEventHandler for damage
				_veh addMPEventHandler ["MPKilled",{_this call vehicle_handleServerKilled;}];
				//Create an unique ID
				_uniqueID = str(round(random 999999));
				_veh setVariable ["ObjectID", _uniqueID, true];
				_veh setVariable ["ObjectUID", _uniqueID, true];
				//Set lastUpdate time for server
				_veh setVariable ["lastUpdate",time,true];
				//Add it to Object Monitor
				if(!isNil "dayz_serverObjectMonitor")then {
					dayz_serverObjectMonitor set [count dayz_serverObjectMonitor, _veh];
				};
			
			//Add Loot to vehicle (0-3)
			_num = floor(random 4);
			_allCfgLoots = ["policeman","civilian","viralloot","food","generic","medical","trash","hunter","CastleLoot","Church","crashMED","Farm","Hangar","Hangar","hospital","hunter","Industrial","military","militaryEAST","militaryWEST","Residential","Supermarket"];
			for "_x" from 1 to _num do {
				waitUntil{!isNil "BIS_fnc_selectRandom"};
				_lootTable = _allCfgLoots call BIS_fnc_selectRandom;
				_itemTypes = [];
				{ _itemTypes set [count _itemTypes, _x select 0]
				} foreach getArray (configFile >> "cfgLoot" >> _lootTable);
				_index = dayz_CLBase find _lootTable;
				_weights = dayz_CLChances select _index;
				_cntWeights = count _weights;
				_index = floor(random _cntWeights);
				_index = _weights select _index;
				_itemType = _itemTypes select _index;
				_veh addMagazineCargoGlobal [_itemType,1];
			};
			
			//If Vehicle is not a bicycle generate damage and fuel and add after it's published to HIVE
			_fuel = 0;
			if (getNumber(configFile >> "CfgVehicles" >> _vehicle >> "isBicycle") != 1) then {
			//Create randomly damaged parts
			_array = [];
			_hitpoints = _veh call vehicle_getHitpoints;
			//Generate damage on all parts
			{	_dam = random(100) / 100;
				_selection = getText(configFile >> "cfgVehicles" >> (typeOf _veh)  >> "HitPoints" >> _x >> "name");
					if (_dam > 0) then {
						_array set [count _array,[_selection,_dam]];
					};
				} forEach _hitpoints;
			//Generate fuel
			_fuel = (random(100)) / 100;
			};
		
			//Everything is ready so let's publish to HIVE	
			_typeObj = typeOf _veh;
			_posObj = getPos _veh;
			_dirObj = getDir _veh;

			//The Hive 999 call to publish the object
			/* ///START/// */
			_key = format["CHILD:999:select `id` from `vehicle` where `class_name` = '?' LIMIT 1:[""%1""]:", _typeObj];
			_data = "HiveEXT" callExtension _key;             
			_result = call compile format ["%1", _data];
			_status = _result select 0;
			if (_status == "CustomStreamStart") then {
				"HiveEXT" callExtension _key;
				_temp = _result select 1;
				if (_temp == 0) then {
					_data = "HiveEXT" callExtension format ["CHILD:999:Insert into vehicle 
					(class_name, damage_min, damage_max, fuel_min, fuel_max, limit_min, limit_max, parts, inventory)
					values
					('?',0,0,1.0,1.0,0,99,'',''):[""%1""]:", _typeObj];
				};	
			};
			
			_data = "HiveEXT" callExtension format ["CHILD:999:Insert into world_vehicle
			(vehicle_id, world_id, worldspace, chance)
			values
			((SELECT `id` FROM `vehicle` where `class_name` = '?' LIMIT 1), 1, '%3',1):[""%1"", ""%2""]:", _typeObj, worldName, [_dirObj, _posObj]];

			_data = "HiveEXT" callExtension format["CHILD:999:Insert into instance_vehicle
			(world_vehicle_id, instance_id, worldspace, inventory, parts, fuel, damage)
			values
			((SELECT `id` FROM `world_vehicle` where `vehicle_id` = (SELECT `id` FROM `vehicle` where `class_name` = '%1' LIMIT 1) LIMIT 1), %3, '%2','[[[],[]],[[],[]],[[],[]]]','[]',1,0):[]:", _typeObj, [_dirObj, _posObj], dayZ_instance];

			_key = format["CHILD:999:SELECT `id` FROM `instance_vehicle` ORDER BY `id` DESC LIMIT 1:[]:"];
			_data = "HiveEXT" callExtension _key;

			_result = call compile format ["%1", _data];
			_status = _result select 0;
			if (_status == "CustomStreamStart") then {
				_temp = _result select 1;
				if (_temp == 1) then {
					_data = "HiveEXT" callExtension _key;
					_result = call compile format ["%1", _data];
					_status = _result select 0;
				};	
			};
			/* ///END/// */
			//After it's published Set Variables/Damage and Fuel
			_veh setVariable ["lastUpdate",time];
			_veh setVariable ["ObjectID", str(_status), true];
			_veh setVariable ["CharacterID", "1337", true];
			//Set 0 damage
			_veh setDamage 0;
			// Set Hits after ObjectID is set
			{
			_selection = _x select 0;
			_dam = _x select 1;
			//Don't do partial damage to parts cuz in dumb as fuck. If damage roll > 0.66 then destroy it completely...
			if (_dam > 0.66) then {_dam = 1};
			//...and don't destory Engines and FuelTanks completely 
			if (_selection in dayZ_explosiveParts and _dam > 0.8) then {_dam = 0.8};
			PVCDZ_veh_SH = [_veh,_selection,_dam];
			publicVariable "PVCDZ_veh_SH";
			if (local _veh) then {
			PVCDZ_veh_SH call fnc_veh_handleDam;
			};
			} forEach _array;
			//Set Fuel
			_veh setFuel _fuel;
			//Set Velocity
			_veh setvelocity [0,0,1];
			//Reset EH
			_veh call fnc_veh_ResetEH;
			//Mounted Slots
			_veh setVehicleInit format['
			this setVehicleVarname "%1";
			%1 = this;
			mounted_actions_init = if (isNil "mounted_actions_init") then { [] } else {mounted_actions_init};
			mounted_actions_init = mounted_actions_init + [%1];
			[%1] call mounted_add_actions;
			',_vehicle];
			processInitCommands;
			//Update the object via server
			[_veh,"all"] spawn server_updateObject;
			diag_log format ["DAYZED VEHICLE SPAWNER: Spawned %1 near %2 with ObjectID %3",_typeObj,((getPosATL _veh) call fa_coor2str),_status];
		} else {
		diag_log format ["DAYZED VEHICLE SPAWNER: BIS_fnc_findSafePos did not generate Height for %1. Skipping....",_vehicle];
		};
		_freeSlotCounter = _freeSlotCounter - 1;
	};
	sleep 1.5;
};

diag_log format ["DAYZED VEHICLE SPAWNER: Finished. Exiting..."];