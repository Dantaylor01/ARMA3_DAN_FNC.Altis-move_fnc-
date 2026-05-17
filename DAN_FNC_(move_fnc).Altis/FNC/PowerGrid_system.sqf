DAN_PowerGridSystem = {

	if (!isServer) exitWith {};

	private _keywords_main = [
		"dp_mainfactory", 
		"dp_smallfactory", 
		"dpp_01_mainfactory", 
		"dpp_01_smallfactory", 
		"dpp_01_watercooler"
	];
	private _keywords_sub = [
		"Land_dp_transformer_F", 
		"Land_spp_Transformer_F", 
		"Land_DPP_01_transformer_F",
		"spp_transformer_f",
		"dp_transformer_f",
		"garbage_square5_f"
	];

	private _centerPos = getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition");
	private _allBuildings = nearestObjects [_centerPos, ["House", "Building"], worldSize];

	private _matchesKeyword = {
		params ["_typeName", "_keywords"];
		private _t = toLower _typeName;
		_keywords findIf { _t find toLower _x > -1 } > -1
	};

	private _mainStations = _allBuildings select {
		[typeOf _x, _keywords_main] call _matchesKeyword
	};

	private _subStations = _allBuildings select {
		[typeOf _x, _keywords_sub] call _matchesKeyword
	};

	if (_mainStations isEqualTo [] && _subStations isEqualTo []) exitWith {
		if (DAN_DEBUG) then {
			systemChat "[DEBUG][DAN_PowerGridSystem] No power stations or transformers found in the map.";
		};
	};

	if (DAN_DEBUG) then {
		systemChat format [
			"[DEBUG][DAN_PowerGridSystem] Found %1 main powerstations and %2 transformers.",
			count _mainStations, count _subStations
		];
	};

	private _powerGrid = [];

	{
		private _main = _x;
		private _connectedSubs = _subStations select { _x distance _main < 3000 };
		_powerGrid pushBack [_main, _connectedSubs];
	} forEach _mainStations;

	missionNamespace setVariable ["powerGridNetwork", _powerGrid, true];

	
	missionNamespace setVariable ["DAN_fnc_cutPowerArea", {
		params ["_center", ["_radius", 1500]];
		{
			_x setHit ["light_1_hitpoint", 0.97];
			_x setHit ["light_2_hitpoint", 0.97];
			_x setHit ["light_3_hitpoint", 0.97];
			_x setHit ["light_4_hitpoint", 0.97];
		} forEach (nearestObjects [_center, ["Lamps_base_F","PowerLines_base_F","PowerLines_Small_base_F"], _radius]);
	}];

	
	missionNamespace setVariable ["DAN_fnc_restorePowerArea", {
		params ["_center", ["_radius", 1500]];
		{
			_x setHit ["light_1_hitpoint", 0];
			_x setHit ["light_2_hitpoint", 0];
			_x setHit ["light_3_hitpoint", 0];
			_x setHit ["light_4_hitpoint", 0];
		} forEach (nearestObjects [_center, ["Lamps_base_F","PowerLines_base_F","PowerLines_Small_base_F"], _radius]);
	}];

	
	{
		private _main = _x;
		_main setVariable ["DAN_PowerState", true, true]; 

        if (isServer) then
        {    
            [_main,
            ["<t color='#ff2222' shadow='2' size='1.2'><img size='1.5' image='\A3\ui_f\data\IGUI\Cfg\Actions\ico_off_ca.paa'/> Shutdown Power</t>",
            { 
                params ["_target"];
                private _cutPower = missionNamespace getVariable ["DAN_fnc_cutPowerArea", {}];
                private _pos = getPos _target;
                [_pos, 2000] call _cutPower;
                hint format ["⚡ Power station at %1 has been shut down.", mapGridPosition _pos];
                playSound3D ["A3\Sounds_F\sfx\alarm\alarm_independent.wss", _target];
                _target setVariable ["DAN_PowerState", false, true];
            }]] remoteExec ["addAction", 0, true]; 

            [_main,
            ["<t color='#22ff22' shadow='2' size='1.2'><img size='1.5' image='\A3\ui_f\data\IGUI\Cfg\Actions\ico_on_ca.paa'/> Restore Power</t>",
            { 
                params ["_target"];
                private _restorePower = missionNamespace getVariable ["DAN_fnc_restorePowerArea", {}];
                private _pos = getPos _target;
                [_pos, 2000] call _restorePower;
                hint format ["💡 Power restored at %1.", mapGridPosition _pos];
                playSound3D ["A3\Sounds_F\sfx\alarm\alarm_independent.wss", _target];
                _target setVariable ["DAN_PowerState", true, true];
            }]] remoteExec ["addAction", 0, true]; 
        };

		_main addEventHandler ["Killed", {
			params ["_unit"];
			private _grid = missionNamespace getVariable ["powerGridNetwork", []];
			private _cutPower = missionNamespace getVariable ["DAN_fnc_cutPowerArea", {}];
			private _entry = _grid select { (_x select 0) isEqualTo _unit };
			if (_entry isEqualTo []) exitWith {};
			private _subs = (_entry select 0) select 1;
			[getPos _unit, 2000] call _cutPower;
			{ [getPos _x, 1200] call _cutPower; } forEach _subs;
		}];
	} forEach _mainStations;

	
	{
		private _sub = _x;
		_sub setVariable ["DAN_PowerState", true, true];

        if (isServer) then
        {    
            [_sub,
            ["<t color='#ffaa00' shadow='2' size='1.2'><img size='1.5' image='\A3\ui_f\data\IGUI\Cfg\Actions\ico_off_ca.paa'/> Shutdown Transformer</t>",
            { 
                params ["_target"];
                private _cutPower = missionNamespace getVariable ["DAN_fnc_cutPowerArea", {}];
                private _pos = getPos _target;
                [_pos, 1200] call _cutPower;
                hint format ["🔌 Transformer at %1 shut down.", mapGridPosition _pos];
                playSound3D ["A3\Sounds_F\sfx\alarm\alarm_independent.wss", _target];
                _target setVariable ["DAN_PowerState", false, true];
            }]] remoteExec ["addAction", 0, true]; 

            [_sub,
            ["<t color='#22ffaa' shadow='2' size='1.2'><img size='1.5' image='\A3\ui_f\data\IGUI\Cfg\Actions\ico_on_ca.paa'/> Restore Transformer</t>",
            { 
                params ["_target"];
                private _restorePower = missionNamespace getVariable ["DAN_fnc_restorePowerArea", {}];
                private _pos = getPos _target;
                [_pos, 1200] call _restorePower;
                hint format ["🔋 Transformer restored at %1.", mapGridPosition _pos];
                playSound3D ["A3\Sounds_F\sfx\alarm\alarm_independent.wss", _target];
                _target setVariable ["DAN_PowerState", true, true];
            }]] remoteExec ["addAction", 0, true]; 
        };

		_sub addEventHandler ["Killed", {
			params ["_unit"];
			private _cutPower = missionNamespace getVariable ["DAN_fnc_cutPowerArea", {}];
			[getPos _unit, 1200] call _cutPower;
		}];
	} forEach _subStations;

	if (DAN_DEBUG) then {
		hint format [
			"[PowerGrid] setup complete (%1 main, %2 transformers)",
			count _mainStations, count _subStations
		];
	};
};
call DAN_PowerGridSystem;
