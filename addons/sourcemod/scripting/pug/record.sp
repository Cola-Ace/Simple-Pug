stock void Record() {
	if (g_cEnableDemoRecord.BoolValue){
		if (!IsTVEnabled()){
			LogError("Autorecording will not work with current cvar \"tv_enable\"=0. Set \"tv_enable 1\" in server.cfg (or another config file) to fix this.");
		} else {
			char demoName[256], timeFormat[64], formattedTime[64], map[32];
			g_cDemoFile.GetString(demoName, sizeof(demoName));
			g_cDemoTimeFormat.GetString(timeFormat, sizeof(timeFormat));
			int timeStamp = GetTime();
			FormatTime(formattedTime, sizeof(formattedTime), timeFormat, timeStamp);
			GetCurrentMap(map, sizeof(map));
			ReplaceString(demoName, sizeof(demoName), "{TIME}", formattedTime, false);
			ReplaceString(demoName, sizeof(demoName), "{MAP}", map, false);
			ServerCommand("tv_record \"%s\"", demoName);
			LogMessage("Recording to %s", demoName);
		}
	}
}

stock void StopRecord() {
	ServerCommand("tv_stoprecord");
}

stock bool IsTVEnabled() {
  Handle tvEnabledCvar = FindConVar("tv_enable");
  if (tvEnabledCvar == INVALID_HANDLE) {
    LogError("Failed to get tv_enable cvar");
    return false;
  }
  return GetConVarInt(tvEnabledCvar) != 0;
}