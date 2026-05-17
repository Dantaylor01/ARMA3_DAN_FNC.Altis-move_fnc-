
DAN_BehindEnemyLine = {
	if (!isServer) exitWith {};
	if (!DAN_EnableBehindEnemyLine) exitWith {};
    addMissionEventHandler ["EntityKilled", {
        params ["_unit", "_killer", "_instigator", "_useEffects"];
        private _veh = _unit;

        if !(
            _veh isKindOf "Plane" ||
            _veh isKindOf "Helicopter"
        ) exitWith {};

        private _cfgSide = getNumber (configFile >> "CfgVehicles" >> typeOf _veh >> "side");

        systemChat format ["Aircraft destroyed, config side: %1, typeOf: %2", _cfgSide, typeOf _veh];

        if (_cfgSide != 1) exitWith {
            systemChat format ["Aircraft destroyed (not BLUFOR) config side: %1", _cfgSide];
        };

        private _driver = driver _veh;

        if (isNull _driver) exitWith {
            systemChat "BLUFOR Aircraft destroyed (no driver)";
        };

        private _name = if (name _driver != "") then { name _driver } else { "Unknown Pilot" };

        systemChat format ["BLUFOR Aircraft Down! Pilot: %1", _name];
		private _vipPreview = [_driver] call DAN_getpic;
		
		
		private _vehPreview = [_veh] call DAN_getpic;
		private _des = getpos _veh;
		private _taskID = name _driver;
		private _taskDesc = format [
			"<t align='center'><img size='2' image='%1'/></t><br/>"
			+ "<t size='0.8' color='#ffffff'>pilot:</t> <t color='#ff3333'>%2</t><br/><br/>"
			+ "<t align='center'><img size='2' image='%3'/></t><br/>"
			+ "<t size='0.8' color='#ffffff'>Destination:</t> <t color='#33ff33'>%4</t><br/><br/>"
			+ "Behind Enemy Line, bring him back.",
			_vipPreview,
			_taskID,
			_vehPreview,
			mapGridPosition _des
		];
		private _parentTask =[player] call BIS_fnc_taskCurrent;		
		[
			true,
			[_taskID, _parentTask],
			[
				_taskDesc,
				"Behind Enemy Line",
				""
			],
			getPosATL _driver,
			true
		] call BIS_fnc_taskCreate;
		private _hill = selectBestPlaces [_des, 1000, "hills", 1, 3];
        private _hillpos1 = (_hill select 0) select 0;
        [_hillpos1] call DAN_CreateBRNSniperTeams;
        private _sea = selectBestPlaces [_des, 5000, "sea", 1, 3];
        private _seapos = (_sea select 0) select 0;
        [_seapos] call DAN_CreateBRNNavalTeams;
    }];
};

call DAN_BehindEnemyLine;