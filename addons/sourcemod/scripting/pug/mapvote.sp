public int Handler_VoteMap(Menu menu, MenuAction action, int client, int select){
	if (action == MenuAction_Select){
		char map[32];
		menu.GetItem(select, map, sizeof(map));
		int count = 0;
		g_MapVote.GetValue(map, count);
		count++;
		g_MapVote.SetValue(map, count);
		PUG_MessageToAll("%N 选择 %s [%i]", client, map, count);
	}
}

stock void VoteMap(){
	ChangeGameState(GameState_VoteMap);
	Menu menu = new Menu(Handler_VoteMap);
	menu.SetTitle("请投票选择地图");
	char map[32];
	for (int i = 0; i < g_MapList.Length; i++){
		g_MapList.GetString(i, map, sizeof(map));
		menu.AddItem(map, map);
	}
	menu.ExitButton = false;
	menu.ExitBackButton = false;
	for (int i = 0; i < MaxClients; i++){
		if (IsPlayer(i)){
			menu.Display(i, 20);
		}
	}
	CreateTimer(20.0, Timer_ChangeMap);
}

public Action Timer_ChangeMap(Handle timer){
	StringMapSnapshot snap = g_MapVote.Snapshot();
	ArrayList number = new ArrayList(8);
	char map[32], display[256];
	int temp = 0;
	for (int i = 0; i < snap.Length; i++){
		snap.GetKey(i, map, sizeof(map));
		g_MapVote.GetValue(map, temp);
		number.Push(temp);
	}
	int max = GetMaxNumber(number, true);
	snap.GetKey(max, map, sizeof(map));
	Format(display, sizeof(display), "正在切换地图 <font color='#00FF00'>%s</font>", map);
	Huds_ShowRealHudAll(display, 5);
	ArrayList array_map = new ArrayList(16);
	array_map.PushString(map);
	CreateTimer(3.0, Timer_ChangeMap1, array_map);
}

public Action Timer_ChangeMap1(Handle timer, ArrayList array_map){
	g_bIsChangeMap = true;
	char map[32];
	array_map.GetString(0, map, sizeof(map));
	ServerCommand("map %s", map);
}