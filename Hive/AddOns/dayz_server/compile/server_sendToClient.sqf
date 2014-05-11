private ["_unit","_variable","_arraytosend","_owner","_vehicle","_qty"];
//Inbound [_unit,"PVCDZ_hlt_Transfuse",[_unit,player,1000]]
_unit = _this select 0;
_variable = _this select 1;
_arraytosend = _this select 2;
_owner = owner _unit;

if (isNull _unit) exitWith{
diag_log format ["ERROR: sendToClient is Null: %1", _unit]
};

//execution
switch (_variable) do {
	case "VehHandleDam": {
		_vehicle = _arraytosend select 0;
		if (local _vehicle) then {
			_arraytosend call fnc_veh_handleDam;
		} else {
			PVCDZ_veh_SH = _arraytosend;
			_owner publicVariableClient "PVCDZ_veh_SH";
		};
	};
	
	case "SetFuel": {
		_vehicle = _arraytosend select 0;
		_qty = _arraytosend select 1;
		if (local _vehicle) then {
			_vehicle setFuel _qty;
		} else {
			PVCDZ_veh_SetFuel = _arraytosend;
			_owner publicVariableClient  "PVCDZ_veh_SetFuel";
		};
	};
	
	case "GutBody": {
		PVCDZ_obj_GutBody = _arraytosend;
		_owner publicVariableClient "PVCDZ_obj_GutBody";
	};
	
	case "HideBody": {
		PVCDZ_obj_HideBody = _arraytosend select 0;
		_owner publicVariableClient "PVCDZ_obj_HideBody";
	};
	
	case "Humanity": {
		PVCDZ_plr_Humanity = _arraytosend;
		_owner publicVariableClient "PVCDZ_plr_Humanity";
	};
	
	case "dayzSetDate": {
		dayzSetDate = dayz_storeTimeDate;
		_owner publicVariableClient "dayzSetDate";
		//diag_log ("Time and date: " +str (dayz_storeTimeDate));
	};

	case "Transfuse": {
		PVCDZ_hlt_Transfuse = _arraytosend;
		_owner publicVariableClient "PVCDZ_hlt_Transfuse";
		_unit setVariable["medForceUpdate",true];
	};

	case "Painkiller": {
		PVCDZ_hlt_PainK = _arraytosend;
		_owner publicVariableClient "PVCDZ_hlt_PainK";
		_unit setVariable["medForceUpdate",true];
	};

	case "Morphine": {
		PVCDZ_hlt_Morphine = _arraytosend;
		_owner publicVariableClient "PVCDZ_hlt_Morphine";
		_unit setVariable ["hit_legs",0,false];
		_unit setVariable ["hit_hands",0,false];
		_unit setVariable["medForceUpdate",true];
	};

	case "Epinephrine": {
		PVCDZ_hlt_Epi = _arraytosend;
		_owner publicVariableClient "PVCDZ_hlt_Epi";
		_unit setVariable["medForceUpdate",true];
	};

	case "Bandage": {
		PVCDZ_hlt_Bandage = _arraytosend;
		_owner publicVariableClient "PVCDZ_hlt_Bandage";
		_unit setVariable["medForceUpdate",true];
	};

	case "Antibiotics": {
		PVCDZ_hlt_AntiB = _arraytosend;
		_owner publicVariableClient "PVCDZ_hlt_AntiB";
		_unit setVariable["medForceUpdate",true];
	};

	case "Legs": {
		PVCDZ_plr_Legs = _arraytosend;
		_owner publicVariableClient "PVCDZ_plr_Legs";
	};
};
