
"━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
"       RKK missions         ";
"━━━━━━━━━━━━━━━━━━━━━━━━━━━━";

DAN_missions = ["HVT","bomb","hostage","VIP","siege","Rescue"];
/*
DAN_CreateRKKTeams = {
	params ["_pos"];
	private _RKKs = [];
    private _players = allPlayers select {isPlayer _x};
    private _countPlayers = count _players;

    private _playerGroups = ceil ((_countPlayers max 1) / 6);

    private _rkkGroups = _playerGroups * DAN_OpforMultiply;
	private _num = _rkkGroups;
	for "_i" from 1 to (_num) do {
        private _team = selectRandom DAN_RKKteams;
        private _grp  = createGroup east;

        private _vehicles = [];
        private _infantry = [];


        {
            private _class = _x;

            if (getNumber (configFile >> "CfgVehicles" >> _class >> "isMan") == 0) then {

                private _vehPos = [
                    _pos, 10, 80, 5, 0, 20, 0
                ] call BIS_fnc_findSafePos;

                private _veh = createVehicle [_class, _vehPos, [], 0, "NONE"];
                _veh setDir random 360;

                _vehicles pushBack _veh;

            } else {

                private _unit = _grp createUnit [
                    _class, _pos, [], 5, "NONE"
                ];
                if (!isMultiplayer) then {
                    []  spawn {
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

        _RKKs pushBack _grp;
	};
	_RKKs
};

DAN_CreateGarrisonTeams = {
	params ["_pos"];
	private _GarrisonTeams = [];
    private _players = allPlayers select {isPlayer _x};
    private _countPlayers = count _players;

    private _playerGroups = ceil ((_countPlayers max 1) / 6);

    private _rkkGroups = _playerGroups * DAN_OpforMultiply;
	private _num = _rkkGroups;
	for "_i" from 1 to (_num) do {
        private _team = selectRandom DAN_GarrisonTeams;
        private _grp  = createGroup east;

        private _vehicles = [];
        private _infantry = [];


        {
            private _class = _x;

            if (getNumber (configFile >> "CfgVehicles" >> _class >> "isMan") == 0) then {

                private _vehPos = [
                    _pos, 10, 80, 5, 0, 20, 0
                ] call BIS_fnc_findSafePos;

                private _veh = createVehicle [_class, _vehPos, [], 0, "NONE"];
                _veh setDir random 360;

                _vehicles pushBack _veh;

            } else {

                private _unit = _grp createUnit [
                    _class, _pos, [], 5, "NONE"
                ];
                if (!isMultiplayer) then {
                    []  spawn {
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

        _GarrisonTeams pushBack _grp;
	};
	_GarrisonTeams
};
*/

DAN_HVT = {
	params ["_name","_pos"];
    if !(DAN_EnableHVT) exitWith {
        call DAN_bomb;
    };
    private _rkkMarkers = allMapMarkers select {(toLower _x) find "rkk" > -1};

    if (_rkkMarkers isEqualTo []) exitWith {
        if (DAN_DEBUG) then { systemChat "[DAN_DEBUG] [DAN_hostage] No RKK marker found"; };
    };

    private _rkkMarker  = selectRandom _rkkMarkers;
    private _markerSize = getMarkerSize _rkkMarker;
    private _markerPos  = getMarkerPos _rkkMarker;

    
    private _rawHomes = nearestTerrainObjects [
        _markerPos,
        ["CHURCH", "LIGHTHOUSE", "house", "BUILDING", "HOSPITAL"],
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
            systemChat "[DAN_DEBUG] [DAN_hostage] No buildings found, calling bomb mission";
        };
        [] call DAN_bomb;
    };
    
    private _home = selectRandom _homes;
    private _homePos = getPosATL _home;
    private _safePos = [_homePos, 0, 15, 2, 0, 0.3, 0] call BIS_fnc_findSafePos;
    
    private _classname = selectRandom DAN_HVTclass;
    private _side = (getNumber (configFile >> "CfgVehicles" >> _classname >> "side")) call BIS_fnc_sideType;
    private _grp = createGroup _side;
    private _HVT = _grp createUnit [_classname, _homePos, [], 0, "FORM"];
   
    [_HVT, _safePos, _homePos] spawn {
        params ["_HVT", "_safePos", "_homePos"];
        
        waitUntil {!isNull _HVT};
        sleep 1.0;
       	private _taskID = name _HVT;
        
        private _GarTeam = [_safePos] call DAN_CreateGarrisonTeams;
        sleep 1.0;
        [_GarTeam] call DAN_taskGarrison;
        [_GarTeam,_taskID] call DAN_extra;
        private _DefTeam = [_safePos] call DAN_CreateBRNDefendTeams;
        sleep 1.0;
		[_DefTeam,_taskID] call DAN_extra;
        
    		
		
        
        
        private _previewPath = [_HVT] call DAN_getpic;
                
        private _taskDesc = format [
            "<t align='center'><img size='6' image='%1'/></t><br/><br/>"
            + "<t size='1.3' color='#ffffff'>Name:</t> <t color='#ff3333'>%2</t><br/>"
            + "<t size='1.0' color='#aaaaaa'>Grid: %3</t><br/><br/>"
            + "he is the leader of RKK",
            _previewPath,
            _taskID,
            mapGridPosition _homePos
        ];
        
        [
            true,
            _taskID,
            [_taskDesc, "HVT", "capture or kill him"],
            getPosATL _HVT,
            true
        ] call BIS_fnc_taskCreate;
        
        [_taskID, "ASSIGNED"] call BIS_fnc_taskSetState;
        _HVT setVariable ["taskID", _taskID, true];
        

        [_homePos,daytime,_taskID ] call DAN_CreateMissionCIVAmbient;
		if (DAN_random) then {
            [_HVT] spawn {
                params ["_HVT"];
                sleep 2.0;
                [_HVT] call DAN_DeadCallBRNMotorTeams;
                [_HVT] call DAN_2ndbomb;
                [] remoteExec ["DAN_MissionDynamicWeather"];
            };
		};
		
    };


};
DAN_bomb = {
	
	if !(DAN_EnableBomb) exitWith {
        call DAN_hostage;
    };
	_foundIED = [];
	_foundIEDcontainer = [];
	{
		_foundIED append (allMissionObjects _x);
	} forEach DAN_allarmedbombs;
	
	{
		_foundIEDcontainer append (allMissionObjects _x);
	} forEach DAN_IEDContainerclass;
	
	{
		private _booster = _x getVariable ["mybooster", objNull];
		if (!isNull _booster) then {
			_foundIED pushBack _booster;
		};
	} forEach _foundIEDcontainer;
	
	
	private _availableIEDs = _foundIED select {
		!(_x getVariable ["evidenced", false])
	};
	
	if (count _availableIEDs == 0) exitWith {
		if (DAN_DEBUG) then {
			systemChat "[DEBUG][DAN_bomb] No available IEDs found for evidence mission, calling another mission instead.";
		};
		[] call DAN_hostage;
	};
	
	private _IED = selectRandom _availableIEDs;	
	private _IEDPos = getPos _IED;

	private _RKK = _IED getVariable ["mybomber", grpNull];
	
	private _taskID = format ["evidence%1", floor (random 100000)];
	
	_IED setVariable ["taskID", _taskID, true];
	_IED setVariable ["evidenced", true, true];
	private _leader = leader _RKK;
	

	private _container = _IED getVariable ["mycontainer", objNull];
	[_RKK,_taskID] call DAN_extra;
	[_container, _taskID] call DAN_extra;
	private _marker = createMarker [_taskID, _IEDPos]; 
	_marker setMarkerShape "ELLIPSE";
	_marker setMarkerSize [100, 100];
	_marker setMarkerText "511";
	_marker setMarkerColor "#(1,0,0,1)";
	private _mkPos = getMarkerPos _marker;
	_IED setVariable ["mymarker",_marker];
	[_marker,_taskID] call DAN_extra;
	missionNamespace setVariable [_taskID + "_marker", _marker, true];

	private _taskTitle = "511";
	private _taskDesc = "find IED in red circle and disarm it before it explodes";

	[
		west,
		[_taskID],
		[_taskDesc, _taskTitle, ""],
		objNull,
		"ASSIGNED", 
		1, 
		true, 
		"mine", 
		true
	] call BIS_fnc_taskCreate;
	


	_IED addEventHandler ["Explode", {
		params ["_projectile", "_position", "_velocity"];
		private _taskID = _projectile getVariable ["taskID", ""];
		private _marker = missionNamespace getVariable [_taskID + "_marker", ""];     
		if (_taskID isEqualType "" && {_taskID != ""}) then {
			[_taskID, "CANCELED", true] remoteExecCall ["BIS_fnc_taskSetState", 0];
            missionNamespace setVariable ["DAN_MissionIsRunning", false, true];
			if (_marker != "") then {
				deleteMarker _marker;
			};
		};				
		private _officer = missionNamespace getVariable ["inquiryOfficial", objNull]; 
		

		
	}];

};
DAN_hostage = {
    if !(DAN_EnableHostage) exitWith {
        call DAN_VIP;
    };
    private _rkkMarkers = allMapMarkers select {(toLower _x) find "rkk" > -1};
    
    if (_rkkMarkers isEqualTo []) exitWith {  
		 
        if (DAN_DEBUG) then {
            systemChat "[DAN_DEBUG] [DAN_hostage] No RKK marker found";
        }; 
    };
    
    private _rkkMarker = selectRandom _rkkMarkers;
    private _markerSize = getMarkerSize _rkkMarker;
    private _markerPos = getMarkerPos _rkkMarker;
    
    private _homes = nearestTerrainObjects [
        _markerPos, 
        ["CHURCH", "LIGHTHOUSE", "house", "BUILDING", "HOSPITAL"], 
        _markerSize select 0, 
        false
    ];
    
    if (_homes isEqualTo []) exitWith {
        if (DAN_DEBUG) then {
            systemChat "[DAN_DEBUG] [DAN_hostage] No buildings found, calling bomb mission";
        };
        [] call DAN_VIP;
    };
    
    private _home = selectRandom _homes;
    private _homePos = getPosATL _home;
    private _safePos = [_homePos, 0, 15, 2, 0, 0.3, 0] call BIS_fnc_findSafePos;
    
    private _classname = selectRandom DAN_hostageclass;
    private _side = (getNumber (configFile >> "CfgVehicles" >> _classname >> "side")) call BIS_fnc_sideType;
    private _grp = createGroup _side;
    private _pow = _grp createUnit [_classname, _homePos, [], 0, "FORM"];
    
    removeAllWeapons _pow;
    removeBackpack _pow;
    removeHeadgear _pow;
    removeGoggles _pow;
    _pow setCaptive true;
    _pow playAction "Surrender";
    
    [_pow, _safePos, _homePos] spawn {
        params ["_pow", "_safePos", "_homePos"];
        
        waitUntil {!isNull _pow};
        sleep 1.0;
		private _RKKs = [_safePos] call DAN_CreateGarrisonTeams;
		_RKK = selectRandom _RKKs;
        private _lead = leader _RKK;
        private _powpos = getPosATL _pow;
        _lead setVariable ["myhostage", _pow, true];

        _lead setPosATL _powpos;
        
        sleep 1.0;
        _lead lookAt _pow;
       	{
			[_x] call DAN_taskGarrison;
            sleep 2.0;
		} foreach _RKKs;

        private _taskID = name _pow;

        private _previewPath = [_pow] call DAN_getpic;
        
        if (_previewPath isEqualTo "") then {
            _previewPath = "\A3\EditorPreviews_F\Data\CfgVehicles\Default.jpg";
        };
        
        private _taskDesc = format [
            "<t align='center'><img size='6' image='%1'/></t><br/><br/>"
            + "<t size='1.3' color='#ffffff'>Name:</t> <t color='#ff3333'>%2</t><br/>"
            + "<t size='1.0' color='#aaaaaa'>Grid: %3</t><br/><br/>"
            + "Rescue the hostage and bring him to safety",
            _previewPath,
            _taskID,
            mapGridPosition _homePos
        ];
        
        [
            true,
            _taskID,
            [_taskDesc, "Hostage Rescue", "Rescue hostage"],
            getPosATL _pow,
            true
        ] call BIS_fnc_taskCreate;
        
        [_taskID, "ASSIGNED"] call BIS_fnc_taskSetState;
        _pow setVariable ["taskID", _taskID, true];
        
        private _code = {
			params ["_thisTrigger","_thisList", "_owner"];
			if (captive _owner) then {
				playMusic "RadioAmbient21";
				titleText ["<t color='#fffdfd' size='5'>OPERATION HOSTAGE</t><br/>", "PLAIN", 0, true, true];
			};
        };
        
        private _officer = missionNamespace getVariable ["inquiryOfficial", objNull];
        [getPos _officer, 500, _pow, _code] call DAN_TriggerOwner;
        
        
        _RKK addEventHandler ["EnemyDetected", {
            params ["_group", "_newTarget"];
            private _gunman = leader _group;
            
            if (isNull _gunman || {!alive _gunman}) exitWith {
                if (DAN_DEBUG) then {
                    systemChat format ["[DEBUG][DAN_hostage] Gunman invalid or dead in group %1", _group];
                };
            };
            
            if (isNull _newTarget || {!alive _newTarget}) exitWith {
                if (DAN_DEBUG) then {
                    systemChat "[DEBUG][DAN_hostage] Invalid or dead target detected";
                };
            };
            
            private _hostage = _gunman getVariable ["myhostage", objNull];
            
            if (isNull _hostage) exitWith {
                if (DAN_DEBUG) then {
                    systemChat "[DEBUG][DAN_hostage] No hostage assigned to gunman";
                };
            };
            
            if (DAN_DEBUG) then {
                systemChat format [
                    "[DEBUG][DAN_hostage] %1 detected %2, targeting hostage %3",
                    name _gunman,
                    name _newTarget,
                    name _hostage
                ];
            };
            
            _hostage setCaptive false;
			_grp = createGroup west;
            [_hostage] joinSilent _grp;
            _hostage allowFleeing 1;
            _gunman doTarget _hostage;
            _gunman doWatch _hostage;
            if (DAN_DEBUG) then {
                systemChat format [
                    "[DEBUG][DAN_hostage] EnemyDetected EH added "
                ];
            };
        }];

        if (isServer) then
        {            
            [_pow,
            ["<t color='#0206fd' shadow='2' size='1.3'><img size='2' image='\A3\ui_f\data\IGUI\Cfg\Actions\talk_ca.paa'/> join me!!!!!</t>",
            { 
                params ["_target", "_caller", "_actionId"];
                if (!alive _target) exitWith {};	
                [_target] join _caller;
            }]] remoteExec ["addAction", 0, true]; 
        };
		[_RKKs,_taskID] call DAN_extra;     
		[_powpos,daytime,_taskID ] call DAN_CreateMissionCIVAmbient;
		if (DAN_random) then {
            [_pow] spawn {
                params ["_pow"];
                sleep 2.0;
			    [_pow] call DAN_DeadCallBRNMotorTeams;
			    [_pow] call DAN_2ndbomb;
                [] remoteExec ["DAN_MissionDynamicWeather"];
            };
		};
    };
};
DAN_VIP = {
	params ["_name","_des"];
    if !(DAN_EnableVIP) exitWith {
        call DAN_siege;
    };
	private _Allmkr = allMapMarkers;
	private _rkkMarkers = _Allmkr select {
		(toLower _x) find "rkk" > -1
	};
	if (_rkkMarkers isEqualTo []) exitWith {
		call DAN_bomb;	 
		if (DAN_DEBUG) then {
			systemChat "[DAN_DEBUG] [DAN_VIP] there is no rkk marker";
		}; 
	};

	private _rkkMarker = selectRandom _rkkMarkers;
	private _sMkr = getMarkerSize _rkkMarker;						
	private _pMkr = getMarkerPos  _rkkMarker;

	private _homes = nearestTerrainObjects [_pMkr, ["house","BUILDING","HOSPITAL","TRANSMITTER"], (_sMkr select 0), false];	
	private _home = selectRandom _homes;

	if (isNull _home) exitWith {
		call DAN_siege;	 
		if (DAN_DEBUG) then {
			systemChat "[DAN_DEBUG] [DAN_VIP] there is no building destination found";
		}; 
	};
	private _des = getpos _home;

	private _runways = nearestObjects [_pMkr, ["Land_Runway_PAPI"], worldSize * 1.5];

	
	if (_runways isEqualTo []) exitWith {
		call DAN_bomb;	 
		if (DAN_DEBUG) then {
			systemChat "[DAN_DEBUG] [DAN_VIP] there is no airport found";
		}; 
	};

	private _airports = _runways apply {
		private _pos = getPosATL _x;
		private _nearestLocation = nearestLocation [_pos, "NameLocal"];
		[_pos, _nearestLocation]
	};
	private _airport = _airports select 0;

	private _airpos = _airport select 0;
	private _class = selectRandom DAN_civclass;

	private _side = civilian;
	private _grp  = createGroup _side;
	private _VIP  = _grp createUnit [_class, _airpos, [], 0, "NONE"];
    if (call DAN_random1in2) then {
        [_VIP] call DAN_2ndbomb;
    };	

	[_VIP,_home,_des] spawn {
		params ["_VIP","_home","_des"];
		waitUntil { !isNull _VIP };
		sleep 1.0;
		_VIP setBehaviour "SAFE";
		_grp = createGroup (side player);
		[_VIP] joinSilent _grp;
		
		private _taskID = name _VIP;
		private _marker = createMarker [_taskID, _home]; 
		_marker setMarkerType "hd_dot";
		_marker setMarkerText "deliver VIP here";
		_marker setMarkerColor "#(1,0,0,1)"; 
		_VIP setvariable ["mymarker",_marker];
		
		private _vipPreview = [_VIP] call DAN_getpic;
		
		
		private _homePreview = [_home] call DAN_getpic;
		[_home] call DAN_2ndbomb;
		
		private _taskDesc = format [
			"<t align='center'><img size='2' image='%1'/></t><br/>"
			+ "<t size='0.8' color='#ffffff'>VIP:</t> <t color='#ff3333'>%2</t><br/><br/>"
			+ "<t align='center'><img size='2' image='%3'/></t><br/>"
			+ "<t size='0.8' color='#ffffff'>Destination:</t> <t color='#33ff33'>%4</t><br/><br/>"
			+ "escort VIP, don't use handcuffs on him, and bring him to the destination safely.",
			_vipPreview,
			_taskID,
			_homePreview,
			mapGridPosition _des
		];
		
		[
			true,
			_taskID,
			[
				_taskDesc,
				"escort VIP",
				""
			],
			getPosATL _VIP,
			true
		] call BIS_fnc_taskCreate;
    

		[_taskID, "ASSIGNED"] call BIS_fnc_taskSetState;
		_VIP setVariable ["taskID", _taskID, true];
		_VIP setVariable ["myhome", _des, true];
		_VIP addEventHandler ["Killed", {
			params ["_unit", "_killer", "_instigator", "_useEffects"];
			private _marker = _unit getvariable ["mymarker",""];
			deleteMarker _marker;
		}];
        if (isServer) then
        {    
            [_VIP,
            ["<t color='#0206fd' shadow='2' size='1.3'><img size='2' image='\A3\ui_f\data\IGUI\Cfg\Actions\talk_ca.paa'/> join me!!!!!</t>",
            { 
                params ["_target", "_caller", "_actionId"];
                if (!alive _target) exitWith {};
                [_target] join _caller;
            }]] remoteExec ["addAction", 0, true]; 
        };
		

		_onactcomplete = {
			params ["_thisTrigger","_thisList", "_owner"];
			
			private _taskID = _owner getVariable ["taskID", ""];
			if ( !(_taskID isEqualTo "") && { allPlayers findIf { !alive _x } == -1 }) then {
				[_taskID, "SUCCEEDED"] call BIS_fnc_taskSetState;
                missionNamespace setVariable ["DAN_MissionIsRunning", false, true];
				[_taskID] call DAN_CleanupExtra;
				private _marker = _owner getvariable ["mymarker",""];
				deleteMarker _marker;
				deleteVehicle _owner;
				deleteVehicle _thisTrigger;
				if (DAN_DEBUG) then {
					if (isNull _thisTrigger) then {
						systemChat "[DAN_DEBUG] [DAN_VIP] task complete delete trigger";
					};
				};
				private _officer = missionNamespace getVariable ["inquiryOfficial", objNull]; 
				


			};
			
		};
		_onactambu = {
			params ["_thisTrigger","_thisList", "_owner"];
			if !(isOnRoad _owner)  exitWith {};
			private _pos = getPos _owner;
			private _homePos = _owner getVariable ["myhome", [0,0,0]];
			private _midPoint = _pos vectorAdd ((_homePos vectorDiff _pos) vectorMultiply 0.5);
			private _iedPos = getPos ((_midPoint nearRoads 50) select 0);
			private _dista = _pos distance _homePos;
			if (DAN_DEBUG) then {
				systemChat format ['[DAN_2ndbomb] Distance between positions: %1', _dista];
			};
			private _foundUnits = allUnits select {
				side _x isEqualTo west && _x distance _iedPos < 100
			};

			if (_foundUnits isEqualTo []) then {
				
				[_iedPos,50] call DAN_RKKsetbomb;
				if (DAN_DEBUG) then {
					systemChat '[DAN_2ndbomb] Placed IED successfully';
				};

			} else {
				
				systemChat format ['Unit %1 is too close to the trigger, not placing IED', name _owner];
			};			

			
		};		
		[getpos _home,1000,_VIP,_onactambu] call DAN_TriggerOwner;
		[getpos _home,10,_VIP,_onactcomplete] call DAN_TriggerOwner;
		[getpos _home,daytime,_taskID ] call DAN_CreateMissionCIVAmbient;
        [] remoteExec ["DAN_MissionDynamicWeather"];
	};



};
DAN_siege = {
    params ["_name","_pos"];
    if !(DAN_EnableSiege) exitWith {
        call DAN_Rescue;
    };
    private _Allmkr = allMapMarkers;
    private _rkkMarkers = _Allmkr select { (toLower _x) find "rkk" > -1 };

    if (_rkkMarkers isEqualTo []) exitWith {
        if (DAN_DEBUG) then {
            systemChat "[DAN_DEBUG] [DAN_siege] there is no rkk marker";
        };
    };

    private _rkkMarker = selectRandom _rkkMarkers;
    private _sMkr = getMarkerSize _rkkMarker;
    private _pMkr = getMarkerPos _rkkMarker;

    private _searchRadius = (_sMkr select 0);

    private _allPos = [];
    for "_i" from 1 to 200 do {
        private _r = random _searchRadius;
        private _a = random 360;
        private _px = (_pMkr#0) + (sin _a) * _r;
        private _py = (_pMkr#1) + (cos _a) * _r;
        private _pz = getTerrainHeightASL [_px,_py];
        _allPos pushBack [_px,_py,_pz];
    };

    private _mountains = _allPos select { _x#2 > 80 };

    if (_mountains isEqualTo []) exitWith {
        if (DAN_DEBUG) then {
            systemChat "[DAN_DEBUG] [DAN_siege] No mountain positions found.";
        };
        call DAN_SearchAndRescue;
    };

    private _RKKcampPos = selectRandom _mountains;
    private _safePos = [_RKKcampPos, 0, 15, 2, 0, 1, 0] call BIS_fnc_findSafePos;
    private _campPosATL = ASLToATL _RKKcampPos;
	private _RKKs = [_campPosATL] call DAN_CreateBRNDefendTeams;
	private _RKK = selectRandom _RKKs;

	[_RKK, _campPosATL, 50] call lambs_wp_fnc_taskCamp;

    private _leadclass = selectRandom DAN_HVTclass;
    private _side = (getNumber (configFile >> "CfgVehicles" >> _leadclass >> "side")) call BIS_fnc_sideType;
    private _grp = createGroup _side;
    private _HVT = _grp createUnit [_leadclass, _campPosATL, [], 0, "FORM"];
	private _lead = _HVT;

    
    private _campObjects = [];
    
    
    private _numTents = 4;
    private _tentRadius = 6;

    for "_i" from 0 to (_numTents - 1) do {
        private _angle = _i * (360 / _numTents);
        private _offset = [
            _tentRadius * sin(_angle),
            _tentRadius * cos(_angle),
            0
        ];

        private _posTent = _campPosATL vectorAdd _offset;

        private _tent = createVehicle ["Land_TentA_F", _posTent, [], 0, "NONE"];
        _tent setVectorUp (surfaceNormal _posTent);
        
        
        _campObjects pushBack _tent;
    };

    
    private _fire = createVehicle ["Campfire_burning_F", _campPosATL, [], 0, "NONE"];
    _fire setVectorUp (surfaceNormal _campPosATL);
    
    
    _campObjects pushBack _fire;

    
    [_campPosATL, _RKKs, _lead, _campObjects] spawn {
        params ["_campPosATL","_RKKs","_lead","_campObjects"];

        waitUntil { !isNull _lead };
        sleep 1;

        private _nameOBJ = name _lead;
        sleep 1;
        _lead setVariable ["taskID", _nameOBJ, true];
        private _previewPath = [_lead] call DAN_getpic;

        if (_previewPath isEqualTo "") then {
            _previewPath = "\A3\EditorPreviews_F\Data\CfgVehicles\Default.jpg";
        };

        private _taskDesc = format [
            "<t align='center'><img size='6' image='%1'/></t><br/><br/>" +
            "<t size='1.3' color='#ffffff'>Target:</t> <t color='#ff3333'>%2</t><br/><br/>" +
            "Eliminate or capture the High Value Target (HVT).",
            _previewPath,
            _nameOBJ
        ];

        private _taskID = _nameOBJ;
        
        
        [_RKKs, _taskID] call DAN_extra;
                        
        {
            [_x, _taskID] call DAN_extra;
        } forEach _campObjects;

        [
            true,
            _taskID,
            [
                _taskDesc,
                "siege",
                "Eliminate RKK team"
            ],
            _campPosATL,
            true
        ] call BIS_fnc_taskCreate;
		[_taskID, "ASSIGNED"] call BIS_fnc_taskSetState;       

        private _code = {
            params ["_thisTrigger","_thisList","_owner"];
            if (captive _owner) then {
                playMusic "RadioAmbient21";
                titleText ["<t color='#fffdfd' size='5'>OPERATION SIEGE</t><br/>", "PLAIN", 0, true, true];
            };
        };

        private _officer = missionNamespace getVariable ["inquiryOfficial", objNull];
        [getPos _officer, 500, _lead, _code] call DAN_TriggerOwner;
		if (DAN_random) then {
            [_lead] spawn {
                params ["_lead"];
                sleep 2.0;
                [_lead] call DAN_DeadCallBRNMotorTeams;
			    [_lead] call DAN_2ndbomb;
                [] remoteExec ["DAN_MissionDynamicWeather"];
            }

		};
		
    };
};

DAN_SearchAndRescue ={
    if !(DAN_EnableRescue) exitWith {
        call DAN_HVT;
    };
    private _rkkMarkers = allMapMarkers select {(toLower _x) find "rkk" > -1};
    
    if (_rkkMarkers isEqualTo []) exitWith {     
        if (DAN_DEBUG) then {
            systemChat "[DAN_DEBUG] [DAN_hostage] No RKK marker found";
        }; 
    };
    
    private _rkkMarker = selectRandom _rkkMarkers;
    private _markerSize = getMarkerSize _rkkMarker;
    private _markerPos = getMarkerPos _rkkMarker;
    private _villages = nearestLocations [_markerPos, ["NameVillage", "NameCity", "NameCityCapital"], _markerSize select 0];

    private _homes = [];

    if (_villages isEqualTo []) then {
        if (DAN_DEBUG) then {
            systemChat "[DAN_DEBUG] [DAN_hostage] No village found, searching from marker position";
        };
        
        _homes = nearestTerrainObjects [
            _markerPos, 
            ["CHURCH", "LIGHTHOUSE", "house", "BUILDING", "HOSPITAL"], 
            _markerSize select 0, 
            false
        ];
    } else {
        private _village = selectRandom _villages;
        private _villagePos = locationPosition _village;
        private _villageSize = (size _village) select 0;
        
        if (DAN_DEBUG) then {
            systemChat format ["[DAN_DEBUG] [DAN_hostage] Found village: %1 at %2", text _village, mapGridPosition _villagePos];
        };
        
        _homes = nearestTerrainObjects [
            _villagePos, 
            ["CHURCH", "LIGHTHOUSE", "house", "BUILDING", "HOSPITAL"], 
            _villageSize, 
            false
        ];
    };

    if (_homes isEqualTo []) exitWith {
        if (DAN_DEBUG) then {
            systemChat "[DAN_DEBUG] [DAN_hostage] No buildings found, calling bomb mission";
        };
        [] call DAN_HVT;
    };
    
    private _home = selectRandom _homes;
    private _homePos = getPosATL _home;
    private _safePos = [_homePos, 0, 15, 2, 0, 0.3, 0] call BIS_fnc_findSafePos;
    
    private _classname = selectRandom DAN_hostageclass;
    private _side = (getNumber (configFile >> "CfgVehicles" >> _classname >> "side")) call BIS_fnc_sideType;
    private _grp = createGroup _side;
    private _pow = _grp createUnit [_classname, _homePos, [], 0, "FORM"];
    
    removeAllWeapons _pow;
    removeBackpack _pow;
    removeHeadgear _pow;
    removeGoggles _pow;	
	
    _pow setCaptive true;
    _pow playAction "Surrender";
    
    [_pow, _safePos, _homePos, _homes] spawn {
        params ["_pow", "_safePos", "_homePos", "_homes"];
        
        waitUntil {!isNull _pow};
        sleep 1;
        private _taskID = name _pow;
        private _RKKs = [_safePos] call DAN_CreateGarrisonTeams;
        [_RKKs, _taskID] call DAN_extra;
        {
            [_x] call DAN_taskGarrison;
            sleep 2.0;
        } foreach _RKKs;
        
        [_pow] call DAN_taskGarrison;
                
        [
            _homePos,
            50,
            1,
            1,
            true,
            "1,2,3",         
            true             
        ] call DAN_doorlock;

        private _previewPath = [_pow] call DAN_getpic;
        
        
        private _taskDesc = "";
        
        if (DAN_random) then {
            private _time = selectRandom [15, 20, 25, 30];
            [_pow, _time] call DAN_attachbomb;
            
            private _currentTime = daytime;
            private _bombTime = _currentTime + (_time / 60); 
            if (_bombTime >= 24) then {
                _bombTime = _bombTime - 24;
            };

            private _hours = floor _bombTime;
            private _minutes = round ((_bombTime - _hours) * 60);


            if (_minutes >= 60) then {
                _hours = _hours + 1;
                _minutes = _minutes - 60;
            };

            private _timeString = format ["%1:%2", 
                if (_hours < 10) then {"0" + str _hours} else {str _hours},
                if (_minutes < 10) then {"0" + str _minutes} else {str _minutes}
            ];

            
            _taskDesc = format [
                "<t align='center'><img size='6' image='%1'/></t><br/><br/>"
                + "<t size='1.3' color='#ffffff'>Name:</t> <t color='#ff3333'>%2</t><br/>"
                + "<t size='1.0' color='#aaaaaa'>Grid: %3</t><br/>"
                + "<t size='4' color='#ff0000'>⚠ Bomb Detonation: %4</t><br/><br/>"
                + "find buiding and break the door, find him and bring him back",
                _previewPath,
                _taskID,
                mapGridPosition _homePos,
                _timeString
            ];
        } else {
            _taskDesc = format [
                "<t align='center'><img size='6' image='%1'/></t><br/><br/>"
                + "<t size='1.3' color='#ffffff'>Name:</t> <t color='#ff3333'>%2</t><br/>"
                + "<t size='1.0' color='#aaaaaa'>Grid: %3</t><br/><br/>"
                + "find buiding and break the door, find him and bring him back",
                _previewPath,
                _taskID,
                mapGridPosition _homePos
            ];
        };
        
        [
            true,
            _taskID,
            [_taskDesc, "Search And Rescue", "Rescue hostage"],
            objNull,
            "ASSIGNED"
        ] call BIS_fnc_taskCreate;
        [_taskID, "ASSIGNED"] call BIS_fnc_taskSetState;

        _pow setVariable ["taskID", _taskID, true];
      
        private _code = {
            params ["_thisTrigger", "_thisList", "_owner"];

            playMusic "RadioAmbient21";
            titleText ["<t color='#fffdfd' size='5'>OPERATION Search And Rescue</t><br/>", "PLAIN", 0, true, true];
        };
        
        private _officer = missionNamespace getVariable ["inquiryOfficial", objNull];
        [getPos _officer, 500, _pow, _code] call DAN_TriggerOwner;
        if (isServer) then
        {    
            [_pow,
            ["<t color='#0206fd' shadow='2' size='1.3'><img size='2' image='\A3\ui_f\data\IGUI\Cfg\Actions\talk_ca.paa'/> join me!!!!!</t>",
            { 
                params ["_target", "_caller", "_actionId"];
                if (!alive _target) exitWith {};
                [_target] join _caller;
            }]] remoteExec ["addAction", 0, true]; 
        };
        [_RKKs, _taskID] call DAN_extra;     
        [_homePos, daytime, _taskID] call DAN_CreateMissionCIVAmbient;
		if (DAN_random) then {
            [_pow] spawn {
                params ["_pow"];    
                sleep 2.0;
			    [_pow] call DAN_DeadCallBRNMotorTeams;
			    [_pow] call DAN_2ndbomb;
                
            };
		};
    };
};

DAN_CreateRKKTeams = {

	params ["_pos"];

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
			selectRandom DAN_RKKteams;

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
DAN_CreateGarrisonTeams = {

	params ["_pos"];

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
			selectRandom DAN_GarrisonTeams;

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