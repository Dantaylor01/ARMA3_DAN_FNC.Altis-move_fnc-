
DAN_addRTP_jam_command = {
    params ["_obj"];
    _obj addAction [ 
        "<t color='#f10808' shadow='2' size='1.3'><img size='2' image='\A3\ui_f\data\IGUI\Cfg\Actions\RadarOff_ca.paa'/> RANDOM JAM</t>",  
        { 
            params ["_target", "_caller", "_actionId"];
            {
            private _unit = _X;
            private _weapon = currentWeapon _unit;
            private _wpnCfg	= configFile >> "cfgWeapons" >> _weapon;
            private _WeaSim	= getNumber (_wpnCfg >> "DanWeaponSim");
            if (_WeaSim != 1) exitWith {};
            private _RealWea = getText (_wpnCfg >> "DanRealWeapon");
            private _BoltOpened = getText (_wpnCfg >> "DanBoltOpened");
            private _WeaJammed = getText (_wpnCfg >> "DanJammed");
            private _doubleFeed = getText (_wpnCfg >> "DanDoubleFeed");

            private _AllJam = [_WeaJammed,_doubleFeed];
            private _RandomJam = selectRandom _AllJam ;
            [_RandomJam, 0] call Dan_Weapon_Sim_fnc_DanConvertModel;
        } forEach allPlayers;
        systemChat "random Jam is Activated"; 
    },
    nil, 1.5, true, true, "", "(_target distance _this) < 10"  
    ];

    _obj addAction [ 
        "<t color='#f10808' shadow='2' size='1.3'><img size='2' image='\A3\ui_f\data\IGUI\Cfg\Actions\RadarOff_ca.paa'/> common Jam</t>",  
        { 
            params ["_target", "_caller", "_actionId"];
            {
                private _unit = _X;
                private _weapon = currentWeapon _unit;
                private _wpnCfg	= configFile >> "cfgWeapons" >> _weapon;
                private _WeaSim	= getNumber (_wpnCfg >> "DanWeaponSim");
                if (_WeaSim != 1) exitWith {};
                private _RealWea = getText (_wpnCfg >> "DanRealWeapon");
            private _BoltOpened = getText (_wpnCfg >> "DanBoltOpened");
            private _WeaJammed = getText (_wpnCfg >> "DanJammed");
            private _doubleFeed = getText (_wpnCfg >> "DanDoubleFeed");

            [_WeaJammed, 0] call Dan_Weapon_Sim_fnc_DanConvertModel;
        } forEach allPlayers;
        systemChat "common Jam is Activated"; 
    },
    nil, 1.5, true, true, "", "(_target distance _this) < 10"  
    ];

    _obj addAction [ 
        "<t color='#f10808' shadow='2' size='1.3'><img size='2' image='\A3\ui_f\data\IGUI\Cfg\Actions\RadarOff_ca.paa'/> doubleFeed JAM</t>",  
        { 
            params ["_target", "_caller", "_actionId"];
            {
                private _unit = _X;
                private _weapon = currentWeapon _unit;
                private _wpnCfg	= configFile >> "cfgWeapons" >> _weapon;
                private _WeaSim	= getNumber (_wpnCfg >> "DanWeaponSim");
                if (_WeaSim != 1) exitWith {};
                private _RealWea = getText (_wpnCfg >> "DanRealWeapon");
            private _BoltOpened = getText (_wpnCfg >> "DanBoltOpened");
            private _WeaJammed = getText (_wpnCfg >> "DanJammed");
            private _doubleFeed = getText (_wpnCfg >> "DanDoubleFeed");

            [_doubleFeed, 0] call Dan_Weapon_Sim_fnc_DanConvertModel;
        } forEach allPlayers;

        systemChat "doubleFeed Jam is Activated"; 
    },
    nil, 1.5, true, true, "", "(_target distance _this) < 10"  
    ];
};
