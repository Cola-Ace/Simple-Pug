 //Bool
bool g_bIsReady[MAXPLAYERS + 1];
bool g_bIsChangeMap = false;
bool g_bFriendlyFire = false;

//Int
int g_iCaptain[2] = -1;
int g_iReadyPlayers = 0;
int g_iAllowFriendlyFire = 0;
int g_iAllowCT = 0;
int g_iAllowT = 0;

//ConVar
ConVar g_cPrefix;
ConVar g_cMaxPlayers;
//ConVar g_cMapChange;
//ConVar g_cKnifeRound;
ConVar g_cEnableDemoRecord;
ConVar g_cDemoFile;
ConVar g_cDemoTimeFormat;
ConVar g_cFriendlyFire;

//Forward
Handle g_hOnGameStateChanged;
Handle g_hOnReady;
Handle g_hOnUnready;
Handle g_hOnLive;
Handle g_hOnForceEnd;
Handle g_hOnForceStart;
Handle g_hOnMatchOver;
Handle g_hOnWarmupConfigExecuted;

//GameState
GameState g_GameState = GameState_None;

//Map Change State
MapChange g_MapChange = MapChange_Vote; 

//Map Array
ArrayList g_MapList;

//Vote Array
StringMap g_MapVote;