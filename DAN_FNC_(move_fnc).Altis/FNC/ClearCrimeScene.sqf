DAN_ClearCrimeScene = {
    if (allPlayers findIf {!alive _x} != -1) exitWith {
        hint "Cannot clear crime scene while players are dead";
        if (DAN_DEBUG) then {
            systemChat "[DAN_DEBUG][DAN_clearcrimescene] Aborted: Dead players detected";
        };
    };
    private _deletedCount = 0;
    
    
    private _deadToDelete = allDeadMen select {!isPlayer _x};
    {
        deleteVehicle _x;
        _deletedCount = _deletedCount + 1;
    } forEach _deadToDelete;
	private _damagedVehicles = vehicles select {
		!isNull _x &&
		{damage _x > 0.8} &&
		{crew _x findIf {isPlayer _x} == -1}
	};

    
    {
        deleteVehicle _x;
        _deletedCount = _deletedCount + 1;
    } forEach _damagedVehicles;
	{
		{
			deleteVehicle _x;
			_deletedCount = _deletedCount + 1;
		} forEach (allMissionObjects _x);
	} forEach ["Land_DirtPatch_03_F", "Land_ClutterCutter_large_F"];
    hint format ["Crime scene cleared\n%1 objects removed", _deletedCount];
};