public int Handler_VoteTeam(Menu menu, MenuAction action, int client, int select){
	if (action == MenuAction_Select){
		char temp[4];
		menu.GetItem(select, temp, sizeof(temp));
		int team = StringToInt(temp);
		if (team == CS_TEAM_CT){
			g_iAllowCT++;
		} else {
			g_iAllowT++;
		}
		if (g_iAllowCT == 3 || g_iAllowT == 3){
			CancelAllMenus();
			SwitchTeam();
		}
	}
}

stock void VoteTeam(int team){
	ChangeGameState(GameState_VoteTeam);
	Menu menu = new Menu(Handler_VoteTeam);
	menu.SetTitle("选择队伍");
	menu.AddItem("2", "恐怖分子");
	menu.AddItem("3", "反恐精英");
	menu.ExitButton = false;
	menu.ExitBackButton = false;
	for (int i = 0; i < MaxClients; i++){
		if (IsPlayer(i) && GetClientTeam(i) == team){
			menu.Display(i, 10);
		}
	}
	CreateTimer(10.0, Timer_EndTeamVote);
}

public Action Timer_EndTeamVote(Handle timer){
	if (PUG_GetGameState() == GameState_VoteTeam){
		CancelAllMenus();
		GoingLive();
	}
}