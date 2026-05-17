"━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
" ฟังชัน, ระบบ พนักงานสอบสวน   ";
"━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
DAN_MissionIsRunningEH = {
    if (!isServer) exitWith {};
    missionNamespace setVariable ["DAN_MissionIsRunning", false, true];
};
call DAN_MissionIsRunningEH;
DAN_inquiryOfficial = {
	params ["_unit"];
	[_unit] spawn {
		params ["_unit"];
		waitUntil { time > 0 };
		missionNamespace setVariable ["inquiryOfficial", _unit];
		if (isNull _unit) exitWith {
			diag_log "assign_inquiry_official: Invalid unit (null)";
		};
        _unit addAction [
            "<t color='#0206fd' shadow='2' size='1.3'><img size='2' image='\A3\ui_f\data\IGUI\Cfg\Actions\talk_ca.paa'/> Give me a task </t>",
            {
                params ["_target", "_caller", "_actionId", "_arguments"];
                private _missionType = DAN_missions call BIS_fnc_selectRandom;
                switch (_missionType) do {
                    case "HVT": {

                        [] call DAN_HVT;
                        
                        missionNamespace setVariable ["DAN_MissionIsRunning", true, true];

                    };
                    case "hostage": {


                        [] call DAN_hostage;
                        
                        missionNamespace setVariable ["DAN_MissionIsRunning", true, true];

                    };
                    case "bomb": {

                        [] call DAN_bomb;
                        
                        missionNamespace setVariable ["DAN_MissionIsRunning", true, true];

                    };
                    case "VIP": {

                        [] call DAN_VIP;
                        
                        missionNamespace setVariable ["DAN_MissionIsRunning", true, true];

                    };
                    case "siege": {

                        [] call DAN_siege;
                        
                        missionNamespace setVariable ["DAN_MissionIsRunning", true, true];

                    };
                    case "Rescue": {

                        [] call DAN_SearchAndRescue;
                        
                        missionNamespace setVariable ["DAN_MissionIsRunning", true, true];

                    };			
                    default {
                        hint format ["DAN_givemission: Unknown mission type '%1' for %2", _missionType, name _target];
                    };
                };   
            },
            nil,
            1.5,
            true,
            true,
            "",
            "alive _target && (_target distance _this) < 5 && !(missionNamespace getVariable ['DAN_MissionIsRunning', false])",
            5,
            false,
            "",
            ""
        ];		

        _unit addAction [
            "<t color='#f90202' shadow='2' size='1.3'><img size='1.5' image='\A3\ui_f\data\IGUI\Cfg\Actions\ico_off_ca.paa'/> Cancel assigned task </t>",
            {
                params ["_target", "_caller", "_actionId", "_arguments"];
                if (!alive _target) exitWith {};

                private _currentTask = [_caller] call BIS_fnc_taskCurrent;
                if (_currentTask == "") exitWith {};
				[_currentTask] call DAN_CleanupExtra;
				
				[_currentTask, true, true] remoteExecCall ["BIS_fnc_deleteTask", 0];
               //[_currentTask, "CANCELED"] remoteExecCall ["BIS_fnc_taskSetState", 0];
                missionNamespace setVariable ["DAN_MissionIsRunning", false, true];

                
				[DAN_RKKIncreaseMarkerSize] call DAN_resizeRKKMarkers;

            },
            nil,
            1.5,
            true,
            true,
            "",
            "!(''== ([player] call BIS_fnc_taskCurrent))",
            5,
            false,
            "",
            ""
        ];
		/*
		_unit addAction [
			"<t color='#0206fd' shadow='2' size='1.3'><img size='2' image='\A3\ui_f\data\IGUI\Cfg\Actions\talk_ca.paa'/> Examine Suspect</t>",
			{
				params ["_target", "_caller", "_actionId", "_arguments"];
				if (!alive _target) exitWith { };			
				private _suspects = allUnits select {
					captive _x && (_target distance _x <= 5) && alive _x && {_x != _target}
				};
				if (_suspects isEqualTo []) exitWith {
					hint "No captive suspects nearby";
				};			
				private _nearestSuspect = _suspects select 0;
				private _arrested = _nearestSuspect getVariable ["arrested", false];
                private _isIEDmaker = _nearestSuspect getVariable ["IEDmaker", false];
				if (_arrested) exitWith {
					hint format ["Suspect %1 has already been arrested", name _nearestSuspect];
				};
                if (_isIEDmaker) exitWith {
                    call DAN_End;
                    _target action ["Salute", _target];
                    hint "we made it, he is a bomb maker!!!!!!!" ;
                };
				private _taskID = _nearestSuspect getVariable ["taskID", ""];
				if ( !(_taskID isEqualTo "") && { allPlayers findIf { !alive _x } == -1 }) then {
					
					private _taskChildren = [_taskID] call BIS_fnc_taskChildren;
					if (_taskChildren isNotEqualTo []) then {

						
						private _alltaskChildrenstates = [];
						{
							private _taskState = [_x] call BIS_fnc_taskState;
							_alltaskChildrenstates pushBack _taskState;
						} forEach _taskChildren;	
						if (
							_alltaskChildrenstates findIf {
								_x in ["CREATED", "ASSIGNED"]
							} != -1
						) exitWith {

							hint "you got child task";
						};
					} else {
						[_taskID, "SUCCEEDED"] call BIS_fnc_taskSetState;
						missionNamespace setVariable ["DAN_MissionIsRunning", false, true];
						_target action ["Salute", _caller];
						[_taskID] call DAN_CleanupExtra;
						[DAN_RKKDecreaseMarkerSize] call DAN_resizeRKKMarkers;
						hint format ["Suspect %1 identified and task completed", name _nearestSuspect];
						_nearestSuspect setVariable ["arrested", true, true];						
					};


					

                    
				} else {
					hint format ["%1 He’s not my suspect .", name _nearestSuspect];

				};

			},
			nil,       
			1.5,       
			true,      
			true,     
			"",        
			
			"!(allUnits select {captive _x && (_target distance _x <= 5) && alive _x && {_x != _target}} isEqualTo []) ",
			5,         
			false,    
			"",       
			""         
		];
		*/
		_unit addAction [
			"<t color='#0206fd' shadow='2' size='1.3'><img size='2' image='\A3\ui_f\data\IGUI\Cfg\Actions\talk_ca.paa'/> Examine Suspect</t>",
			{
				params ["_target", "_caller", "_actionId", "_arguments"];
				if (!alive _target) exitWith { };			
				private _suspects = allUnits select {
					captive _x && (_target distance _x <= 5) && alive _x && {_x != _target}
				};
				if (_suspects isEqualTo []) exitWith {
					hint "No captive suspects nearby";
				};			
				private _nearestSuspect = _suspects select 0;
				private _arrested = _nearestSuspect getVariable ["arrested", false];
                private _isIEDmaker = _nearestSuspect getVariable ["IEDmaker", false];
				if (_arrested) exitWith {
					hint format ["Suspect %1 has already been arrested", name _nearestSuspect];
				};
                if (_isIEDmaker) exitWith {
                    call DAN_End;
                    _target action ["Salute", _target];
                    hint "we made it, he is a bomb maker!!!!!!!" ;
                };
				private _taskID = _nearestSuspect getVariable ["taskID", ""];
				if ( !(_taskID isEqualTo "") && { allPlayers findIf { !alive _x } == -1 }) then {
					
					private _taskChildren =
						[_taskID]
						call BIS_fnc_taskChildren;

					// =====================================
					// CHECK ACTIVE CHILD TASKS
					// =====================================

					private _hasActiveChild =
						_taskChildren findIf {

							private _state =
								[_x]
								call BIS_fnc_taskState;

							!(
								_state in [
									"SUCCEEDED",
									"FAILED",
									"CANCELED"
								]
							)

						} != -1;

					if (_hasActiveChild) exitWith {

						hint "you got child task";
					};

					// =====================================
					// COMPLETE TASK
					// =====================================

					[_taskID, "SUCCEEDED"]
					call BIS_fnc_taskSetState;

					missionNamespace setVariable [
						"DAN_MissionIsRunning",
						false,
						true
					];

					_target action ["Salute", _caller];

					[_taskID]
					call DAN_CleanupExtra;

					[DAN_RKKDecreaseMarkerSize]
					call DAN_resizeRKKMarkers;

					hint format [
						"Suspect %1 identified and task completed",
						name _nearestSuspect
					];

					_nearestSuspect setVariable [
						"arrested",
						true,
						true
					];


					

                    
				} else {
					hint format ["%1 He’s not my suspect .", name _nearestSuspect];

				};

			},
			nil,       
			1.5,       
			true,      
			true,     
			"",        
			
			"!(allUnits select {captive _x && (_target distance _x <= 5) && alive _x && {_x != _target}} isEqualTo []) ",
			5,         
			false,    
			"",       
			""         
		];
		_unit addAction [
			"<t color='#1100ff' shadow='2' size='1.3'><img size='2' image='\A3\ui_f\data\IGUI\Cfg\Actions\heal_ca.paa'/> Examine Body</t>",
			{
				params ["_target", "_caller", "_actionId", "_arguments"];
				if (!alive _target) exitWith { };
				
				private _nearCorpses = allDeadMen select { _x distance (getPos _target) <= 5 };
				private _evidencedCorpses = _nearCorpses select {
					_x getVariable ["evidenced", false]
				};
				if (count _evidencedCorpses > 0) exitWith {
					hint "These corpses have already been processed.";
				};
				private _corpsenames1 = _nearCorpses apply { name _x };
                private _IEDMakernameList = missionNamespace getVariable ["IEDMakernameList", []];
                if (count _IEDMakernameList > 0) then {
                    private _matchedIEDMaker = _corpsenames1 in _IEDMakernameList;
                    if (_matchedIEDMaker) exitwith {
                        call DAN_End;
                        _target action ["Salute", _target];
                        hint "we made it, he is a bomb maker!!!!!!!" ;
            
                    };
                };
				private _taskID = [player] call BIS_fnc_tasksUnit;
				private _matchedName = _corpsenames1 findIf { _x in _taskID };

				if ((_matchedName != -1) && { allPlayers findIf { !alive _x } == -1 }) then {
					private _foundTaskID = _corpsenames1 select _matchedName;
					private _taskChildren =
						[_foundTaskID]
						call BIS_fnc_taskChildren;

					// =====================================
					// CHECK ACTIVE CHILD TASKS
					// =====================================

					private _hasActiveChild =
						_taskChildren findIf {

							private _state =
								[_x]
								call BIS_fnc_taskState;

							!(
								_state in [
									"SUCCEEDED",
									"FAILED",
									"CANCELED"
								]
							)

						} != -1;

					if (_hasActiveChild) exitWith {

						hint "you got child task";
					};				
					[_foundTaskID, "FAILED"] remoteExecCall ["BIS_fnc_taskSetState", 0];
                    missionNamespace setVariable ["DAN_MissionIsRunning", false, true];
					{
						_x setVariable ["evidenced", true, true];
					} forEach _nearCorpses;
					deleteVehicle _nearCorpses;
					[_foundTaskID] call DAN_CleanupExtra;
					[DAN_IEDAtfail] call DAN_RKKArea;
					[DAN_RKKIncreaseMarkerSize] call DAN_resizeRKKMarkers;

                    
					hint format ["Task for %1 completed", _foundTaskID];
				} else { 
					hint format ["%1 is a wrong person motherfucker!!!!", _corpsenames1 joinString ", "];
				};


			},
			nil,     
			1.5,    
			true,    
			true,    
			"",      
			
			"({ _x distance _target <= 5 } count allDeadMen) > 0",
			5,      
			false,   
			"",      
			""       
		];

		_unit addAction [
			"<t color='#f50541' shadow='2' size='1.3'><img size='2' image='\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_search_ca.paa'/> Examine evidence</t>",
			{
				params ["_target", "_caller", "_actionId", "_arguments"];
				if (!alive _target) exitWith { };
				private _nearestObj = (nearestObjects [getPos _target, ["WeaponHolderSimulated", "WeaponHolder"], 5]) select 0;
				private _evidenced = _nearestObj getVariable ["evidenced", false];
				if (_evidenced) exitWith {
					hint "This evidence has already been processed.";
				};
				private _objMags = magazineCargo _nearestObj;

				private _found = _objMags findIf { _x in DAN_allunarmedbombs } != -1;

				if (_found) then {
					private _playerTasks = [player] call BIS_fnc_tasksUnit;
					private _evidenceTasks = _playerTasks select {
						(toLower _x find "evidence" >= 0) && 
						{([_x] call BIS_fnc_taskState) != "SUCCEEDED"}
					};
					if (count _evidenceTasks > 0 && { allPlayers findIf { !alive _x } == -1 }) then {				
						private _mainTask = _evidenceTasks select 0;
						private _marker = missionNamespace getVariable [_mainTask + "_marker", ""];
						[_mainTask, "SUCCEEDED"] remoteExecCall ["BIS_fnc_taskSetState", 0];
                        missionNamespace setVariable ["DAN_MissionIsRunning", false, true];
                        _target action ["Salute", _caller];
						if (_marker != "") then {
							deleteMarker _marker;
						};
						_nearestObj setVariable ["evidenced", true, true];
						[_mainTask] call DAN_CleanupExtra;
						[DAN_RKKDecreaseMarkerSize] call DAN_resizeRKKMarkers;
	
                        
						deleteVehicle _nearestObj;
						hint format ["Task for %1 completed", _mainTask];
					} else { 
						hint format ["has no info in bomb database"];
					};
				} else {
					hint "No IED evidence found nearby";
				};
				

			},
			nil,     
			1.5,    
			true,    
			true,    
			"",      
			
			"(count (nearestObjects [_target, ['WeaponHolderSimulated', 'WeaponHolder'], 5]) > 0)",
			5,      
			false,   
			"",      
			""       
		];

		_unit addAction [
			"<t color='#f50541' shadow='2' size='1.3'><img size='2' image='\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_search_ca.paa'/> Examine bodybag</t>",
			{
				params ["_target", "_caller", "_actionId", "_arguments"];
				if (!alive _target) exitWith { };			
				private _nearestbodybag = (nearestObjects [
					_target,
					["ACE_bodyBagObject"],
					5
				]) select 0;
				private _evidenced = _nearestbodybag getVariable ["evidenced", false];
				if (_evidenced) exitWith {
					hint "This bodybag has already been processed.";
				};
				private _dogtagDATA =  _nearestbodybag call ace_dogtags_fnc_getDogtagData;
				private _bodybagname = _dogtagDATA select 0;
                private _IEDMakernameList = missionNamespace getVariable ["IEDMakernameList", []];
                if (_IEDMakernameList isNotEqualTo []) then {
                    private _matchedIEDMaker = _bodybagname in _IEDMakernameList;
                    if (_matchedIEDMaker) exitwith {
                        call DAN_End;
                        _target action ["Salute", _target];
                        hint "we made it, he is a bomb maker!!!!!!!" ;
            
                    };
                };
				private _playerTasks = [player] call BIS_fnc_tasksUnit;
				if ((_bodybagname in _playerTasks) && { allPlayers findIf { !alive _x } == -1 }) then {				
					private _taskChildren =
						[_bodybagname]
						call BIS_fnc_taskChildren;

					// =====================================
					// CHECK ACTIVE CHILD TASKS
					// =====================================

					private _hasActiveChild =
						_taskChildren findIf {

							private _state =
								[_x]
								call BIS_fnc_taskState;

							!(
								_state in [
									"SUCCEEDED",
									"FAILED",
									"CANCELED"
								]
							)

						} != -1;

					if (_hasActiveChild) exitWith {

						hint "you got child task";
					};
					[_bodybagname, "FAILED"] remoteExecCall ["BIS_fnc_taskSetState", 0];
                    missionNamespace setVariable ["DAN_MissionIsRunning", false, true];
					_nearestbodybag setVariable ["evidenced", true, true];
					[_bodybagname] call DAN_CleanupExtra;
					deleteVehicle _nearestbodybag;
					[DAN_IEDAtfail] call DAN_RKKArea;
					[DAN_RKKIncreaseMarkerSize] call DAN_resizeRKKMarkers;

					hint format ["Task for %1 completed", _bodybagname];
				} else { 
					hint format ["wrong person or your teammate is dead motherfucker!!!!"];
				};
				

			},
			nil,     
			1.5,    
			true,    
			true,    
			"",      
			
			"(count (nearestObjects [_target, ['ACE_bodyBagObject'], 5]) > 0)",
			5,      
			false,   
			"",      
			""       
		];

		_unit addAction [
			"<t color='#f50541' shadow='2' size='1.3'><img size='2' image='\a3\ui_f\data\IGUI\Cfg\Actions\arrow_down_gs.paa'/> clear crime scene </t>",
			{
				params ["_target", "_caller", "_actionId", "_arguments"];
				
				[] call DAN_ClearCrimeScene;
			},
			nil,     
			1.5,    
			true,    
			true,    
			"",      
			"alive _target && (_target distance _this) < 5 && !(missionNamespace getVariable ['DAN_MissionIsRunning', false])",  
			5,      
			false,   
			"",      
			""       
		];
	};
};
DAN_givemission = {
	params ["_unit","_missionType"];
    
	switch (_missionType) do {
		case "HVT": {
			_unit addAction
			[
				"<t color='#0206fd' shadow='2' size='1.3'><img size='2' image='\A3\ui_f\data\IGUI\Cfg\Actions\talk_ca.paa'/> HVT</t>",
				{
					params ["_target", "_caller", "_actionId", "_arguments"];
                    _target action ["Talk", _caller];
					[] call DAN_HVT;
					_target removeAction _actionId;
                    missionNamespace setVariable ["DAN_MissionIsRunning", true, true];
				},
				nil,
				1.5,
				true,
				true,
				"",
				"alive _target && (_target distance _this) < 5 && !(missionNamespace getVariable ['DAN_MissionIsRunning', false])",
				5,
				false,
				"",
				""
			];
		};
		case "hostage": {
			_unit addAction
			[
				"<t color='#0206fd' shadow='2' size='1.3'><img size='2' image='\A3\ui_f\data\IGUI\Cfg\Actions\talk_ca.paa'/> hostage </t>",
				{
					params ["_target", "_caller", "_actionId", "_arguments"];
                    _target action ["Talk", _caller];
					[] call DAN_hostage;
					_target removeAction _actionId;
                    missionNamespace setVariable ["DAN_MissionIsRunning", true, true];
				},
				nil,
				1.5,
				true,
				true,
				"",
				"alive _target && (_target distance _this) < 5 && !(missionNamespace getVariable ['DAN_MissionIsRunning', false])",
				5,
				false,
				"",
				""
			];
		};
		case "bomb": {
			_unit addAction
			[
				"<t color='#0206fd' shadow='2' size='1.3'><img size='2' image='\A3\ui_f\data\IGUI\Cfg\Actions\talk_ca.paa'/> bomb </t>",
				{
					params ["_target", "_caller", "_actionId", "_arguments"];
                    _target action ["Talk", _caller];
					[] call DAN_bomb;
					_target removeAction _actionId;
                    missionNamespace setVariable ["DAN_MissionIsRunning", true, true];
				},
				nil,
				1.5,
				true,
				true,
				"",
				"alive _target && (_target distance _this) < 5 && !(missionNamespace getVariable ['DAN_MissionIsRunning', false])",
				5,
				false,
				"",
				""
			];
		};
		case "VIP": {
			_unit addAction
			[
				"<t color='#0206fd' shadow='2' size='1.3'><img size='2' image='\A3\ui_f\data\IGUI\Cfg\Actions\talk_ca.paa'/> VIP </t>",
				{
					params ["_target", "_caller", "_actionId", "_arguments"];
                    _target action ["Talk", _caller];
					[] call DAN_VIP;
					_target removeAction _actionId;
                    missionNamespace setVariable ["DAN_MissionIsRunning", true, true];
				},
				nil,
				1.5,
				true,
				true,
				"",
				"alive _target && (_target distance _this) < 5 && !(missionNamespace getVariable ['DAN_MissionIsRunning', false])",
				5,
				false,
				"",
				""
			];
		};
		case "siege": {
			_unit addAction
			[
				"<t color='#0206fd' shadow='2' size='1.3'><img size='2' image='\A3\ui_f\data\IGUI\Cfg\Actions\talk_ca.paa'/> Siege </t>",
				{
					params ["_target", "_caller", "_actionId", "_arguments"];
                    _target action ["Talk", _caller];
					[] call DAN_siege;
					_target removeAction _actionId;
                    missionNamespace setVariable ["DAN_MissionIsRunning", true, true];
				},
				nil,
				1.5,
				true,
				true,
				"",
				"alive _target && (_target distance _this) < 5 && !(missionNamespace getVariable ['DAN_MissionIsRunning', false])",
				5,
				false,
				"",
				""
			];
		};
		case "Rescue": {
			_unit addAction
			[
				"<t color='#0206fd' shadow='2' size='1.3'><img size='2' image='\A3\ui_f\data\IGUI\Cfg\Actions\talk_ca.paa'/> Search And Rescue </t>",
				{
					params ["_target", "_caller", "_actionId", "_arguments"];
                    _target action ["Talk", _caller];
					[] call DAN_SearchAndRescue;
					_target removeAction _actionId;
                    missionNamespace setVariable ["DAN_MissionIsRunning", true, true];
				},
				nil,
				1.5,
				true,
				true,
				"",
				"alive _target && (_target distance _this) < 5 && !(missionNamespace getVariable ['DAN_MissionIsRunning', false])",
				5,
				false,
				"",
				""
			];
		};			
		default {
			hint format ["DAN_givemission: Unknown mission type '%1' for %2", _missionType, name _unit];
		};
	};
    
};
/*
DAN_clearcrimescene = {
    params [["_taskID", "", [""]]];
    private _taskIDextra = format ["%1extra", _taskID];
    
    
    if (allPlayers findIf {!alive _x} != -1) exitWith {
        hint "Cannot clear crime scene while players are dead";
        if (DAN_DEBUG) then {
            systemChat "[DAN_DEBUG][DAN_clearcrimescene] Aborted: Dead players detected";
        };
    };
    
    private _deletedCount = 0;
    
    
    private _deadToDelete = allDeadMen select {!isPlayer _x};
    {
        deleteVehicle _x;
        _deletedCount = _deletedCount + 1;
    } forEach _deadToDelete;
    
    if (DAN_DEBUG) then {
        systemChat format ["[DAN_DEBUG][DAN_clearcrimescene] Deleted %1 corpses", count _deadToDelete];
    };
    
    
	private _damagedVehicles = vehicles select {
		!isNull _x &&
		{damage _x > 0.8} &&
		{crew _x findIf {isPlayer _x} == -1}
	};

    
    {
        deleteVehicle _x;
        _deletedCount = _deletedCount + 1;
    } forEach _damagedVehicles;
    
    if (DAN_DEBUG) then {
        systemChat format ["[DAN_DEBUG][DAN_clearcrimescene] Deleted %1 damaged vehicles", count _damagedVehicles];
    };
	{
		{
			deleteVehicle _x;
			_deletedCount = _deletedCount + 1;
		} forEach (allMissionObjects _x);
	} forEach ["Land_DirtPatch_03_F", "Land_ClutterCutter_large_F"];

    
	private _taggedObjects = allMissionObjects "All" select {
		!isNull _x &&
		{!isPlayer _x} &&
		{_x getVariable ["taskIDextra", ""] isEqualTo _taskIDextra} 
	};

    
    {
        if (DAN_DEBUG) then {
            systemChat format [
                "[DAN_DEBUG][DAN_clearcrimescene] Deleting: %1 (type: %2)",
                _x,
                typeOf _x
            ];
        };
        deleteVehicle _x;
        _deletedCount = _deletedCount + 1;
    } forEach _taggedObjects;
    
    if (DAN_DEBUG) then {
        systemChat format ["[DAN_DEBUG][DAN_clearcrimescene] Deleted %1 tagged objects", count _taggedObjects];
    };
    

    if (DAN_DEBUG) then {
        systemChat format [
            "[DAN_DEBUG][DAN_clearcrimescene] Total deleted: %1 objects",
            _deletedCount
        ];
    };
    
    hint format ["Crime scene cleared\n%1 objects removed", _deletedCount];
};
*/
DAN_clearcrimescene = {

	params ["_taskID"];

	private _entities = missionNamespace getVariable [_taskID, []];
	{
		switch (typeName _x) do {

			// =========================
			// OBJECT
			// =========================

			case "OBJECT": {

				if (!isNull _x) then {
					deleteVehicle _x;
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
				};
			};
		};

	} forEach _entities;

	// remove registry
	missionNamespace setVariable [
		_taskID,
		nil,
		true
	];

	if (DAN_DEBUG) then {

		systemChat format [
			"[DAN_cleanupTask] Cleaned task: %1",
			_taskID
		];
	};
};
DAN_ClearEntityMarkerEH = {
    if (!isServer) exitWith {};
    addMissionEventHandler ["EntityDeleted", {
        params ["_entity"];
        private _marker = _entity getVariable ["mymarker", ""];
        if (_marker != "") then { deleteMarker _marker; };
        private _trigger = _entity getVariable ["mytrigger", objNull];
        if (!isNull _trigger) then { deleteVehicle _trigger; };


    }];
};
call DAN_ClearEntityMarkerEH;
