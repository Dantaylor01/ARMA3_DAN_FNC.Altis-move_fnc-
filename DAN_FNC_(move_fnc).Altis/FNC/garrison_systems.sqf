
DAN_BestDirAndStairsDir = {

    params ["_input", ["_maxDist", 20], ["_step", 15]];

    private _units = if (_input isEqualType grpNull) then {
        units _input
    } else {
        [_input]
    };

    private _results = [];

    private _HighAngle = [
        ["45", 0.7],
        ["60", 0.87]
    ];

    private _PlaneAngle = [
        ["0", 0]
    ];

    {
        private _unit = _x;
        if (!alive _unit) then { continue };

        private _eye = eyePos _unit;

        private _bestDir = 0;
        private _bestDist = 0;

        private _debugLines = [];

 
        private _bestHighDir = 0;
        private _bestHighDist = 0;

        for "_dir" from 0 to 360 step _step do {

            private _maxInDir = 0;

            {
                _x params ["_name", "_zMul"];

                private _dx = sin _dir * _maxDist;
                private _dy = cos _dir * _maxDist;
                private _dz = -_maxDist * _zMul;

                private _targetPos = [
                    (_eye select 0) + _dx,
                    (_eye select 1) + _dy,
                    (_eye select 2) + _dz
                ];

                private _hit = lineIntersectsSurfaces [
                    _eye,
                    _targetPos,
                    _unit,
                    objNull,
                    true,
                    1,
                    "GEOM",
                    "NONE"
                ];

                private _hitPos = if (_hit isEqualTo []) then {
                    _targetPos
                } else {
                    (_hit select 0) select 0
                };

                private _dist = _eye distance _hitPos;

                _debugLines pushBack [ASLToATL _eye, ASLToATL _hitPos, _dir, _dist];

                if (_dist > _maxInDir) then {
                    _maxInDir = _dist;
                };

            } forEach _HighAngle;

            private _intDist = floor _maxInDir;

            if (_intDist > _bestHighDist) then {
                _bestHighDist = _intDist;
                _bestHighDir = _dir;
            };
        };

  
        if (_bestHighDir != 0) then {

            
            _bestDir = _bestHighDir;
            _bestDist = _bestHighDist;

        } else {

            private _bestPlaneDir = 0;
            private _bestPlaneDist = 0;

            for "_dir" from 0 to 360 step _step do {

                private _dx = sin _dir * _maxDist;
                private _dy = cos _dir * _maxDist;

                private _targetPos = [
                    (_eye select 0) + _dx,
                    (_eye select 1) + _dy,
                    (_eye select 2)
                ];

                private _hit = lineIntersectsSurfaces [
                    _eye,
                    _targetPos,
                    _unit,
                    objNull,
                    true,
                    1,
                    "GEOM",
                    "NONE"
                ];

                private _hitPos = if (_hit isEqualTo []) then {
                    _targetPos
                } else {
                    (_hit select 0) select 0
                };

                private _dist = _eye distance _hitPos;

                _debugLines pushBack [ASLToATL _eye, ASLToATL _hitPos, _dir, _dist];
                if (_dist > _bestPlaneDist) then {
                    _bestPlaneDist = _dist;
                    _bestPlaneDir = _dir;
                };
            };

            _bestDir = _bestPlaneDir;
            _bestDist = _bestPlaneDist;
        };

      
        _unit setDir _bestDir;
        _unit doWatch (_unit getPos [10, _bestDir]);

        if (DAN_DEBUG) then {

            systemChat format [
                "[DAN] %1 bestDir = %2 (maxDist %3)",
                name _unit,
                _bestDir,
                _bestDist
            ];

            private _arrowPos = _unit getPos [3, _bestDir];
            

            missionNamespace setVariable ["DAN_DebugVectors", _debugLines];
            missionNamespace setVariable ["DAN_DebugBestDir", _bestDir];

            if (isNil "DAN_DebugDrawEH") then {

                DAN_DebugDrawEH = addMissionEventHandler ["Draw3D", {

                    private _lines = missionNamespace getVariable ["DAN_DebugVectors", []];
                    private _bestDir = missionNamespace getVariable ["DAN_DebugBestDir", -1];

                    {
                        _x params ["_start", "_end", "_dir", "_dist"];

                        private _color = if (_dir == _bestDir) then {
                            [0,1,0,1]
                        } else {
                            [1,0,0,0.2]
                        };

                        drawLine3D [_start, _end, _color];

                    } forEach _lines;

                }];
            };
        };


        _results pushBack [_unit, _bestDir, _bestDist];

    } forEach _units;

    _results
};
DAN_BestDir = {

    params ["_input", ["_maxDist", 20], ["_step", 15]];

    private _units = [];

    
    if (_input isEqualType grpNull) then {
        _units = units _input;
    } else {
        _units = [_input];
    };

    private _results = [];

    {
        private _unit = _x;
        if (!alive _unit) then { continue };

        private _eye = eyePos _unit;
        private _bestDir = getDir _unit;
        private _bestScore = 0;

        for "_dir" from 0 to 360 step _step do {

            private _targetPos = [
                (_eye select 0) + (sin _dir * _maxDist),
                (_eye select 1) + (cos _dir * _maxDist),
                (_eye select 2)
            ];

            private _hit = lineIntersectsSurfaces [
                _eye,
                _targetPos,
                _unit,
                objNull,
                true,
                1,
                "GEOM",
                "NONE"
            ];

            private _dist = if (_hit isEqualTo []) then {
                _maxDist
            } else {
                _eye distance ((_hit select 0) select 0)
            };

            if (_dist > _bestScore) then {
                _bestScore = _dist;
                _bestDir = _dir;
            };
        };

        _unit setDir _bestDir;
        _unit doWatch (_unit getPos [10, _bestDir]);
        if (DAN_DEBUG) then {
            systemChat format ["DEBUG: Best direction for %1 is %2 degrees with clear distance of %3 meters", name _unit, _bestDir, _bestScore];
        };
        _unit setSkill ["aimingSpeed", 1];
        _unit setSkill ["aimingAccuracy", 1];
        _unit setSkill ["spotTime", 1];
        _results pushBack [_unit, _bestDir];

    } forEach _units;

    _results
};
DAN_BestDirVerticalCheck = {

    params ["_input", ["_maxDist", 20], ["_step", 15]];

    private _units = if (_input isEqualType grpNull) then {
        units _input
    } else {
        [_input]
    };

    private _results = [];

    {
        private _unit = _x;
        if (!alive _unit) then { continue };

        private _eye = eyePos _unit;

        private _bestDir1 = 0;
        private _bestDist1 = 0;

        private _bestDir2 = 0;
        private _bestDrop = 0;

        private _debugLines = [];


        for "_dir" from 0 to 360 step _step do {


            private _dx = sin _dir * _maxDist;
            private _dy = cos _dir * _maxDist;

            private _targetPos = [
                (_eye select 0) + _dx,
                (_eye select 1) + _dy,
                (_eye select 2)
            ];

            private _hit = lineIntersectsSurfaces [
                _eye,
                _targetPos,
                _unit,
                objNull,
                true,
                1,
                "GEOM",
                "NONE"
            ];

            private _hitPos = if (_hit isEqualTo []) then {
                _targetPos
            } else {
                (_hit select 0) select 0
            };

            private _dist = _eye distance _hitPos;

            
            if (_dist > _bestDist1) then {
                _bestDist1 = _dist;
                _bestDir1 = _dir;
            };


            private _dirVec = [
                sin _dir,
                cos _dir,
                0
            ];

            private _checkPos = [
                (_hitPos select 0) - (_dirVec select 0) * 0.3,
                (_hitPos select 1) - (_dirVec select 1) * 0.3,
                (_hitPos select 2)
            ];

            private _downPos = [
                _checkPos select 0,
                _checkPos select 1,
                (_checkPos select 2) - 5
            ];

            private _downHit = lineIntersectsSurfaces [
                _checkPos,
                _downPos,
                _unit,
                objNull,
                true,
                1,
                "GEOM",
                "NONE"
            ];

            private _groundPos = if (_downHit isEqualTo []) then {
                _downPos
            } else {
                (_downHit select 0) select 0
            };

            private _drop = (_checkPos select 2) - (_groundPos select 2);

            if (_drop > _bestDrop) then {
                _bestDrop = _drop;
                _bestDir2 = _dir;
            };

            
            _debugLines pushBack [ASLToATL _checkPos, ASLToATL _groundPos, _dir, _drop];
        };


        private _finalDir = _bestDir1;
        private _TerrainHeight = getTerrainHeight getPosWorld _unit;
        if (_bestDrop > 1.9) then {
            _finalDir = _bestDir2;
        } else {
            _finalDir = _bestDir1;
            _bestDrop = 0;
            _bestDist1  = _bestDist1
        };

        _unit setDir _finalDir;
        _unit doWatch (_unit getPos [10, _finalDir]);


        if (DAN_DEBUG) then {

            systemChat format [
                "[DAN] %1 dir=%2 drop=%3f horiz=%4f",
                name _unit,
                _finalDir,
                _bestDrop,
                _bestDist1
            ];


            missionNamespace setVariable ["DAN_DebugVectors", _debugLines];
            missionNamespace setVariable ["DAN_DebugBestDir", _finalDir];

            if (isNil "DAN_DebugDrawEH") then {

                DAN_DebugDrawEH = addMissionEventHandler ["Draw3D", {

                    private _lines = missionNamespace getVariable ["DAN_DebugVectors", []];
                    private _bestDir = missionNamespace getVariable ["DAN_DebugBestDir", -1];

                    {
                        _x params ["_start", "_end", "_dir", "_drop"];

                        private _color = if (_dir == _bestDir) then {
                            [0,1,0,1]
                        } else {
                            [0,0,1,0.2]
                        };

                        drawLine3D [_start, _end, _color];

                    } forEach _lines;

                }];
            };
        };

        _results pushBack [_unit, _finalDir, _bestDrop];

    } forEach _units;

    _results
};

DAN_taskGarrison = {

    params [
        ["_groupInput", grpNull, [grpNull, objNull, []]],
        ["_pos", [], [[], objNull]],
        ["_radius", 100, [0]],
        ["_teleport", true, [false]]
    ];


    private _groups = [];

    if (_groupInput isEqualType []) then {
        _groups = _groupInput;
    } else {
        if (_groupInput isEqualType objNull) then {
            _groups = [group _groupInput];
        } else {
            _groups = [_groupInput];
        };
    };


    _groups = _groups select {
        !isNull _x && {local _x}
    };

    if (_groups isEqualTo []) exitWith {false};


    if (_pos isEqualTo []) then {
        _pos = getPosATL leader (_groups select 0);
    };

    if (_pos isEqualType objNull) then {
        _pos = getPosATL _pos;
    };


    private _buildingPos = [];
    private _buildings = nearestObjects [_pos, ["House"], _radius];

    {
        private _i = 0;

        while {true} do {
            private _p = _x buildingPos _i;
            if (_p isEqualTo [0,0,0]) exitWith {};

            private _hit = lineIntersectsSurfaces [
                AGLToASL _p,
                (AGLToASL _p) vectorAdd [0,0,6],
                objNull,
                objNull,
                true,
                1,
                "GEOM",
                "NONE"
            ];

            if !(_hit isEqualTo []) then {
                _buildingPos pushBack _p;
            };

            _i = _i + 1;
        };

    } forEach _buildings;

    if (_buildingPos isEqualTo []) exitWith {false};

    _buildingPos = _buildingPos call BIS_fnc_arrayShuffle;


    private _units = [];

    {
        _units append (units _x select {
            alive _x && {!isPlayer _x} && {isNull objectParent _x}
        });
    } forEach _groups;

    if (_units isEqualTo []) exitWith {false};


    {
        private _unit = _x;
        private _targetPos = [];

        {
            if ((nearestObjects [_x, ["CAManBase"], 1.5]) isEqualTo []) exitWith {
                _targetPos = _x;
                _buildingPos set [_forEachIndex, objNull];
            };
        } forEach _buildingPos;

        _buildingPos = _buildingPos - [objNull];

        if (_targetPos isEqualTo []) then {
            private _fallback = _pos getPos [random 15, random 360];
            _unit doMove _fallback;
        } else {

            doStop _unit;

            if (_teleport) then {

                _unit setPosATL _targetPos;
                [_unit] call DAN_BestDirVerticalCheck;

                _unit disableAI "PATH";
                _unit disableAI "TARGET";

            } else {

                _unit doMove _targetPos;

                [_unit, _targetPos] spawn {
                    params ["_u","_t"];

                    waitUntil {
                        sleep 0.5;
                        (!alive _u) || {_u distance _t < 1.5}
                    };

                    if (!alive _u) exitWith {};

                    [_u] call DAN_BestDirVerticalCheck;
                    _u disableAI "PATH";
                    _u disableAI "TARGET";
                };
            };
        };

    } forEach _units;

    true
};
