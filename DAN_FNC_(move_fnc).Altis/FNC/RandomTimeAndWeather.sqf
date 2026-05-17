"━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
"  ฟังชัน, ระบบ สภาพอากาศแบบไดนามิก   ";       
"━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
DAN_SessionDynamicWeather = {
    if !(DAN_EnableSessionDynamicWeather) exitWith {};
    if (!isServer) exitWith {};
    params [
        ["_transitionTime", 600],
        ["_force", false]
    ];
    private _timeToSkipTo = selectRandom [0, 6, 12, 18, 23];
    private _overcast = random 1;
    private _rain     = 0;
    private _fog      = random 0.3;
    private _windStr  = random 0.8; 

  
    if (_overcast > 0.4) then {
        private _rainChance = random 1;

        if (_rainChance > 0.3) then {
            
            _rain = random [_overcast * 0.5, _overcast * 0.75, _overcast];
        };

    
        if (_overcast > 0.75) then {
            if (_rainChance > 0.5) then {
                _rain = random [0.7, 0.85, 1.0]; 
            };
        };
    };

    if (_overcast < 0.3) then {
        _fog = random 0.08;
    };

   
    if (_rain > 0.5) then {
        _windStr = _windStr max (random [0.4, 0.6, 0.9]);
        _fog = _fog max (random 0.25);
    };

  
    private _t = _transitionTime max 1; 
    _t setOvercast _overcast;
    _t setRain _rain;
    _t setFog _fog;

    private _windDir = random 360;
    private _windX = (sin _windDir) * _windStr;
    private _windY = (cos _windDir) * _windStr;
    setWind [_windX, _windY, true];

    if (_force) then {
        forceWeatherChange;
    };

    private _current = dayTime;
    private _delta   = (_timeToSkipTo - _current + 24) % 24;
    if (_delta == 0) then { _delta = 24 };
    skipTime _delta;
    
};

[0,true] call DAN_SessionDynamicWeather;

DAN_MissionDynamicWeather = {
    if !(DAN_EnableMissionDynamicWeather) exitWith {};
    if (!isServer) exitWith {};
    params [
        ["_transitionTime", 600],
        ["_force", false]
    ];
    private _timeToSkipTo = selectRandom [0, 6, 12, 18, 23];
    private _overcast = random 1;
    private _rain     = 0;
    private _fog      = random 0.3;
    private _windStr  = random 0.8; 

  
    if (_overcast > 0.4) then {
        private _rainChance = random 1;

        if (_rainChance > 0.3) then {
            
            _rain = random [_overcast * 0.5, _overcast * 0.75, _overcast];
        };

    
        if (_overcast > 0.75) then {
            if (_rainChance > 0.5) then {
                _rain = random [0.7, 0.85, 1.0]; 
            };
        };
    };

    if (_overcast < 0.3) then {
        _fog = random 0.08;
    };

   
    if (_rain > 0.5) then {
        _windStr = _windStr max (random [0.4, 0.6, 0.9]);
        _fog = _fog max (random 0.25);
    };

  
    private _t = _transitionTime max 1; 
    _t setOvercast _overcast;
    _t setRain _rain;
    _t setFog _fog;

    private _windDir = random 360;
    private _windX = (sin _windDir) * _windStr;
    private _windY = (cos _windDir) * _windStr;
    setWind [_windX, _windY, true];

    if (_force) then {
        forceWeatherChange;
    };

    private _current = dayTime;
    private _delta   = (_timeToSkipTo - _current + 24) % 24;
    if (_delta == 0) then { _delta = 24 };
    skipTime _delta;
    
};