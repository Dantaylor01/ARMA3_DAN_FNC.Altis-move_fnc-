DAN_stop_missfire_artillery_trigger = {
    if (!isServer) exitWith {};
    private _trigger = createTrigger ["EmptyDetector", [0,0,0]];

    _trigger setTriggerArea [50, 50, 0, false];

    _trigger setTriggerActivation ["ANY", "PRESENT", true];

    _trigger setTriggerStatements [
        "this",
        "
        {
            _x setCombatBehaviour 'CARELESS';
            systemChat 'stop miss fire artillery trigger activated';
        } forEach thisList;
        ",
        ""
    ];
};
call DAN_stop_missfire_artillery_trigger;