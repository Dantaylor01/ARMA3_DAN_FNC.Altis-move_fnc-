DAN_WelcomeText = {
    _text1 = "DAN_narathiwat_dynamic_mission";
    private _clean = DAN_V regexReplace ["Last Modified:\s*", ""];
    private _parts = _clean splitString " ";

    private _date = _parts select 0;
    private _time = _parts select 1;


    private _txt = parseText format [
        "
        <t align='center' size='1.4' color='#FFD700'>%1</t><br/>
        <t align='center' size='1'>
            Last Modified:
            <t color='#00FF00'> %2</t>
            <t color='#FF0000'> %3</t>
        </t>
        ",
        _text1,
        _date,
        _time
    ];



    [
        _txt,
        true,
        [10,5],
        15,
        0.5,
        0
    ] spawn BIS_fnc_textTiles;
    player createDiaryRecord [
    "Diary",
    ["code version", DAN_V]
];
};
[] remoteExec ["DAN_WelcomeText", 0, true];
