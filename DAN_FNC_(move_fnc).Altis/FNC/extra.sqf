/*
DAN_extra = {
    params ["_input", "_taskID"];
    
    private _taskIDextra = format ["%1extra", _taskID];
    private _units = [];
    
    if (DAN_DEBUG) then {
        systemChat format ["[DAN_DEBUG][DAN_extra] Input type: %1", typeName _input];
    };
    
    
    switch (typeName _input) do {
        
        
        case "ARRAY": {
            {
                private _item = _x;
                
                
                if (_item isEqualType grpNull) then {
                    _units append (units _item);
                } 
                
                else {
                    if (_item isEqualType objNull && {!isNull _item}) then {
                        
                        
                        if (_item isKindOf "Man") then {
                            _units pushBack _item;
                        } 
                        
                        else {
                            if (_item isKindOf "AllVehicles") then {
                                private _crew = crew _item;
                                if (_crew isNotEqualTo []) then {
                                    _units append _crew;
                                };
                            };
                            
                        };
                    };
                };
            } forEach _input;
            
            if (DAN_DEBUG) then {
                systemChat format ["[DAN_DEBUG][DAN_extra] Array processed → %1 units found", count _units];
            };
        };
        
        
        case "GROUP": {
            _units = units _input;
            if (DAN_DEBUG) then {
                systemChat format ["[DAN_DEBUG][DAN_extra] Group → %1 units", count _units];
            };
        };
        
        
        case "OBJECT": {
            if (!isNull _input) then {
                
                if (_input isKindOf "Man") then {
                    _units = [_input];
                    if (DAN_DEBUG) then {
                        systemChat "[DAN_DEBUG][DAN_extra] Single unit detected";
                    };
                } 
               
                else {
                    if (_input isKindOf "AllVehicles") then {
                        private _crew = crew _input;
						_units = [_input];
                        if (_crew isNotEqualTo []) then {
                            _units = _crew;
                            if (DAN_DEBUG) then {
                                systemChat format ["[DAN_DEBUG][DAN_extra] Vehicle → %1 crew", count _crew];
                            };
                        } else {
							
                            if (DAN_DEBUG) then {
                                systemChat "[DAN_DEBUG][DAN_extra] Vehicle has no crew";
                            };
                        };
                    } else {
                        _input setVariable ["taskIDextra", _taskIDextra, true];
                        if (DAN_DEBUG) then {
                            systemChat "[DAN_DEBUG][DAN_extra] Non-unit object → no units assigned";
                        };
                    };
                };
            };
        };
    };
    
    
    private _validUnits = _units select {!isNull _x && {alive _x} && {!isPlayer _x}};
    
    {
        _x setVariable ["taskIDextra", _taskIDextra, true];
    } forEach _validUnits;
    
    if (DAN_DEBUG) then {
        systemChat format [
            "[DAN_DEBUG][DAN_extra] Applied taskIDextra to %1/%2 units", 
            count _validUnits, 
            count _units
        ];
    };
    
    
    count _validUnits
};
*/
DAN_extra = {

	params ["_entities","_taskID"];

	private _varName = format ["%1extra", _taskID];

	// =====================================
	// Ensure array
	// =====================================

	if !(_entities isEqualType []) then {
		_entities = [_entities];
	};

	// =====================================
	// Existing registry
	// =====================================

	private _existing =
		missionNamespace getVariable [_varName, []];

	// =====================================
	// Append
	// =====================================

	_existing append _entities;

	// remove duplicates
	_existing = _existing arrayIntersect _existing;

	// =====================================
	// Save
	// =====================================

	missionNamespace setVariable [
		_varName,
		_existing,
		true
	];

	_existing
};