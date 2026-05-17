DAN_CleanupExtra = {

	params ["_taskID"];
    if (allPlayers findIf {!alive _x} != -1) exitWith {
        hint "Cannot clear crime scene while players are dead";
        if (DAN_DEBUG) then {
            systemChat "[DAN_DEBUG][DAN_ClearCrimeScene] Aborted: Dead players detected";
        };
    };
	private _deletedCount = 0;
    private _TaskIDExtra = format ["%1extra", _taskID];
	private _entities = missionNamespace getVariable [_TaskIDExtra, []];
	{
		switch (typeName _x) do {

			// =========================
			// OBJECT
			// =========================

			case "OBJECT": {

				if (!isNull _x) then {
					deleteVehicle _x;
					_deletedCount = _deletedCount + 1;
				};
			};

			// =========================
			// GROUP
			// =========================

			case "GROUP": {

				if (!isNull _x) then {

					{
						if (!isNull _x) then {
							deleteVehicle _x;
							_deletedCount = _deletedCount + 1;
						};
					} forEach units _x;

					deleteGroup _x;
				};
			};

			// =========================
			// MARKER
			// =========================

			case "STRING": {

				if (markerShape _x != "") then {
					deleteMarker _x;
					_deletedCount = _deletedCount + 1;
				};
			};
		};

	} forEach _entities;

	// remove registry
	missionNamespace setVariable [
		_TaskIDExtra,
		nil,
		true
	];

	if (DAN_DEBUG) then {

		systemChat format [
			"[DAN_cleanupTask] Cleaned task: %1 | Entities removed: %2",
			_taskID,
			_deletedCount
		];
	};
    call DAN_ClearCrimeScene;
};