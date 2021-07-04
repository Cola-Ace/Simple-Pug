stock void ReadMapConfig(){
	char Path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, Path, sizeof(Path), "configs/pug/map.txt");
	File file = OpenFile(Path, "r");
	char mapName[64];
	while (file.ReadLine(mapName, sizeof(mapName))){
		g_MapList.PushString(mapName);
	}
}