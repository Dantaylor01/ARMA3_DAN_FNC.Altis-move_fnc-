DAN_CaptiveEH = {
    if (!isServer) exitWith {};
    ["ace_captiveStatusChanged", {

        params ["_unit", "_state", "_reason", "_caller"];
        if (isPlayer _unit) exitWith {};
        if (_state) then {
            [_unit] remoteExecCall ["DAN_AddAskInfo", 2];
        };

    }] call CBA_fnc_addEventHandler;
};
call DAN_CaptiveEH;