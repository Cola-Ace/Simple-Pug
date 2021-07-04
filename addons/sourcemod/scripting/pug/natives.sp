public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	CreateNative("PUG_IsWarmup", Native_IsWarmup);
	CreateNative("PUG_IsPaused", Native_IsPaused);
	CreateNative("PUG_Message", Native_Message);
	CreateNative("PUG_MessageToAll", Native_MessageToAll);
	CreateNative("PUG_GetCaptain", Native_GetCaptain);
	CreateNative("PUG_IsCaptain", Native_IsCaptain);
	CreateNative("PUG_GetMaxPlayers", Native_GetMaxPlayers);
	CreateNative("PUG_IsReady", Native_IsReady);
	CreateNative("PUG_GetGameState", Native_GetGameState);
	CreateNative("PUG_GetMapChangeState", Native_GetMapChangeState);
	CreateNative("PUG_SetCaptain", Native_SetCaptain);
	CreateNative("PUG_IsLive", Native_IsLive);
	CreateNative("PUG_ReadyPlayer", Native_ReadyPlayer);
	CreateNative("PUG_UnReadyPlayer", Native_UnReadyPlayer);
	CreateNative("PUG_SetRandomCaptains", Native_SetRandomCaptains);
}

public int Native_SetRandomCaptains(Handle plugin, int numParams) {
	if (!PUG_IsWarmup())return;
	ArrayList clients = new ArrayList();
	for (int i = 0; i < MaxClients; i++) {
		if (IsPlayer(i) && GetClientTeam(i) != CS_TEAM_SPECTATOR) {
			clients.Push(i);
		}
	}
	for (int i = 0; i <= 1; i++) {
		int client = clients.Get(GetRandomInt(0, clients.Length - 1));
		g_iCaptain[i] = client;
		clients.Erase(clients.FindValue(client));
	}
}

public int Native_ReadyPlayer(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	if (!IsPlayer(client))SetFailState("Invalid %i Client Index", client);
	g_bIsReady[client] = true;
	Call_StartForward(g_hOnReady);
	Call_PushCell(client);
	Call_Finish();
}

public int Native_UnReadyPlayer(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	if (!IsPlayer(client))SetFailState("Invalid %i Client Index", client);
	g_bIsReady[client] = false;
	Call_StartForward(g_hOnUnready);
	Call_PushCell(client);
	Call_Finish();
}

public int Native_IsLive(Handle plugin, int numParams) {
	return g_GameState == GameState_Live;
}

public int Native_SetCaptain(Handle plugin, int numParams) {
	if (!PUG_IsWarmup()) {
		return false;
	}
	int client = GetNativeCell(1);
	if (!IsPlayer(client)) {
		return false;
	}
	int number = GetNativeCell(2);
	if (number != 1 && number != 2) {
		return false;
	}
	g_iCaptain[number - 1] = client;
	return true;
}

public int Native_GetMapChangeState(Handle plugin, int numParams) {
	return view_as<int>(g_MapChange);
}

public int Native_GetGameState(Handle plugin, int numParams) {
	return view_as<int>(g_GameState);
}

public int Native_IsReady(Handle plugin, int numParams) {
	return g_bIsReady[GetNativeCell(1)];
}

public int Native_GetMaxPlayers(Handle plugin, int numParams) {
	return g_cMaxPlayers.IntValue;
}

public int Native_IsCaptain(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	if (g_iCaptain[0] == client)return 1;
	else if (g_iCaptain[1] == client)return 2;
	else return -1;
}

public int Native_IsWarmup(Handle plugin, int numParams) {
	return g_GameState == GameState_Warmup;
}

public int Native_IsPaused(Handle plugin, int numParams) {
	return IsPaused();
}

public int Native_Message(Handle plugin, int numParams) {
	char buffer[512];
	int byte = 0;
	FormatNativeString(0, 2, 3, sizeof(buffer), byte, buffer);
	CPrintToChat(GetNativeCell(1), buffer);
}

public int Native_MessageToAll(Handle plugin, int numParams) {
	char buffer[512];
	int byte = 0;
	FormatNativeString(0, 1, 2, sizeof(buffer), byte, buffer);
	for (int i = 0; i < MaxClients; i++){
		if (IsPlayer(i)){
			CPrintToChat(i, buffer);
		}
	}
}

public int Native_GetCaptain(Handle plugin, int numParams) {
	int index = GetNativeCell(1);
	if (index != 1 && index != 2) {
		SetFailState("Invalid Captain Number");
	}
	return g_iCaptain[index - 1];
} 