"━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
"  ฟังชัน, ระบบ CSI, ลายนิ้วมือ   ";       
"━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
DAN_FingerPrintOnWeaDrop = {
    params ["_unit"];
    _unit addEventHandler ["Put", {
        params ["_unit", "_container", "_item"];

        if !(_container isKindOf "WeaponHolder" ||
             _container isKindOf "GroundWeaponHolder" ||
             _container isKindOf "WeaponHolderSimulated") exitWith {};

        if (_container getVariable ["processed", false]) exitWith {};
        _container setVariable ["processed", true];

        _container setVariable ["owner",     _unit,       true];
        _container setVariable ["ownername", name _unit,  true];
        _container setVariable ["item",      _item,       true];

        if (DAN_DEBUG) then {
            systemChat format ["DEBUG: %1 put %2 in %3", name _unit, _item, typeOf _container];
        };

        _container addAction [
            "<t color='#f50541' shadow='2' size='1.3'><img size='2' image='\a3\ui_f\data\IGUI\Cfg\Actions\arrow_down_gs.paa'/> Examine Fingerprint</t>",
            {
                params ["_target", "_caller"];

                private _item      = _target getVariable ["item",      "UNKNOWN"];
                private _owner     = _target getVariable ["owner",     objNull];
                private _ownerName = _target getVariable ["ownername", "UNKNOWN"];

                
                private _itemPic = getText (configFile >> "CfgWeapons" >> _item >> "picture");
                private _ownerPic = [_owner] call DAN_getpic;

            
                private _diaryKey = format ["FPDiary_%1", _target];
                if (_caller getVariable [_diaryKey, false]) exitWith {
                    hintSilent parseText "<t color='#f5a005'>Fingerprint already recorded.</t>";
                };
                _caller setVariable [_diaryKey, true];

                private _diaryContent = format [
                    "<img image='%1' width='200' height='80'/><br/>
                    <font size='16'><b>Item: %2</b></font><br/>
                    <br/>
                    <img image='%3' width='130' height='80'/><br/>
                    <font size='14'>Owner: <b>%4</b></font>",
                    _itemPic,
                    _item,
                    _ownerPic,
                    _ownerName
                ];

                _caller createDiaryRecord [
                    "Diary",
                    ["Fingerprint Report", _diaryContent],
                    taskNull,
                    "",
                    false
                ];
            },
            nil, 6, true, false, "", "", 3
        ];
    }];
};
DAN_FingerPrintOnWeaDropEH = {
    if (!isServer) exitWith {};
    if !(DAN_EnableFingerPrint) exitWith {};
    addMissionEventHandler ["EntityCreated", {
        params ["_entity"];
        if (!(_entity isKindOf "Man")) exitWith {};
        [_entity] call DAN_FingerPrintOnWeaDrop;
    }];

};
call DAN_FingerPrintOnWeaDropEH;


"━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
"  ฟังชัน, ระบบ CSI, toolsmark   ";       
"━━━━━━━━━━━━━━━━━━━━━━━━━━━━";

DAN_WeaponToolsMarkLoop = {
    params ["_unit"];


    _unit addEventHandler ["Fired", {
        params ["_unit", "_weapon"];

        private _key = format ["TM_%1", _weapon];

        if (isNil { _unit getVariable _key }) then {
            private _tm = format ["TM_%1_%2", netId _unit, diag_tickTime];
            _unit setVariable [_key, _tm, true];
            if (DAN_DEBUG) then {
                systemChat format ["%1 fired %2, assigned Toolmark ID: %3", name _unit, _weapon, _tm];
            };
        };
    }];


    _unit addEventHandler ["Put", {
        params ["_unit", "_container", "_item"];

        if (isNull _container) exitWith {};

        private _key = format ["TM_%1", _item];
        private _tm  = _unit getVariable [_key, nil];

        if (isNil "_tm") exitWith {};

        _container setVariable [_key, _tm, true];
        _unit setVariable [_key, nil, true];
        if (DAN_DEBUG) then {
            systemChat format ["%1 put %2 in %3, transferred Toolmark ID: %4", name _unit, _item, typeOf _container, _tm];
        };
    }];


    _unit addEventHandler ["Take", {
        params ["_unit", "_container", "_item"];

        if (isNull _container) exitWith {};

        private _key = format ["TM_%1", _item];
        private _tm  = _container getVariable [_key, nil];

        if (isNil "_tm") exitWith {};

        _unit setVariable [_key, _tm, true];
        _container setVariable [_key, nil, true];
        if (DAN_DEBUG) then {
            systemChat format ["%1 took %2 from %3, received Toolmark ID: %4", name _unit, _item, typeOf _container, _tm];
        };
    }];
};
DAN_AssignToolsMarkEH = {
    if (!isServer) exitWith {};
    if !(DAN_EnableToolMarks) exitWith {};
    addMissionEventHandler ["EntityCreated", {
        params ["_entity"];
        if (!(_entity isKindOf "Man")) exitWith {};
        [_entity] call DAN_WeaponToolsMarkLoop;
    }];
    addMissionEventHandler ["EntityKilled", {
        params ["_unit", "_killer", "_instigator"];

        if (isNull _instigator) exitWith {};
        if !(_instigator isKindOf "Man") exitWith {};

        private _weapon = currentWeapon _instigator;
        if (_weapon == "") exitWith {};

        private _key    = format ["TM_%1", _weapon];
        private _tm     = _instigator getVariable [_key, "UNKNOWN"];
        private _shooter = name _instigator;

        
        private _magazine = currentMagazine _instigator;
        private _ammoType = getText (configFile >> "CfgMagazines" >> _magazine >> "displayName");
        if (_ammoType == "") then { _ammoType = _magazine }; 

        _unit setVariable ["BulletInfo", [
            _tm,
            _shooter,
            _weapon,
            _ammoType
        ], true];

        private _oldAction = _unit getVariable ["BulletInfoAction", -1];
        if (_oldAction != -1) then { _unit removeAction _oldAction };

        private _actionId = _unit addAction [
            "<t color='#f50541' shadow='2' size='1.3'><img size='2' image='\a3\ui_f\data\IGUI\Cfg\Actions\arrow_down_gs.paa'/> Bullet Investigation</t>",
            {
                params ["_target", "_caller", "_actionId"];

                private _info = _target getVariable ["BulletInfo", []];
                if (_info isEqualTo []) exitWith {
                    hint "No ballistic evidence found.";
                };

                private _tm       = _info select 0;
                private _shooter  = _info select 1;
                private _weapon   = _info select 2;
                private _ammoType = _info select 3;

                
                private _diaryKey = format ["DiaryCreated_%1", _target];
                if (_caller getVariable [_diaryKey, false]) exitWith {
                    hint "Ballistic report already filed.";
                };
                _caller setVariable [_diaryKey, true];

                
                private _unitPicture   = [_target] call DAN_getpic;
                private _unitName      = name _target;
                private _weaponPicture = getText (configFile >> "CfgWeapons"   >> _weapon        >> "picture");
                private _weaponName    = getText (configFile >> "CfgWeapons"   >> _weapon        >> "displayName");
                private _ammoPicture   = getText (configFile >> "CfgMagazines" >> _ammoType      >> "picture");

                if (_weaponName == "") then { _weaponName = _weapon };

                private _diaryContent = format [
                    "<img image='%1' width='130' height='80'/><br/>
                    <font size='16'><b>%2</b></font><br/>
                    <br/>
                    <img image='%3' width='200' height='80'/><br/>
                    <font size='14'>Weapon: <b>%4</b></font><br/>
                    <br/>
                    <img image='%5' width='80' height='80'/><br/>
                    <font size='14'>Ammo: <b>%6</b></font><br/>
                    <br/>
                    <font size='14'>Toolmark ID: <b>%7</b></font>",
                    _unitPicture,
                    _unitName,
                    _weaponPicture,
                    _weaponName,
                    _ammoPicture,
                    _ammoType,
                    _tm
                ];

                _caller createDiaryRecord [
                    "Diary",
                    ["Ballistic Report", _diaryContent],
                    taskNull,
                    "",
                    false
                ];
            },
            nil, 1.5, true, false, "", "", 3
        ];

        _unit setVariable ["BulletInfoAction", _actionId, false];
    }];
    
};
call DAN_AssignToolsMarkEH;

DAN_PlaceInBodyBagEH = {
    if (!isServer) exitWith {};
    if !(DAN_EnableToolMarks) exitWith {};
    ["ace_placedInBodyBag", {
        params ["_target", "_bodyBag", "_isGrave", "_medic"];
        private _unitPicture   = [_target] call DAN_getpic;
        private _unitName      = name _target;
        private _info = _target getVariable ["BulletInfo", []];
        _bodybag setVariable ["BulletInfo", _info];
        _bodyBag setVariable ["PersonInfo", [
            _unitName,
            _unitPicture
        ], true];
        systemChat format ["%1 placed %2 in body bag", name _medic, _unitName];


        private _actionId = _bodyBag addAction [
            "<t color='#f50541' shadow='2' size='1.3'><img size='2' image='\a3\ui_f\data\IGUI\Cfg\Actions\arrow_down_gs.paa'/> Bullet Investigation</t>",
            {
                params ["_target", "_caller", "_actionId"];

                private _info = _target getVariable ["BulletInfo", []];
                if (_info isEqualTo []) exitWith {
                    hint "No ballistic evidence found.";
                };

                private _tm       = _info select 0;
                private _shooter  = _info select 1;
                private _weapon   = _info select 2;
                private _ammoType = _info select 3;

                
                private _diaryKey = format ["DiaryCreated_%1", _target];
                if (_caller getVariable [_diaryKey, false]) exitWith {
                    hint "Ballistic report already filed.";
                };
                _caller setVariable [_diaryKey, true];

                private _personInfo = _target getVariable ["PersonInfo", ["Unknown", ""]];
                private _unitName    = _personInfo select 0;
                private _unitPicture = _personInfo select 1;
                private _weaponPicture = getText (configFile >> "CfgWeapons"   >> _weapon        >> "picture");
                private _weaponName    = getText (configFile >> "CfgWeapons"   >> _weapon        >> "displayName");
                private _ammoPicture   = getText (configFile >> "CfgMagazines" >> _ammoType      >> "picture");

                if (_weaponName == "") then { _weaponName = _weapon };

                private _diaryContent = format [
                    "<img image='%1' width='130' height='80'/><br/>
                    <font size='16'><b>%2</b></font><br/>
                    <br/>
                    <img image='%3' width='200' height='80'/><br/>
                    <font size='14'>Weapon: <b>%4</b></font><br/>
                    <br/>
                    <img image='%5' width='80' height='80'/><br/>
                    <font size='14'>Ammo: <b>%6</b></font><br/>
                    <br/>
                    <font size='14'>Toolmark ID: <b>%7</b></font>",
                    _unitPicture,
                    _unitName,
                    _weaponPicture,
                    _weaponName,
                    _ammoPicture,
                    _ammoType,
                    _tm
                ];

                _caller createDiaryRecord [
                    "Diary",
                    ["Ballistic Report", _diaryContent],
                    taskNull,
                    "",
                    false
                ];
            },
            nil, 1.5, true, false, "", "", 3
        ];

    }] call CBA_fnc_addEventHandler;
};
call DAN_PlaceInBodyBagEH;
