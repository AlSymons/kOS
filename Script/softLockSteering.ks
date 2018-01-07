DECLARE PARAMETER tgtheading is 90, tgtpitch is 10.

set deltaHeading to 0.
set deltaPitch to 0.

IF tgtheading = -1
	THROW("Usage: runpath(''0:\softLockSteering'',heading,pitch).").
SAS OFF.

UNTIL 0
{
	set pilotcontrolling to 0.
	//check for pilot input
	IF SHIP:CONTROL:PILOTYAW > 0
		SET deltaHeading TO deltaHeading + 5.
	IF SHIP:CONTROL:PILOTYAW < 0
		SET deltaHeading TO deltaHeading - 5.
	
	IF SHIP:CONTROL:PILOTPITCH > 0
		SET deltaPitch TO deltaPitch + 5.
	IF SHIP:CONTROL:PILOTPITCH < 0
		SET deltaPitch TO deltaPitch - 5.
	
	set temptgtpitch to MAX(-90,MIN(90,(tgtpitch + deltapitch))).
	set temptgtheading to tgtheading + deltaHeading.
	
	IF temptgtheading > 359
			SET temptgtheading TO temptgtheading - 360.
	IF temptgtheading < 0
			SET temptgtheading TO temptgtheading + 360.

	LOCK STEERING TO HEADING(temptgtheading,temptgtpitch).

	WAIT 1.

	//bring deltas 1 closer to 0.
	IF NOT deltaPitch = 0
		set deltaPitch to deltaPitch - (deltaPitch / sqrt(deltaPitch*deltaPitch)).
	IF NOT deltaHeading = 0
		set deltaHeading to deltaHeading - (deltaHeading / sqrt(deltaHeading*deltaHeading)).
}