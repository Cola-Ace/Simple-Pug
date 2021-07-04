#if defined _pug_included
#endinput
#endif
#define _pug_included

enum GameState {
	GameState_None,
	GameState_Warmup,
	GameState_KnifeRound,
	GameState_VoteMap,
	GameState_VetoMap,
	GameState_VoteFriendlyfire,
	GameState_VoteTeam,
	GameState_GoingLive,
	GameState_Live,
	GameState_PickingPlayers
}

enum MapChange {
	MapChange_Instant, 
	MapChange_Vote, 
	MapChange_Veto
}

/*
 * Called When GameState Changed.
 *
 * @param Before Before State.
 * @param After After State.
 */
forward void PUG_OnGameStateChanged(GameState before, GameState after);

/*
 * Called When Ready To Start Game.
 */
forward void PUG_OnReadyToStart();

/*
 * Called When Match Is Live.
 */
forward void PUG_OnLive();

/*
 * Called When Warmup To Live.
 */
forward void PUG_OnGoingLive();

/*
 * Called When Client Ready.
 *
 * @param client client index.
 */
forward void PUG_OnReady(int client);

/*
 * Called When Client Unready.
 *
 * @param client client index.
 */
forward void PUG_OnUnready(int client);

/*
 * Called When Game Force Start.
 *
 * @param client client index.
 */
forward void PUG_OnForceStart(int client);

/*
 * Called When Game Force End.
 *
 * @param client client index.
 */
forward void PUG_OnForceEnd(int client);

/*
 * Called When Warmup Config Executed.
 */
forward void PUG_OnWarmupConfigExecuted();

/*
 * Called When Match Over.
 */
forward void PUG_OnMatchOver(bool hasDemo, const char[] demoName);

/****************/
/**** Native ****/
/****************/

/*
 * If Game In Warmup.
 *
 * @return Return true if game in warmup.
 */
native bool PUG_IsWarmup();

/*
 * If Game In Paused.
 *
 * @return Return true if game in paused.
 */
native bool PUG_IsPaused();

/*
 * Return true if game is live.
 */
native bool PUG_IsMatchLive();

/*
 * Send Message To Client.
 *
 * @param client client index.
 * @param format format message.
 */
native void PUG_Message(int client, const char[] format, any:...);

/*
 * Send Message To All Client.
 *
 * @param format format message.
 */
native void PUG_MessageToAll(const char[] format, any:...);

/*
 * Get Captain with number. If not set always return -1.
 * Captain Number always 1 or 2.
 *
 * @param captainNumber captainNumber.
 */
native int PUG_GetCaptain(int captainNumber);

/*
 * Return captain number if client is captain(if not warmup or not captain will return -1).
 *
 * @param client client index.
 */
native int PUG_IsCaptain(int client);

/*
 * Return Set Max Players.
 */
native int PUG_GetMaxPlayers();

/*
 * Return true if client is ready(Always return false is not in warmup).
 */
native bool PUG_IsReady(int client);

/*
 * Return Game State.
 */
native GameState PUG_GetGameState();

/*
 * Return Map Change State.
 */
native MapChange PUG_GetMapChangeState();

/*
 * Set Client Ready State (Never call when game force start).
 *
 * @param client client index.
 */
native void PUG_ReadyPlayer(int client);

/*
 * Set Client UnReady State.
 *
 * @param client client index.
 */
native void PUG_UnReadyPlayer(int client);

/*
 * Set Captain (Only Warmup).
 *
 * @param client client index.
 * @param number captain number (1 or 2).
 */
native bool PUG_SetCaptain(int client, int captain);

/*
 * Random Captain (Only Warmup).
 */
native void PUG_SetRandomCaptains();

public SharedPlugin __pl_pug =  {
	name = "pug", file = "pug.smx", 
	#if defined REQUIRE_PLUGIN
	required = 1, 
	#else
	required = 0, 
	#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_pug_SetNTVOptional() {
	MarkNativeAsOptional("PUG_ReadyPlayer");
	MarkNativeAsOptional("PUG_UnreadyPlayer");
	MarkNativeAsOptional("PUG_IsReady");
	MarkNativeAsOptional("PUG_GetTeamType");
	MarkNativeAsOptional("PUG_GetMapType");
	MarkNativeAsOptional("PUG_GetGameState");
	MarkNativeAsOptional("PUG_IsMatchLive");
	MarkNativeAsOptional("PUG_IsWarmup");
	MarkNativeAsOptional("PUG_SetCaptain");
	MarkNativeAsOptional("PUG_GetCaptain");
	MarkNativeAsOptional("PUG_GetMaxPlayers");
	MarkNativeAsOptional("PUG_SetRandomCaptains");
	MarkNativeAsOptional("PUG_GetMapChangeState");
	MarkNativeAsOptional("PUG_Message");
	MarkNativeAsOptional("PUG_MessageToAll");
}
#endif