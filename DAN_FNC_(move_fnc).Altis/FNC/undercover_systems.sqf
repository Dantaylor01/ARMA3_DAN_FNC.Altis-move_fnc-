
DAN_initBlacklist = {
    private _blacklist = createHashMap;
    private _cfgWeapons = configFile >> "CfgWeapons";
    private _cfgVehicles = configFile >> "CfgVehicles";  
	private _vestBases = [
		_cfgWeapons >> "Vest_Camo_Base",
		_cfgWeapons >> "Vest_NoCamo_Base"
	];
	private _bagBase = _cfgVehicles >> "Bag_Base";
    
    
    {
        private _cls = configName _x;
        private _first = _cls select [0, 2];
        
        
        switch (_first) do {
            case "U_": {
                private _uniformClass = getText (_x >> "ItemInfo" >> "uniformClass");
                if (_uniformClass != "") then {
                    private _side = getNumber (_cfgVehicles >> _uniformClass >> "side");
                    if (_side in [0,1,2]) then {
                        _blacklist set [_cls, true];
                    };
                };
            };
            case "V_": {
                if ({inheritsFrom _x isEqualTo _x} count _vestBases > 0) then {
                    _blacklist set [_cls, true];
                };
            };
            case "H_": {
                _blacklist set [_cls, true];
            };
            case "G_": {
                _blacklist set [_cls, true];
            };
            case "NV": {
                if (_cls select [0, 9] == "NVGoggles") then {
                    _blacklist set [_cls, true];
                };
            };
        };
    } forEach configProperties [_cfgWeapons, "isClass _x", true];
    
    
    {
        if (inheritsFrom _x isEqualTo _bagBase) then {
            _blacklist set [configName _x, true];
        };
    } forEach configProperties [_cfgVehicles, "isClass _x", true];
    
    _blacklist
};

DAN_BlacklistData = call DAN_initBlacklist;

DAN_isThreat = {
    params ["_unit"];
    
    
    if (isNull _unit || {!alive _unit}) exitWith {true};
    if (primaryWeapon _unit != "" || {handgunWeapon _unit != ""}) exitWith {true};
    
    
    private _blacklist = DAN_BlacklistData;
    private _gear = [uniform _unit, vest _unit, headgear _unit, goggles _unit, backpack _unit];
    
    {
        if (_x != "" && {_blacklist getOrDefault [_x, false]}) exitWith {true};
        false
    } forEach _gear
};

DAN_addEnemyDetection = {
    params ["_group"];    
    _group setBehaviourStrong "CARELESS";                 
    _group addEventHandler ["EnemyDetected", { 
        params ["_group", "_target"];
		if (DAN_DEBUG) then {
			systemChat format ["Enemy detected by group %1: %2", groupId _group, name _target]; 
		};
        if ([_target] call DAN_isThreat) then {
			if (DAN_DEBUG) then {
				systemChat format ["Target %1 is identified as a threat.", name _target];
			};
        	_group setBehaviourStrong  "COMBAT";
        }; 
                
    }];
};