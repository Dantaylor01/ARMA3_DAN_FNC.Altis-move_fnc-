"━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
"       BRN HQ               ";
"━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
/*
DAN_CreateBRNMotorTeams = {
	
    private _hqList = missionNamespace getVariable ["BRNHQ_LIST", []];
    private _BRNHQ = selectRandom _hqList;
    if (isNil "_BRNHQ") exitWith {
        if (DAN_DEBUG_BRNHQ) then {
            systemChat "[DAN_DEBUG] No BRNHQ found, skipping OPFOR reinforcements.";
        };
    };
    private _BRNHQtrg = _BRNHQ getVariable ["mytrigger", objNull];
    private _iscaptured = _BRNHQtrg getVariable ["captured", false];
    if (_iscaptured) exitwith {
        if (DAN_DEBUG_BRNHQ) then {
            systemChat "[DAN_DEBUG] BRNHQ is captured, skipping OPFOR reinforcements.";
        };
    };
    private _pos = getPosATL _BRNHQ;

	private _OpfReinfroces = [];

    private _players = allPlayers select {isPlayer _x};
    private _countPlayers = count _players;

    private _playerGroups = ceil ((_countPlayers max 1) / 6);
    private _ORFGroups = _playerGroups * DAN_OpforMultiply;

	for "_i" from 1 to _ORFGroups do {

        private _team = selectRandom DAN_BRNMotorTeams;
        private _grp  = createGroup east;

        private _vehicles = [];
        private _infantry = [];


        {
            private _class = _x;

            if (getNumber (configFile >> "CfgVehicles" >> _class >> "isMan") == 0) then {
                private _roads = nearestTerrainObjects [_pos, ["MAIN ROAD", "ROAD","CROSS","TRACK"], 300];
                private _road = selectRandom _roads;
                if (_road isEqualTo objNull) then {
                    _road = _pos;
                };
                private _vehPos = [
                    _road,
                    1, 
                    80, 
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
                    _class, _pos, [], 5, "NONE"
                ];
                if (!isMultiplayer) then {
                    [] spawn {
                        sleep 0.1;
                    };
                };
                _infantry pushBack _unit;
            };

        } forEach _team;
        [] spawn {
            sleep 0.5;
        };

        {
            private _veh = _x;
            private _seats = fullCrew [_veh, "", true];

            {
                private _role = _x select 1;
                private _turretPath = if (count _x > 2) then {_x select 2} else {[]};

                private _unit = objNull;

                
                if (_infantry isNotEqualTo []) then {
                    _unit = _infantry deleteAt 0;
                } else {
                    
                    _unit = _grp createUnit [
                        "O_G_Soldier_F",
                        position _veh,
                        [],
                        5,
                        "NONE"
                    ];
                    if (!isMultiplayer) then {
                        [] spawn {
                            sleep 0.1;
                        };
                    };
                };

                
                switch (_role) do {

                    case "driver": {
                        _unit moveInDriver _veh;
                    };

                    case "gunner": {
                        _unit moveInGunner _veh;
                    };

                    case "commander": {
                        _unit moveInCommander _veh;
                    };

                    case "turret": {

                        if (_turretPath isEqualType []) then {
                            _unit moveInTurret [_veh, _turretPath];
                        } else {
                            _unit moveInCargo _veh;
                        };
                    };

                    default {
                        _unit moveInCargo _veh;
                    };
                };

            } forEach _seats;

        } forEach _vehicles;

        _OpfReinfroces pushBack _grp;
	};

	_OpfReinfroces
};
*/
DAN_CreateBRNMotorTeams = {
	
    private _hqList = missionNamespace getVariable ["BRNHQ_LIST", []];
    private _BRNHQ = selectRandom _hqList;
    if (isNil "_BRNHQ") exitWith {
        if (DAN_DEBUG_BRNHQ) then {
            systemChat "[DAN_DEBUG] No BRNHQ found, skipping OPFOR reinforcements.";
        };
    };
    private _BRNHQtrg = _BRNHQ getVariable ["mytrigger", objNull];
    private _iscaptured = _BRNHQtrg getVariable ["captured", false];
    if (_iscaptured) exitwith {
        if (DAN_DEBUG_BRNHQ) then {
            systemChat "[DAN_DEBUG] BRNHQ is captured, skipping OPFOR reinforcements.";
        };
    };
    private _pos = getPosATL _BRNHQ;

	private _createdEntities = [];

	private _players =
		allPlayers select {isPlayer _x};

	private _countPlayers =
		count _players;

	private _playerGroups =
		ceil ((_countPlayers max 1) / 6);

	private _rkkGroups =
		_playerGroups * DAN_OpforMultiply;

	for "_i" from 1 to _rkkGroups do {

		private _team =
			selectRandom DAN_BRNMotorTeams;

		private _grp =
			createGroup east;

		_createdEntities pushBack _grp;

		private _vehicles = [];
		private _infantry = [];

		// =====================================
		// CREATE ENTITIES
		// =====================================

		{
			private _class = _x;

			if (
				getNumber (
					configFile >>
					"CfgVehicles" >>
					_class >>
					"isMan"
				) == 0
			) then {

				private _vehPos = [
					_pos,
					10,
					80,
					5,
					0,
					20,
					0
				] call BIS_fnc_findSafePos;

				private _veh =
					createVehicle [
						_class,
						_vehPos,
						[],
						0,
						"NONE"
					];

				_veh setDir random 360;

				_vehicles pushBack _veh;

				_createdEntities pushBack _veh;

			} else {

				private _unit =
					_grp createUnit [
						_class,
						_pos,
						[],
						5,
						"NONE"
					];

				_infantry pushBack _unit;

				_createdEntities pushBack _unit;
			};

		} forEach _team;

		// =====================================
		// FILL VEHICLES
		// =====================================

		{
			private _veh = _x;

			private _seats =
				fullCrew [_veh, "", true];

			{
				private _role =
					_x select 1;

				private _turretPath =
					if (count _x > 2)
					then {_x select 2}
					else {[]};

				private _unit = objNull;

				// reuse infantry
				if (_infantry isNotEqualTo []) then {

					_unit =
						_infantry deleteAt 0;

				} else {

					_unit =
						_grp createUnit [
							"O_G_Soldier_F",
							position _veh,
							[],
							5,
							"NONE"
						];

					_createdEntities pushBack _unit;
				};

				switch (_role) do {

					case "driver": {
						_unit moveInDriver _veh;
					};

					case "gunner": {
						_unit moveInGunner _veh;
					};

					case "commander": {
						_unit moveInCommander _veh;
					};

					case "turret": {

						if (_turretPath isEqualType []) then {

							_unit moveInTurret [
								_veh,
								_turretPath
							];

						} else {

							_unit moveInCargo _veh;
						};
					};

					default {
						_unit moveInCargo _veh;
					};
				};

			} forEach _seats;

		} forEach _vehicles;
	};

	_createdEntities
};
DAN_CreateBRNDefendTeams = {
	params ["_pos"];
    
    if (DAN_BRNDefendTeams isEqualTo []) exitWith {
        if (DAN_DEBUG) then { systemChat "[DAN_DEBUG] No BRN Defend Teams defined, skipping creation."; };
    };
	private _BRNDefendTeams = [];

    private _players = allPlayers select {isPlayer _x};
    private _countPlayers = count _players;

    private _playerGroups = ceil ((_countPlayers max 1) / 6);
    private _ORFGroups = _playerGroups * DAN_OpforMultiply;

	for "_i" from 1 to _ORFGroups do {

        private _team = selectRandom DAN_BRNDefendTeams;
        private _grp  = createGroup east;

        private _vehicles = [];
        private _infantry = [];


        {
            private _class = _x;

            if (getNumber (configFile >> "CfgVehicles" >> _class >> "isMan") == 0) then {

                private _vehPos = [
                    _pos,
                    1, 
                    80, 
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
                    _class, _pos, [], 5, "NONE"
                ];
                if (!isMultiplayer) then {
                    [] spawn {
                        sleep 0.1;
                    };
                };
                _infantry pushBack _unit;
            };

        } forEach _team;
        [] spawn {
            sleep 0.5;
        };

        {
            private _veh = _x;
            private _seats = fullCrew [_veh, "", true];

            {
                private _role = _x select 1;
                private _turretPath = if (count _x > 2) then {_x select 2} else {[]};

                private _unit = objNull;

                
                if (_infantry isNotEqualTo []) then {
                    _unit = _infantry deleteAt 0;
                } else {
                    
                    _unit = _grp createUnit [
                        "O_G_Soldier_F",
                        position _veh,
                        [],
                        5,
                        "NONE"
                    ];
                    if (!isMultiplayer) then {
                        [] spawn {
                            sleep 0.1;
                        };
                    };
                };

                
                switch (_role) do {

                    case "driver": {
                        _unit moveInDriver _veh;
                    };

                    case "gunner": {
                        _unit moveInGunner _veh;
                    };

                    case "commander": {
                        _unit moveInCommander _veh;
                    };

                    case "turret": {

                        if (_turretPath isEqualType []) then {
                            _unit moveInTurret [_veh, _turretPath];
                        } else {
                            _unit moveInCargo _veh;
                        };
                    };

                    default {
                        _unit moveInCargo _veh;
                    };
                };

            } forEach _seats;

        } forEach _vehicles;

        _BRNDefendTeams pushBack _grp;
	};

	_BRNDefendTeams
};
DAN_CreateBRNSniperTeams = {
	params ["_pos"];
	
	if (DAN_BRNSniperTeams isEqualTo []) exitWith {
		if (DAN_DEBUG) then { systemChat "[DAN_DEBUG] No BRN Sniper Teams defined, skipping creation."; };
	};
	private _hill = selectBestPlaces [_pos, 1000, "hills", 1, 5];
	private _hillpos = (selectRandom _hill) select 0;	
    private _BRNSniperTeams = [];

	private _players = allPlayers select {isPlayer _x};
	private _countPlayers = count _players;

	private _playerGroups = ceil ((_countPlayers max 1) / 6);
	private _ORFGroups = _playerGroups * DAN_OpforMultiply;

	for "_i" from 1 to _ORFGroups do {

		private _team = selectRandom DAN_BRNSniperTeams;
		private _grp  = createGroup east;

		private _vehicles = [];
		private _infantry = [];


		{
			private _class = _x;

			if (getNumber (configFile >> "CfgVehicles" >> _class >> "isMan") == 0) then {

				private _vehPos = [
					_hillpos,
					1, 
					80, 
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
					_class, _hillpos, [], 5, "NONE"
				];
				if (!isMultiplayer) then {
					[] spawn {
						sleep 0.1;
					};
				};
				_infantry pushBack _unit;
			};

		} forEach _team;
		[] spawn {
			sleep 0.5;
		};

		{
			private _veh = _x;
			private _seats = fullCrew [_veh, "", true];

			{
				private _role = _x select 1;
				private _turretPath = if (count _x > 2) then {_x select 2} else {[]};

				private _unit = objNull;

				
				if (_infantry isNotEqualTo []) then {
					_unit = _infantry deleteAt 0;
				} else {
					
					_unit = _grp createUnit [
						"O_G_Soldier_F",
						position _veh,
						[],
						5,
						"NONE"
					];
					if (!isMultiplayer) then {
						[] spawn {
							sleep 0.1;
						};
					};
				};

				
				switch (_role) do {

					case "driver": {
						_unit moveInDriver _veh;
					};

					case "gunner": {
						_unit moveInGunner _veh;
					};

					case "commander": {
						_unit moveInCommander _veh;
					};

					case "turret": {

						if (_turretPath isEqualType []) then {
							_unit moveInTurret [_veh, _turretPath];
						} else {
							_unit moveInCargo _veh;
						};
					};

					default {
						_unit moveInCargo _veh;
					};
				};

			} forEach _seats;

		} forEach _vehicles;

		_BRNSniperTeams pushBack _grp;
	};

	_BRNSniperTeams
};
DAN_CreateBRNAntiAirTeams = {
	params ["_pos"];
    
    if (DAN_BRNAntiAirTeams isEqualTo []) exitWith {
        if (DAN_DEBUG) then { systemChat "[DAN_DEBUG] No BRN Anti-Air Teams defined, skipping creation."; };
    };
    private _hill = selectBestPlaces [_pos, 1000, "hills", 1, 5];
	private _hillpos = (selectRandom _hill) select 0;	
	private _BRNAntiAirTeams = [];

    private _players = allPlayers select {isPlayer _x};
    private _countPlayers = count _players;

    private _playerGroups = ceil ((_countPlayers max 1) / 6);
    private _ORFGroups = _playerGroups * DAN_OpforMultiply;

	for "_i" from 1 to _ORFGroups do {

        private _team = selectRandom DAN_BRNAntiAirTeams;
        private _grp  = createGroup east;

        private _vehicles = [];
        private _infantry = [];


        {
            private _class = _x;

            if (getNumber (configFile >> "CfgVehicles" >> _class >> "isMan") == 0) then {

                private _vehPos = [
                    _hillpos,
                    1, 
                    80, 
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
                    _class, _hillpos, [], 5, "NONE"
                ];
                if (!isMultiplayer) then {
                    [] spawn {
                        sleep 0.1;
                    };
                };
                _infantry pushBack _unit;
            };

        } forEach _team;
        [] spawn {
            sleep 0.5;
        };

        {
            private _veh = _x;
            private _seats = fullCrew [_veh, "", true];

            {
                private _role = _x select 1;
                private _turretPath = if (count _x > 2) then {_x select 2} else {[]};

                private _unit = objNull;

                
                if (_infantry isNotEqualTo []) then {
                    _unit = _infantry deleteAt 0;
                } else {
                    
                    _unit = _grp createUnit [
                        "O_G_Soldier_F",
                        position _veh,
                        [],
                        5,
                        "NONE"
                    ];
                    if (!isMultiplayer) then {
                        [] spawn {
                            sleep 0.1;
                        };
                    };
                };

                
                switch (_role) do {

                    case "driver": {
                        _unit moveInDriver _veh;
                    };

                    case "gunner": {
                        _unit moveInGunner _veh;
                    };

                    case "commander": {
                        _unit moveInCommander _veh;
                    };

                    case "turret": {

                        if (_turretPath isEqualType []) then {
                            _unit moveInTurret [_veh, _turretPath];
                        } else {
                            _unit moveInCargo _veh;
                        };
                    };

                    default {
                        _unit moveInCargo _veh;
                    };
                };

            } forEach _seats;

        } forEach _vehicles;

        _BRNAntiAirTeams pushBack _grp;
	};

	_BRNAntiAirTeams
};
DAN_CreateBRNNavalTeams = {
	params ["_pos"];
    
    if (DAN_BRNBoatTeams isEqualTo []) exitWith {
        if (DAN_DEBUG) then { systemChat "[DAN_DEBUG] No BRN Boat Teams defined, skipping creation."; };
    };
    private _sea = selectBestPlaces [_pos, 5000, "sea", 1, 3];
    private _seapos = (_sea select 0) select 0;
	private _BRNNavalTeams = [];

    private _players = allPlayers select {isPlayer _x};
    private _countPlayers = count _players;

    private _playerGroups = ceil ((_countPlayers max 1) / 6);
    private _ORFGroups = _playerGroups * DAN_OpforMultiply;

	for "_i" from 1 to _ORFGroups do {

        private _team = selectRandom DAN_BRNBoatTeams;
        private _grp  = createGroup east;

        private _vehicles = [];
        private _infantry = [];


        {
            private _class = _x;

            if (getNumber (configFile >> "CfgVehicles" >> _class >> "isMan") == 0) then {

                private _vehPos = [
                    _seapos,
                    1, 
                    80, 
                    5, 
                    2, 
                    20, 
                    1
                ] call BIS_fnc_findSafePos;

                private _veh = createVehicle [_class, _vehPos, [], 0, "NONE"];
                _veh setDir random 360;

                _vehicles pushBack _veh;

            } else {

                private _unit = _grp createUnit [
                    _class, _seapos, [], 5, "NONE"
                ];
                if (!isMultiplayer) then {
                    [] spawn {
                        sleep 0.1;
                    };
                };
                _infantry pushBack _unit;
            };

        } forEach _team;
        [] spawn {
            sleep 0.5;
        };

        {
            private _veh = _x;
            private _seats = fullCrew [_veh, "", true];

            {
                private _role = _x select 1;
                private _turretPath = if (count _x > 2) then {_x select 2} else {[]};

                private _unit = objNull;

                
                if (_infantry isNotEqualTo []) then {
                    _unit = _infantry deleteAt 0;
                } else {
                    
                    _unit = _grp createUnit [
                        "O_G_Soldier_F",
                        position _veh,
                        [],
                        5,
                        "NONE"
                    ];
                    if (!isMultiplayer) then {
                        [] spawn {
                            sleep 0.1;
                        };
                    };
                };

                
                switch (_role) do {

                    case "driver": {
                        _unit moveInDriver _veh;
                    };

                    case "gunner": {
                        _unit moveInGunner _veh;
                    };

                    case "commander": {
                        _unit moveInCommander _veh;
                    };

                    case "turret": {

                        if (_turretPath isEqualType []) then {
                            _unit moveInTurret [_veh, _turretPath];
                        } else {
                            _unit moveInCargo _veh;
                        };
                    };

                    default {
                        _unit moveInCargo _veh;
                    };
                };

            } forEach _seats;

        } forEach _vehicles;

        _BRNNavalTeams pushBack _grp;
	};

	_BRNNavalTeams
};
DAN_CreateBRNCommander = {
    params ["_pos"];
    if (DAN_BRNCommanderClass isEqualTo []) exitWith {
        if (DAN_DEBUG) then { systemChat "[DAN_DEBUG] No BRN Commander classes defined, skipping commander creation."; };
    };
    private _commanderClass = selectRandom DAN_BRNCommanderClass;

    private _grp = createGroup [east, true];

    private _commander = _grp createUnit [
        _commanderClass,
        _pos,
        [],
        5,
        "NONE"
    ];

    if (DAN_BRNCommanderNames isEqualTo []) then {
        _name = selectRandom DAN_BRNCommanderNames;
        _commander setName _name;
    };
    _commander setVariable ["IEDmaker", true, true];
    private _IEDMakernameList = missionNamespace getVariable ["IEDMakernameList", []];
    _IEDMakernameList pushBack (name _commander);
    missionNamespace setVariable ["IEDMakernameList", _IEDMakernameList];
    private _taskID = name _commander;
    private _previewPath = [_commander] call DAN_getpic;
        private _taskDesc = format [
            "<t align='center'><img size='6' image='%1'/></t><br/><br/>"
            + "<t size='1.3' color='#ffffff'>Name:</t> <t color='#ff3333'>%2</t><br/>"
            + "BRN Commander",
            _previewPath,
            _taskID
        ];
        
        [
            true,
            _taskID,
            [_taskDesc, "BRN commander", "capture or kill him"],
            getPosATL Objnull,
            true
        ] call BIS_fnc_taskCreate;
    _commander
};
DAN_CreateBRNArtilleryTeams = {
	params ["_pos"];
    if (DAN_BRNArtilleryTeams isEqualTo []) exitWith {
        if (DAN_DEBUG) then { systemChat "[DAN_DEBUG] No BRN Artillery Teams defined, skipping creation."; };
    };
    private _hill = selectBestPlaces [_pos, 1000, "hills", 1, 5];
	private _hillpos = (selectRandom _hill) select 0;	
	private _BRNArtilleryTeams = [];

    private _players = allPlayers select {isPlayer _x};
    private _countPlayers = count _players;

    private _playerGroups = ceil ((_countPlayers max 1) / 6);
    private _ORFGroups = _playerGroups * DAN_OpforMultiply;

	for "_i" from 1 to _ORFGroups do {

        private _team = selectRandom DAN_BRNArtilleryTeams;
        private _grp  = createGroup east;

        private _vehicles = [];
        private _infantry = [];


        {
            private _class = _x;

            if (getNumber (configFile >> "CfgVehicles" >> _class >> "isMan") == 0) then {

                private _vehPos = [
                    _hillpos,
                    1, 
                    80, 
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
                    _class, _hillpos, [], 5, "NONE"
                ];
                if (!isMultiplayer) then {
                    [] spawn {
                        sleep 0.1;
                    };
                };
                _infantry pushBack _unit;
            };

        } forEach _team;
        [] spawn {
            sleep 0.5;
        };

        {
            private _veh = _x;
            private _seats = fullCrew [_veh, "", true];

            {
                private _role = _x select 1;
                private _turretPath = if (count _x > 2) then {_x select 2} else {[]};

                private _unit = objNull;

                
                if (_infantry isNotEqualTo []) then {
                    _unit = _infantry deleteAt 0;
                } else {
                    
                    _unit = _grp createUnit [
                        "O_G_Soldier_F",
                        position _veh,
                        [],
                        5,
                        "NONE"
                    ];
                    if (!isMultiplayer) then {
                        [] spawn {
                            sleep 0.1;
                        };
                    };
                };

                
                switch (_role) do {

                    case "driver": {
                        _unit moveInDriver _veh;
                    };

                    case "gunner": {
                        _unit moveInGunner _veh;
                    };

                    case "commander": {
                        _unit moveInCommander _veh;
                    };

                    case "turret": {

                        if (_turretPath isEqualType []) then {
                            _unit moveInTurret [_veh, _turretPath];
                        } else {
                            _unit moveInCargo _veh;
                        };
                    };

                    default {
                        _unit moveInCargo _veh;
                    };
                };

            } forEach _seats;

        } forEach _vehicles;

        _BRNArtilleryTeams pushBack _grp;
	};

	_BRNArtilleryTeams
};
DAN_CreateBRNTankTeams = {
	params ["_pos"];
    
    if (DAN_BRNTankTeams isEqualTo []) exitWith {
        if (DAN_DEBUG) then { systemChat "[DAN_DEBUG] No BRN Tank Teams defined, skipping creation."; };
    };
    private _meadow = selectBestPlaces [
        _pos,
        1500,
        "(1 - houses) * (1 - forest) * (1 - hills)",
        30,
        20
    ];
    private _meadowpos = (_meadow select 0) select 0;
    if (DAN_DEBUG_BRNHQ) then {
        private _markerName = format ["TANK_%1", round (random 99999)];
        private _marker = createMarker [_markerName, _meadowpos];

        _marker setMarkerShape "ICON";
        _marker setMarkerType "mil_dot";
        _marker setMarkerColor "ColorRed";
        _marker setMarkerSize [0.7,0.7];
        _marker setMarkerText "tank";
    };
	private _BRNTankTeams = [];

    private _players = allPlayers select {isPlayer _x};
    private _countPlayers = count _players;

    private _playerGroups = ceil ((_countPlayers max 1) / 6);
    private _ORFGroups = _playerGroups * DAN_OpforMultiply;

	for "_i" from 1 to _ORFGroups do {

        private _team = selectRandom DAN_BRNTankTeams;
        private _grp  = createGroup east;

        private _vehicles = [];
        private _infantry = [];


        {
            private _class = _x;

            if (getNumber (configFile >> "CfgVehicles" >> _class >> "isMan") == 0) then {

                private _veh = createVehicle [_class, _meadowpos, [], 0, "NONE"];
                _veh setDir random 360;

                _vehicles pushBack _veh;

            } else {

                private _unit = _grp createUnit [
                    _class, _meadowpos, [], 5, "NONE"
                ];
                if (!isMultiplayer) then {
                    [] spawn {
                        sleep 0.1;
                    };
                };
                _infantry pushBack _unit;
            };

        } forEach _team;
        [] spawn {
            sleep 0.5;
        };

        {
            private _veh = _x;
            private _seats = fullCrew [_veh, "", true];

            {
                private _role = _x select 1;
                private _turretPath = if (count _x > 2) then {_x select 2} else {[]};

                private _unit = objNull;

                
                if (_infantry isNotEqualTo []) then {
                    _unit = _infantry deleteAt 0;
                } else {
                    
                    _unit = _grp createUnit [
                        "O_G_Soldier_F",
                        position _veh,
                        [],
                        5,
                        "NONE"
                    ];
                    if (!isMultiplayer) then {
                        [] spawn {
                            sleep 0.1;
                        };
                    };
                };

                
                switch (_role) do {

                    case "driver": {
                        _unit moveInDriver _veh;
                    };

                    case "gunner": {
                        _unit moveInGunner _veh;
                    };

                    case "commander": {
                        _unit moveInCommander _veh;
                    };

                    case "turret": {

                        if (_turretPath isEqualType []) then {
                            _unit moveInTurret [_veh, _turretPath];
                        } else {
                            _unit moveInCargo _veh;
                        };
                    };

                    default {
                        _unit moveInCargo _veh;
                    };
                };

            } forEach _seats;

        } forEach _vehicles;

        _BRNTankTeams pushBack _grp;
	};

	_BRNTankTeams
};
DAN_CreateBRNHQ = {
    if (!isServer) exitWith {};

    private _Allmkr = allMapMarkers;
    private _rkkMarkers = _Allmkr select {
        (toLower _x) find "rkk" > -1
    };
    if (_rkkMarkers isEqualTo []) exitWith {
        if (DAN_DEBUG) then { systemChat "[DAN_DEBUG] [DAN_CreateBRNHQ] No RKK marker found"; };
    };
    {
		private _mkr = _x;
        private _markerSize = getMarkerSize _mkr;
        private _markerPos  = getMarkerPos _mkr;

        
        private _rawHomes = nearestTerrainObjects [
            _markerPos,
            ["HOUSE"],
            _markerSize select 0,
            false
        ];
        private _homes = _rawHomes select {
            private _cfg = configOf _x;
            private _sim = toLower getText (_cfg >> "simulation");
            private _cls = toLower typeOf _x;

            
            !(
                _sim in ["ruin","wreck"] ||       
                {_cls find "ruin"  > -1} ||       
                {_cls find "wreck" > -1}          
            )
        };
        if (_homes isEqualTo []) exitWith {
            if (DAN_DEBUG) then {
                systemChat "[DAN_DEBUG] [DAN_CreateBRNHQ] No buildings found, calling bomb mission";
            };
            
        };
        private _BRNHQ = selectRandom _homes;        
        private _BRNHQPos = getPosATL _BRNHQ;       
        _BRNHQ setVariable ["BRNHQ", true, true];
        private _BRNHQtrg = createTrigger ["EmptyDetector", _BRNHQPos];

        _BRNHQtrg setVariable ["myowner", _BRNHQ, true];
        _BRNHQ setVariable ["mytrigger", _BRNHQtrg, true];

        private _allHQ = missionNamespace getVariable ["BRNHQ_LIST", []];
        _allHQ pushBack _BRNHQ;
        missionNamespace setVariable ["BRNHQ_LIST", _allHQ, true];
        _BRNHQ addEventHandler ["Killed", {
            params ["_unit", "_killer", "_instigator", "_useEffects"];

            private _allHQ = missionNamespace getVariable ["BRNHQ_LIST", []];

            _allHQ = _allHQ - [_unit]; 

            missionNamespace setVariable ["BRNHQ_LIST", _allHQ, true];
            if (DAN_DEBUG_BRNHQ) then {
                systemChat format ["DEBUG: BRN HQ destroyed. Remaining HQs: %1", count _allHQ];
            };
        }];

        _BRNHQtrg setTriggerArea [1000, 1000, 0, false, 20];
        _BRNHQtrg setTriggerActivation ["WEST", "PRESENT", true];

        _BRNHQtrg setTriggerStatements
        [
            "this",
            "thisTrigger setVariable ['captured', true, true];",
            "thisTrigger setVariable ['captured', false, true];"
        ];

        if (DAN_DEBUG_BRNHQ) then {

            private _markerName = format ["DAN_BRNHQ_%1", round (random 99999)];
            private _marker = createMarker [_markerName, _BRNHQPos];

            _marker setMarkerShape "ICON";
            _marker setMarkerType "mil_dot";
            _marker setMarkerColor "ColorRed";
            _marker setMarkerSize [0.7,0.7];
            _marker setMarkerText "BRN HQ";

        };
        [_BRNHQPos] call DAN_CreateBRNCommander;
        [_BRNHQPos] call DAN_CreateBRNDefendTeams;
        [_BRNHQPos] call DAN_CreateBRNSniperTeams;
        [_BRNHQPos] call DAN_CreateBRNAntiAirTeams;
        [_BRNHQPos] call DAN_CreateBRNArtilleryTeams;
        [_BRNHQPos] call DAN_CreateBRNNavalTeams;
        [_BRNHQPos] call DAN_CreateBRNTankTeams;

    } forEach _rkkMarkers;
};
["CBA_loadingScreenDone", {
    if (DAN_EnableBRNHQ) then {
        [] call DAN_CreateBRNHQ;
    };
}] call CBA_fnc_addEventHandler;