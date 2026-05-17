
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
[getpos player] call DAN_CreateBRNTankTeams;