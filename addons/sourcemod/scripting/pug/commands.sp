stock void LoadCommands() {
	RegConsoleCmd("sm_ready", Command_Ready);
	RegConsoleCmd("sm_r", Command_Ready);
	RegConsoleCmd("sm_unready", Command_UnReady);
	RegConsoleCmd("sm_forcestart", Command_ForceStart);
	RegConsoleCmd("sm_forceend", Command_ForceEnd);
	RegConsoleCmd("sm_test", Test);
}

public Action Test(int client, int args){
	
}

public Action Command_ForceStart(int client, int args) {
	if (!IsAdmin(client)) {
		PUG_Message(client, "你无权使用此指令");
		return Plugin_Stop;
	}
	ForceStart(client);
	return Plugin_Continue;
}

public Action Command_ForceEnd(int client, int args) {
	if (!IsAdmin(client)) {
		PUG_Message(client, "你无权使用此指令");
		return Plugin_Stop;
	}
	if (PUG_IsWarmup() || PUG_GetGameState() != GameState_KnifeRound || PUG_GetGameState() != GameState_Live){
		PUG_Message(client, "现在无法使用此指令");
	}
	ForceEnd(client);
	return Plugin_Continue;
}

public Action Command_Ready(int client, int args) {
	if (!PUG_IsWarmup()) {
		return Plugin_Stop;
	}
	if (PUG_IsReady(client)) {
		PUG_Message(client, "你已经准备过了");
		return Plugin_Stop;
	}
	g_iReadyPlayers++;
	PUG_ReadyPlayer(client);
	PUG_MessageToAll("%N 已准备", client);
	return Plugin_Continue;
}

public Action Command_UnReady(int client, int args) {
	if (!PUG_IsWarmup() || !PUG_IsReady(client)) {
		return Plugin_Stop;
	}
	g_iReadyPlayers--;
	PUG_UnReadyPlayer(client);
	PUG_MessageToAll("%N 取消准备", client);
	return Plugin_Continue;
}