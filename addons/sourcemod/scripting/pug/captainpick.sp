stock void CaptainPick(){
	if (PUG_GetCaptain(1) == -1 || PUG_GetCaptain(2) == -1){
		PUG_SetRandomCaptains();
	}
	ChangeGameState(GameState_PickingPlayers);
	int captain1 = PUG_GetCaptain(1);
	int captain2 = PUG_GetCaptain(2);
	for (int i = 0; i < MaxClients; i++){
		if (IsPlayer(i)){
			if (i != captain1 && i != captain2){
				CS_SwitchTeam(i, CS_TEAM_SPECTATOR);
			}
		}
	}
	CS_SwitchTeam(captain1, CS_TEAM_CT);
	CS_SwitchTeam(captain2, CS_TEAM_T);
	PUG_MessageToAll("队长1是 {green}%N", captain1);
	PUG_MessageToAll("队长2是 {green}%N", captain2);
	ShowPickMenu(captain1);
}

public int Handler_PickPlayers(Menu menu, MenuAction action, int client, int select){
	if (action == MenuAction_Select){
		char temp[4];
		menu.GetItem(select, temp, sizeof(temp));
		int pick = StringToInt(temp);
		CS_SwitchTeam(pick, GetClientTeam(client));
		PUG_MessageToAll("队长%i选择了 {green}%N", PUG_GetCaptain(client), pick);
		if (GetRealClientCount() == PUG_GetMaxPlayers()){
			VoteFriendlyFire();
		} else {
			ShowPickMenu(PUG_GetCaptain(client) == 1 ? 2:1);
		}
	} else if (action == MenuAction_Cancel){
		ShowPickMenu(client);
	}
}

stock void ShowPickMenu(int client){
	Menu menu = new Menu(Handler_PickPlayers);
	menu.SetTitle("请选择你的队员");
	char temp[4], display[64];
	for (int i = 0; i < MaxClients; i++){
		if (IsPlayer(i) && i != PUG_GetCaptain(1) && i != PUG_GetCaptain(2)){
			IntToString(i, temp, sizeof(temp));
			GetClientName(i, display, sizeof(display));
			menu.AddItem(temp, display, GetClientTeam(i) == CS_TEAM_SPECTATOR ? ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
		}
	}
	menu.Display(client, MENU_TIME_FOREVER);
}