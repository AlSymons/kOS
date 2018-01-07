DECLARE PARAMETER tgtAltitude IS (ALTITUDE + 100).

SAS OFF.
LOCK gravityHere to CONSTANT:G*BODY:MASS/((altitude+BODY:RADIUS)^2).
WAIT UNTIL SHIP:MAXTHRUST > 0.
LOCK TWR to SHIP:MAXTHRUST/(gravityHere*SHIP:MASS).

PRINT "==| Hover script running. |==".
PRINT "Target Altitude:" + tgtAltitude.

SET tgtHeading to MOD(ROUND(360 - SHIP:BEARING),360). //why tho
PRINT "SHIP HEADING: " + tgtHeading.

SET tgtPitch to 0.
//TODO: VESSEL:GROUNDSPEED exists

UNTIL FALSE
{
	CLEARSCREEN.
	
	//Don't go underground
	IF tgtAltitude < (ALTITUDE - ALT:RADAR)
		SET tgtAltitude TO (ALTITUDE - ALT:RADAR).

	//Throttle control
	IF SHIP:VERTICALSPEED >= 0 //we are going up
	{
		IF ALTITUDE < tgtAltitude //we are supposed to be going up
			SET X TO (1 - (SHIP:APOAPSIS / tgtAltitude))*10.
		ELSE //we are supposed to be going down
			SET X TO 0.
	}
	ELSE //we are going down.
	{
		IF ALTITUDE < tgtAltitude //we are supposed to be going up
		{
			IF SHIP:VERTICALSPEED < -6
				SET X TO 1.
			ELSE
				SET X TO 1 / TWR + (1 - ALTITUDE / tgtAltitude).
		}
		ELSE //this is fine
		{
			IF SHIP:VERTICALSPEED < MAX(-50,((tgtAltitude - ALTITUDE)*0.15))
				SET X TO 1 / TWR - (1 - SHIP:VERTICALSPEED / -3).
			ELSE
				SET X TO 1 / TWR + (1 - ALTITUDE / tgtAltitude).
		}
	}
	IF SHIP:STATUS = "LANDED"
		IF ABS(tgtAltitude - ALTITUDE) < 3
			SET X TO 0.
	
	LOCK THROTTLE TO X.
	//////////////////////////
	
	//Read pilot inputs
	IF SHIP:CONTROL:PILOTROLL > 0
		SET tgtHeading TO tgtHeading + 1.
	IF SHIP:CONTROL:PILOTROLL < 0
		SET tgtHeading TO tgtHeading - 1.
	
	IF tgtHeading > 359
			SET tgtHeading TO tgtHeading - 360.
	IF tgtHeading < 0
			SET tgtHeading TO tgtHeading + 360.
	
	IF SHIP:CONTROL:PILOTPITCH > 0
		SET tgtPitch TO tgtPitch - 0.1.
	IF SHIP:CONTROL:PILOTPITCH < 0
		SET tgtPitch TO tgtPitch + 0.1.
	
	IF SHIP:CONTROL:PILOTTOP > 0
		SET tgtAltitude TO tgtAltitude - 1.
	IF SHIP:CONTROL:PILOTTOP < 0
		SET tgtAltitude TO tgtAltitude + 1.
	/////////////////////////////////////////////
	
	//Readouts
	PRINT "Throttle set to " + X.
	PRINT "Heading: " + tgtHeading + " | Altitude: " + tgtAltitude.
	PRINT "Tilt: " + tgtPitch.
	
	//Steer
	//UNLOCK STEERING. WAIT 0.01.//this allows limited manual steering

	
	IF SHIP:CONTROL:PILOTPITCH = 0
	{
		IF SHIP:GROUNDSPEED > 0.1
		{
			IF tgtPitch = 0
				IF SHIP:VERTICALSPEED < 0
					LOCK STEERING TO (SHIP:SRFRETROGRADE:VECTOR + (UP:VECTOR * MAX(20,MIN(1,(1/SHIP:GROUNDSPEED^2))))).
				//ELSE
					
		}
		ELSE
			LOCK STEERING TO HEADING(tgtHeading,90 - tgtPitch).

		SET tgtPitch TO tgtPitch * 0.9. //Automatically bleed target pitch over time
	}
	ELSE
		LOCK STEERING TO HEADING(tgtHeading,90 - tgtPitch).
	
	IF ABS(tgtPitch) < 0.01
		SET tgtPitch TO 0.

	WAIT 0.01.
}

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.