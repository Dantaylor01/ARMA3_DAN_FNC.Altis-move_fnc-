DAN_V = "Last Modified: 2026-05-12 22:37:00";


#include "setting.sqf";
#include "welcome_text.sqf";
#include "respawn_systems.sqf";
#include "inquiryOfficial_systems.sqf";
#include "arsenal_systems.sqf";
#include "IED_systems.sqf";
#include "BRN_HQ_mission.sqf";
#include "RKK_missions.sqf";
#include "vehicle_door.sqf";
#include "CreateMissionCIVAmbient.sqf";
#include "CreateDynaCIVAmbient.sqf";
#include "undercover_systems.sqf";
#include "PowerGrid_system.sqf";
#include "door_lock_systems.sqf";
#include "extra.sqf";
#include "DeadCallBRNMotorTeams.sqf";
#include "CaptiveEH.sqf";
#include "garrison_systems.sqf";
#include "CSI.sqf";
#include "RandomTimeAndWeather.sqf";
#include "sound_track.sqf";
#include "addRTP_jam_command.sqf";
#include "stop_missfire_artillery_trigger.sqf";
#include "fix_vehicle.sqf";
#include "resizeRKKMarkers.sqf";
#include "ClearCrimeScene.sqf";
#include "CleanupExtra.sqf";
#include "BehindEnemyLine.sqf";
DAN_random = true;
DAN_random1in2 = {
    selectRandom [true, false]
};
DAN_random1in3 = {
    selectRandom [true,false,false]
};

DAN_spawndog = {
	params ["_obj"];
	_obj addAction [
		"<t color='#964B00' shadow='2' size='1.3'><img size='2' image='\A3\ui_f\data\IGUI\Cfg\Actions\animal_ca.paa'/> Spawn K9 Dog</t>",
		{
			params ["_target", "_caller", "_actionId", "_arguments"];
			private _dogs = ["MFR_B_GermanShepherd","MFR_B_GermanShepherd_Black","MFR_B_Shepinois"]; 
			private _dog = selectRandom _dogs; 
			private _classname = _dog;
			private _side = (getNumber (configfile >> "CfgVehicles" >> _classname >> "side")) call BIS_fnc_sideType;
			private _grp = createGroup _side;
			private _k9 = _grp createUnit [_classname, _caller, [], 0, "FORM"];

			
		},
		nil,
		1.5,
		true,
		true,
		"",
		"alive _target && (_target distance _this) < 5",
		50,
		false,
		"",
		""
	];

};




DAN_warehouse = {
	params ["_obj"];
	_obj addAction [
		"<t color='#964B00' shadow='2' size='1.3'><img size='2' image='\A3\ui_f\data\IGUI\Cfg\Actions\animal_ca.paa'/> Spawn K9 Dog</t>",
		{
			params ["_target", "_caller", "_actionId", "_arguments"];
			private _dogs = ["MFR_B_GermanShepherd","MFR_B_GermanShepherd_Black","MFR_B_Shepinois"]; 
			private _dog = selectRandom _dogs; 
			private _classname = _dog;
			private _side = (getNumber (configfile >> "CfgVehicles" >> _classname >> "side")) call BIS_fnc_sideType;
			private _grp = createGroup _side;
			private _k9 = _grp createUnit [_classname, _caller, [], 0, "FORM"];

			
		},
		nil,
		1.5,
		true,
		true,
		"",
		"true",
		50,
		false,
		"",
		""
	];
};

DAN_doctor = {
	params ["_unit"];
	
};



DAN_TriggerOwner = {
    params [
        ["_pos", [1000,1000,0], [[]]],
        ["_size", 15, [0]],
        ["_owner", objNull, [objNull]],
        ["_actcode", {}, [{}]],
        ["_deactcode", {}, [{}]],
        ["_autoDelete", false, [false]]
    ];
    
    private _trg = createTrigger ["EmptyDetector", _pos];
    _trg setTriggerArea [_size, _size, 0, false];
    _trg setTriggerActivation ["ANY", "PRESENT", false];
    _trg setTriggerTimeout [0, 0, 0, true];
    _trg setVariable ["DAN_owner", _owner];
    _trg setVariable ["DAN_actcode", _actcode];
    _trg setVariable ["DAN_deactcode", _deactcode];
    
    _owner setVariable ["mytrigger", _trg];
    
    _owner addEventHandler ["Killed", {
        params ["_unit", "_killer", "_instigator", "_useEffects"];
        private _trg = _unit getVariable ["mytrigger", objNull];
        
        if (!isNull _trg) then {
            deleteVehicle _trg;
            
            if (DAN_DEBUG) then {
                systemChat "[DAN_DEBUG] [DAN_triggerOwner] killedEH deleted trigger";
            };
        };
    }];
    
    
    private _activationCode = "[thisTrigger, thisList, (thisTrigger getVariable 'DAN_owner')] call (thisTrigger getVariable 'DAN_actcode');";
    
    if (_autoDelete) then {
        _activationCode = _activationCode + " deleteVehicle thisTrigger;";
    };
    
    
    private _deactivationCode = "";
    
    if (str _deactcode != "{}") then {
        _deactivationCode = "[thisTrigger, thisList, (thisTrigger getVariable 'DAN_owner')] call (thisTrigger getVariable 'DAN_deactcode');";
    };
    
    _trg setTriggerStatements [
        "this && (thisList findIf {_x isEqualTo (thisTrigger getVariable 'DAN_owner')} > -1)",
        _activationCode,
        _deactivationCode
    ];
    
    if (DAN_DEBUG) then {
        systemChat format [
            "[DEBUG][DAN_TriggerOwner] Created trigger at %1 for %2 (autoDelete: %3, hasDeactivation: %4)", 
            _pos, 
            name _owner, 
            _autoDelete,
            (_deactivationCode != "")
        ];
    };
    
    _trg
};





DAN_addintel = {
    params ["_unit", "_data", ["_pic", "", [""]]];

    [_unit, "acex_intelitems_notepad", _data] call ace_intelitems_fnc_addIntel;

   
    if (_pic != "") then {
        [_unit, "acex_intelitems_photo", _pic] call ace_intelitems_fnc_addIntel;
    };
};

DAN_getpic = {
    params ["_input"];

    private _classname = if (_input isEqualType "") then {_input} else {typeOf _input};

    private _paths = [
        configFile >> "CfgVehicles",
        configFile >> "CfgWeapons",
        configFile >> "CfgMagazines",
        configFile >> "CfgGlasses",
        configFile >> "CfgBackpacks",
        configFile >> "CfgAmmo"
    ];

    private _pic = "";
    private _config = configNull;

    
    {
        if (isClass (_x >> _classname)) exitWith {
            _config = _x >> _classname;
            _pic = getText (_config >> "editorPreview");
        };
    } forEach _paths;

    
    if (_pic isEqualTo "" && !isNull _config) then {
        
        _pic = getText (_config >> "icon");
        
        
        if (_pic isEqualTo "") then {
            _pic = getText (_config >> "picture");
        };
        
        
        if (_pic isEqualTo "") then {
            _pic = getText (_config >> "texture");
        };
        
        
        if (_pic isEqualTo "") then {
            _pic = getText (_config >> "model");
        };
    };

    
    if (_pic isEqualTo "") then {
        _pic = "\A3\EditorPreviews_F\Data\CfgVehicles\Default.jpg";
    };

    _pic
};

DAN_abductor = {
    params ["_unit"];

    group _unit addEventHandler ["EnemyDetected", {
        params ["_group", "_newTarget"];
        if !(_newTarget getVariable ["ACE_isUnconscious", false]) exitWith {};
        private _ab = leader _group;
        private _dis = _ab distance2D _newTarget;
        private _carrydis = 3;
        
        if (_dis > _carrydis) exitWith {};

        
        private _nearPlayers = allPlayers select {
            (_x != _newTarget)
            && (_x distance2D _newTarget < 50)
            && (alive _x)
        };

        if !( _nearPlayers isEqualTo [] ) exitWith {
            if (DAN_DEBUG) then {
                systemChat "[DEBUG] Capture aborted: players nearby.";
            };
        };

 
        private _houses = nearestObjects [_ab, ["House"], 50];

        if (_houses isEqualTo []) exitWith {
            if (DAN_DEBUG) then {
                systemChat "[DEBUG] No houses found within 50m.";
            };
        };

        
        private _house = selectRandom _houses;

        
        private _positions = [];
        private _i = 0;
        while {true} do {
            private _p = _house buildingPos _i;
            if (_p isEqualTo [0,0,0]) exitWith {};
            _positions pushBack _p;
            _i = _i + 1;
        };

        if (_positions isEqualTo []) exitWith {
            if (DAN_DEBUG) then {
                systemChat "[DEBUG] House has no building positions.";
            };
        };

        
        private _targetPos = selectRandom _positions;

        
        _newTarget setPosASL _targetPos;

        if (DAN_DEBUG) then {
            systemChat format [
                "[DEBUG] %1 moved to house at %2",
                name _newTarget, _targetPos
            ];
        };
        [_newTarget,10]call DAN_attachbomb;  

    }];
};

DAN_garage = {
    params ["_obj"];
    _obj addAction [
        "<t color='#0206fd' shadow='2' size='1.3'><img size='2' image='\A3\ui_f\data\IGUI\Cfg\Actions\talk_ca.paa'/> open garage</t>",
        {
			params ["_target", "_caller", "_actionId", "_arguments"];
            ["Open", [true, _target]] call BIS_fnc_garage;
        },
        nil, 1.5, true, true, "", "(_target distance _this) < 10"  
    ];
};



DAN_InvestCrimeScene = {
	params ["_pos"];
	[_VIP,_home,_des] spawn {
		params ["_VIP","_home","_des"];

		
		private _taskID = name _VIP;
		private _marker = createMarker [_taskID, _home]; 
		_marker setMarkerType "hd_dot";
		_marker setMarkerText "investigation here";
		_marker setMarkerColor "#(1,0,0,1)"; 
		_VIP setvariable ["mymarker",_marker];
		
		private _vipPreview = [_VIP] call DAN_getpic;
		
		
		private _homePreview = [_home] call DAN_getpic;
		
		
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
		_VIP setVariable ["myhome", _homePos, true];
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
				
				systemChat format ['Unit %1 is too close to the trigger, not placing IED', name _unit];
			};			

			
		};		
		[getpos _home,1000,_VIP,_onactambu] call DAN_TriggerOwner;
		[getpos _home,10,_VIP,_onactcomplete] call DAN_TriggerOwner;
		[getpos _home,daytime,_taskID ] call DAN_CreateMissionCIVAmbient;
	};



};

DAN_OpforArmy = {

    params [
        ["_faction", "", [""]],
        ["_groupCount", 3, [0]],
        ["_marker", "", ["",0]],
        ["_difficulty", 1, [0]], 
        ["_enableDynamics", true, [true]]
    ];

    if (_faction isEqualTo "") exitWith {
        diag_log "[AI COMMANDER] ERROR: No faction provided";
    };

    private _markerPos = if (_marker isEqualType "") then {
        getMarkerPos _marker
    } else {
        getPos player
    };

    private _markerSize = if (_marker isEqualType "") then {
        (getMarkerSize _marker) select 0
    } else {
        _marker
    };

    private _side = switch (getNumber (configFile >> "CfgFactionClasses" >> _faction >> "side")) do {
        case 0: { east };
        case 1: { west };
        case 2: { resistance };
        case 3: { civilian };
    };

    if (isNil "DAN_AI_Commander_Bases") then {
        DAN_AI_Commander_Bases = [];
    };

    private _baseID = format ["BASE_%1_%2", _faction, random 99999];



    private _analyzeTerrainAdvanced = {
        params ["_pos", "_radius"];
        
        private _buildings = nearestObjects [_pos, ["House","Building"], _radius];
        private _roads = _pos nearRoads _radius;
        private _forests = nearestTerrainObjects [_pos, ["TREE","SMALL TREE","BUSH"], _radius];
        
        private _elevation = getTerrainHeightASL _pos;
        
        
        private _waterDepth = abs (getTerrainHeightASL _pos);
        private _isWater = surfaceIsWater _pos;
        
        
        private _nearestShore = [_pos, _radius * 2] call {
            params ["_center", "_searchRadius"];
            private _bestShore = _center;
            private _minDist = 9999;
            
            for "_angle" from 0 to 350 step 10 do {
                private _testPos = _center getPos [_searchRadius, _angle];
                if (!surfaceIsWater _testPos && _testPos distance _center < _minDist) then {
                    _minDist = _testPos distance _center;
                    _bestShore = _testPos;
                };
            };
            _bestShore
        };
        
        private _distanceToShore = _pos distance _nearestShore;
        
      
        private _waterCoverage = 0;
        for "_i" from 0 to 7 do {
            private _testPos = _pos getPos [_radius * 0.5, _i * 45];
            if (surfaceIsWater _testPos) then {
                _waterCoverage = _waterCoverage + 0.125;
            };
        };
        
       
        private _urbanDensity = (count _buildings / (_radius / 50)) min 1;
        private _forestDensity = (count _forests / (_radius / 10)) min 1;
        private _roadDensity = (count _roads / (_radius / 30)) min 1;
        
        
        private _defensibility = (_elevation / 100) + (_urbanDensity * 0.3) + (_forestDensity * 0.2);
        private _accessibility = _roadDensity * 0.5 + (1 - _forestDensity) * 0.3;
        private _concealment = _forestDensity * 0.6 + _urbanDensity * 0.4;
        
      
        private _terrainType = "open";
        
        if (_isWater && _waterDepth > 10) then { 
            _terrainType = "deep_water" 
        };
        if (_isWater && _waterDepth <= 10 && _waterDepth > 3) then { 
            _terrainType = "shallow_water" 
        };
        if (_waterCoverage > 0.6 && !_isWater) then { 
            _terrainType = "coastal" 
        };
        if (_waterCoverage > 0.3 && _waterCoverage <= 0.6) then { 
            _terrainType = "beachhead" 
        };
        if (_urbanDensity > 0.4 && _waterCoverage < 0.3) then { 
            _terrainType = "urban" 
        };
        if (_forestDensity > 0.5 && _waterCoverage < 0.3) then { 
            _terrainType = "forest" 
        };
        
        [
            _terrainType,
            _defensibility,
            _accessibility,
            _concealment,
            _buildings,
            _roads,
            _forests,
            _elevation,
            _waterDepth,
            _isWater,
            _waterCoverage,
            _distanceToShore,
            _nearestShore
        ]
    };

    private _terrainData = [_markerPos, _markerSize] call _analyzeTerrainAdvanced;
    _terrainData params [
        "_terrainType","_defensibility","_accessibility","_concealment",
        "_buildings","_roads","_forests","_elevation",
        "_waterDepth","_isWater","_waterCoverage","_distanceToShore","_nearestShore"
    ];



    private _assessThreat = {
        params ["_pos", "_radius"];
        
        private _enemyUnits = allUnits select {
            side _x != _side && 
            side _x != civilian && 
            _x distance _pos < _radius * 1.5 &&
            alive _x
        };
        
        private _enemyVehicles = vehicles select {
            side _x != _side && 
            _x distance _pos < _radius * 2 &&
            alive _x
        };
        
        private _infantryCount = count (_enemyUnits select {vehicle _x == _x});
        private _armorCount = count (_enemyVehicles select {_x isKindOf "Tank"});
        private _airCount = count (_enemyVehicles select {_x isKindOf "Air"});
        private _navalCount = count (_enemyVehicles select {_x isKindOf "Ship"});
        
        private _threatLevel = (_infantryCount * 0.1) + (_armorCount * 2) + (_airCount * 3) + (_navalCount * 2.5);
        private _threatType = "low";
        
        if (_threatLevel > 10) then { _threatType = "extreme" };
        if (_threatLevel > 5) then { _threatType = "high" };
        if (_threatLevel > 2) then { _threatType = "medium" };
        
        [_threatLevel, _threatType, _infantryCount, _armorCount, _airCount, _navalCount]
    };

    private _threatData = [_markerPos, _markerSize] call _assessThreat;
    _threatData params ["_threatLevel","_threatType","_enemyInf","_enemyArmor","_enemyAir","_enemyNaval"];



    private _timeOfDay = dayTime;
    private _isNight = (_timeOfDay < 6 || _timeOfDay > 20);
    private _weather = overcast;
    private _visibility = if (_isNight) then {0.3} else {1 - (_weather * 0.7)};



    private _findStrategicPositions = {
        params ["_centerPos", "_radius", "_count", "_terrainType"];
        
        private _positions = [];
        private _isNavalOperation = _terrainType in ["deep_water","shallow_water","coastal","beachhead"];
        
        for "_i" from 0 to (_count - 1) do {
            private _angle = (_i / _count) * 360;
            private _dist = _radius * 0.7;
            private _testPos = _centerPos getPos [_dist, _angle];
            
            
            if (_isNavalOperation) then {
                if (surfaceIsWater _testPos) then {
                   
                    _testPos = [_testPos select 0, _testPos select 1, 0];
                } else {
                  
                    _testPos = [_testPos, 0, 100, 3, 0, 20, 0] call BIS_fnc_findSafePos;
                };
            };
            
           
            private _elevScore = if (surfaceIsWater _testPos) then {
                0.5 
            } else {
                (getTerrainHeightASL _testPos) / 100
            };
            
            private _coverScore = count (nearestTerrainObjects [_testPos, ["TREE","BUSH","HOUSE"], 30]) / 10;
            private _roadScore = if (count (_testPos nearRoads 50) > 0) then {0.5} else {0};
          
            private _coastalBonus = 0;
            if (_isNavalOperation && !surfaceIsWater _testPos) then {
                private _nearWater = false;
                for "_a" from 0 to 350 step 30 do {
                    if (surfaceIsWater (_testPos getPos [50, _a])) exitWith {
                        _nearWater = true;
                    };
                };
                if (_nearWater) then { _coastalBonus = 0.7 };
            };
            
            private _score = _elevScore + _coverScore + _roadScore + _coastalBonus;
            
            _positions pushBack [_testPos, _score];
        };
        
        _positions sort false;
        _positions
    };

    private _strategicPositions = [_markerPos, _markerSize, 12, _terrainType] call _findStrategicPositions;

   
    private _hqPos = (_strategicPositions select 0) select 0;
    private _defenseRing1 = (_strategicPositions select [1,4]) apply {_x select 0};
    private _defenseRing2 = (_strategicPositions select [5,4]) apply {_x select 0};
    private _patrolPoints = (_strategicPositions select [9,3]) apply {_x select 0};



    private _calculateForceComposition = {
        params ["_threat", "_terrain", "_difficulty", "_groupCount"];
        
        private _composition = createHashMap;
        
        
        _composition set ["infantry", 0.4];
        _composition set ["mechanized", 0.2];
        _composition set ["armor", 0.1];
        _composition set ["aa", 0.1];
        _composition set ["support", 0.1];
        _composition set ["recon", 0.1];
        
   
        _composition set ["naval", 0];
        _composition set ["amphibious", 0];
        _composition set ["coastal_defense", 0];
        
     
        if (_threat == "high" || _threat == "extreme") then {
            _composition set ["armor", (_composition get "armor") + 0.15];
            _composition set ["aa", (_composition get "aa") + 0.1];
        };
        
       
        switch (_terrain) do {
            case "deep_water": {
                _composition set ["naval", 0.5];
                _composition set ["infantry", 0.1];
                _composition set ["mechanized", 0];
                _composition set ["armor", 0];
                _composition set ["amphibious", 0.2];
                _composition set ["aa", 0.2];
            };
            case "shallow_water": {
                _composition set ["naval", 0.4];
                _composition set ["amphibious", 0.3];
                _composition set ["infantry", 0.1];
                _composition set ["mechanized", 0];
                _composition set ["armor", 0];
            };
            case "coastal": {
                _composition set ["coastal_defense", 0.3];
                _composition set ["amphibious", 0.2];
                _composition set ["infantry", 0.3];
                _composition set ["naval", 0.1];
                _composition set ["mechanized", 0.1];
            };
            case "beachhead": {
                _composition set ["infantry", 0.4];
                _composition set ["coastal_defense", 0.2];
                _composition set ["amphibious", 0.2];
                _composition set ["mechanized", 0.1];
            };
            case "urban": {
                _composition set ["infantry", (_composition get "infantry") + 0.2];
                _composition set ["mechanized", (_composition get "mechanized") - 0.1];
            };
            case "forest": {
                _composition set ["infantry", (_composition get "infantry") + 0.15];
                _composition set ["recon", (_composition get "recon") + 0.1];
            };
            case "open": {
                _composition set ["armor", (_composition get "armor") + 0.15];
                _composition set ["mechanized", (_composition get "mechanized") + 0.1];
            };
        };
        
       
        private _multiplier = 1 + (_difficulty * 0.5);
        private _totalGroups = round (_groupCount * _multiplier);
        
        [_composition, _totalGroups]
    };

    private _forceData = [_threatType, _terrainType, _difficulty, _groupCount] call _calculateForceComposition;
    _forceData params ["_composition", "_totalGroups"];



    private _grpPath = configFile >> "CfgGroups";
    private _pools = createHashMap;

    {
        _pools set [_x, []];
    } forEach ["infantry","mechanized","armor","aa","support","recon","hq","naval","amphibious","coastal_defense"];

    {
        private _cat = configName _x;
        {
            private _grpClass = _x;
            private _name = toLower (configName _grpClass);
            
            switch (true) do {
                case (_cat == "Infantry"): {
                    if (_name find "recon" > -1 || _name find "sniper" > -1) then {
                        (_pools get "recon") pushBack _grpClass;
                    } else {
                        (_pools get "infantry") pushBack _grpClass;
                    };
                };
                case (_cat in ["Motorized","Mechanized"]): {
                    (_pools get "mechanized") pushBack _grpClass;
                };
                case (_cat == "Armored"): {
                    (_pools get "armor") pushBack _grpClass;
                };
                case (_cat == "Naval"): {
                    (_pools get "naval") pushBack _grpClass;
                };
                case (_name find "aa" > -1): {
                    (_pools get "aa") pushBack _grpClass;
                };
                case (_name find "support" > -1 || _name find "mortar" > -1): {
                    (_pools get "support") pushBack _grpClass;
                };
                case (_name find "hq" > -1 || _name find "command" > -1): {
                    (_pools get "hq") pushBack _grpClass;
                };
            };
            
        } forEach ("true" configClasses _x);
    } forEach ("true" configClasses (_grpPath >> str _side >> _faction));



    private _spawnGroupAdvanced = {
        params ["_grpClass","_pos","_role","_baseID"];
        
        if (isNil "_grpClass" || {isNull _grpClass}) exitWith {
            diag_log "[AI COMMANDER] ERROR: Invalid group class";
            grpNull
        };
        
        private _group = [_pos, _side, _grpClass] call BIS_fnc_spawnGroup;
        
        if (isNull _group) exitWith {
            diag_log "[AI COMMANDER] ERROR: Failed to spawn group";
            grpNull
        };
        
        _group setVariable ["DAN_Role", _role];
        _group setVariable ["DAN_BaseID", _baseID];
        _group setVariable ["DAN_SpawnTime", time];
        
        private _skillLevel = 0.3 + (_difficulty * 0.2);
        {
            _x setSkill _skillLevel;
            _x setSkill ["courage", _skillLevel + 0.2];
            _x setSkill ["commanding", _skillLevel + 0.15];
        } forEach (units _group);
        
        switch (_role) do {
            case "hq": {
                _group setBehaviour "AWARE";
                _group setCombatMode "YELLOW";
                _group setSpeedMode "LIMITED";
            };
            case "patrol": {
                _group setBehaviour "SAFE";
                _group setCombatMode "YELLOW";
                _group setSpeedMode "LIMITED";
            };
            case "naval_patrol": {
                _group setBehaviour "SAFE";
                _group setCombatMode "YELLOW";
                _group setSpeedMode "NORMAL";
            };
            case "defense": {
                _group setBehaviour "COMBAT";
                _group setCombatMode "RED";
                _group setSpeedMode "LIMITED";
            };
            case "qrf": {
                _group setBehaviour "AWARE";
                _group setCombatMode "RED";
                _group setSpeedMode "FULL";
            };
            default {
                _group setBehaviour "AWARE";
                _group setCombatMode "YELLOW";
            };
        };
        
        _group
    };



    private _spawnNavalVehicle = {
        params ["_vehicleClass","_pos","_role","_baseID"];
        
        private _vehicle = createVehicle [_vehicleClass, _pos, [], 0, "NONE"];
        private _group = createGroup _side;
        
      
        private _crewCount = [_vehicleClass, true] call BIS_fnc_crewCount;
        for "_i" from 1 to _crewCount do {
            private _unit = _group createUnit [
                getText (configFile >> "CfgVehicles" >> _vehicleClass >> "crew"),
                _pos,
                [],
                0,
                "NONE"
            ];
            _unit moveInAny _vehicle;
        };
        
        _group setVariable ["DAN_Role", _role];
        _group setVariable ["DAN_BaseID", _baseID];
        _group setVariable ["DAN_NavalVehicle", _vehicle];
        
        _group setBehaviour "SAFE";
        _group setCombatMode "YELLOW";
        
        _group
    };



    private _allGroups = [];
    private _groupsByRole = createHashMap;

 
    if (count (_pools get "hq") > 0) then {
       
        private _actualHqPos = if (_terrainType in ["deep_water","shallow_water"]) then {
            _nearestShore
        } else {
            _hqPos
        };
        
        private _hqGrp = [(_pools get "hq") select 0, _actualHqPos, "hq", _baseID] call _spawnGroupAdvanced;
        _allGroups pushBack _hqGrp;
        _groupsByRole set ["hq", [_hqGrp]];
        
        diag_log format ["[AI COMMANDER] HQ established at %1", _actualHqPos];
    };

   
    if (count (_pools get "naval") > 0 && (_composition get "naval") > 0) then {
        private _navalGroups = [];
        private _navalCount = round ((_composition get "naval") * _totalGroups) max 1;
        
        for "_i" from 1 to _navalCount do {
            
            private _navalPos = _markerPos getPos [random _markerSize, random 360];
            if (!surfaceIsWater _navalPos) then {
                
                for "_angle" from 0 to 350 step 10 do {
                    private _testPos = _markerPos getPos [_markerSize * 0.8, _angle];
                    if (surfaceIsWater _testPos) exitWith {
                        _navalPos = _testPos;
                    };
                };
            };
            
            private _navalGrp = [(_pools get "naval") select 0, _navalPos, "naval_patrol", _baseID] call _spawnGroupAdvanced;
            _allGroups pushBack _navalGrp;
            _navalGroups pushBack _navalGrp;
        };
        _groupsByRole set ["naval", _navalGroups];
        
        diag_log format ["[AI COMMANDER] Naval force deployed: %1 vessels", count _navalGroups];
    };

    
    if ((_composition get "coastal_defense") > 0) then {
        private _coastalGroups = [];
        private _coastalCount = round ((_composition get "coastal_defense") * _totalGroups) max 1;
        
        for "_i" from 1 to _coastalCount do {
            private _coastalPos = _nearestShore getPos [random 200, random 360];
            _coastalPos = [_coastalPos, 0, 100, 5, 0, 20, 0] call BIS_fnc_findSafePos;
            
            private _pool = if (count (_pools get "aa") > 0) then {
                _pools get "aa"
            } else {
                _pools get "infantry"
            };
            
            private _coastalGrp = [selectRandom _pool, _coastalPos, "defense", _baseID] call _spawnGroupAdvanced;
            _allGroups pushBack _coastalGrp;
            _coastalGroups pushBack _coastalGrp;
        };
        _groupsByRole set ["coastal_defense", _coastalGroups];
        
        diag_log format ["[AI COMMANDER] Coastal defense: %1 positions", count _coastalGroups];
    };

    
    if (count (_pools get "aa") > 0) then {
        private _aaGroups = [];
        for "_i" from 0 to (1 + _difficulty) do {
            private _pos = _defenseRing1 select (_i mod (count _defenseRing1));
            
            
            if (surfaceIsWater _pos) then {
                _pos = _nearestShore getPos [random 100, random 360];
            };
            
            private _aaGrp = [(_pools get "aa") select 0, _pos, "defense", _baseID] call _spawnGroupAdvanced;
            _allGroups pushBack _aaGrp;
            _aaGroups pushBack _aaGrp;
        };
        _groupsByRole set ["aa", _aaGroups];
    };

    
    private _combatGroups = [];
    for "_i" from 1 to _totalGroups do {
        
        private _roll = random 1;
        private _poolType = "infantry";
        private _role = "defense";
        
        private _cumulative = 0;
        {
            _cumulative = _cumulative + _y;
            if (_roll < _cumulative) exitWith {
                _poolType = _x;
            };
        } forEach _composition;
        
        
        if (_poolType in ["naval","amphibious","coastal_defense"]) then {
            continue;
        };
        
        private _pool = _pools get _poolType;
        if (count _pool == 0) then {
            _pool = _pools get "infantry";
        };
        
        private _pos = if (_i <= count _defenseRing1) then {
            _defenseRing1 select ((_i - 1) mod (count _defenseRing1))
        } else {
            _defenseRing2 select ((_i - 1) mod (count _defenseRing2))
        };
        
      
        if (surfaceIsWater _pos) then {
            _pos = _nearestShore getPos [random 100, random 360];
        };
        
        _pos = _pos getPos [random 50, random 360];
        _pos = [_pos, 0, 50, 5, 0, 20, 0] call BIS_fnc_findSafePos;
        
        private _grp = [selectRandom _pool, _pos, _role, _baseID] call _spawnGroupAdvanced;
        if (!isNull _grp) then {
            _allGroups pushBack _grp;
            _combatGroups pushBack _grp;
        };
    };
    _groupsByRole set ["combat", _combatGroups];

    
    if (count (_pools get "recon") > 0) then {
        private _reconGroups = [];
        {
            private _reconPos = _x getPos [_markerSize * 1.2, random 360];
            
            if (surfaceIsWater _reconPos) then {
                _reconPos = _nearestShore getPos [random 200, random 360];
            };
            
            private _reconGrp = [(_pools get "recon") select 0, _reconPos, "recon", _baseID] call _spawnGroupAdvanced;
            _allGroups pushBack _reconGrp;
            _reconGroups pushBack _reconGrp;
        } forEach _patrolPoints;
        _groupsByRole set ["recon", _reconGroups];
    };



    if (_enableDynamics) then {
        
       
        {
            if (!isNull _x) then {
                [_x, _markerPos, _markerSize] spawn {
                    params ["_grp","_center","_radius"];
                    
                    while {count (units _grp) > 0} do {
                        private _nextPos = _center getPos [random _radius, random 360];
                        if (surfaceIsWater _nextPos) then {
                            _nextPos = [_nextPos, 0, _radius, 3, 0, 20, 0, [], [_center, _center]] call BIS_fnc_findSafePos;
                        };
                        
                        _grp move _nextPos;
                        
                        waitUntil {
                            sleep 5;
                            (leader _grp) distance _nextPos < 50 || count (units _grp) == 0
                        };
                        
                        sleep (30 + random 60);
                    };
                };
            };
        } forEach (_groupsByRole getOrDefault ["recon", []]);
        
       
        {
            if (!isNull _x) then {
                [_x, _markerPos, _markerSize] spawn {
                    params ["_grp","_center","_radius"];
                    
                    while {count (units _grp) > 0} do {
                        private _nextPos = _center getPos [random _radius, random 360];
                        
                      
                        if (!surfaceIsWater _nextPos) then {
                            for "_angle" from 0 to 350 step 10 do {
                                _nextPos = _center getPos [_radius * 0.7, _angle];
                                if (surfaceIsWater _nextPos) exitWith {};
                            };
                        };
                        
                        _grp move _nextPos;
                        
                        waitUntil {
                            sleep 10;
                            (leader _grp) distance _nextPos < 100 || count (units _grp) == 0
                        };
                        
                        sleep (60 + random 120);
                    };
                };
            };
        } forEach (_groupsByRole getOrDefault ["naval", []]);
    };




    private _baseData = createHashMap;
    _baseData set ["id", _baseID];
    _baseData set ["faction", _faction];
    _baseData set ["position", _markerPos];
    _baseData set ["size", _markerSize];
    _baseData set ["groups", _allGroups];
    _baseData set ["groupsByRole", _groupsByRole];
    _baseData set ["terrain", _terrainType];
    _baseData set ["threat", _threatType];
    _baseData set ["spawnTime", time];
    _baseData set ["difficulty", _difficulty];

    DAN_AI_Commander_Bases pushBack _baseData;



    diag_log "============================================================================";
    diag_log format ["[AI COMMANDER] Base %1 OPERATIONAL", _baseID];
    diag_log format ["  Faction: %1 | Side: %2", _faction, _side];
    diag_log format ["  Terrain: %1 | Threat: %2 | Difficulty: %3", _terrainType, _threatType, _difficulty];
    diag_log format ["  Total Groups: %1 | Total Units: %2", count _allGroups, {count (units _x)} forEach _allGroups];
    diag_log format ["  Defense Score: %1 | Concealment: %2", _defensibility toFixed 2, _concealment toFixed 2];
    diag_log format ["  HQ Position: %1 | Elevation: %2m", _hqPos, _elevation toFixed 0];
    {
        diag_log format ["  Role '%1': %2 groups", _x, count _y];
    } forEach _groupsByRole;
    diag_log "============================================================================";

   
    _baseData
};

DAN_BlueforCommander = {
	params ["_unit"];
	_unit addAction [
		"<t color='#0206fd' shadow='2' size='1.3'><img size='2' image='\A3\ui_f\data\IGUI\Cfg\Actions\talk_ca.paa'/> WAR!!!!!</t>",
		{
			params ["_target", "_caller", "_actionId", "_arguments"];
			if (!alive _target) exitWith { };
            DAN_EnableBRNHQ = true;
            [] call DAN_CreateBRNHQ;

		},		
		nil, 1.5, true, true, "", "(_target distance _this) < 3.5"         
	];
};

DAN_FindCategoryFromFaction ={
    private _faction = "OPF_F";

    private _sideNum = getNumber (configFile >> "CfgFactionClasses" >> _faction >> "side");
    private _side = ["East","West","Indep","Civ"] select _sideNum;

    private _categories = "true" configClasses (
        configFile >> "CfgGroups" >> _side >> _faction
    );

    _categories apply { configName _x };

};

DAN_SpawnGroupByCategory = {
    params [
        "_faction",
        "_category",
        "_pos",
        ["_radius", 0]
    ];

    
    if (!isClass (configFile >> "CfgFactionClasses" >> _faction)) exitWith {grpNull};

   
    private _sideNum = getNumber (configFile >> "CfgFactionClasses" >> _faction >> "side");
    private _side = ["East","West","Indep","Civ"] select _sideNum;

    
    private _catPath = configFile >> "CfgGroups" >> _side >> _faction >> _category;
    if (!isClass _catPath) exitWith {grpNull};

    
    private _groups = "true" configClasses _catPath;
    if (_groups isEqualTo []) exitWith {grpNull};

    
    private _grpClass = selectRandom _groups;

  
    private _spawnPos = if (_radius > 0) then {
        [_pos, 0, _radius, 5, 0, 20, 0] call BIS_fnc_findSafePos
    } else {
        _pos
    };

   
    [_spawnPos, call {
        switch (_side) do {
            case "East": { east };
            case "West": { west };
            case "Indep": { resistance };
            case "Civ": { civilian };
        }
    }, _grpClass] call BIS_fnc_spawnGroup;
};

DAN_AddDiaryLocal = {
    params ["_info","_header"];

    private _fullText = format [
        "
        <t size='1.3' color='#00FFAA'>INTELLIGENCE REPORT</t><br/>
        <t size='1.1'>%1</t><br/>
        <t color='#888888'>-----------------------------------</t><br/><br/>
        %2
        ",
        _header,
        _info
    ];

    player createDiaryRecord [
        "Diary",
        [_header, _fullText]
    ];
};
DAN_GatherIntel = {

    params ["_unit","_caller"];

    if (!alive _unit) exitWith {};
    if (!isServer) exitWith {
        [_unit, _caller] remoteExecCall ["DAN_GatherIntel", 2];
    };


    private _t = daytime;
    private _h = floor _t;
    private _m = floor ((_t - _h) * 60);
    private _time = format ["%1:%2", _h, if (_m < 10) then {"0"+str _m} else {_m}];

    private _header = format ["Intel from %1 (%2)", name _unit, _time];


    private _oldInfo = _unit getVariable ["DANinfo", ""];
    if (_oldInfo != "") exitWith {

        [_unit, "acex_intelitems_notepad", _oldInfo, _header]
            call ace_intelitems_fnc_addIntel;

        [_oldInfo, _header] remoteExec ["DAN_AddDiaryLocal", _caller];
        ["Old intel added check Briefing"] remoteExec ["hint", _caller];
    };


    private _lines = [];

    private _cfgSideNum = getNumber (configFile >> "CfgVehicles" >> typeOf _unit >> "side");
    private _cfgSide = _cfgSideNum call BIS_fnc_sideType;

    private _groups = allGroups select {
        side _x == _cfgSide &&
        { count (units _x select { alive _x }) > 0 }
    };


    _groups resize 12;

    {
        private _grp = _x;
        private _leader = leader _grp;
        if (isNull _leader) then { continue };
        private _pic = getText (configFile >> "CfgVehicles" >> typeOf _leader >> "editorPreview");

        if (_pic == "") then {
            _pic = getText (configFile >> "CfgVehicles" >> typeOf _leader >> "picture");
        };
        private _factionClass = faction _leader;
        private _factionName = getText (
            configFile >> "CfgFactionClasses" >> _factionClass >> "displayName"
        );
        if (_factionName == "") then { _factionName = _factionClass };

        private _aliveUnits = units _grp select { alive _x };
        private _unitCount = count _aliveUnits;

        private _vehicles = [];
        {
            private _veh = vehicle _x;
            if (_veh != _x) then {
                _vehicles pushBackUnique getText (
                    configFile >> "CfgVehicles" >> typeOf _veh >> "displayName"
                );
            };
        } forEach _aliveUnits;

        private _vehText = if (_vehicles isEqualTo []) then {"None"} else {_vehicles joinString ", "};


        private _color = switch (side _grp) do {
            case east: {"#FF4444"};
            case west: {"#44AAFF"};
            case resistance: {"#44FF44"};
            default {"#CCCCCC"};
        };


        _lines pushBack format [
            "
            <t color='%8'>========== GROUP REPORT =========</t><br/>            
            <t color='%8'>CALLSIGN:</t> %1<br/>
            <t color='%8'>FACTION:</t> %2<br/>
            <img image='%7' size='1.5' align='center'/><br/><br/>
            <t color='%8'>LEADER:</t> %3<br/>
            <t color='%8'>GRID:</t> %4<br/>
            <t color='%8'>UNITS:</t> %5<br/>
            <t color='%8'>VEHICLE:</t> %6<br/>
            ",
            groupId _grp,
            _factionName,
            name _leader,
            mapGridPosition _leader,
            _unitCount,
            _vehText,
            _pic,
            _color
        ];


        if (DAN_PlotIntelOnMap) then {

            private _markerName = format [
                "Intel_%1_%2",
                groupId _grp,
                floor random 9999
            ];

            private _marker = createMarker [_markerName, getPos _leader];
            _marker setMarkerType "mil_dot";
            _marker setMarkerColor "ColorRed";
            _marker setMarkerText groupId _grp;
            _marker setMarkerSize [0.7,0.7];
        };

    } forEach _groups;


    private _info = _lines joinString "<br/>";
    _unit setVariable ["DANinfo", _info, true];

    copyToClipboard _info;

    [_unit, "acex_intelitems_notepad", _info, _header]
        call ace_intelitems_fnc_addIntel;


    [_info, _header] remoteExec ["DAN_AddDiaryLocal", _caller];

    ["Intel added to briefing & notepad"] remoteExec ["hint", _caller];
};

DAN_AddAskInfo = {
	params ["_unit"];
    if (isServer) then
    {    
        [_unit,
        ["<t color='#f10808' shadow='2' size='1.3'><img size='2' image='\A3\ui_f\data\IGUI\Cfg\Actions\talk_ca.paa'/> Ask Him</t>",
        { 
            params ["_target", "_caller", "_actionId"];
            if (!alive _target) exitWith {};
            [_target, _caller] call DAN_GatherIntel;
        }]] remoteExec ["addAction", 0, true]; 
    };
	
};

DAN_End = {

    if (!hasInterface) exitWith {};

    addMusicEventHandler ["MusicStop", {
        params ["_musicClassname"];
        if (_musicClassname == "LeadTrack01_F") then {
            endMission "END1";
        };
    }];

    [] spawn {


        playMusic "LeadTrack01_F";
        private _players = allPlayers select {isPlayer _x};
        private _focusPlayer = selectRandom _players;

        private _pos = getPosASL _focusPlayer;

        private _cam = "camera" camCreate (_pos vectorAdd [0,30,20]);
        _cam cameraEffect ["INTERNAL","BACK"];
        showCinemaBorder true;

        _cam camSetTarget _focusPlayer;
        _cam camSetFov 0.7;
        _cam camCommit 0;

        sleep 2;


        private _radius = 40;

        for "_i" from 0 to 360 step 45 do {

            private _xPos =
                (_pos select 0) + (sin _i * _radius);

            private _yPos =
                (_pos select 1) + (cos _i * _radius);

            private _zPos = 25;

            private _newPos = [_xPos,_yPos,_zPos];

            _cam camSetPos _newPos;
            _cam camSetTarget _focusPlayer;
            _cam camCommit 6;

            sleep 2;
        };



        private _flyStart = _pos vectorAdd [-120,-120,40];
        private _flyEnd   = _pos vectorAdd [120,120,35];

        _cam camSetPos _flyStart;
        _cam camSetTarget _focusPlayer;
        _cam camCommit 0;

        sleep 1;

        _cam camSetPos _flyEnd;
        _cam camCommit 12;

        sleep 2;



        



        private _MissionName =
            "<t size='3.5' color='#f3eeee'>RKK NEMESIS</t><br/><br/>";

        [parseText _MissionName,true,nil,8,0.7,0]
            spawn BIS_fnc_textTiles;

        sleep 8;

        private _director =
            "<t size='2.5' color='#f3eeee'>SCRIPT BY DAN TAYLOR</t><br/><br/>";

        [parseText _director,true,nil,8,0.7,0]
            spawn BIS_fnc_textTiles;

        sleep 8;



        private _header =
            "<t size='2.8' color='#d4b24c'>OPERATORS</t><br/><br/>";

        [parseText _header,true,nil,8,0.7,0]
            spawn BIS_fnc_textTiles;

        sleep 6;

        {
            private _name = name _x;

            private _text = format [
                "<t size='2.2' color='#f3eeee'>%1</t>",
                _name
            ];

            [parseText _text,true,nil,7,0.7,0]
                spawn BIS_fnc_textTiles;

            sleep 4;

        } forEach _players;

        sleep 5;



        titleCut ["","BLACK OUT",5];
        sleep 5;

        camDestroy _cam;
    };
};


