startLoadingScreen ["","RscDisplayLoadCustom"];

/*Check ARMA Version*/

_ARMAv = productVersion;
if ((_ARMAv select 3) > 103718) exitWith
{
	startLoadingScreen ["PLEASE INSTALL ARMA BETA PATCH #103718!", "DayZ_loadingScreen"];
	sleep 10;
	endMission "END1";
	endLoadingScreen;
};

cutText ["","BLACK OUT"];
enableSaving [false, false];

//Server Settings
dayZ_instance = 1; // The instance
dayZ_ATPList = ["123456789"]; //Built in ATP UID exclusions

#include "\z\addons\dayz_code\system\mission\init.sqf"