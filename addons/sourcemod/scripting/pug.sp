#include <sourcemod>
#include <pug>
#include <multicolors>
#include <smlib>
#include <cstrike>
#include <restorecvars>
#include <sdkhooks>
#include <fys.huds>

#pragma semicolon 1
#pragma newdecls required

#include "pug/globals.sp"
#include "pug/record.sp"
#include "pug/teamvote.sp"
#include "pug/mapvote.sp"
#include "pug/captainpick.sp"
#include "pug/friendlyfire.sp"
#include "pug/commands.sp"
#include "pug/util.sp"
#include "pug/natives.sp"
#include "pug/configs.sp"

public Plugin myinfo = {
	name = "PUG - Main",
	author = "Xc_ace",
	description = "Match Plugin for CS:GO",
	version = "1.0 alpha",
	url = "https://github.com/Cola-Ace/Simple-Pug"
}

public void OnPluginStart(){
	g_MapList = new ArrayList(64);
	g_MapVote = new StringMap();
	//Command
	LoadCommands();
	//Read Map
	ReadMapConfig();
	//ConVar
	g_cPrefix = CreateConVar("sm_simple_pug_prefix", "[{green}PUG{default}]", "Message Prefix");
	g_cMaxPlayers = CreateConVar("sm_simple_pug_maxplayers", "10", "Max Players in a round", _, true, 2.0);
	//g_cMapChange = CreateConVar("sm_simple_pug_mapchange", "0", "Map Change Mode (0=Instant, 1=Vote, 2=Veto)", _, true, 0.0, true, 2.0);
	//g_cKnifeRound = CreateConVar("sm_simple_pug_kniferound", "1", "Enable Knife Round?", _, true, 0.0, true, 1.0);
	g_cEnableDemoRecord = CreateConVar("sm_simple_pug_demo_record", "1", "Record demo?", _, true, 0.0, true, 1.0);
	g_cDemoFile = CreateConVar("sm_simple_pug_demo_file", "PUG#{MAP}#{TIME}", "Demo File Save Location(support {MAP}, {TIME})");
	g_cDemoTimeFormat = CreateConVar("sm_simple_pug_time_format", "%Y-%m-%d_%H:%M", "Time Format");
	g_cFriendlyFire = CreateConVar("sm_simple_pug_friendlyfire", "1", "Props can still deal damage to teammates when mp_friendlyfire is off", _, true, 0.0, true, 1.0);
	//AutoExecConfig(true, "sourcemod/pug/pug.cfg");
	//Hook ConVar
	g_cPrefix.AddChangeHook(OnPrefixChange);
	//ForWard
	g_hOnGameStateChanged = CreateGlobalForward("PUG_OnGameStateChanged", ET_Ignore, Param_Cell, Param_Cell);
	g_hOnReady = CreateGlobalForward("PUG_OnReady", ET_Ignore, Param_Cell);
	g_hOnUnready = CreateGlobalForward("PUG_OnUnready", ET_Ignore, Param_Cell);
	g_hOnLive = CreateGlobalForward("PUG_OnLive", ET_Ignore);
	g_hOnForceEnd = CreateGlobalForward("PUG_OnForceEnd", ET_Ignore, Param_Cell);
	g_hOnForceStart = CreateGlobalForward("PUG_OnForceStart", ET_Ignore, Param_Cell);
	g_hOnMatchOver = CreateGlobalForward("PUG_OnMatchOver", ET_Ignore, Param_Cell, Param_String);
	g_hOnWarmupConfigExecuted = CreateGlobalForward("PUG_OnWarmupConfigExecuted", ET_Ignore);
	//Hook
	HookEvent("cs_win_panel_match", Event_MatchOver);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("round_end", Event_RoundEnd);
	//Set Prefix
	SetPrefix();
	//Listen
	AddCommandListener(Listen_Ready, "drop");
	AddCommandListener(Listen_JoinTeam, "jointeam");
}

public void OnMapStart(){
	ChangeGameState(GameState_Warmup);
}

public Action Listen_JoinTeam(int client, const char[] command, int args){
	if (PUG_GetGameState() == GameState_PickingPlayers){
		CS_SwitchTeam(client, CS_TEAM_SPECTATOR);
		PUG_Message(client, "当前正在选人，无法加入队伍");
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action Listen_Ready(int client, const char[] command, int args){
	if (PUG_IsWarmup()){
		FakeClientCommand(client, "sm_ready");
	}
}

public void OnPrefixChange(ConVar convar, const char[] oldValue, const char[] newValue){
	CSetPrefix(newValue);
}

public void PUG_OnGameStateChanged(GameState before, GameState after){
	//Start Warmup When GameState Changed To Warmup
	if (after == GameState_Warmup){
		StartWarmup();
	}
}

public Action Event_RoundEnd(Event event, const char[] name, bool dontBroadcast){
	if (PUG_GetGameState() == GameState_KnifeRound){
		int team = event.GetInt("winner");
		PUG_MessageToAll("{green}%s{default} 取得了胜利", team == CS_TEAM_CT ? "CT":"T");
		VoteTeam(team);
	}
}

//Give Player Money When Death In Warmup
public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast){
	if (PUG_IsWarmup()){
		int client = GetClientOfUserId(event.GetInt("userid"));
		SetClientMoney(client, 16000);
	}
}

//Set Disconnect Captain
public void OnClientDisconnect(int client){
	int captain = PUG_IsCaptain(client);
	if (captain != -1){
		g_iCaptain[captain] = -1;
	}
	if (PUG_IsReady(client)){
		PUG_UnReadyPlayer(client);
	}
}

public void OnClientPostAdminCheck(int client){
	if (!IsValidClient(client))return;
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	if (GetRealClientCount() >= PUG_GetMaxPlayers()){
		PUG_SetRandomCaptains();
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3]){
	if (!PUG_IsMatchLive()){
		return Plugin_Continue;
	}
	if (g_cFriendlyFire.BoolValue && !g_bFriendlyFire){
		if (attacker < 1 || attacker > MaxClients || attacker == victim || weapon < 1){
			return Plugin_Continue;
		}
		if (GetClientTeam(victim) == GetClientTeam(attacker)){
			return Plugin_Handled;	
		}
	}
	return Plugin_Continue;
}

public Action Event_MatchOver(Event event, const char[] name, bool dontBroadcast){
	char demoName[256];
	g_cDemoFile.GetString(demoName, sizeof(demoName));
	Call_StartForward(g_hOnMatchOver);
	Call_PushCell(g_cEnableDemoRecord.BoolValue);
	Call_PushString(demoName);
	Call_Finish();
	if (g_cEnableDemoRecord.BoolValue){
		StopRecord();
	}
}

public void PUG_OnReady(int client){
	if (g_iReadyPlayers >= PUG_GetMaxPlayers() && g_iReadyPlayers == GetRealClientCount()){
		StartGame();
	}
}