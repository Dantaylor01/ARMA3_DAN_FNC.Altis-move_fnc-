DAN_CreateMissionCIVAmbient = {
    params [
        ["_centerPos", [0,0,0]],
        ["_timeOfDay", daytime],
        ["_taskID", ""]
    ];

    if (!(DAN_EnableMissionCIVAmbient)) exitWith {
        if (DAN_DEBUG) then {
            systemChat "[DEBUG][DAN_CreateMissionCIVAmbient] Ambient civilian spawning is disabled. Exiting function.";
        };
    };
	private _isDay = _timeOfDay >= 6 && _timeOfDay < 18;
	private _homes = nearestObjects [_centerPos, ["House"], 50];
	private _numpop = ceil ((count _homes) / DAN_MissionCivPopulationDivideBy);
	_numpop = _numpop min (count _homes);

	private _homeList = _homes call BIS_fnc_arrayShuffle;
	_homeList resize _numpop;


	private _allciv = [];
	private _allVehicles = [];
	

    for "_i" from 0 to (_numpop - 1) do {
        private _home = _homeList select _i;
        private _classname = selectRandom DAN_civclass;
        private _spawnPos = getPosATL _home;
        private _grpCiv = createGroup civilian;
        private _civ = _grpCiv createUnit [
            _classname,
            _spawnPos,
            [],
            0,
            "CAN_COLLIDE"
        ];

        _allciv pushBack _civ;
        sleep 0.1;

    };
    for "_i" from 0 to ((count _allciv) - 1) do {

        private _roads = nearestTerrainObjects [_centerPos, ["MAIN ROAD", "ROAD","CROSS","TRACK"], 200, false];
        if (count _roads == 0) exitWith {
            if (DAN_DEBUG) then {
                systemChat format ["[DEBUG][CreateCivInCity] No valid roads near marker %1"];
            };
        };
        private _rdist = 5.75;
        private _road = selectRandom _roads;
        private _info = getRoadInfo _road;
        _info params ["_mapType", "_width", "_isPedestrian", "_texture", "_textureEnd", "_material", "_begPos", "_endPos", "_isBridge"];

        private _roadDir = _begPos getDir _endPos;


        private _sideDir = if ((random 1) > 0.5) then {_roadDir + 90} else {_roadDir - 90};


        private _offset = (_width / 2) + 1;

        private _pos = getPos _road;
        private _tx = (_pos select 0) + (_offset * sin _sideDir);
        private _ty = (_pos select 1) + (_offset * cos _sideDir);

        private _carpos = [_tx,_ty,0];

        private _vehType = selectRandom DAN_carclass;
        private _veh = createVehicle [_vehType, _carpos, [], 0, "NONE"];
        _veh setDir _roadDir;

        _allVehicles pushBack _veh;
        sleep 0.1;

    };
    if (DAN_CarbombInCity) then {
        [_allciv,_allVehicles] spawn {
            params ["_allciv","_allVehicles"];
            private _time = selectRandom [0,15,20];
            private _bomber = selectRandom _allciv;
            
            sleep 0.5;
            [_bomber] joinSilent createGroup east;
            _bomber allowFleeing 0;
            private _carbomb = selectRandom _allVehicles;
            _bomb = [_carbomb,_time] call DAN_attachbomb;
            
            [_bomber,_bomb] call DAN_armbomb;
            
        };
    };

	{
		[_x, _taskID] call DAN_extra;
		
	} forEach _allciv;

	{
		[_x, _taskID] call DAN_extra;
		
	} forEach _allVehicles;

	_allciv
};