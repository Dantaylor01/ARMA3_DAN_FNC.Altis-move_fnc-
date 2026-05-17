DAN_arsenalclose = {
	private _p = player;

	
	private _forceSecondaryWp = "";		
	private _pwp = primaryWeapon _p;
	if (DAN_RestrictWeapon ) then {
		if (_pwp isEqualTo "" || { !(_pwp in DAN_WhitelistWeapons) }) then {
            private _w = selectrandom DAN_WhitelistWeapons;
            _p addWeapon _w;			
		};
	};
	if (DAN_noNVG) then {
		private _nvg = hmd _p;
		if (_nvg != "") then {
			_p unlinkItem _nvg;
			_p removeItem _nvg;
		};
	};
	if (DAN_noSuppressor) then {

		
		private _priMuzzle = (primaryWeaponItems _p) select 0;
		if (_priMuzzle != "") then {
			_p removePrimaryWeaponItem _priMuzzle;
		};

		
		private _hgMuzzle = (handgunItems _p) select 0;
		if (_hgMuzzle != "") then {
			_p removeHandgunItem _hgMuzzle;
		};
	};


	[_p] call tsp_fnc_animate_inspect;

    private _items = DAN_blacklistitems;
    if (_items isEqualType "") then {
        _items = [_items];
    };
    
    private _removedItems = createHashMap;
    
    {
        private _item = _x;
        private _count = 0;
        
        
        while {_item in (uniformItems _p)} do {
            _p removeItemFromUniform _item;
            _count = _count + 1;
        };
        
        while {_item in (vestItems _p)} do {
            _p removeItemFromVest _item;
            _count = _count + 1;
        };
        
        while {_item in (backpackItems _p)} do {
            _p removeItemFromBackpack _item;
            _count = _count + 1;
        };
        
        if (_item in (assignedItems _p)) then {
            _p unassignItem _item;
            _p removeItem _item;
            _count = _count + 1;
        };
        
        
        if (_item in (weapons _p)) then {
            _p removeWeapon _item;
            _count = _count + 1;
        };
        
       
        while {_item in (magazines _p)} do {
            _p removeMagazine _item;
            _count = _count + 1;
        };
        
        
        if (_count > 0) then {
            _removedItems set [_item, _count];
        };
        
    } forEach _items;
    
    
    if (count _removedItems > 0) then {
        private _text = "<t size='1.2' color='#ff0000'>black list items</t><br/><br/>";
        
        {
            private _itemClass = _x;
            private _itemCount = _y;
            private _itemName = getText (configFile >> "CfgWeapons" >> _itemClass >> "displayName");
            
            if (_itemName == "") then {
                _itemName = getText (configFile >> "CfgMagazines" >> _itemClass >> "displayName");
            };
            if (_itemName == "") then {
                _itemName = getText (configFile >> "CfgVehicles" >> _itemClass >> "displayName");
            };
            if (_itemName == "") then {
                _itemName = _itemClass;
            };
            
            private _picture = getText (configFile >> "CfgWeapons" >> _itemClass >> "picture");
            if (_picture == "") then {
                _picture = getText (configFile >> "CfgMagazines" >> _itemClass >> "picture");
            };
            if (_picture == "") then {
                _picture = getText (configFile >> "CfgVehicles" >> _itemClass >> "picture");
            };
            
            _text = _text + format ["<img image='%1' size='1.5'/> <t color='#ffffff'>%2 has been removed</t> x<t color='#ffff00'>%3</t><br/>", _picture, _itemName, _itemCount];
            
        } forEach _removedItems;
        
        [parseText _text, true, nil, 7, 0.7, 0] spawn BIS_fnc_textTiles;
    };
    
    true
};
[missionNamespace, "arsenalClosed", {call DAN_arsenalclose;}] call BIS_fnc_addScriptedEventHandler;
["ace_arsenal_displayClosed", {
    params ["_display"];
    call DAN_arsenalclose;
}] call CBA_fnc_addEventHandler;