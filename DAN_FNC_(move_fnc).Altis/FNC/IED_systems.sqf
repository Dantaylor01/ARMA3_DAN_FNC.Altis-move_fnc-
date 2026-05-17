"━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
"       ฟังชัน, ระบบ IED       ";
"━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
DAN_IEDtriggers = [
    "Command",
    "MK16_Transmitter",
    "DeadManSwitch",
    "Cellphone",
    "PressurePlate",
    "IRSensor",
    "Timer",
    "Tripwire"
];
DAN_armedIEDs = [
	"ACE_IEDLandSmall_Command_Ammo",
	"ACE_IEDUrbanBig_Command_Ammo"
];
DAN_unarmIEDs = [
	"IEDLandSmall_Remote_Mag", 
	"IEDUrbanBig_Remote_Mag"
];
DAN_armedexplo = [
	"ACE_DemoCharge_Remote_Ammo"
];
DAN_unarmexplo = [
	"DemoCharge_Remote_Mag"
];
DAN_allarmedbombs = DAN_armedIEDs + DAN_armedexplo;
DAN_allunarmedbombs = DAN_unarmIEDs + DAN_unarmexplo;
DAN_BoobyTrapClass = [
    "APERSMine_Range_Ammo",
    "ATMine_Range_Ammo",
    "APERSBoundingMine_Range_Ammo"
];
DAN_IEDContainerclass = [
	"Land_GasTank_01_blue_F", 
	"Land_GasTank_01_khaki_F", 
	"Land_GasTank_01_yellow_F", 
	"Land_GasTank_02_F", 
	"Land_FireExtinguisher_F"
];
DAN_IEDDefuseStartEH = {
    if (!isServer) exitWith {};
    ["ace_explosives_defuseStart", {

        params ["_explosive", "_unit"];
        private _container = _explosive getVariable ["mycontainer", objNull];
        if (_container isEqualTo objNull) exitwith {};
        private _maincharge = _container getVariable ["mymaincharge", ""];
        
        private _bank = _container getVariable ["myBankvalue", 0];
        private _maxbank = _bank + 10;
        private _minbank = _bank - 10;
        private _curentpitchBank = _container call BIS_fnc_getPitchBank;
        private _curentbank = _curentpitchBank select 1;
        if (_minbank < _curentbank && _maxbank > _curentbank) exitwith {};
        [[_explosive], 0] call ace_explosives_fnc_scriptedExplosive; 
        if (_maincharge != "") then {     
            
            _maincharge createVehicle (getPosATL _container);
        };

    }] call CBA_fnc_addEventHandler;
};
call DAN_IEDDefuseStartEH;
DAN_IEDDefusedEH = {
    if (!isServer) exitWith {};
    ["ace_explosives_defuse", {

        params ["_explosive", "_unit"];
		private _taskID = _explosive getVariable ["taskID", ""];
		private _marker = missionNamespace getVariable [_taskID + "_marker", ""];     
		if (_taskID isEqualType "" && {_taskID != ""}) then {
			[_taskID, "SUCCEEDED", true] remoteExecCall ["BIS_fnc_taskSetState", 0];
            missionNamespace setVariable ["DAN_MissionIsRunning", false, true];
			if (_marker != "") then {
				deleteMarker _marker;
			};
		};				


    }] call CBA_fnc_addEventHandler;
};
call DAN_IEDDefusedEH;
DAN_IEDExplodeOnDefuseEH = {
    if (!isServer) exitWith {};
    ["ace_explosives_explodeOnDefuse", {

        params ["_explosive", "_unit"];
		private _taskID = _explosive getVariable ["taskID", ""];
		private _marker = missionNamespace getVariable [_taskID + "_marker", ""];     
		if (_taskID isEqualType "" && {_taskID != ""}) then {
			[_taskID, "FAILED", true] remoteExecCall ["BIS_fnc_taskSetState", 0];
            missionNamespace setVariable ["DAN_MissionIsRunning", false, true];
			if (_marker != "") then {
				deleteMarker _marker;
			};
		};				


    }] call CBA_fnc_addEventHandler;
};
call DAN_IEDExplodeOnDefuseEH;
DAN_aceIEDjammerEH = {
	[{
		params ["_unit", "_range", "_explosive", "_fuzeTime", "_triggerItem"];
		private _jammed = _explosive getVariable ["EODS_Ied_jammed", false];
		if (_jammed && (_triggerItem == "ace_cellphone")) exitWith {
			if (DAN_DEBUG) then {
				systemChat format ["[DEBUG]DAN_aceIEDjammerEH: IED is jammed, preventing detonation by %1", _triggerItem];
			};
			false
		};
		true
	}] call ace_explosives_fnc_addDetonateHandler;
};
[] call DAN_aceIEDjammerEH;
DAN_RKKsetBomb = {
    params ["_iedPos", "_maxAttempts"];

    if (DAN_DEBUG) then {
        systemChat "[DEBUG][DAN_RKKsetbomb] Starting...";
    };
    

    private _iedName = selectRandom DAN_unarmexplo;
    private _BoobyTrapName = selectRandom DAN_BoobyTrapClass;
    private _validPos = false;
    
    for "_i" from 1 to _maxAttempts do {
        private _bomberPos = [
            _iedPos,
            75,
            150, 
            5, 
            0, 
            10, 
            0
        ] call BIS_fnc_findSafePos;
        
        
        private _nearRoads = _bomberPos nearRoads 100;
        
        if (_nearRoads isEqualTo []) then {
            _validPos = true;
            private _RKKteam = selectRandom DAN_RKKteams;
            private _RKK = [_bomberPos, east, _RKKteam,[],[],[],[],[],_iedPos] call BIS_fnc_spawnGroup;
            private _bomber = leader _RKK;
            
            private _ied = [_bomber, _iedPos, 134, _iedName, "Cellphone", []] call ace_explosives_fnc_placeExplosive;

            if ((call DAN_random1in3)&&(!isNil "rid_core_fnc_createIED")) then {
                _Boobytrap = [_iedPos, _BoobyTrapName, "standard", 3, "vib"] call rid_core_fnc_createIED;
            };


            
			[_ied, _bomber, _RKK] spawn {
				scopeName "cancelRKK";
                params ["_ied", "_bomber", "_RKK"];

                waitUntil {!isNull _ied};
                sleep 1;
				[_ied] call DAN_MakeContainerIED;

                
                {
                    _x lookAt _ied;
                    _x setDir (_x getDir _ied);
                } forEach (units _RKK);
				sleep 3;
				private _bomberZ = (getPosWorld _bomber) select 2;
				private _iedZ = (getPosWorld _ied) select 2;
				
				if (_bomberZ < _iedZ) then {
					if (DAN_DEBUG) then {
						systemChat format [
							"[DEBUG][DAN_RKKsetbomb] Bomber is lower than IED (Bomber Z: %1 | IED Z: %2) → calculating opposite relocation",
							_bomberZ, _iedZ
						];
					};

					private _posIED = getPosATL _ied;
					private _posBomber = getPosATL _bomber;

					private _dirIEDtoBomber = _posIED getDir _posBomber;
					private _oppositeDir = (_dirIEDtoBomber + 180) mod 360;
					private _distance = _posBomber distance2D _posIED;

					private _newX = (_posIED select 0) + (sin _oppositeDir) * _distance;
					private _newY = (_posIED select 1) + (cos _oppositeDir) * _distance;
					private _newPos = [_newX, _newY, 0];
					private _groundZ = getTerrainHeightASL [_newX, _newY];
					private _newPosZ = _groundZ;     

					if (DAN_DEBUG) then {
						systemChat format [
							"[DEBUG][DAN_RKKsetbomb] Checking new position Z: newPosZ=%1 vs bomberZ=%2",
							_newPosZ, _bomberZ
						];
					};

					if (_newPosZ > _bomberZ) then {

						{
							_x setPosATL [_newX, _newY, 0];
						} forEach (units _RKK);

						sleep 0.5;

						if (DAN_DEBUG) then {
							systemChat "[DEBUG][DAN_RKKsetbomb] Group relocated to opposite side (new pos is higher)";
						};

					} else {

						if (DAN_DEBUG) then {
							systemChat format [
								"[DEBUG][DAN_RKKsetbomb] CANCEL bomb placement → New position too low (newZ=%1 <= bomberZ=%2)",
								_newPosZ, _bomberZ
							];
						};

						deleteVehicle _ied;

						{
							deleteVehicle _x;
						} forEach units _RKK;

						deleteGroup _RKK;

						
						breakOut "cancelRKK";

					};

				};
                
                private _canSee = (([_bomber, "VIEW"] checkVisibility [eyePos _bomber, getPosASL _ied]) > 0.03);

               if (!_canSee) then {
                    if (DAN_DEBUG) then {
                        systemChat "[DEBUG][DAN_RKKsetbomb] Bomber does NOT see IED → moving closer";
                    };
                    private _step = 5;
                    private _maxApproach = 50;
                    sleep 0.5;
                    for "_a" from 1 to _maxApproach do {
                        
                        private _canSeeNow = (([_bomber, "VIEW"] checkVisibility [eyePos _bomber, getPosASL _ied]) > 0.03);

                        if (_canSeeNow) exitWith {
                            if (DAN_DEBUG) then {
                                systemChat "[DEBUG][DAN_RKKsetbomb] Bomber now sees IED.";
                            };
                            doStop _bomber;
                            _bomber lookAt _ied;
							sleep 0.5;
							if (DAN_burryIED) then {
								[_ied] call DAN_burry;
							};
						};



                        private _dist = _bomber distance _ied;
                        if (_dist < 80) exitWith {
                            if (DAN_DEBUG) then {
                                systemChat format ["[DEBUG][DAN_RKKsetbomb] Bomber is within %1m → stopping.", _dist];
                            };
                            doStop _bomber;
                            _bomber lookAt _ied;
							sleep 0.5;
							if (DAN_burryIED) then {
								[_ied] call DAN_burry;
							};
                        };

                        private _posIED = getPosATL _ied;
                        private _posBom = getPosATL _bomber;
                        
                        private _dirToIED = _posBom getDir _posIED;

                        
                        private _newX = (_posBom select 0) + (sin _dirToIED) * _step;
                        private _newY = (_posBom select 1) + (cos _dirToIED) * _step;
                        private _newPos = [_newX, _newY, _posBom select 2];


                        _bomber doMove _newPos;



                        sleep 2;
					};


                } else {
                    if (DAN_DEBUG) then {
                    	systemChat "[DEBUG][DAN_RKKsetbomb] RKK already see ied.";
                	};
                    doStop _bomber;
                    _bomber lookAt _ied;
					sleep 0.5;
					if (DAN_burryIED) then {
						[_ied] call DAN_burry;
					};
                };

                if (DAN_DEBUG) then {
                    systemChat "[DEBUG][DAN_RKKsetbomb] IED placed successfully (visibility checked).";
                };
            };


            
            _ied addEventHandler ["Explode", {
                params ["_projectile", "_position", "_velocity"];
				[DAN_IEDAtfail] call DAN_RKKArea;
				if (DAN_DEBUG) then {
					systemChat "[DEBUG][DAN_RKKsetbomb] IED exploded, spawning new RKK";
				};
            }];
            _bomber setVariable ["myIED", _ied, true];
			_bomber addItem "ItemRadio";
			_ied setVariable ["mybomber", _RKK, true];
            if (call DAN_random1in2) then {
                [_ied] spawn {
                    params ["_ied"];    
                    sleep 5;
                    [_ied] call DAN_2ndbomb;
                };
            };
            _RKK addEventHandler ["EnemyDetected", {
                params ["_group", "_newTarget"];
                _group setCombatMode "GREEN";
                private _bomber = leader _group;
                private _ied = _bomber getVariable ["myIED", objNull];
                
                if (isNull _ied || {!alive _ied}) exitWith {
					_group setCombatMode "RED";
				};

                if (_bomber getVariable ["DAN_tracking", false]) exitWith {};
                _bomber setVariable ["DAN_tracking", true];
                
                if (DAN_DEBUG) then {
                    systemChat format ["[DEBUG] RKK tracking %1", name _newTarget];
                };
                
                [_bomber, _ied, _newTarget, _group] spawn {
                    params ["_bomber", "_ied", "_enemy", "_group"];               
                    private _previousDistance = _enemy distance _ied;
                    private _lastSeen = time;
                    
                    while {alive _ied && alive _bomber} do {
                        
                        
                        private _knowsAbout = _bomber knowsAbout _enemy;
                        
                        if (_knowsAbout > 0) then {
                            _lastSeen = time;
                        } else {
                            
                            if (time - _lastSeen > 5) exitWith {
                                if (DAN_DEBUG) then {
                                    systemChat "[DEBUG] Lost target, stop tracking";
                                };
                            };
                        };
                        
                        
                        if (!alive _enemy) exitWith {
                            if (DAN_DEBUG) then {
                                systemChat "[DEBUG] Target dead";
                            };
                        };
                        
                        private _currentDistance = _enemy distance _ied;
                        
                        if (_currentDistance <= _previousDistance || _currentDistance < 30) then {
                            _previousDistance = _currentDistance;
                            
                            if (_currentDistance < 25) exitWith {
                                [_bomber, -1, [_ied, 1], "ACE_Cellphone"] call ACE_Explosives_fnc_detonateExplosive;
                                
                                if (DAN_DEBUG) then {
                                    systemChat format ["[DEBUG] Detonated at %1m", round _currentDistance];
                                };
                            };
                            
                            sleep 0.2;
                        } else {
                            break;
                        };
                    };
                    
                    
                    _bomber setVariable ["DAN_tracking", false];
                };
            }];
            
 
            break;
        };
        
        if (DAN_DEBUG && _i == _maxAttempts) then {
            systemChat format ["[DEBUG][DAN_RKKsetBomb] Failed to find valid position after %1 attempts", _maxAttempts];
        };
    };
    
    _validPos

};
DAN_RKKArea = {
    params ["_numIED", "_pos"];
	if (DAN_DEBUG) then {
		systemChat format ["[DEBUG][DAN_RKKArea] running..."];
	};
    if (isNil "_pos") then {
        private _Allmkr = allMapMarkers;
        private _rkkMarkers = _Allmkr select {
            (toLower _x) find "rkk" > -1
        };
        {
            for "_i" from 1 to _numIED do {	
                private _sMkr = getMarkerSize _x;						
                private _pMkr = getMarkerPos _x;
                private _roads = nearestTerrainObjects [_pMkr, ["MAIN ROAD", "ROAD","CROSS","TRACK"], (_sMkr select 0), false];
                private _playerUnits = allUnits select {side _x == west && alive _x};
                _roads = _roads select {
                    private _rpos = getPosATL _x;
                    (_playerUnits findIf {_rpos distance2D _x < 500}) == -1
                };
                if (count _roads == 0) exitWith {
                    if (DAN_DEBUG) then {
                        systemChat format ["[DEBUG][DAN_RKKArea] No valid roads near marker %1", _x];
                    };
                };
                private _rdist = 5.75;
                private _road = selectRandom _roads;
                private _roadDir = getDir _road;
                private _chance = random 100;
                private _newDir = _roadDir;
                if (_chance < 50) then {_newDir = (_newDir + 180)};
                private _dir = _newDir;
                private _pos = getPos _road;
                private _posx = _pos select 0;
                private _posy = _pos select 1;
                private _tx = (_posx + (_rdist * sin _dir));
                private _ty = (_posy + (_rdist * cos _dir));
                private _iedpos = [_tx,_ty,0];		
                private _maxAttempts = 50;
                private _bomber = objNull;
                
                [_iedpos,_maxAttempts] call DAN_RKKsetBomb;

            };			
        } forEach _rkkMarkers;
    } else {
        if (DAN_DEBUG) then {
            systemChat format ["[DEBUG][DAN_RKKArea] recieve param (_pos):%1", _pos];
        };
        for "_i" from 1 to _numIED do {	
            private _maxAttempts = 50;
            private _bomber = objNull;
            [_pos,_maxAttempts] call DAN_RKKsetBomb;
        };
    };
};
DAN_1stRKK = {
	if (!isServer) exitWith {};
	[DAN_IEDstart] call DAN_RKKArea;
};
["CBA_loadingScreenDone", {
    [] call DAN_1stRKK;
}] call CBA_fnc_addEventHandler;
DAN_burry = {
	params ["_obj"];
	if (isNull _obj) exitWith {};

	[_obj] spawn {
		params ["_obj"];

		
		{
			_x hideObjectGlobal true;
		} forEach attachedObjects _obj;

		
		private _container = attachedTo _obj;
		if (!isNull _container) then {
			_container hideObjectGlobal true;
		};

		sleep 0.1;

		
		_obj hideObjectGlobal true;
	};
};
DAN_ServerDig = {

    params ["_positions","_pos","_burriedItems"];

    if (!isServer) exitWith {};

    setTerrainHeight [_positions, true];

    {
        _x createVehicle _pos;
    } forEach [
        "Land_DirtPatch_03_F",
        "Land_ClutterCutter_large_F"
    ];

    {
        _x hideObjectGlobal false;
    } forEach _burriedItems;

};
DAN_Digstatement = {

    params ["_target","_player","_params"];

    private _unit = _player;
    private _detectionRange = 2;
    private _digDepth = -1;
    private _digRadius = 0.5;

    private _pos = getPos _unit;
    private _height = getTerrainHeightASL _pos;

    private _positions = [];
    private _nearObjects = nearestObjects [_unit, [], _detectionRange];
    private _burriedItems = _nearObjects select { isObjectHidden _x };

    [_unit,"medicStart"] remoteExec ["playActionNow",_unit];

    [_unit,_positions,_pos,_digRadius,_height,_digDepth,_burriedItems] spawn {

        params [
            "_unit",
            "_positions",
            "_pos",
            "_digRadius",
            "_height",
            "_digDepth",
            "_burriedItems"
        ];

        sleep 10;

        [_unit,"medicStop"] remoteExec ["playActionNow",_unit];

        for "_i" from 0 to 359 step 30 do {

            _positions pushBack [
                (_pos select 0) + (_digRadius * sin _i),
                (_pos select 1) + (_digRadius * cos _i),
                _height + _digDepth
            ];

        };

        [_positions,_pos,_burriedItems]
            remoteExec ["DAN_ServerDig",2];

    };

};
DAN_Digcondition = {
    params ["_target","_player","_params"];
    (vehicle _player == _player) &&
    (DAN_digtools findIf { _x in (items _player + weapons _player) }) > -1
};
DAN_Digaction = [
    "start_digging",
    "start digging",
    "",
    DAN_Digstatement,
    DAN_Digcondition
] call ace_interact_menu_fnc_createAction;
DAN_AddDigAction = {
    params ["_unit"];
    [
        typeOf _unit, 
        1, 
        ["ACE_SelfActions"], 
        DAN_Digaction
    ] call ace_interact_menu_fnc_addActionToClass;
};
[player] call DAN_AddDigAction;
DAN_Addjammer = {
	params ["_obj"];
	[_obj] spawn {
		params ["_obj"];
		waitUntil { time > 0 };
		_obj addAction [  
			"<t color='#3af700' shadow='2' size='1.3'><img size='2' image='\A3\ui_f\data\IGUI\Cfg\Actions\RadarOn_ca.paa'/> ACTIVE JAMMER</t>", 
			{  
				params ["_target", "_caller", "_actionId"];

				private _jammer = _target;
				if (_jammer getVariable ["EODS_JammerLoopRunning", false]) exitWith {
					systemChat "Jammer is already running!";
				};

				_jammer setVariable ["EODS_JammerActive", true, true];
				_jammer setVariable ["EODS_JammerLoopRunning", true, false];

				systemChat "Car Jammer is Activated";

				private _range = 75;
				private _iedsJammed = [];
				private _playersJammed = [];

				
				while { _jammer getVariable ["EODS_JammerActive", false] } do {

					private _ieds = _jammer nearObjects ["EODS_base_ied_cellphone", _range];
					private _players = allPlayers;

					
					{
						if (isNil { _x getVariable "EODS_Ied_calculo_jammeo_hecho" }) then {
							_x setVariable ["EODS_Ied_jammed", true, true];
							_x setVariable ["EODS_Ied_calculo_jammeo_hecho", true, true];
							_iedsJammed pushBackUnique _x;
						};
					} forEach _ieds;

					private _aceIEDs = nearestMines [_jammer, ["ACE_IEDLandSmall_Command_Ammo","ACE_IEDUrbanBig_Command_Ammo"], _range];
					{
						if (isNil { _x getVariable "EODS_Ied_calculo_jammeo_hecho" }) then {
							_x setVariable ["EODS_Ied_jammed", true, true];
							_x setVariable ["EODS_Ied_calculo_jammeo_hecho", true, true];
							_iedsJammed pushBackUnique _x;
						};
					} forEach _aceIEDs;

					{
						if (_jammer distance _x > _range) then {
							_x setVariable ["EODS_Ied_jammed", false, true];
							_x setVariable ["EODS_Ied_calculo_jammeo_hecho", false, true];
							_iedsJammed deleteAt (_iedsJammed find _x);
						};
					} forEach +_iedsJammed;

					
					{
						private _isJammed = _x getVariable ["EODS_Ied_Radio_Jam", false];
						private _dist = _jammer distance _x;

						if (_dist < _range && !_isJammed) then {
							_x setVariable ["tf_unable_to_use_radio", true, true];
							_x setVariable ["EODS_Ied_Radio_Jam", true, true];
							_playersJammed pushBackUnique _x;
						};

						if (_dist >= _range && _isJammed) then {
							_x setVariable ["tf_unable_to_use_radio", false, true];
							_x setVariable ["EODS_Ied_Radio_Jam", false, true];
							_playersJammed deleteAt (_playersJammed find _x);
						};

					} forEach _players;
					
					{   
						private _dist = _jammer distance _x;
						if  (_dist < _range) then {
							_x connectTerminalToUAV objNull;
						};
					} foreach _players;
					
					private _uavTypes = [
						"B_UAV_01_F",
						"B_UAV_02_F",
						"O_UAV_01_F",
						"O_UAV_02_F",
						"I_UAV_01_F",
						"I_UAV_02_F",
						"I_UAV_06_F"
					];
					private _nearUAVs = _jammer nearEntities [_uavTypes, _range];
					{
						_x engineOn false;
						_x setAutonomous false;
						_x disableAI "ALL";
						_x setVariable ["EODS_UAV_Jammed", true, true];
					} forEach _nearUAVs;
					sleep 0.5;
				};

				
				{
					_x setVariable ["EODS_Ied_jammed", false, true];
					_x setVariable ["EODS_Ied_calculo_jammeo_hecho", false, true];
				} forEach _iedsJammed;

				{
					_x setVariable ["tf_unable_to_use_radio", false, true];
					_x setVariable ["EODS_Ied_Radio_Jam", false, true];
				} forEach _playersJammed;

				systemChat "Car Jammer is Deactivated";
				_jammer setVariable ["EODS_JammerLoopRunning", false, false];



				
				{
					if (_jammer distance _x > _range) then {
						_x enableAI "ALL";
						_x engineOn true;
						_x setAutonomous true;
						_x setVariable ["EODS_UAV_Jammed", false, true];
					};
				} forEach (allUnits select { _x getVariable ["EODS_UAV_Jammed", false] });

			},
			nil, 1.5, true, true, "", "(_target distance _this) < 3.5"    
		];

		_obj addAction [ 
			"<t color='#f10808' shadow='2' size='1.3'><img size='2' image='\A3\ui_f\data\IGUI\Cfg\Actions\RadarOff_ca.paa'/> DEACTIVE JAMMER</t>",  
			{ 
				params ["_target", "_caller", "_actionId"];
				_target setVariable ["EODS_JammerActive", false, true];
				_target setVariable ["EODS_JammerLoopRunning", false, false]; 
				systemChat "Jammer is Deactivated"; 
			},
			nil, 1.5, true, true, "", "(_target distance _this) < 3.5"  
		];
	};
};
DAN_attachbomb = {
    params ["_unit", "_timedelay"];
    
    if (isNull _unit) exitWith {
        if (DAN_DEBUG) then { systemChat "[DAN_attachbomb] unit is null"; };
    };
    
    private _bombtime = _timedelay * 60;
	private _expl = selectRandom DAN_armedexplo;
    private _expl1 = _expl createVehicle (position _unit);
    private _finalBomb = _expl1;      
    if (DAN_DEBUG) then {
        systemChat format ["[DAN_attachbomb] bomb created. Delay = %1 sec", _bombtime];
    };
    
    if (_unit isKindOf "LandVehicle" || _unit isKindOf "Air" || _unit isKindOf "Ship") then {
             
        if (DAN_DEBUG) then {
            systemChat format ["[DAN_attachbomb] Vehicle detected. Attaching to %1", _unit];
        };
        
        _expl1 attachTo [_unit];
        
    } else {
        
        if (DAN_DEBUG) then {
            systemChat "[DAN_attachbomb] Infantry detected. Attaching to pelvis";
        };
        
        _expl1 attachTo [_unit, [0, 0.15, 0.15], "Pelvis"];
        _expl1 setVectorDirAndUp [[1,0,0],[0,1,0]];
    };
    
    if (_bombtime > 0) then {
        [_finalBomb, _bombtime, _unit] spawn {
            params ["_finalBomb", "_bombtime", "_unit"];
			[_finalBomb, _bombtime] call ace_explosives_fnc_startTimer;
        };
    } else {
        if (DAN_DEBUG) then {
            systemChat "[DAN_attachbomb] No timer set, bomb will not detonate automatically.";
        };
    };
    
    if (DAN_DEBUG) then {
        systemChat format ["[DAN_attachbomb] Function complete. Returned %1", _finalBomb];
    };
    
    _finalBomb
};
DAN_armbomb = {
    params ["_bomber", "_ied"];
    _bomber setVariable ["myIED", _ied, true];
    _bomber addItem "ItemRadio";
    _ied setVariable ["mybomber", _bomber, true];
	
    group _bomber addEventHandler ["EnemyDetected", {
        params ["_group", "_newTarget"];
        _group setCombatMode "GREEN";
        private _bomber = leader _group;
        private _ied = _bomber getVariable ["myIED", objNull];
        
        if (isNull _ied || {!alive _ied}) exitWith {
            _group setCombatMode "RED";
        };

        if (_bomber getVariable ["DAN_tracking", false]) exitWith {};
        _bomber setVariable ["DAN_tracking", true];
        
        if (DAN_DEBUG) then {
            systemChat format ["[DEBUG] RKK tracking %1", name _newTarget];
        };
        
        [_bomber, _ied, _newTarget, _group] spawn {
            params ["_bomber", "_ied", "_enemy", "_group"];               
            private _previousDistance = _enemy distance _ied;
            private _lastSeen = time;
            
            while {alive _ied && alive _bomber} do {
                
                
                private _knowsAbout = _bomber knowsAbout _enemy;
                
                if (_knowsAbout > 0) then {
                    _lastSeen = time;
                } else {
                    
                    if (time - _lastSeen > 5) exitWith {
                        if (DAN_DEBUG) then {
                            systemChat "[DEBUG] Lost target, stop tracking";
                        };
                    };
                };
                
                
                if (!alive _enemy) exitWith {
                    if (DAN_DEBUG) then {
                        systemChat "[DEBUG] Target dead";
                    };
                };
                
                private _currentDistance = _enemy distance _ied;
                
                if (_currentDistance <= _previousDistance || _currentDistance < 30) then {
                    _previousDistance = _currentDistance;
                    
                    if (_currentDistance < 25) exitWith {
                        [_bomber, -1, [_ied, 1], "ACE_Cellphone"] call ACE_Explosives_fnc_detonateExplosive;
                        
                        if (DAN_DEBUG) then {
                            systemChat format ["[DEBUG] Detonated at %1m", round _currentDistance];
                        };
                    };
                    
                    sleep 0.2;
                } else {
                    break;
                };
            };
            
            
            _bomber setVariable ["DAN_tracking", false];
        };
    }];
    _ied addEventHandler ["Explode", {
        params ["_projectile", "_position", "_velocity"];
        if (DAN_MoreIEDPower) then {
            "Bo_GBU12_LGB" createVehicle (getPosATL _projectile);
        };
        [DAN_IEDAtfail] call DAN_RKKArea;
        if (DAN_DEBUG) then {
            systemChat "[DEBUG][DAN_armbomb] IED exploded, spawning new RKK";
        };
    }];
};
DAN_2ndbomb = {
	params ["_unit"];
	[_unit] call DAN_ObserveAreaTrig;
};
DAN_ObserveAreaTrig = {
	params ["_unit"];
	private _pos = getPos _unit;
	private _size = selectRandom [400,450,500,550,600];
	private _owner = _unit;
	private _OAT = createTrigger ["EmptyDetector", _pos];
    _OAT setTriggerArea [_size, _size, 0, false];
    _OAT setTriggerActivation ["WEST", "PRESENT", true];
    _OAT setTriggerTimeout [0, 0, 0, true];
    _OAT setVariable ["DAN_owner", _owner];
    
    if (DAN_DEBUG_2ndbomb) then {
        systemChat format [
            "[DEBUG][DAN_ObserveAreaTrig] Trigger created at %1 with size %2", 
            _pos, 
            _size
        ];
        
        private _markerName = format ["DAN_TriggerDebug_%1", random 99999];
        private _marker = createMarker [_markerName, _pos];
        _marker setMarkerShape "RECTANGLE";
        _marker setMarkerSize [_size, _size];
        _marker setMarkerColor "ColorRed";
        _marker setMarkerBrush "Solid";
        _marker setMarkerAlpha 0.5;
        _marker setMarkerText format ["OAT %1m", _size];
        
        _OAT setVariable ["DAN_debugMarker", _markerName];
        
        
        _OAT addEventHandler ["Deleted", {
            params ["_trigger"];
            private _markerName = _trigger getVariable ["DAN_debugMarker", ""];
            if (_markerName != "") then {
                deleteMarker _markerName;
                if (DAN_DEBUG_2ndbomb) then {
                    systemChat format ["[DEBUG] Marker %1 deleted", _markerName];
                };
            };
        }];
    };
    
	private _actcode = {
		params ["_trigger", "_thisList", "_owner"];
		private _unit = _thisList select 0;
		private _objOnRoad = isOnRoad _unit;
		if !(_objOnRoad) exitWith {};
		if (_trigger getVariable ["DAN_2ndbombrunning", false]) exitWith {};
		_trigger setVariable ["DAN_2ndbombrunning", true];
		private _pos = getPos _unit;
		[_pos,300] call DAN_PlaceBombAreaTrig;
		deleteVehicle _trigger;
        if (DAN_DEBUG_2ndbomb) then {
            if (isNull _trigger) then {
                systemChat "[DAN_DEBUG][DAN_ObserveAreaTrig] Trigger is null after deletion";
            } else {
                systemChat "[DAN_DEBUG][DAN_ObserveAreaTrig] Trigger still exists after deletion";
            };
        };
	};

    _OAT setVariable ["DAN_actcode", _actcode];
    _owner setVariable ["mytrigger", _OAT];
    
    _owner addEventHandler ["Killed", {
        params ["_unit", "_killer", "_instigator", "_useEffects"];
        private _OAT = _unit getVariable ["mytrigger", objNull];
        if (!isNull _OAT) then {
            deleteVehicle _OAT;
            if (DAN_DEBUG_2ndbomb) then {
                systemChat "[DAN_DEBUG] [DAN_triggerOwner] killedEH deleted trigger";
            };
        };
    }];

    _owner addEventHandler ["Explode", {
        params ["_projectile", "_position", "_velocity"];
        private _OAT = _projectile getVariable ["mytrigger", objNull];
        if (!isNull _OAT) then {
            deleteVehicle _OAT;
            if (DAN_DEBUG_2ndbomb) then {
                systemChat "[DAN_DEBUG] [DAN_triggerOwner] ExplodeEH deleted trigger";
            };
        };        
    }];
    
    _owner addEventHandler ["Deleted", {
        params ["_entity"];
        private _OAT = _entity getVariable ["mytrigger", objNull];
        if (!isNull _OAT) then {
            deleteVehicle _OAT;
            if (DAN_DEBUG_2ndbomb) then {
                systemChat "[DAN_DEBUG] [DAN_triggerOwner] DeletedEH deleted trigger";
            };
        }; 
    }];
    
    private _activationCode = "[thisTrigger, thisList, (thisTrigger getVariable 'DAN_owner')] call (thisTrigger getVariable 'DAN_actcode');";
    private _deactivationCode = "";
    
    _OAT setTriggerStatements [
        "this",
        _activationCode,
        _deactivationCode
    ];
    
    if (DAN_DEBUG_2ndbomb) then {
        systemChat format [
            "[DEBUG][DAN_ObserveAreaTrig] Created trigger at %1 for %2", 
            _pos, 
            name _owner
        ];
    };
    
    _OAT
};
DAN_PlaceBombAreaTrig = {
    params ["_pos","_size"];
    private _trg = createTrigger ["EmptyDetector", _pos];
    _trg setTriggerArea [_size, _size, 0, false];
    _trg setTriggerActivation ["WEST", "PRESENT", true];
    _trg setTriggerTimeout [0, 0, 0, true];
    _trg setVariable ["DAN_fired", false];

    if (DAN_DEBUG_2ndbomb) then {
        systemChat format [
            "[DEBUG][DAN_PlaceBombAreaTrig] Trigger created at %1 with size %2", 
            _pos, 
            _size
        ];
        
        private _markerName = format ["DAN_BombTrigger_%1", random 99999];
        private _marker = createMarker [_markerName, _pos];
        _marker setMarkerShape "RECTANGLE";
        _marker setMarkerSize [_size, _size];
        _marker setMarkerColor "ColorOrange";
        _marker setMarkerBrush "Solid";
        _marker setMarkerAlpha 0.5;
        _marker setMarkerText format ["Bomb %1m", _size];
        
        _trg setVariable ["DAN_debugMarker", _markerName];
        
        
        _trg addEventHandler ["Deleted", {
            params ["_trigger"];
            private _markerName = _trigger getVariable ["DAN_debugMarker", ""];
            if (_markerName != "") then {
                deleteMarker _markerName;
                if (DAN_DEBUG_2ndbomb) then {
                    systemChat format ["[DEBUG] Marker %1 deleted", _markerName];
                };
            };
        }];
    };
    
    private _deactCode = {
		params ["_trigger"];
        private _playerIsInside = player inArea _trigger;
        if (_playerIsInside) exitWith {
            if (DAN_DEBUG_2ndbomb) then {
                systemChat "[DAN_PlaceBombAreaTrig] Player is inside trigger area, bomb will not be placed.";
            };
        };
		if (_trigger getVariable ["DAN_fired", false]) exitWith {};
		_trigger setVariable ["DAN_fired", true];
		private _pos = getPos _trigger;

		if (DAN_DEBUG_2ndbomb) then {
			systemChat "[DAN_PlaceBombAreaTrig] WEST left area, placing bomb";
		};

		[_pos, 50] call DAN_RKKsetbomb;
		deleteVehicle _trigger;
        
        if (DAN_DEBUG_2ndbomb) then {
            if (isNull _trigger) then {
                systemChat "[DAN_DEBUG][DAN_PlaceBombAreaTrig] Trigger successfully deleted";
            } else {
                systemChat "[DAN_DEBUG][DAN_PlaceBombAreaTrig] Trigger still exists after deletion";
            };
        };
	};

	_trg setVariable ["DAN_deactCode", _deactCode];

	private _deactivationCode = "[thisTrigger] call (thisTrigger getVariable 'DAN_deactCode');";

	_trg setTriggerStatements [
		"this",
		"",
		_deactivationCode
	];

	if (DAN_DEBUG_2ndbomb) then {
		systemChat format [
			"[DEBUG][DAN_PlaceBombAreaTrig] Trigger created at %1",
			_pos
		];
	};

	_trg
};
DAN_MakeContainerIED = {
	params ["_ied"];

    if (isServer) then
    {        
        private _booster = _ied;
        if (isNull _booster) exitWith {};

        private _containerClass = selectRandom DAN_IEDContainerclass;

        if (DAN_DEBUG) then {
            systemChat format [
                "[DAN_MakeContainerIED] Creating HE IED in container %1",
                _containerClass
            ];
        };

        private _container = createVehicle [
            _containerClass,
            getPosATL _booster,
            [],
            0,
            "CAN_COLLIDE"
        ];

        _booster attachTo [_container, [0, 0.15, 0]];
        _booster setVectorDirAndUp [[1,0,0],[0,1,0]];
        _booster setVariable ["mycontainer", _container, true];
        _container setVariable ["mybooster", _booster, true];
        _container setVariable ["mymaincharge", "Bo_GBU12_LGB", true];
        
        private _bank = 90;
        _container setVariable ["myBankvalue", _bank, true];
        [_container, 90, _bank] call BIS_fnc_setPitchBank;
        _container addEventHandler ["Explosion", {
            params ["_vehicle", "_damage", "_explosionSource"];
            private _explosive = _vehicle getVariable ["mymaincharge", ""];
            if (_explosive != "") then {
                deleteVehicle _vehicle;
                _explosive createVehicle (getPosATL _vehicle);
            };
            if (DAN_DEBUG) then {
                systemChat format ["%1 damaged by %2", typeOf _vehicle, _explosionSource];
            };

        }];


        [_container,
         [ "<t color='#f50541' shadow='2' size='1.3'><img size='2' image='\a3\ui_f\data\IGUI\Cfg\Actions\arrow_down_gs.paa'/> 1.examine IED</t>",
          { 
            params ["_target", "_caller", "_actionId"];
            
            private _bank = _target getVariable ["myBankvalue", 0];
            private _maxbank = _bank + 10;
            private _minbank = _bank - 10;
            private _curentpitchBank = _target call BIS_fnc_getPitchBank;
            private _curentbank = _curentpitchBank select 1;
            if (_minbank < _curentbank && _maxbank > _curentbank) then {
                hint "IED is stable enough to attempt defusal.";
            } else {
                hint "IED is not stable It may detonate if you try to defuse it.";
            };
            
            
            
        }]] remoteExec ["addAction", 0, true];
        
        [_container,
         [ "<t color='#f50541' shadow='2' size='1.3'><img size='2' image='\a3\ui_f\data\IGUI\Cfg\Actions\arrow_down_gs.paa'/> 3.take maincharge off </t>",
          { 
            params ["_target", "_caller", "_actionId"];
            private _container = _target;
            private _booster = _target getVariable ["mybooster", objNull];
            if (isNull _booster) then {
                private _mainchargecls = _target getVariable ["mymaincharge", ""];
                if (_mainchargecls != "") then {
                    _target setVariable ["mymaincharge", "", true];
                    private _maincharge = "ACE_SandbagObject" createVehicle (getPos _caller);
                    
                    [_maincharge] call DAN_AddIEDMakerFingerPrint;
                
                } else {
                    hint "No maincharge found in container!";
                };
            } else {
                [[_booster], -3] call ace_explosives_fnc_scriptedExplosive;
            };
        }]] remoteExec ["addAction", 0, true];

        [_container,
         [  "<t color='#f50541' shadow='2' size='1.3'><img size='2' image='\a3\ui_f\data\IGUI\Cfg\Actions\arrow_down_gs.paa'/> 4.examine fingerprint</t>",
          { 
            params ["_target", "_caller", "_actionId"];
            private _container = _target;
            private _booster = _target getVariable ["mybooster", objNull];
            if !(isNull _booster) exitWith {
                [[_booster], -3] call ace_explosives_fnc_scriptedExplosive;
            };
            private _nameIEDmaker = _target getVariable ["IEDmakerName", ""];
            if (_nameIEDmaker != "") then {
                hint parseText format [
                    "<img image='insignia\finger3.jpg' size='10' align='center' /><br/><br/>" +
                    "<t size='1.5' color='#00ff88' align='center' shadow='2'> found! </t><br/>" +
                    "<t size='1.2' color='#ffffff' align='center'>%1</t>",
                    _nameIEDmaker
                ];
                
            } else {
                hint "No fingerprints found";
            };
        }]] remoteExec ["addAction", 0, true];
        if (DAN_DEBUG_HEIED) then {
            systemChat format [
                "[DAN_MakeContainerIED] Actions added to container %1",
                typeOf _container
            ];
        };  



        [_container] call DAN_AssignIEDMakerName;
        [_container, true, [0, 1, 0], 0] call ace_dragging_fnc_setCarryable;
        _booster
    };


};
DAN_TimeDetonator = {
	params ["_ied", "_timedelay"];
	
	_ied = cursorObject;
	_timedelay = 50;

	
	if (isNull _ied) exitWith {
		if (DAN_DEBUG) then { 
			systemChat "[DAN_TimeDetonator] IED is null"; 
		};
		objNull  
	};

	
	if (isNil "ace_explosives_fnc_startTimer") exitWith {
		if (DAN_DEBUG) then {
			systemChat "[DAN_TimeDetonator]  ACE Explosives mod not loaded!";
		};
		objNull
	};

	private _container = _ied getVariable ["mycontainer", objNull];
	private _bombtime = _timedelay * 60;

	if (DAN_DEBUG) then {
		systemChat format ["[DAN_TimeDetonator] Setting timer for %1 seconds", _bombtime];
		systemChat format ["[DAN_TimeDetonator] IED: %1", typeOf _ied];
		systemChat format ["[DAN_TimeDetonator] Container: %1", if (isNull _container) then {"NONE"} else {typeOf _container}];
	};

	
	private _watchObj = "Land_Watch_01_F" createVehicle [0,0,0]; 

	if (isNull _watchObj) exitWith {
		if (DAN_DEBUG) then {
			systemChat "[DAN_TimeDetonator]  Failed to create watch object!";
		};
		objNull
	};

	
	if (!isNull _container) then {
		_watchObj attachTo [_container, [0.1, 0.1, 0.15]];
		_watchObj setVectorDirAndUp [[0.5, -0.5, 0], [0.5, 0.5, 0]];
		
		_container setVariable ["mywatch", _watchObj, true];
		_ied setVariable ["mywatch", _watchObj, true];
		
		if (DAN_DEBUG) then {
			systemChat format ["[DAN_TimeDetonator] ✅ Watch attached to container"];
		};
	} else {
		_watchObj attachTo [_ied, [0, 0.15, 0.15]];
		_watchObj setVectorDirAndUp [[1,0,0],[0,1,0]];
		_ied setVariable ["mywatch", _watchObj, true];
		
		if (DAN_DEBUG) then {
			systemChat format ["[DAN_TimeDetonator] ✅ Watch attached to IED"];
		};
	};

	
	if (_bombtime > 0) then {
		[_ied, _bombtime, _watchObj] spawn {
			params ["_bomb", "_time", "_watch"];
			
			
			private _timerStarted = [_bomb, _time, 0, true] call ace_explosives_fnc_startTimer;
			
			if (DAN_DEBUG) then {
				if (!isNil "_timerStarted") then {
					systemChat format ["[DAN_TimeDetonator] ✅ Timer started: %1 seconds", _time];
				} else {
					systemChat "[DAN_TimeDetonator] ⚠️ Timer may not have started correctly";
				};
			};
			
			
			waitUntil {
				sleep 1;
				!alive _bomb || isNull _bomb
			};
			
		
			if (!isNull _watch) then {
				deleteVehicle _watch;
				if (DAN_DEBUG) then {
					systemChat "[DAN_TimeDetonator] Watch cleaned up after explosion";
				};
			};
		};
	} else {
		if (DAN_DEBUG) then {
			systemChat "[DAN_TimeDetonator] ⚠️ Timer is 0 or negative, bomb not armed";
		};
	};


	_ied addEventHandler ["Deleted", {
		params ["_bomb"];
		private _watch = _bomb getVariable ["mywatch", objNull];
		if (!isNull _watch) then {
			deleteVehicle _watch;
			if (DAN_DEBUG) then {
				systemChat "[DAN_TimeDetonator] Watch cleaned up (IED deleted)";
			};
		};
	}];

	if (DAN_DEBUG) then {
		systemChat format ["[DAN_TimeDetonator] ✅ Setup complete, returning watch object: %1", _watchObj];
	};

	_watchObj  
};
DAN_CreateAndAssignIEDMaker = {

	if (!isServer) exitWith {};

	// Global sync variable
	missionNamespace setVariable ["DAN_IEDmaker", objNull, true];

	// =========================================
	// Entity Created
	// =========================================

	addMissionEventHandler ["EntityCreated", {

		params ["_entity"];

		// ต้องเป็นคน
		if (!(_entity isKindOf "Man")) exitWith {};

		// ไม่ใช่ player
		if (isPlayer _entity) exitWith {};

		// ต้องเป็น EAST
		if (side group _entity != east) exitWith {};

		// มี IED maker อยู่แล้ว
		private _currentIED = missionNamespace getVariable ["DAN_IEDmaker", objNull];

		if (!isNull _currentIED) exitWith {};

		// สุ่ม 1 ใน 3
		if (call DAN_random1in3) exitWith {};

		private _leader = leader group _entity;

		if (isNull _leader) exitWith {};

		// กัน spawn ที่ origin
		if ((getPosATL _leader) distance2D [0,0,0] < 1000) exitWith {};

		// Assign
		missionNamespace setVariable ["DAN_IEDmaker", _leader, true];

		_leader setVariable ["IEDmaker", true, true];

		// =====================================
		// DEBUG
		// =====================================

		if (missionNamespace getVariable ["DAN_DEBUG", false]) then {

			private _markerName = format [
				"IEDMaker_%1",
				diag_tickTime
			];

			private _marker = createMarker [_markerName, getPos _leader];

			_marker setMarkerType "hd_dot";
			_marker setMarkerText "IED Maker";
			_marker setMarkerColor "ColorRed";

			_leader setVariable ["mymarker", _marker, true];

			[
				format [
					"DAN: New IED Maker = %1",
					name _leader
				]
			] remoteExec ["systemChat", 0];
		};

	}];

	// =========================================
	// Entity Deleted
	// =========================================

	addMissionEventHandler ["EntityDeleted", {

		params ["_entity"];

		private _currentIED =
			missionNamespace getVariable ["DAN_IEDmaker", objNull];

		if (_entity != _currentIED) exitWith {};

		// DEBUG
		if (missionNamespace getVariable ["DAN_DEBUG", false]) then {

			private _marker =
				_entity getVariable ["mymarker", ""];

			if (_marker != "") then {
				deleteMarker _marker;
			};

			[
				"DAN: IED Maker deleted. Waiting for replacement..."
			] remoteExec ["systemChat", 0];
		};

		// Reset
		missionNamespace setVariable ["DAN_IEDmaker", objNull, true];

	}];

};
call DAN_CreateAndAssignIEDMaker;
DAN_AssignIEDMakerName = {
    params ["_obj"];
    
    private _currentIEDmaker = DAN_IEDmaker;

    
    if (!isNull _currentIEDmaker) then {

        if (DAN_DEBUG) then {
            systemChat "DEBUG: Creating new IEDmaker...";
        };



        private _nameIEDmaker = name _currentIEDmaker;

        [_obj, _nameIEDmaker] spawn {
            params ["_obj", "_name"];
            sleep 1;
            _obj setVariable ["IEDmakerName", _name, true];
        };

        if (DAN_DEBUG) then {
            systemChat format ["DEBUG: Assigned name = %1", _nameIEDmaker];
        };

        true
    };

};
DAN_AddIEDMakerFingerPrint = {
    params ["_container"];

    if (isServer) then
    {    
        [_container,
        [ "<t color='#f50541' shadow='2' size='1.3'><img size='2' image='\a3\ui_f\data\IGUI\Cfg\Actions\arrow_down_gs.paa'/> examine fingerprint</t>",
        { 
            params ["_target", "_caller", "_actionId"];
            private _nameIEDmaker = _target getVariable ["IEDmakerName", ""];
            if (_nameIEDmaker != "") then {
                hint parseText format [
                    "<img image='insignia\finger3.jpg' size='10' align='center' /><br/><br/>" +
                    "<t size='1.5' color='#00ff88' align='center' shadow='2'> found! </t><br/>" +
                    "<t size='1.2' color='#ffffff' align='center'>%1</t>",
                    _nameIEDmaker
                ];
                
            } else {
                hint "No fingerprints found";
            };
        }]] remoteExec ["addAction", 0, true]; 
    };

};
player addEventHandler ["Respawn", {
	params ["_unit", "_corpse"];
	[_unit] call DAN_AddDigAction;
    

}];

player addMPEventHandler ["MPRespawn", {
	params ["_unit", "_corpse"];
	[_unit] call DAN_AddDigAction;
    
   
}];

addMissionEventHandler ["EntityRespawned", {
	params ["_newEntity", "_oldEntity"];
    if (isPlayer _newEntity) then {
        [_newEntity] call DAN_AddDigAction;
       
    
    };
}];