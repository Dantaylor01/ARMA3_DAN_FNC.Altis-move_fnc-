DAN_vehdoor = {
    params ["_vehicle"];

    
    private _cfg = configFile >> "CfgVehicles" >> typeOf _vehicle >> "AnimationSources";
    private _sources = [];

    for "_i" from 0 to (count _cfg - 1) do {
        private _srcName = configName (_cfg select _i);
        
        if (toLower _srcName find "door" >= 0) then {
            _sources pushBack _srcName;
        };
    };

	private _userActions = configFile >> "CfgVehicles" >> typeOf _vehicle >> "UserActions";
    if (isClass _userActions) then {
        for "_i" from 0 to (count _userActions - 1) do {
            private _actionName = configName (_userActions select _i);
            if (toLower _actionName find "door" >= 0) then {
                _sources pushBackUnique _actionName;
            };
        };
    };
    hintSilent format ["%1 door animation sources found for %2", count _sources, typeOf _vehicle];

    {
        private _src = _x;

        
        _vehicle addAction [
            format ["<t color='#00ff00'>Open %1</t>", _src],
            {
                params ["_target", "_caller", "_actionId", "_args"];
                private _srcName = _args select 0;
                _target animateDoor [_srcName, 1];
                systemChat format ["%1 opened on %2", _srcName, typeOf _target];
            },
            [_src]
        ];

        
        _vehicle addAction [
            format ["<t color='#ff0000'>Close %1</t>", _src],
            {
                params ["_target", "_caller", "_actionId", "_args"];
                private _srcName = _args select 0;
                _target animateDoor [_srcName, 0];
                systemChat format ["%1 closed on %2", _srcName, typeOf _target];
            },
            [_src]
        ];
    } forEach _sources;
};