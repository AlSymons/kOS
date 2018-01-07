//Variant of basic launcher designed to launch with ludicrous SRBs

DECLARE PARAMETER argapoapsis IS 80000, argheading IS 90.
PRINT "==| Basic orbital launcher running. |==".
PRINT "Target Apoapsis:" + argapoapsis.
PRINT "Target Heading:" + argheading.
SET tgtheading TO (argheading * 1). // crash if input parameter not numeric
SET apoapsistarget TO (argapoapsis * 1). // crash if input parameter not numeric

WHEN ALTITUDE > 45000 THEN
{
	TOGGLE AG9. //fairings
	LOCK THROTTLE TO 1.
}

//DECLARE FUNCTION keepStaging
//{
//	DECLARE PARAMETER stagesleft.
//	IF stagesleft <= 0
//	{
//		RETURN.
//	}
//	ELSE
//	{
//		WHEN SHIP:MAXTHRUST = 0 THEN
//		{
//			STAGE.
//			SET stagesleft TO stagesleft - 1.
//			PRINT "Autostaging. " + stagesleft + " to go.".
//			keepStaging(stagesleft).
//		}
//	}
//}

LOCK THROTTLE TO 0.
SET countdown TO 3.

UNTIL countdown = 0
{
    PRINT countdown + "..." .
    SET countdown TO countdown - 1.
    WAIT 1.
}

PRINT "Launch!".

WHEN SHIP:MAXTHRUST = 0 THEN
{
	STAGE.
	PRESERVE.
}
IF SHIP:SOLIDFUEL > 0
WHEN SHIP:SOLIDFUEL < 1 THEN
{
	STAGE.
}


PRINT "Performing gradual turn until Apoapsis > " + apoapsistarget.

//LOCK STEERING TO heading(tgtheading,(90-(altitude / (70000 / 90)))).
LOCK STEERING TO heading(tgtheading,MAX(-20,((90-(SHIP:APOAPSIS / ((apoapsistarget + 50000) / 90)))))).
WAIT UNTIL SHIP:APOAPSIS > apoapsistarget.
LOCK THROTTLE TO 0.
PRINT "Apoapsis target reached. Waiting to escape atmosphere.".

//SET WARPMODE TO "PHYSICS".
//SET WARP TO 3.
//WAIT UNTIL ALTITUDE > 67000.
//SET WARP TO 0.

//Angle to maintain apoapsis while accelerating.
LOCK STEERING TO heading(tgtheading, (((apoapsistarget - SHIP:APOAPSIS) / 150) * (SHIP:VERTICALSPEED / SQRT(SHIP:VERTICALSPEED * SHIP:VERTICALSPEED)))).

WAIT UNTIL ALTITUDE > 70000.
TOGGLE AG10. //turn on antennas etc

PRINT "Atmosphere edge reached. Throttling up and angling to maintain target apoapsis.".
LOCK THROTTLE TO 1.

WAIT UNTIL SHIP:PERIAPSIS > 70000.
UNLOCK STEERING.
LOCK THROTTLE TO 0.

PRINT "Orbit achieved.".

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0. //Pilot throttle - throttle after program ends - only pilot control that is settable.