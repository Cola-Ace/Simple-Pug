public int Handler_VoteFriendlyFire(Menu menu, MenuAction action, int client, int select){
	if (action == MenuAction_Select){
		char temp[4];
		menu.GetItem(select, temp, sizeof(temp));
		bool allow = view_as<bool>(StringToInt(temp));
		if (allow){
			g_iAllowFriendlyFire++;
		}
	}
}

stock void VoteFriendlyFire(){
	ChangeGameState(GameState_VoteFriendlyfire);
	Menu menu = new Menu(Handler_VoteFriendlyFire);
	menu.SetTitle("是否开启队友伤害？");
	menu.AddItem("1", "开启队友伤害");
	menu.AddItem("0", "不开启队友伤害");
	menu.ExitButton = false;
	menu.ExitBackButton = false;
	for (int i = 0; i < MaxClients; i++){
		if (IsPlayer(i)){
			menu.Display(i, 20);
		}
	}
	CreateTimer(20.0, Timer_CheckFriendlyFire);
}

public Action Timer_CheckFriendlyFire(Handle timer){
	if (g_iAllowFriendlyFire >= 6){
		g_bFriendlyFire = true;
		PUG_MessageToAll("投票结果为 {dark_red}开启队伤");
	} else {
		g_bFriendlyFire = false;
		PUG_MessageToAll("投票结果为 {green}关闭队伤");
	}
	CreateTimer(1.0, Timer_StartCountDown, 5, TIMER_REPEAT);
	StartKnifeRound();
}

public Action Timer_StartCountDown(Handle timer, int second){
	PUG_MessageToAll("倒计时: {green}%i{default}秒", second);
	second--;
	if (second == 0){
		StartKnifeRound();
		return Plugin_Stop;
	}
	return Plugin_Continue;
}