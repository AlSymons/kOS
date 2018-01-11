//Basic spaceplane runway takeoff boot program.
//This handles takeoff and then runs the larger ascent to orbit script.
//For some reason this dodges a bug that causes KSP to think the ship's status is landed at all times.

IF SHIP:STATUS = "PRELAUNCH"
{
	WAIT UNTIL KUNIVERSE:CANQUICKSAVE.
	KUNIVERSE:QUICKSAVETO("_Script start").
	PRINT "game saved to '_Script start'".

	if ADDONS:KAC:AVAILABLE
	{
		SET pauseAlarm TO addAlarm("Raw",time:seconds+590, "kOS Pause", "Game paused by kOS script").
		SET pauseAlarm:ACTION TO "PauseGame".
	}

	SAS ON.

	STAGE.
	TOGGLE AG3.
	LOCK THROTTLE TO 1.
	LOCK STEERING TO HEADING(90,0). //flying off end of runway dodges flying landed KSP bug.
	
	//Wait until SHIP:AIRSPEED > 130.
	//SET SHIP:CONTROL:PITCH to 1.

	WAIT UNTIL ALT:RADAR > 3.
	//SET SHIP:CONTROL:PITCH to 0.

	RUNPATH("0:/SPACEPLANE.KS").
	RUNPATH("0:/setboot").
}