DAN_resizeRKKMarkers = {
    params [
        ["_finalsize", 2]
    ];
    if (!DAN_RKKResizeIfFailed) exitWith {};
    private _Allmkr = allMapMarkers;
    
    private _rkkMarkers = _Allmkr select {
        (toLower _x) find "rkk" > -1
    };


    {
        private _size = getMarkerSize _x;

        _x setMarkerSize [
            (_size select 0) * _finalsize,
            (_size select 1) * _finalsize
        ];

    } forEach _rkkMarkers;
};
