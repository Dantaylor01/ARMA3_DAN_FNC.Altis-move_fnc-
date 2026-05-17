DAN_DeadCallBRNMotorTeams = {
    params ["_target"];

    private _getUnits = {
        private _t = _this;
        private _list = [];

        if (_t isEqualType objNull) exitWith {[_t]};
        if (_t isEqualType grpNull) exitWith {units _t};

        if (_t isEqualType []) then {
            {
                if (_x isEqualType objNull) then {_list pushBack _x};
                if (_x isEqualType grpNull) then {_list append (units _x)};
            } forEach _t;
        };
        _list
    };

    private _targets = _target call _getUnits;

    {
        _x addEventHandler ["Killed", {
            params ["_unit", "_killer", "_instigator"];

            if (DAN_DEBUG) then {
                systemChat format [
                    "[DEBUG][DAN_DeadCallBRNMotorTeams] Unit %1 killed by %2",
                    name _unit,
                    name _killer
                ];
            };

            if (isNull _instigator) exitWith {};

            private _grp = group _unit;

            if ((units _grp) findIf {alive _x} != -1) exitWith {
                if (DAN_DEBUG) then {
                    systemChat "[DEBUG][DAN_DeadCallBRNMotorTeams] Group not fully dead yet";
                };
            };

            if (DAN_DEBUG) then {
                systemChat "[DEBUG][DAN_DeadCallBRNMotorTeams] Group fully dead, calling another reinforcement";
            };



            private _taskID = _unit getvariable ["taskID", ""];

            private _blufor = allUnits select {side _x == west};
            private _blacklist = _blufor apply {[getPosATL _x, 200]};

            private _pos = [
                _instigator,
                500,
                1000,
                2,
                0,
                1,
                0,
                _blacklist
            ] call BIS_fnc_findSafePos;

            [_pos, _instigator, _taskID] spawn {
                params ["_pos", "_instigator", "_taskID"];
                sleep 2;
                private _OpfReinfroces = call DAN_CreateBRNMotorTeams;

                sleep 2;

                
                [_OpfReinfroces, _taskID] call DAN_extra;

                
               

                sleep 2;

                {
                    private _grp = _x;
                    private _grpLead = leader _grp;

                    _grpLead move (getPos _instigator);

                    if (DAN_DEBUG) then {
                        systemChat format [
                            "[DEBUG][DAN_DeadCallBRNMotorTeams] Moving group %1 to %2",
                            groupId _grp,
                            name _instigator
                        ];
                    };

                } forEach _OpfReinfroces;
            };
        }];
    } forEach _targets;
};