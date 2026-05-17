DAN_SoundTrackIsPlaying = false;
DAN_SoundTrackList = [
	"LeadTrack01b_F",
    "LeadTrack01a_F",
    "LeadTrack04_F"
];
addMusicEventHandler ["MusicStop", {

    params ["_musicClassname"];

    if (_musicClassname in DAN_SoundTrackList) then {
        DAN_SoundTrackIsPlaying = false;
    };
}];
DAN_AssignSoundTrack = {
    params ["_unit"];
    _unit addEventHandler ["Hit", {
        params ["_unit", "_source", "_damage", "_instigator"];
        if !(DAN_SoundTrack) exitWith {};
        if (DAN_SoundTrackIsPlaying) exitWith {};
        DAN_SoundTrackIsPlaying = true;
        private _track = selectRandom DAN_SoundTrackList;
        playMusic _track;
        if (DAN_DEBUG) then {
            systemChat "DEBUG: Soundtrack triggered by hit event";
        };
    }];
};
[player] call DAN_AssignSoundTrack;

player addEventHandler ["Respawn", {
	params ["_unit", "_corpse"];
	
    [_unit] call DAN_AssignSoundTrack;

}];

player addMPEventHandler ["MPRespawn", {
	params ["_unit", "_corpse"];
	
    [_unit] call DAN_AssignSoundTrack;
   
}];

addMissionEventHandler ["EntityRespawned", {
	params ["_newEntity", "_oldEntity"];
    if (isPlayer _newEntity) then {
        
        [_newEntity] call DAN_AssignSoundTrack;
    
    };
}];
