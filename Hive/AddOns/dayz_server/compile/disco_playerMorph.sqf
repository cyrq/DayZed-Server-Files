private ["_object","_playerID","_characterID","_penalty","_model","_position","_playerName","_dir","_currentAnim","_isInVehicle","_updates","_humanity","_temp","_worldspace","_zombieKills","_headShots","_humanKills","_banditKills","_medical","_messing","_weapons","_magazines","_primweapon","_secweapon","_newBackpackType","_backpackWpn","_backpackMag","_currentWpn","_muzzles","_doLoop","_key","_primary","_newUnit","_newBackpack","_backpackWpnTypes","_backpackWpnQtys","_countr","_backpackmagTypes","_backpackmagQtys","_backpackmag","_fractures","_mydamage_eh1","_isDead","_playerGear","_playerBackp"];

_object = _this select 0;
_playerID = _this select 1; 
_characterID = _this select 2; 
_penalty = _this select 3;
_dir = _this select 4;
_position = _this select 5;
_playerName	= name _object;
_model = typeOf _object;
_position = getPosATL _object;
_dir = getDir _object;
_currentAnim = animationState _object;
_isInVehicle = 	vehicle _object != _object;

_object removeAllEventHandlers "FiredNear";
_object removeAllEventHandlers "HandleDamage";
_object removeAllEventHandlers "Killed";
_object removeAllEventHandlers "Fired";

_updates 	= _object getVariable["updatePlayer",[false,false,false,false,false]];
_updates set [0,true];
_object setVariable["updatePlayer",_updates,true];

_humanity 	= _object getVariable["humanity",0];
_temp 		= round(_object getVariable ["temperature",100]);
_worldspace 	= [round(_dir),_position];
_zombieKills 	= _object getVariable ["zombieKills",0];
_headShots 	= _object getVariable ["headShots",0];
_humanKills 	= _object getVariable ["humanKills",0];
_banditKills 	= _object getVariable ["banditKills",0];
_freeTarget	= _object getVariable ["freeTarget",false];
_medical 	= _object call player_sumMedical;
_messing	= _object getVariable ["messing",[0,0]];

//BackUp Weapons and Mags
	_weapons 	= weapons _object;
	_magazines	= magazines _object;
	_primweapon	= primaryWeapon _object;
	_secweapon	= secondaryWeapon _object;

//Checks
	if(!(_primweapon in _weapons) && _primweapon != "") then {
		_weapons set [(count _weapons), _primweapon];
	};

	if(!(_secweapon in _weapons) && _secweapon != "") then {
		_weapons set [(count _weapons), _secweapon];
	};

	if ((_isInVehicle) && (count _position > 0)) then {
		_position set [2,0];
	};

//BackUp Backpack
	_newBackpackType = (typeOf unitBackpack _object);
	if(_newBackpackType != "") then {
		_backpackWpn = getWeaponCargo unitBackpack _object;
		_backpackMag = getMagazineCargo unitBackpack _object;
	};

//Get Muzzle
	_currentWpn = currentWeapon _object;
	_muzzles = getArray(configFile >> "cfgWeapons" >> _currentWpn >> "muzzles");
	if (count _muzzles > 1) then {
		_currentWpn = currentMuzzle player;
	};
	
//Create New Character
	_group 		= createGroup civilian;
	_newUnit 	= _group createUnit [_model,[0,0,0],[],0,"NONE"];
	sleep 0.1;


//Clear New Character
	{_newUnit removeMagazine _x;} forEach magazines _newUnit;
	removeAllWeapons _newUnit;

//Equip New Charactar
	{
		if (typeName _x == "ARRAY") then {_newUnit addMagazine [_x select 0,_x select 1] } else { _newUnit addMagazine _x };
		//sleep 0.05;
	} forEach _magazines;

	{
		_newUnit addWeapon _x;
		//sleep 0.05;
	} forEach _weapons;

//Check and Compare it
	if(str(_weapons) != str(weapons _newUnit)) then {
		//Get Differecnce
		{
			_weapons = _weapons - [_x];
		} forEach (weapons _newUnit);

		//Add the Missing
		{
			_newUnit addWeapon _x;
			//sleep 0.2;
		} forEach _weapons;
	};

	if(_primweapon != (primaryWeapon _newUnit)) then {
		_newUnit addWeapon _primweapon;
	};

	if(_secweapon != (secondaryWeapon _newUnit) && _secweapon != "") then {
		_newUnit addWeapon _secweapon;
	};

//Add and Fill BackPack
	if (!isNil "_newBackpackType") then {
		if (_newBackpackType != "") then {
			_newUnit addBackpack _newBackpackType;
			//_oldBackpack = dayz_myBackpack;
			_newBackpack = unitBackpack _newUnit;

//Fill backpack contents
			//Weapons
			_backpackWpnTypes = [];
			_backpackWpnQtys = [];
			if (count _backpackWpn > 0) then {
				_backpackWpnTypes = _backpackWpn select 0;
				_backpackWpnQtys = _backpackWpn select 1;
			};
			_countr = 0;
			{
			_newBackpack addWeaponCargoGlobal  [_x,(_backpackWpnQtys select _countr)];
			_countr = _countr + 1;
			} forEach _backpackWpnTypes;
			//magazines
			_backpackmagTypes = [];
			_backpackmagQtys = [];
			if (count _backpackmag > 0) then {
				_backpackmagTypes = _backpackMag select 0;
				_backpackmagQtys = _backpackMag select 1;
			};
			_countr = 0;
			{
				_newBackpack addmagazineCargoGlobal [_x,(_backpackmagQtys select _countr)];
				_countr = _countr + 1;
			} forEach _backpackmagTypes;
		};
	};

//Medical stuff
	if (count _medical > 0) then {
	_newUnit setVariable["USEC_isDead",(_medical select 0),true];
	_newUnit setVariable["NORRN_unconscious", (_medical select 1), true];
	_newUnit setVariable["USEC_infected",(_medical select 2),true];
	_newUnit setVariable["USEC_injured",(_medical select 3),true];
	_newUnit setVariable["USEC_inPain",(_medical select 4),true];
	_newUnit setVariable["USEC_isCardiac",(_medical select 5),true];
	_newUnit setVariable["USEC_lowBlood",(_medical select 6),true];
	_newUnit setVariable["USEC_BloodQty",(_medical select 7),true];
	_newUnit setVariable["unconsciousTime",(_medical select 10),true];

	{
	_newUnit setVariable[_x,true,true];
	[_newUnit,_x,0] spawn fnc_usec_damageBleed;
	PVDZ_hlt_Bleed = [_newUnit,_x,0];
	publicVariable "PVDZ_hlt_Bleed";
	} forEach (_medical select 8);

	_fractures = (_medical select 9);
	_newUnit setVariable ["hit_legs",(_fractures select 0),true];
	_newUnit setVariable ["hit_hands",(_fractures select 1),true];
	} else {

	_newUnit setVariable ["hit_legs",0,true];
	_newUnit setVariable ["hit_hands",0,true];
	_newUnit setVariable ["USEC_injured",false,true];
	_newUnit setVariable ["USEC_inPain",false,true];	
	};

	_newUnit setVariable["characterID",_characterID,true];
	_newUnit setVariable["worldspace",_worldspace,true];
	_newUnit setVariable["bodyName",_playerName,true];
	_newUnit setVariable["freeTarget",_freeTarget,true];
	_newUnit setVariable["playerID",_playerID,true];
	_newUnit setVariable["temperature",_temp,true];
	_newUnit setVariable["messing",_messing,true];

//Add bot
	_newUnit allowDamage true;
	deleteVehicle _object;
	deleteGroup (group _object);
	_newUnit setDir _dir;
	_newUnit setPosATL _position;
	_newUnit disableConversation true;
	_newUnit setCaptive false;
	_newUnit setVariable ["BotName",_playerName];

	botPlayers = botPlayers + [_playerID];

	_mydamage_eh1 = _newUnit addeventhandler ["HandleDamage",{ _this call disco_damageHandler; }];
	[_newUnit,20,true,getPosATL _newUnit] spawn player_alertZombies;

	diag_log format["DISCOBOT: Player (%3) with UID (%1) added to Bots: Players with Bots: %2",_playerID,botPlayers,_playerName];

	_isDead = _newUnit getVariable["USEC_isDead",false];
	_doLoop = 0;
	diag_log format["DISCOBOT: Starting 30 sec timer for (%3)! (%1 sec), Player Dead - %2",_doLoop,_isDead,_playerName];
	while { _doLoop < 30 && !_isDead } do 
	{
	_isDead = _newUnit getVariable["USEC_isDead",false];
	_doLoop = _doLoop + 1;
	sleep 1;
	};
	diag_log format["DISCOBOT: Ending 30 sec timer for (%3%)! (%1 sec), Player Dead - %2",_doLoop,_isDead,_playerName];
	_newUnit removeAllEventHandlers "handleDamage";

	if (!_isDead) then {
	_medical = _newUnit call player_sumMedical;
	_newBackpack = unitBackpack _newUnit;
	_playerGear = [_weapons, _magazines];
	_playerBackp = [typeOf _newBackpack,getWeaponCargo _newBackpack,getMagazineCargo _newBackpack];

	deleteVehicle _newUnit;
	deleteGroup _group;

	//[_characterID,_worldspace,_playerGear,_playerBackp,_medical,[],""] call server_characterSync;
	//Send to HIVE backpack and medical only
	[_characterID,_worldspace,[],_playerBackp,_medical,[],""] call server_characterSync;
	};
	botPlayers = botPlayers - [_playerID];
	diag_log format["DISCOBOT: Player (%3) with UID (%1) removed from botPlayers: Players with Bots: %2",_playerID,botPlayers,_playerName];
