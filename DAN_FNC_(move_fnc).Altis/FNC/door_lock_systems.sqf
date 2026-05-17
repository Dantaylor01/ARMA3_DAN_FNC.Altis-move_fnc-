DAN_doorlock = {
	params [
		"_centerPos",
		"_radius",
		"_buildingLockChance",
		"_doorLockChance",
		"_alwaysLockFloorDoors",
		"_alwaysLockDoors"
	];
    if (!DAN_Enabledoorlock) exitWith {};
	private _housesList = nearestObjects [
		_centerPos,
		["House", "House_Small", "Building"],
		_radius,
		true
	];

	private _selectedBuildingsCount = 0;
	private _lockedDoorsCount = 0;
	private _door = "";
	private _doorIsFirstFloor = false;
	private _doorIsExternal = false;


	for "_i" from 0 to ((count _housesList) - 1) do {
		if ((random 1) <= _buildingLockChance) then
		{	
			
			_house = _housesList select _i;
			_houseDoors = (selectionNames _house) select {toUpper _x find "DOOR" >= 0 AND toUpper _x find "HANDLE" == -1};
			_houseDoors sort true;
			_doorCount = count _houseDoors;
			

			
			_selectedBuildingsCount = _selectedBuildingsCount + 1;
			
			
			
			for "_j" from 1 to _doorCount do 
			{
				_door = _houseDoors select (_j - 1);
				
				
				if (_alwaysLockFloorDoors)
				then
				{
				
					_doorPosition = _house modelToWorld (_house selectionPosition _door);
					if ((_doorPosition select 2) <= 2) 
					then {_doorIsFirstFloor = true;}
					else {_doorIsFirstFloor = false;};
					
				
					_doorAlignment = [];
					_doorAlignment1 = 0; 
					_doorAlignment2 = 0;   
					
					_doorTriggerPos = _house selectionPosition format ["%1_trigger", _door]; 
					_doorAxispos = _house selectionposition format ["%1_axis", _door];
					_doorLocalAlignment = _doorTriggerPos getDir _doorAxisPos; 
					
					_doorTriggerPos1 = [(_doorTriggerPos select 0) - 0.3, (_doorTriggerPos select 1) - 0.3, (_doorTriggerPos select 2) + 0.6]; 
					_doorTriggerPos1 = _house modelToWorld _doorTriggerPos1; 
					_doorTriggerPos2 = [(_doorTriggerPos select 0) + 0.3, (_doorTriggerPos select 1) + 0.3, (_doorTriggerPos select 2) + 0.6]; 
					_doorTriggerPos2 = _house modelToWorld _doorTriggerPos2; 
					
					_doorTriggerPos = _house modelToWorld (_doorTriggerPos); 
					_doorAxispos = _house modeltoworld (_doorAxispos); 
					_doorAlignment = _doorTriggerPos getdir _doorAxisPos; 
					
		
					if ((_doorLocalAlignment >= 45) && (_doorLocalAlignment <= 225)) 
					then 
					{ 
						_doorAlignment1 = (_doorAlignment) + 90;  
						_doorAlignment2 = (_doorAlignment) - 90; 
					} 
					else 
					{ 
						_doorAlignment1 = (_doorAlignment) - 90;  
						_doorAlignment2 = (_doorAlignment) + 90; 
					}; 


					_doorOrthogonalVector1X = sin _doorAlignment1;  
					_doorOrthogonalVector1Y = cos _doorAlignment1; 
					_doorOrthogonalVector2X = sin _doorAlignment2;  
					_doorOrthogonalVector2Y = cos _doorAlignment2;  

					_doorOrthogonalVector1 = [_doorOrthogonalVector1X * 8,_doorOrthogonalVector1Y * 8, 2.4]; 
					_doorOrthogonalVector2 = [_doorOrthogonalVector2X * 8,_doorOrthogonalVector2Y * 8, 2.4]; 

					_line1 = _doorTriggerPos1 vectorAdd _doorOrthogonalVector1;   
					_line2 = _doorTriggerPos2 vectorAdd _doorOrthogonalVector2;  

	
					if ((lineIntersects [AGLToASL _doorTriggerPos1, AGLToASL _line1]) && (lineIntersects [AGLToASL _doorTriggerPos2, AGLToASL _line2])) 
					then 
					{ 
						_doorIsExternal = false; 
					} 
					else 
					{ 
						_doorIsexternal = true; 
					};
								
				};

				if (((random 1) <= _doorLockChance) || ((_alwaysLockDoors find (str _j)) != -1) || (_doorIsFirstFloor && _doorIsExternal && _alwaysLockFloorDoors)) then
				{
					_house setVariable [format["bis_disabled_%1",_door],1,true];

					_lockedDoorsCount = _lockedDoorsCount + 1;	
				};			
			};
		};
	};

	if (DAN_DEBUG) then {
		systemChat format ["%1 buildings selected for Lockdown.", _selectedBuildingsCount];
		systemChat format ["%1 doors locked.", _lockedDoorsCount];
	};
};