SAS OFF.

WHEN SHIP:MAXTHRUST = 0 THEN
{
	STAGE.
	PRESERVE.
}

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
	LOCK STEERING TO RETROGRADE.
	LOCK THROTTLE TO 0.

	WAIT UNTIL TimeToImpact(0) <= BurnTime(-SHIP:VERTICALSPEED)
	LOCK THROTTLE TO 1.

	WAIT UNTIL SHIP:VERTICALSPEED > -7.
	IF ALT:RADAR > 50
		Drop().
}

SET tgtHeading to MOD(ROUND(360 - SHIP:BEARING),360).
LOCK STEERING TO HEADING(tgtHeading,90).

SET tgtAltitude TO 0.

UNTIL SHIP:STATUS = "Landed"
{
	//Don't go underground
	IF tgtAltitude < (ALTITUDE - ALT:RADAR)
		SET tgtAltitude TO (ALTITUDE - ALT:RADAR).

		//negative vertical speed should approach zero as we approach target alt, which we are above
		IF SHIP:VERTICALSPEED < MAX(-7,((tgtAltitude - ALTITUDE)*0.15))
			SET X TO 1. 
		ELSE
			SET X TO 0. //we're not dropping too fast

	LOCK THROTTLE TO X.
	//////////////////////////
}

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.