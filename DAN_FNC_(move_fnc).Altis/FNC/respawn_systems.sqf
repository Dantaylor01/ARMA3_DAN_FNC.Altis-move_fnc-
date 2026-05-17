"━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
"    ฟังชัน, ระบบ respawn      ";
"━━━━━━━━━━━━━━━━━━━━━━━━━━━━";

DAN_unloadBB = { 
    params ["_trigger"];
    private _units = _trigger nearObjects 8;      

    { 
        private _vehicle = _x; 

        
        if (_vehicle isKindOf "LandVehicle" || _vehicle isKindOf "Air" || _vehicle isKindOf "Ship") then {

            
            [_vehicle] spawn {
				params ["_vehicle"];
				waitUntil {sleep 0.5; speed _vehicle < 1};
				private _cargo = _vehicle getVariable ["ace_cargo_loaded", []]; 
				{
					private _bodyBag = _x; 
					if (_bodyBag isKindOf "ACE_bodyBagObject") then {
						[_bodyBag, _vehicle, _vehicle] call ace_cargo_fnc_unloadItem;  
						systemChat format ["Unload complete from %1", typeOf _vehicle]; 
					};
				} forEach _cargo;
			};
        } else {
            if (DAN_DEBUG) then {
            	systemChat format ["[DEBUG]DAN_unloadBB %1 is not a vehicle, skip.", typeOf _vehicle];
			};
		};

    } forEach _units;
};

DAN_loadBB = {
	params ["_heli"];
	if !(_heli isKindOf "Air") exitWith {};
	_this addEventHandler ["Gear", {
		params ["_vehicle", "_gearState"];
		
		if (_gearState) then {
			[_vehicle] spawn {
				params ["_vehicle"];
				
				
				waitUntil {isTouchingGround _vehicle || !alive _vehicle};
				if (!alive _vehicle) exitWith {};
				
				
				waitUntil {sleep 0.5; (speed _vehicle) < 1 || !alive _vehicle};
				if (!alive _vehicle) exitWith {};
				
				systemChat "Scanning for body bags and corpses nearby...";
				private _nearestBodyBags = nearestObjects [_vehicle, ["ACE_bodyBagObject"], 15];
				private _nearCorpses = allDeadMen select {_x distance _vehicle <= 15};
				private _targets = _nearestBodyBags + _nearCorpses;
				
				
				{
					private _item = _x;
					
					
					[_item, _vehicle,true] call ace_cargo_fnc_canLoadItemIn;
																
					private _BBdata = _item call ace_dogtags_fnc_getDogtagData;
					private _BBname = _BBdata select 0;
					systemChat format ["Loading %1 into helicopter...", _BBname];				
					sleep 0.2; 
				} forEach _targets;
			};
		};
	}];
};

DAN_giveticket = {
	params ["_trigger"];
	_process = {
		params ["_trigger"];
		if (DAN_DEBUG) then {
			systemChat "[DEBUG]DAN_giveticket Rescue area check active.";
		};
		
		private _triggerEntities = _trigger nearObjects 10;

		{

			private _giveticket = false;
			private _bodybag = _x;
			private _dogtagDATA =  _bodybag call ace_dogtags_fnc_getDogtagData;
			private _DeadNameInRescueZone = _dogtagDATA select 0;
			hint format ["%1", _DeadNameInRescueZone];
			private _deadmenname = allDeadMen apply {name _x};

			if ((_x isKindOf "ACE_bodyBagObject") and (_DeadNameInRescueZone in _deadmenname)) then {
				if (name player == _DeadNameInRescueZone) then {
					deleteVehicle _bodybag;
					[player, 1] call BIS_fnc_respawnTickets;
				};
			};
			if ((_x isKindOf "CAManBase") and (_DeadNameInRescueZone in _deadmenname)) then {
				if (name player == _DeadNameInRescueZone) then {
					[_bodybag] remoteExec ["deleteVehicle", 2];
					[player, 1] call BIS_fnc_respawnTickets;
				};
			};
		}forEach _triggerEntities;
	};
	[_process,_trigger] spawn {
		params ["_process","_trigger"];
		private _startTime = time;
		while {time < _startTime + 5} do {
			[_trigger] call _process;
			sleep 1;
		};
		if (DAN_DEBUG) then {
			systemChat "[DEBUG]DAN_giveticket Rescue area check stopped after 5 seconds.";
		};
	};

};

DAN_rescuearea = {
	params ["_trigger"];
	[_trigger] call DAN_unloadBB;
	[_trigger] call DAN_giveticket;
};
DAN_ResetTicketEH = {
    params ["_unit"];
    systemChat format ["Reset Ticket EH assigned to %1 ", name _unit];
    _unit addEventHandler ["Killed", {
        params ["_unit"];

        [_unit] spawn {
            params ["_unit"];
            private _Tickets = [_unit, nil, true] call BIS_fnc_respawnTickets;
        
            private _ReTicket = - _Tickets;
                    
            [_unit, _ReTicket] call BIS_fnc_respawnTickets;
            [_unit, -1] call BIS_fnc_respawnTickets;


            systemChat "Kill EH reset player ticket";
        };
        
    }];

};
[player] call DAN_ResetTicketEH;

player addEventHandler ["Respawn", {
	params ["_unit", "_corpse"];
    [_unit] call DAN_ResetTicketEH;
}];

player addMPEventHandler ["MPRespawn", {
	params ["_unit", "_corpse"];
    [_unit] call DAN_ResetTicketEH;
}];

addMissionEventHandler ["EntityRespawned", {
	params ["_newEntity", "_oldEntity"];
    if (isPlayer _newEntity) then {
        [_newEntity] call DAN_ResetTicketEH;
    };
}];