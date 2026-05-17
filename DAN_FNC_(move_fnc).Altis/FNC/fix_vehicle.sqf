DAN_fix_vehicle = {
    params ["_obj"];
    _obj addAction ["<t color='#00BFFF'>Repair / Rearm</t>", { 
 
    if (vehicle player != player) then { 
        player action ["GetOut", vehicle player]; 
        hint "Get your ass down here and fix it yourself!"; 
    } else { 
 
        private _nearVeh = objNull;   
 
        private _vehicles = nearestObjects [player, ["Car", "Truck", "Tank", "Air", "Ship"], 5]; 
         
        if (count _vehicles > 0) then { 
            _nearVeh = _vehicles select 0; 
            { 
                if ((player distance _x) < (player distance _nearVeh)) then { 
                    _nearVeh = _x; 
                }; 
            } forEach _vehicles; 
        }; 
 
        if (isNull _nearVeh) exitWith {hint "You want me to fix the air, you idiot?"}; 
 
        if ((player distance _nearVeh) < 3) then { 
 
            titleText ["Repairing and Rearming vehicle...", "PLAIN DOWN", 0.5]; 
            player playMove "Acts_carFixingWheel"; 
 
            private _smoke = "SmokeShellWhite" createVehicle position _nearVeh; 
            private _sparks = "SmallDestructionFire" createVehicle position _nearVeh; 
 
            disableSerialization; 
            private _display = findDisplay 46 createDisplay "RscDisplayEmpty"; 
 
            private _ctrlBack = _display ctrlCreate ["RscText", -1]; 
            _ctrlBack ctrlSetPosition [0.4, 0.9, 0.2, 0.03]; 
            _ctrlBack ctrlSetBackgroundColor [0,0,0,0.7]; 
            _ctrlBack ctrlCommit 0; 
 
            private _ctrlBar = _display ctrlCreate ["RscText", -1]; 
            _ctrlBar ctrlSetPosition [0.4, 0.9, 0, 0.03]; 
            _ctrlBar ctrlSetBackgroundColor [0,0.6,1,0.8]; 
            _ctrlBar ctrlCommit 0; 
 
            private _ctrlText = _display ctrlCreate ["RscText", -1]; 
            _ctrlText ctrlSetPosition [0.43, 0.87, 0.14, 0.03]; 
            _ctrlText ctrlSetTextColor [1,1,1,1]; 
            _ctrlText ctrlSetBackgroundColor [0,0,0,0]; 
            _ctrlText ctrlCommit 0; 
 
            private _duration = 5; 
            private _interval = 0.02; 
            private _elapsed = 0; 
            private _cancelled = false; 
            private _soundTimer = 0; 
 
            while {_elapsed < _duration} do { 
                private _progress = _elapsed / _duration; 
                private _percent = floor (_progress * 100); 
 
                _ctrlBar ctrlSetPosition [0.4, 0.9, 0.2 * _progress, 0.03]; 
                _ctrlBar ctrlCommit 0.02; 
                _ctrlText ctrlSetText format ["Repairing... %1%%", _percent]; 
 
                if ((player distance _nearVeh) > 3) exitWith {_cancelled = true;}; 
 
                _soundTimer = _soundTimer + _interval; 
                if (_soundTimer >= (0.5 + random 1)) then { 
                    _soundTimer = 0; 
                    private _snds = ["A3\sounds_f\vehicles\servicing\repair_toolkit_1.wss", 
                                    "A3\sounds_f\vehicles\servicing\repair_toolkit_2.wss"]; 
                    playSound3D [selectRandom _snds, _nearVeh]; 
                }; 
 
                _smoke setPos [(position _nearVeh select 0) + (random 0.5) - 0.25, (position _nearVeh select 1) + (random 0.5) - 0.25, (position _nearVeh select 2)]; 
                _sparks setPos [(position _nearVeh select 0) + (random 0.5) - 0.25, (position _nearVeh select 1) + (random 0.5) - 0.25, (position _nearVeh select 2)]; 
                _sparks setDamage (random 0.2); 
 
                sleep _interval; 
                _elapsed = _elapsed + _interval; 
            }; 
 
            _display closeDisplay 1; 
 
            if (_cancelled) then { 
                player playMove "Acts_carFixingWheel"; 
                playSound ["A3\Sounds_F\weapons\mechanical\tool_drop_1.wss", true]; 
                deleteVehicle _smoke; 
                deleteVehicle _sparks; 
                player switchMove ""; 
                titleText ["Repair cancelled! You moved too far away.", "PLAIN DOWN", 0.5]; 
            } else { 
                [_nearVeh, 0] remoteExec ["setDamage"]; 
                [_nearVeh, 1] remoteExec ["setVehicleAmmo"]; 
                playSound3D ["A3\sounds_f\weapons\reloads\reload_weapon_3.wss", _nearVeh]; 
                deleteVehicle _smoke; 
                deleteVehicle _sparks; 
                player switchMove ""; 
                titleText ["Vehicle repaired and rearmed!", "PLAIN DOWN", 0.5]; 
                playSound ["hintExpand", true]; 
            }; 
 
        } else { 
            hint "That's too far. Are you going to fix the car via Bluetooth?"; 
        }; 
    }; 
}];
};
