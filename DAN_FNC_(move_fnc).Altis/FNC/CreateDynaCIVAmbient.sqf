"━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
"  ฟังชัน, ประชาชนในพื้นที่แบบไดนามิก  ";
"━━━━━━━━━━━━━━━━━━━━━━━━━━━━";



DAN_CreateCivAndCarInCity = {
    params ["_pos","_cityname"];
    if (DAN_DynamicCivInCityClass isEqualTo []) exitWith {
        if (DAN_DEBUG) then { systemChat "[DAN_DEBUG] No CIV Defend Teams defined, skipping creation."; };
    };
	

	private _homes = nearestObjects [_pos, ["House"], 50];
	private _numpop = ceil ((count _homes) / DAN_DynamicCivPopulationDivideBy);
	_numpop = _numpop min (count _homes);

	private _homeList = _homes call BIS_fnc_arrayShuffle;


	_homeList resize _numpop;


	private _allciv = [];
	private _allVehicles = [];
	

	
		
	for "_i" from 0 to (_numpop - 1) do {
        private _home = _homeList select _i;
        private _classname = selectRandom DAN_DynamicCivInCityClass;
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
        [] spawn {
            sleep 0.1;
        };
	};
    for "_i" from 0 to ((count _allciv) - 1) do {
        private _roads = nearestTerrainObjects [_pos, ["MAIN ROAD", "ROAD","CROSS","TRACK"], 200, false];
        if (count _roads == 0) exitWith {
            if (DAN_DEBUG) then {
                systemChat format ["[DEBUG][CreateCivInCity] No valid roads near marker %1", _x];
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

        private _vehType = selectRandom DAN_DynamicCivCarClass;
        private _veh = createVehicle [_vehType, _carpos, [], 0, "NONE"];
        _veh setDir _roadDir;

        _allVehicles pushBack _veh;
        [] spawn {
            sleep 0.1;
        };
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
	_allciv    
};
DAN_CreateforestCivTeams = {
    params ["_pos"];
   
    private _forest = selectBestPlaces [_pos, 1000, "forest", 1, 3];
    if (_forest isEqualTo [])  exitWith {
        if (DAN_DEBUG) then {
            systemChat "there is no forest"
        };

    };
    private _forestpos1 = (_forest select 0) select 0;
    private _forestCivTeam = selectRandom DAN_DynamicCivInForestTeams;
    private _grp  = createGroup civilian;
    private _forestCivTeams = [];
    private _vehicles = [];
    private _infantry = [];
    {
        private _class = _x;

        if (getNumber (configFile >> "CfgVehicles" >> _class >> "isMan") == 0) then {

            private _vehPos = [
                _forestpos1,
                1, 
                10, 
                5, 
                0, 
                20, 
                0
            ] call BIS_fnc_findSafePos;

            private _veh = createVehicle [_class, _vehPos, [], 0, "NONE"];
            _veh setDir random 360;

            _vehicles pushBack _veh;

        } else {

            private _unit = _grp createUnit [
                _class, _forestpos1, [], 5, "NONE"
            ];
            if (!isMultiplayer) then {
                [] spawn {
                    sleep 0.1;
                };
            };
            _infantry pushBack _unit;
        };

    } forEach _forestCivTeam;
    [] spawn {
        sleep 0.5;
    };

    _forestCivTeams pushBack _grp;
    _forestCivTeams
};
DAN_CreateDynaCIVAmbient = {
    if (!isServer) exitWith {};
    if !(DAN_EnableDynaCIVAmbient) exitWith {
        if (DAN_DEBUG) then {
            systemChat "[DAN_DEBUG] Civilian ambient is disabled, skipping city creation.";
        };
    };
    private _CityTypes = ["NameCity", "NameVillage", "NameCityCapital", "NameLocal"];
    private _CityLocations = nearestLocations [[worldSize / 2, worldSize / 2, 0], _CityTypes, worldSize];

    {
        private _loc = _x;
        private _pos = locationPosition _loc;
        private _cityName = text _loc;

        
        private _trg = createTrigger ["EmptyDetector", _pos];
        _trg setTriggerArea [DAN_DynamicCIVCityTriggerSize, DAN_DynamicCIVCityTriggerSize, 0, false];
        _trg setTriggerActivation ["WEST", "PRESENT", true];
        _trg setVariable ["myCity", _cityName];
        

        private _enter = {
            params ["_trigger", "_units", "_city"];
            private _pos = getPosATL _trigger;
            [_pos] call DAN_CreateCivAndCarInCity;
            [_pos] call DAN_CreateforestCivTeams;
            if (DAN_DEBUG) then {
                {
                    systemChat format ["%1 enter %2", name _x, _city];
                } forEach _units;
            };

            
        };


        private _out = {
            params ["_trigger"];
            private _city = _trigger getVariable ["myCity", ""];
            if (allPlayers findIf {!alive _x} != -1) exitWith {
                
                if (DAN_DEBUG) then {
                    systemChat format ["cannot clear %1 cuz player is dead", _city];
                };
            };


            
        
            private _Allobj = vehicles inAreaArray _trigger;
            private _CivCar = _Allobj select {
                (typeOf _x) in DAN_DynamicCivCarClass
            };
            private _Allunit = allUnits inAreaArray _trigger;
            private _Civunit = _Allunit select {
                side _x isEqualTo civilian
            };
            private _DelObj = _CivCar + _Civunit;

            {
                
                if (!isPlayer _x) then {
                    deleteVehicle _x;
                };
            } forEach _DelObj;

            if (DAN_DEBUG) then {
                systemChat format ["Cleared city: %1 (%2 objects)", _city, count _DelObj];
            };
        };
        _trg setVariable ["enter", _enter];
        _trg setVariable ["out", _out];

        _trg setTriggerStatements [
            "this",
            "[thisTrigger, thisList, (thisTrigger getVariable 'myCity')] call (thisTrigger getVariable 'enter');",
            "[thisTrigger, thisList] call (thisTrigger getVariable 'out');"
        ];

        if (DAN_DEBUG) then {
            private _markerName = format ["DAN_City_%1", _cityName];
            private _m = createMarker [_markerName, _pos];
            _m setMarkerShape "RECTANGLE";
            _m setMarkerSize [DAN_DynamicCIVCityTriggerSize, DAN_DynamicCIVCityTriggerSize];
            _m setMarkerColor "ColorRed";
            _m setMarkerAlpha 0.5;
            _m setMarkerText _cityName;
        };

    } forEach _CityLocations;
};
call DAN_CreateDynaCIVAmbient;