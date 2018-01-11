DECLARE PARAMETER delay is 1.

if ADDONS:KAC:AVAILABLE
{
	SET pauseAlarm TO addAlarm("Raw",time:seconds+delay, "kOS Pause", "Game paused by kOS script").
	SET pauseAlarm:ACTION TO "PauseGame".
	PRINT pauseAlarm:ACTION.
}