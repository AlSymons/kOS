WAIT UNTIL KUNIVERSE:CANQUICKSAVE.
KUNIVERSE:QUICKSAVETO("_Script start").
PRINT "game saved to '_Script start'".

SAS OFF.
GEAR OFF. WAIT 0.1. GEAR ON.

LOCK gravityHere to CONSTANT:G*BODY:MASS/((altitude+BODY:RADIUS)^2).
LOCK TWR to SHIP:MAXTHRUST/(gravityHere*SHIP:MASS).
	
//Maneuver burn time
FUNCTION BurnTime
{
	PARAMETER dV.
	RETURN dV / (SHIP:MAXTHRUST / SHIP:MASS).
}

// Time to impact
FUNCTION TimeToImpact
{
	DECLARE PARAMETER margin IS 100.
	
	LOCAL d IS ALT:RADAR - margin.
	LOCAL v IS -SHIP:VERTICALSPEED.
	LOCAL g IS SHIP:BODY:MU / SHIP:BODY:RADIUS^2.
	
	RETURN (SQRT(v^2 + 2 * g * d) - v) / g.
}

FUNCTION Drop
{
	LOCK THROTTLE TO 0.

	WAIT UNTIL TimeToImpact(50) <= BurnTime((-SHIP:VERTICALSPEED + SHIP:GROUNDSPEED)*1.1).
	LOCK THROTTLE TO 1.

	WAIT UNTIL SHIP:VERTICALSPEED > -100.
	IF ALT:RADAR > 100 * TWR
		Drop().
}

LOCK STEERING TO SHIP:SRFRETROGRADE.
	Drop().

//point between retrograde and up
LOCK STEERING TO (SHIP:SRFRETROGRADE:VECTOR + (UP:VECTOR * MAX(2,MIN(1,(1/SHIP:GROUNDSPEED^2))))).	

//LOCK tgtAltitude TO ALTITUDE - ALT:RADAR. //...why do I have this again?
LOCK desiredSpeed TO MAX((0-TWR),(ALT:RADAR*-0.15)). //TODO: 0.15 should be TWR based?
LOCK THROTTLE TO 1 / TWR * (SHIP:VERTICALSPEED / desiredSpeed)^2.
//1 / TWR * (SHIP:VERTICALSPEED / desiredSpeed) works but error correction slow.

WAIT UNTIL SHIP:STATUS = "Landed".

SAS ON.
UNLOCK ALL.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.