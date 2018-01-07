//version of hover script tuned for jet engines
//let's try the same code but min/max the thrust to be between 0.99 and 1.01 TWR

DECLARE PARAMETER tgtAltitude IS (ALTITUDE + 100).

SAS OFF.
LOCK gravityHere to CONSTANT:G*BODY:MASS/((altitude+BODY:RADIUS)^2).
WAIT UNTIL SHIP:MAXTHRUST > 0.
LOCK TWR to SHIP:MAXTHRUST/(gravityHere*SHIP:MASS).

FUNCTION ThrottleTWR
{
	PARAMETER inTWR IS 1.0.
	RETURN 1/TWR * inTWR.
}

print "ThrottleTWR function:".
print throttleTWR.
print "0.99: " + throttleTWR(0.99).
print "1.01: " + throttleTWR(1.01).

IF VANG(SHIP:FACING:FOREVECTOR, SHIP:UP:FOREVECTOR) < 45
	print "Tail sitter detected".
else
	print "Horinzontal facing VTOL detected".

WAIT 1.

PRINT "==| Hover script running. |==".
PRINT "Target Altitude:" + tgtAltitude.

SET tgtHeading to MOD(ROUND(360 - SHIP:BEARING),360). //why tho
PRINT "SHIP HEADING: " + tgtHeading.

SET tgtPitch to 0.
//SET tgtThrottle to
//TODO: VESSEL:GROUNDSPEED exists

set targetDir to ship:facing.

set screentick to time:seconds.
LOCK STEERING TO HEADING(tgtHeading,90 - tgtPitch) * R(90,0,0).

UNTIL FALSE
{
	if time:seconds - screentick > 0.05
	{
		CLEARSCREEN.
		
		//Readouts
		PRINT "Throttle set to " + X.
		PRINT "Heading: " + tgtHeading + " | Altitude: " + tgtAltitude.
		PRINT "Tilt: " + tgtPitch.
			
			
		IF SHIP:STATUS = "LANDED" OR SHIP:STATUS = "PRELAUNCH"
		{
			PRINT "SHIP STATUS LANDED".
			IF ABS(tgtAltitude - ALTITUDE) < 5
			{
				PRINT "LANDED AND STAYING THAT WAY".
			}
			ELSE
			{
				PRINT "TAKING OFF".
			}
		}
		ELSE
			PRINT SHIP:STATUS.
			
		set screentick to time:seconds.
	}
		
	SET steervec TO VECDRAW(
		  V(0,0,0), //start
		  STEERINGMANAGER:TARGET:VECTOR, //vector
		  RGB(0,1,0), //colour
		  "Steering", //words
		  3.0, //scale
		  TRUE, //show
		  0.1 //width 
		).

	SET pgVec TO VECDRAW(
		  V(0,0,0), //start
		  SHIP:SRFRETROGRADE:VECTOR, //vector
		  RGB(0,1,0), //colour
		  "Retrograde", //words
		  3.0, //scale
		  TRUE, //show
		  0.1 //width 
		).
	
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
			IF SHIP:VERTICALSPEED < MAX(-3,((tgtAltitude - ALTITUDE)*0.15))
				SET X TO 1 / TWR - (1 - SHIP:VERTICALSPEED / -3).
			ELSE
				SET X TO 1 / TWR + (1 - ALTITUDE / tgtAltitude).
		}
	}
//	IF SHIP:VERTICALSPEED < 0
		SET X TO MAX(X,ThrottleTWR(1.01)).
//	IF SHIP:VERTICALSPEED > 0 //no min value for throttle if going up?
		SET X TO MIN(X,ThrottleTWR(0.99)). //min TWR 0.99

	
	IF VERTICALSPEED > 1
		SET X TO MIN(X,ThrottleTWR(0.98)).
	
	//TO TRY:
	//have a target throttle, change actual throttle slowly unless going down

	IF SHIP:STATUS = "LANDED" OR SHIP:STATUS = "PRELAUNCH"
	{
		PRINT "SHIP STATUS LANDED".
		IF ABS(tgtAltitude - ALTITUDE) < 5
		{
			SET X TO 0.
			PRINT "LANDED AND STAYING THAT WAY".
		}
		ELSE
		{
			SET THROTTLE TO ThrottleTWR(1.1).
			PRINT "TAKING OFF".
			WAIT UNTIL SHIP:VERTICALSPEED > 1.
		}
	}		
	SET THROTTLE TO X.
	
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
	
	IF SHIP:CONTROL:PILOTPITCH = 0
	{
		IF SHIP:GROUNDSPEED > 0.1
		{
			IF tgtPitch = 0
				IF SHIP:VERTICALSPEED < 0
					LOCK STEERING TO (SHIP:SRFRETROGRADE:VECTOR + (UP:VECTOR * MAX(20,MIN(1,(1/SHIP:GROUNDSPEED^2))))) * R(90,tgtHeading,0).
				//ELSE
					
		}
		ELSE
			LOCK STEERING TO HEADING(tgtHeading,90 - tgtPitch) * R(90,0,0).

		SET tgtPitch TO tgtPitch * 0.9. //Automatically bleed target pitch over time
	}
	ELSE
		LOCK STEERING TO HEADING(tgtHeading,90 - tgtPitch) * R(90,0,0).
	
	IF ABS(tgtPitch) < 0.01
		SET tgtPitch TO 0.

	WAIT 0.01.
}

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.