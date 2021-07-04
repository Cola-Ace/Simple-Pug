stock bool IsValidClient(int client) {
	return client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client);
}

stock bool IsPlayer(int client, bool spec = false) {
	if (spec) {
		return IsValidClient(client) && !IsFakeClient(client);
	} else {
		return IsValidClient(client) && !IsFakeClient(client) && GetClientTeam(client) != CS_TEAM_SPECTATOR;
	}
}

stock int GetMaxNumber(ArrayList number, bool index = false){
	int max = 0;
	for (int i = 0; i < number.Length; i++){
		if (number.Get(i) > max){
			if (index){
				max = i;
			} else {
				max = number.Get(i);
			}
		}
	}
	return max;
}

stock bool IsPaused() {
	return GameRules_GetProp("m_bMatchWaitingForResume") != 0;
}

stock bool IsWarmup() {
	return g_GameState == GameState_Warmup;
}

stock bool IsAdmin(int client) {
	return CheckCommandAccess(client, "sm_admin", ADMFLAG_GENERIC, false);
}

stock int GetRealClientCount(bool spec = false) {
	int clients = 0;
	for (int i = 0; i < MaxClients; i++) {
		if (IsPlayer(i)) {
			if (spec) {
				clients++;
			} else {
				if (GetClientTeam(i) == CS_TEAM_CT || GetClientTeam(i) == CS_TEAM_T) {
					clients++;
				}
			}
		}
	}
	return clients;
}

stock void ChangeGameState(GameState state) {
	Call_StartForward(g_hOnGameStateChanged);
	Call_PushCell(g_GameState);
	Call_PushCell(state);
	Call_Finish();
	g_GameState = state;
}

stock void ForceEnd(int client) {
	ChangeGameState(GameState_Warmup);
	Call_StartForward(g_hOnForceEnd);
	Call_PushCell(client);
	Call_Finish();
}

stock void ForceStart(int client) {
	Call_StartForward(g_hOnForceStart);
	Call_PushCell(client);
	Call_Finish();
	StartGame();
}

stock void StartGame(){
	ChangeGameState(GameState_GoingLive);
	if (!g_bIsChangeMap){
		VoteMap();
	} else {
		CaptainPick();
	}
}

stock void StartKnifeRound(){
	ChangeGameState(GameState_KnifeRound);
	ExecuteAndSaveCvars("sourcemod/pug/knife.cfg");
	Huds_ShowRealHudAll("拼刀选边");
}

stock void SetPrefix() {
	char prefix[256];
	g_cPrefix.GetString(prefix, sizeof(prefix));
	CSetPrefix(prefix);
}

stock void SetClientMoney(int client, int money){
	SetEntProp(client, Prop_Send, "m_iAccount", money);
}

stock void StartWarmup(){
	ExecuteAndSaveCvars("sourcemod/pug/warmup.cfg");
	Call_StartForward(g_hOnWarmupConfigExecuted);
	Call_Finish();
	ClearData();
	CreateTimer(1.0, Timer_CheckReady, _, TIMER_REPEAT);
}

public Action Timer_CheckReady(Handle timer){
	if (!PUG_IsWarmup()){
		return Plugin_Stop;
	}
	for (int i = 0; i < MaxClients; i++){
		if (IsPlayer(i)){
			if (!PUG_IsReady(i)){
				PrintCenterText(i, "按 G 准备");
			} else {
				char msg[256];
				Format(msg, sizeof(msg), "%i/%i 已准备", g_iReadyPlayers, GetRealClientCount());
				Huds_ShowRealHudOne(i, msg, 2);
			}
		}
	}
	return Plugin_Continue;
}

stock void ClearData(){
	for (int i = 0; i < MaxClients; i++){
		g_bIsReady[i] = false;
	}
	g_iReadyPlayers = 0;
	g_iAllowFriendlyFire = 0;
	g_iCaptain[0] = -1;
	g_iCaptain[1] = -1;
	g_MapVote.Clear();
	g_iAllowCT = 0;
	g_iAllowT = 0;
}

stock void CancelAllMenus(){
	for (int i = 0; i < MaxClients; i++){
		if (IsPlayer(i)){
			CancelClientMenu(i);
		}
	}
}

stock void SwitchTeam(){
	ArrayList g_CT = new ArrayList();
	ArrayList g_T = new ArrayList();
	for (int i = 0; i < MaxClients; i++){
		if (IsPlayer(i)){
			if (GetClientTeam(i) == CS_TEAM_CT){
				g_CT.Push(i);
			} else if (GetClientTeam(i) == CS_TEAM_T){
				g_T.Push(i);
			}
		}
	}
	for (int i = 0; i < g_CT.Length; i++){
		CS_SwitchTeam(g_CT.Get(i), CS_TEAM_T);
	}
	for (int i = 0; i < g_T.Length; i++){
		CS_SwitchTeam(g_T.Get(i), CS_TEAM_CT);
	}
}

stock void GoingLive(){
	ChangeGameState(GameState_GoingLive);
	ServerCommand("mp_restartgame 3");
	CreateTimer(3.1, Timer_Live);
}

public Action Timer_Live(Handle timer){
	Huds_ShowRealHudAll("比赛开始");
	ExecuteAndSaveCvars("sourcemod/pug/live.cfg");
	ChangeGameState(GameState_Live);
	Call_StartForward(g_hOnLive);
	Call_Finish();
	Record();
}