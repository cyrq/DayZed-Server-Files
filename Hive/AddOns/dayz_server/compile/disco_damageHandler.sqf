private ["_unit","_hit","_damage","_unconscious","_source","_ammo","_Viralzed","_isMinor","_isHeadHit","_isPlayer","_canHitFree","_isBandit","_punishment","_humanityHit","_myKills","_wpst","_sourceDist","_sourceWeap","_scale","_type","_nrj","_rndPain","_hitPain","_wound","_isHit","_isbleeding","_rndBleed","_hitBleed","_isInjured","_lowBlood","_rndInfection","_hitInfection","_isCardiac","_chance"];

_unit = _this select 0;
_hit = _this select 1;
_damage = _this select 2;
_unconscious = _unit getVariable ["NORRN_unconscious", false];
_player_blood = _unit getVariable["USEC_BloodQty",12000];
_source = _this select 3;
_ammo = _this select 4;
_Viralzed = typeOf _source in DayZ_ViralZeds;
_isMinor = (_hit in USEC_MinorWounds);
_isHeadHit = (_hit == "head_hit");
_isPlayer = (isPlayer _source);
if ((isNull _source) AND {((_ammo == "") OR {({damage _x > 0.9} count((getposATL _unit) nearEntities [["Air", "LandVehicle", "Ship"],15]) == 0) AND (count nearestObjects [getPosATL _unit, ["TrapItems"], 30] == 0)})}) exitWith {0};

if (_hit == "") then {
	if ((_source != player) and _isPlayer) then {
		_canHitFree = 	_unit getVariable ["freeTarget",false];
		_isBandit = (_unit getVariable["humanity",0]) <= -2000;
		_punishment = _canHitFree or _isBandit;
		_humanityHit = 0;

		if (!_punishment) then {
			_myKills = 		200 - (((_unit getVariable ["humanKills",0]) / 30) * 100);
			_humanityHit = -(_myKills * _damage);
			[_source,_humanityHit] spawn {	
				private ["_source","_humanityHit"];
				_source = _this select 0;
				_humanityHit = _this select 1;
				PVDZ_send = [_source,"Humanity",[_source,_humanityHit,30]];
				publicVariableServer "PVDZ_send";
			}
		};
	};
	
	if (((!(isNil {_source})) AND {(!(isNull _source))}) AND {((_source isKindOf "CAManBase") AND {(!local _source )})}) then {
		if (diag_ticktime-(_source getVariable ["lastloghit",0])>2) then {
			private ["_sourceWeap"];
			_source setVariable ["lastloghit",diag_ticktime];
			_wpst = weaponState _source;

			_sourceDist = round(_unit distance _source);
			_sourceWeap = switch (true) do {
				case ((vehicle _source) != _source) : { format ["in %1",getText(configFile >> "CfgVehicles" >> (typeOf (vehicle _source)) >> "displayName")] };
				case (_ammo == "zombie") : { _ammo };
				case (_wpst select 0 == "Throw") : { format ["with %1 thrown", _wpst select 3] };
				case (["Horn", currentWeapon _source] call fnc_inString) : {"with suspicious vehicle "+str((getposATL _source) nearEntities [["Air", "LandVehicle", "Ship"],5])};
				case (["Melee", _wpst select 0] call fnc_inString) : { format ["with %2%1",_wpst select 0, if (_sourceDist>6) then {"suspicious weapon "} else {""}] }; 
				case ((_wpst select 0 == "") AND {(_wpst select 4 == 0)}) : { format ["with %1/%2 suspicious", primaryWeapon _source, _ammo] };
				case (_wpst select 0 != "") : { format ["with %1/%2 <ammo left:%3>", _wpst select 0, _ammo, _wpst select 4] };
				default { "with suspicious weapon" };
			};
			if (_ammo != "zombie") then { // don't log any zombie wounds, even from remote zombies
				PVDZ_sec_atp = [_unit, _source, _sourceWeap, _sourceDist];
				publicVariableServer "PVDZ_sec_atp";
			};
		};
	};
};

if (_Viralzed) then { _scale = 350; } else { _scale = 250; };
_type = 0;
if ((_ammo isKindof "Grenade") or (_ammo isKindof "ShellBase") or (_ammo isKindof "TimeBombCore") or (_ammo isKindof "BombCore") or (_ammo isKindof "MissileCore") or (_ammo isKindof "RocketCore") or (_ammo isKindof "FuelExplosion") or (_ammo isKindof "GrenadeBase")) then {
	_type = 1;
};
if ((_ammo isKindof "B_127x107_Ball") or (_ammo isKindof "B_127x99_Ball")) then {
	_type = 2;
};

if (_damage > 0.1) then {
	if (_ammo != "zombie") then {
		_scale = _scale + 50;
	};
	//Start body part scale
	if (_ammo == "zombie" and _hit == "body") then {
		_scale = _scale * 3; //600 = Normal, 900 = Viral
	};
	if (_ammo == "zombie" and _hit == "legs") then {
		_scale = _scale; //200 = Normal, 300 = Viral
	};
	if (_ammo == "zombie" and _hit == "hands") then {
		_scale = _scale;  //200 = Normal, 300 = Viral
	};
	if (_isHeadHit) then {
		_scale = _scale * 6; //1200 = Normal, 1800 = Viral
	};
	if (_ammo == "zombie" and _unconscious and !_Viralzed) then {
		_scale = 50;
	};
	//End body part scale
	if ((isPlayer _source) and !(player == _source)) then {
		_scale = _scale + 800;
		if (_isHeadHit) then {
			_scale = _scale + 500;
		};
	};
	switch (_type) do {
		case 1: {_scale = _scale + 200};
		case 2: {_scale = _scale + 200};
	};

	_player_blood = _player_blood - (_damage * _scale);
	_unit setVariable ["USEC_BloodQty",_player_blood,true];
	if (_player_blood <= 0) exitWith {
		_id = [_unit,_source,"bled"] spawn disco_playerDeath;
	};
};

//Record Damage to Minor parts (legs, arms)
if (_hit in USEC_MinorWounds) then {
	private ["_type"]; //DO NOT REMOVE THIS!! it prevents _type being set to "fracture"
	if (_ammo == "zombie") then {
		if (_hit == "legs") then {
			[_unit,_hit,(_damage / 6)] call object_processHit;
		} else {
			[_unit,_hit,(_damage / 4)] call object_processHit;
		};
	} else {
		if ((_hit == "legs") AND (_source==_unit) AND (_ammo=="")) then {
			if ((!isNil "Dayz_freefall") AND {(abs(time - (Dayz_freefall select 0))<1)}) then {
				_nrj = ((Dayz_freefall select 1)*20) / 100;
				if (random(((1 + _nrj)^2) - 1) >= 1.5) then { // freefall from 5m => 1/2 chance to get hit legs registered
					[_unit,_hit,_damage] call object_processHit;
				}
				else {
					[_unit,"arms",(_damage / 6)] call object_processHit; // prevent broken legs due to arma bugs
				};
			};
		}
		else {
			[_unit,_hit,(_damage / 2)] call object_processHit;
		};
	};
};

if (_damage > 0.1) then {
	if (local _unit) then {
		_unit setVariable["medForceUpdate",true,true];
	};
};

if (_damage > 0.4) then {
	_rndPain = 	(random 10);
	_hitPain = 	(_rndPain < _damage);
		
	if ((_isHeadHit) or (_damage > 1.2 and _hitPain)) then {
		_hitPain = true;
	};
		
	if (_hitPain) then {
		_unit setVariable["USEC_inPain",true,true];
	};
		
	if ((_damage > 1.5) and _isHeadHit) exitWith {
		_id = [_unit,_source,"shothead"] spawn disco_playerDeath;
	};
};

//Create wound and cause bleed
_wound = _hit call fnc_usec_damageGetWound;
_isHit = _unit getVariable["hit_"+_wound,false];
	
_isbleeding = false;
switch true do {
	default {
		_rndBleed = (random 100);
		_hitBleed = (_rndBleed < 15);

		if (_hitBleed) then {
			_isbleeding = true;
		};
	};
};

if (_ammo == "zombie") then {
	if(!_isHit and _isbleeding) then {
		_unit setVariable["hit_"+_wound,true,true];	
		PVDZ_hlt_Bleed = [_unit,_wound,_damage];
		publicVariable "PVDZ_hlt_Bleed";   // draw blood stream on character, on all gameclients
		[_unit,_wound,_hit] spawn fnc_usec_damageBleed;  // draw blood stream on character, locally
		_isInjured = _unit getVariable["USEC_injured",false];
		if (!_isInjured) then {
			_unit setVariable["USEC_injured",true,true];
		};
	};
	} else {
		if(!_isHit) then {
			_unit setVariable["hit_"+_wound,true,true];
			PVDZ_hlt_Bleed = [_unit,_wound,_damage];
			publicVariable "PVDZ_hlt_Bleed";  // draw blood stream on character, on all gameclients
			[_unit,_wound,_hit] spawn fnc_usec_damageBleed;  // draw blood stream on character, locally
			_isInjured = _unit getVariable["USEC_injured",false];
			if (!_isInjured) then {
				_unit setVariable["USEC_injured",true,true];
			};
		};
	};
	
if (_type == 1) then {
	if (_damage > 4) exitWith {
		_id = [_unit,_source,"explosion"] spawn disco_playerDeath;
	} else {
		if (_damage > 2) then {
			_isCardiac = _unit getVariable["USEC_isCardiac",false];
			if (!_isCardiac) then {
				_unit setVariable["USEC_isCardiac",true,true];
			};
		};
	};
};
	
if (_type == 2) then {
	if (_damage > 4) exitWith {
		_id = [_unit,_source,"shotheavy"] spawn disco_playerDeath;
	} else {
		if (_damage > 2) then {
			_isCardiac = _unit getVariable["USEC_isCardiac",false];
			if (!_isCardiac) then {
				_unit setVariable["USEC_isCardiac",true,true];
			};
		};
	};
};