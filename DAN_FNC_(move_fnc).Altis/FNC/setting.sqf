"━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
"        DEBUG SETTINGS      ";
"━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
DAN_DEBUG = false;                     "เปิดโหมดดีบัก (แสดงข้อความต่างๆในเกม)";
DAN_DEBUG_HEIED = false;
DAN_DEBUG_2ndbomb = false;
DAN_DEBUG_BRNHQ = false;
"━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
"        ตั้งค่า, เปิดปิดต่างๆ     ";
"━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
// สภาพอากาศ
DAN_EnableSessionDynamicWeather = false;    "เปิดระบบสภาพอากาศแบบไดนามิก เมื่อเริ่มเกม";
DAN_EnableMissionDynamicWeather = false;    "เปิดระบบสภาพอากาศแบบไดนามิก เฉพาะเมืองที่มีภารกิจ";

// ประชาชนในเมืองแบบภารกิจ
DAN_EnableMissionCIVAmbient = true;  "เปิดการเกิดพลเรือนในเมือง เฉพาะเมืองที่มีภารกิจ";
DAN_MissionCivPopulationDivideBy = 3; "จำนวนหาร ของประชากรพลเรือนในเมืองภารกิจ (ยิ่งมากยิ่งน้อย)";

// ประชาชนในเมืองแบบไดนามิก
DAN_DynamicCIVCityTriggerSize = 1000; "ขนาดของ trigger สำหรับการเกิดและลบประชาชนในเมืองแบบไดนามิก (หน่วยเป็นเมตร)";
DAN_EnableDynaCIVAmbient = false;    "เปิดการเกิดพลเรือนในเมือง แบบไดนามิก ";
DAN_DynamicCivPopulationDivideBy = 3; "จำนวนหาร ของประชากรพลเรือนในเมืองแบบไดนามิก (ยิ่งมากยิ่งน้อย)";

// arsenal
DAN_RestrictWeapon  = false;        "เปิดการจำกัดอาวุธ";
DAN_noRPG = false; 
DAN_noNVG = false; 
DAN_noSuppressor = false; 

// ภารกิจ
DAN_EnableBRNHQ = true;             "เปิดภารกิจหลัก";
DAN_Enabledoorlock = false;         "เปิดการล็อคประตูในภารกิจรอง";
DAN_EnableHVT = true;               "เปิดการเกิด HVT ในภารกิจรอง";
DAN_EnableBomb = true;              "เปิดภารกิจกู้ระเบิด";
DAN_EnableHostage = true;           "เปิดภารกิจช่วยตัวประกัน";
DAN_EnableVIP = true;
DAN_EnableSiege = true;
DAN_EnableRescue =true;
DAN_OpforMultiply = 1;              "จำนวนคูณของฝั่งตรงข้าม";
DAN_RKKResizeIfFailed = true;        "อนุญาตให้ขนาด marker ของ RKK เปลี่ยนเมื่อภารกิจล้มเหลว";
DAN_RKKIncreaseMarkerSize = 1.5;      "ขนาด marker ของ RKK เมื่อภารกิจล้มเหลว";
DAN_RKKDecreaseMarkerSize = 0.5;      "ขนาด marker ของ RKK เมื่อภารกิจสำเร็จ";
DAN_EnableBehindEnemyLine = false;     "เปิดภารกิจ Behind Enemy Line (ภารกิจกู้นักบินเมื่อเครื่องบินถูกยิงตก)";

// IED
DAN_CarbombInCity = true;           "เปิดการเกิดรถระเบิดในเมือง";
DAN_IEDstart = 2;                   "จำนวน IED ที่จะเริ่มต้นในแผนที่";
DAN_IEDAtfail = 1;                  "จำนวน IED ที่จะเพิ่มเมื่อภารกิจล้มเหลว";
DAN_MoreIEDPower = false;           "เพิ่มความแรงของ IED";
DAN_burryIED = true;                "ฝังระเบิดลงดินเพื่อให้ยากต่อการตรวจจับ";

// CSI
DAN_EnableFingerPrint = false;       "เปิดการเก็บลายนิ้วมือ";
DAN_EnableToolMarks = false;         "เปิดการเก็บรอยเครื่องมือ";

// sound track
DAN_SoundTrack = false;             "เปิดเพลงประกอบ";

// อื่นๆ
DAN_PlotIntelOnMap = false;          "เปิดการแสดงข้อมูลภารกิจบนแผนที่";
"━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
"   classname, arsenal       ";
"━━━━━━━━━━━━━━━━━━━━━━━━━━━━";

DAN_WhitelistWeapons  = [
    "RTP_rifles",
    "RTP_rifles_Bolt_opened",
    "RTP_rifles_chamber_empty",
    "RTP_rifles_jamed",
    "RTP_rifles_Double_Feed"
];
DAN_blacklistitems = [
	"MineDetector"
];
DAN_digtools = [
	"ACE_EntrenchingTool",
	"rhs_weap_etool",         
	"vn_b_item_tool_01"      
];
"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
" classname BRN (ภารกิจหลัก)             ";
"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
DAN_BRNCommanderClass = [
    "C_Man_formal_2_F"
];
DAN_BRNCommanderNames = [
    "Hun Sen",
    "Benjamin Netanyahu",
    "Vladimir Putin",
    "Xi Jinping",
    "Kim Jong-un"
];
DAN_BRNMotorTeams = [
    [
        "O_G_Soldier_TL_F", 
        "O_G_Soldier_AR_F", 
        "O_G_Soldier_LAT_F", 
        "O_G_medic_F", 
        "O_G_Soldier_F", 
        "O_G_Offroad_01_F"
    ],
    [
        "O_G_Offroad_01_armed_F",
        "O_G_Offroad_01_armed_F",
        "O_G_Offroad_01_armed_F"
    ],
    [
        "RKKTerroristFaction_Platoon_Commander_01", 
        "RKKTerroristFaction_Fireteam_Leader_A_01", 
        "RKKTerroristFaction_Fireteam_Leader_B_01", 
        "RKKTerroristFaction_Offroad_01", 
        "RKKTerroristFaction_Van_01"
    ],
    [
        "RKKTerroristFaction_Platoon_Commander_01", 
        "RKKTerroristFaction_Fireteam_Leader_A_01", 
        "RKKTerroristFaction_Fireteam_Leader_B_01", 
        "RKKTerroristFaction_Offroad_01", 
        "RKKTerroristFaction_Truck_01", 
        "RKKTerroristFaction_Van_01"        
    ]
];
DAN_BRNDefendTeams = [
    [
        "O_G_Soldier_SL_F", 
        "O_G_Soldier_AR_F", 
        "O_G_Soldier_LAT_F", 
        "O_G_Soldier_A_F", 
        "O_G_Soldier_F", 
        "O_G_medic_F", 
        "O_G_HMG_02_high_F"
    ]
];
DAN_BRNSniperTeams = [
    [
        "O_G_Soldier_M_F"
    ]
];
DAN_BRNAntiAirTeams = [
    [
        "O_Radar_System_02_F", 
        "O_G_Soldier_TL_F", 
        "O_G_Soldier_AR_F", 
        "O_G_Soldier_LAT_F", 
        "O_G_Soldier_A_F", 
        "rhs_zsu234_aa"
    ]
];
DAN_BRNBoatTeams = [
    [
        "RKKTerroristFaction_Platoon_Commander_01", 
        "RKKTerroristFaction_Boat_01"
    ]
];
DAN_BRNAircraftCarrier = [
    "Land_Carrier_01_base_F"
];
DAN_BRNArtilleryTeams = [
    [    
        "rhs_D30_msv", 
        "O_soldierU_TL_F", 
        "O_soldierU_AR_F", 
        "O_SoldierU_GL_F", 
        "O_soldierU_LAT_F"
    ],
    [
        "RHS_BM21_MSV_01", 
        "O_soldierU_TL_F", 
        "O_soldierU_AR_F", 
        "O_SoldierU_GL_F", 
        "O_soldierU_LAT_F"
    ]
];
DAN_BRNTankTeams = [
    [
        "O_T_MBT_02_cannon_ghex_F"
    ],
    [
        "O_T_APC_Tracked_02_AA_ghex_F"
    ],
    [   
        "O_T_MBT_04_command_F"
    ]
];
"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
" classname (RKK missions)                  ";
"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
DAN_hostageclass = [
    "O_Officer_Parade_F",
    "O_officer_F", 
    "O_Officer_Parade_Veteran_F", 
    "O_diver_TL_F", 
    "O_A_soldier_F", 
    "O_A_soldier_TL_F", 
    "O_T_Officer_F", 
    "O_G_Soldier_A_F", 
    "O_G_Soldier_AR_F", 
    "O_G_engineer_F", 
    "O_G_Soldier_lite_F", 
    "O_G_Sharpshooter_F", 
    "O_G_Survivor_F", 
    "O_G_Soldier_TL_F"
];
DAN_HVTclass = [
	"O_Story_CEO_F", 
	"O_Story_Colonel_F", 
	"O_A_soldier_F", 
	"O_A_soldier_TL_F"
];
DAN_RKKteams = [
	[
		"O_RKKTerroristFaction_Ketua_01", 
		"O_RKKTerroristFaction_Pengawas_01", 
		"O_RKKTerroristFaction_Penulung_Ketua_01", 
		"O_RKKTerroristFaction_Penutupan_01", 
		"O_RKKTerroristFaction_Perubatan_01", 
		"O_RKKTerroristFaction_Sembuyan_01"
	],
	[
		"O_G_Soldier_SL_F", 
		"O_G_Soldier_TL_F", 
		"O_G_Soldier_AR_F", 
		"O_G_Soldier_LAT_F", 
		"O_G_Soldier_A_F", 
		"O_G_medic_F", 
		"O_G_Soldier_F"
	],
    [
        "O_G_Soldier_SL_F", 
        "O_G_Soldier_AR_F", 
        "O_G_Soldier_LAT_F", 
        "O_G_Soldier_A_F", 
        "O_G_Soldier_F", 
        "O_G_medic_F"
    ],
    [
        "O_G_Soldier_TL_F", 
        "O_G_Offroad_01_F", 
        "O_G_Soldier_AR_F", 
        "O_G_Soldier_LAT_F", 
        "O_G_medic_F", 
        "O_G_Soldier_F"
    ],
    [
        "O_G_Soldier_TL_F", 
        "O_G_Soldier_AR_F", 
        "O_G_medic_F"
    ]
];
DAN_GarrisonTeams = [
	[
		"O_RKKTerroristFaction_Ketua_01", 
		"O_RKKTerroristFaction_Pengawas_01", 
		"O_RKKTerroristFaction_Penulung_Ketua_01", 
		"O_RKKTerroristFaction_Penutupan_01", 
		"O_RKKTerroristFaction_Perubatan_01", 
		"O_RKKTerroristFaction_Sembuyan_01"
	],
	[
		"O_G_Soldier_SL_F", 
		"O_G_Soldier_TL_F", 
		"O_G_Soldier_AR_F", 
		"O_G_Soldier_LAT_F", 
		"O_G_Soldier_A_F", 
		"O_G_medic_F", 
		"O_G_Soldier_F"
	],
    [
        "O_G_Soldier_SL_F", 
        "O_G_Soldier_AR_F", 
        "O_G_Soldier_LAT_F", 
        "O_G_Soldier_A_F", 
        "O_G_Soldier_F", 
        "O_G_medic_F"
    ],
    [
        "O_G_Soldier_TL_F", 
        "O_G_Offroad_01_F", 
        "O_G_Soldier_AR_F", 
        "O_G_Soldier_LAT_F", 
        "O_G_medic_F", 
        "O_G_Soldier_F"
    ],
    [
        "O_G_Soldier_TL_F", 
        "O_G_Soldier_AR_F", 
        "O_G_medic_F"
    ]
];
"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
" classname ประชาชนในพื้นที่แบบไดนามิก  ";
"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
DAN_DynamicCivInCityClass = [
    
    "C_man_1","C_man_polo_1_F","C_man_polo_2_F",
    "C_man_polo_3_F","C_man_polo_4_F","C_man_polo_5_F",
    "C_man_polo_6_F","C_man_1_1_F","C_man_1_2_F",
    "C_man_1_3_F","C_Man_casual_1_F","C_Man_casual_2_F",
    "C_Man_casual_3_F","C_man_sport_1_F","C_man_sport_2_F",
    "C_man_sport_3_F"
    
];
DAN_DynamicCivInForestTeams = [
    
    [    
        "C_man_1",
        "C_man_polo_1_F",
        "C_man_polo_2_F",
        "C_Offroad_01_F"
    ]
    
];
DAN_DynamicCivCarClass = [
	"C_Offroad_01_F","C_Offroad_02_unarmed_F","C_SUV_01_F",
	"C_Hatchback_01_F","C_Hatchback_01_sport_F","C_Van_01_transport_F",
	"C_Van_01_box_F","C_Truck_02_transport_F","C_Truck_02_covered_F"
];
"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
" classname ประชาชนในพื้นที่เฉพาะมี mission ";
"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
DAN_civclass = [
	"C_man_1","C_man_polo_1_F","C_man_polo_2_F",
	"C_man_polo_3_F","C_man_polo_4_F","C_man_polo_5_F",
	"C_man_polo_6_F","C_man_1_1_F","C_man_1_2_F",
	"C_man_1_3_F","C_Man_casual_1_F","C_Man_casual_2_F",
	"C_Man_casual_3_F","C_man_sport_1_F","C_man_sport_2_F",
	"C_man_sport_3_F"
];
DAN_carclass = [
	"C_Offroad_01_F","C_Offroad_02_unarmed_F","C_SUV_01_F",
	"C_Hatchback_01_F","C_Hatchback_01_sport_F","C_Van_01_transport_F",
	"C_Van_01_box_F","C_Truck_02_transport_F","C_Truck_02_covered_F"
];
