//store later manoeuvre programs.
DECLARE PARAMETER inputparam IS 1.

PRINT "==| KEO Commsat Launcher Running |==.".
PRINT "Launching Satellite #" + (inputparam * 1). //crash here if input argument isn't a number
SET SHIPNAME TO "KEO Commsat #" + inputparam:TOSTRING().

COPYPATH("0:/CirculariseNodeAtApoapsis.ks", "1:/").
COPYPATH("0:/BoostApToAlt.ks", "1:/").

WHEN ALTITUDE > 45000 THEN
{ 
    LOCK THROTTLE TO 0.
	WAIT 0.5.
	STAGE. // fairings
	PRINT "Altitude > 45Km, decoupling fairings.".
}

LOCK THROTTLE TO 0.8.
SET countdown TO 3.

UNTIL countdown = 0
{
    PRINT countdown + "..." .
    SET countdown TO countdown - 1.
    WAIT 1.
}

PRINT "Launch!".
STAGE.

PRINT "Performing gradual turn until Apoapsis > 90Km".
PRINT "Pitch at sea level: 90. Pitch at 70Km: 0.".

WAIT 1.
WHEN SHIP:MAXTHRUST = 0 THEN //best not to have this condition met at the launch pad.
{
	STAGE.
}

LOCK STEERING TO heading(90,(90-(altitude / (70000 / 90)))).
WAIT UNTIL SHIP:APOAPSIS > 90000.
LOCK THROTTLE TO 0.

WAIT UNTIL SHIP:ALTITUDE > 70000.

PRINT "Altitude > 70Km. Orienting.".


LOCK STEERING TO heading(90,0).
WAIT UNTIL SHIP:VERTICALSPEED < 500.

PRINT "Nearing apoapsis. Accelerating to parking orbit.".
PRINT "Target orbital period: 7183.141666 Seconds (1/3 of Kerbin's Day).".
LOCK THROTTLE TO 1.

WAIT UNTIL SHIP:ORBIT:PERIOD > 7150.
LOCK THROTTLE TO 0.01.
WAIT UNTIL SHIP:ORBIT:PERIOD >= 7183.13.
LOCK THROTTLE TO 0.
PRINT "Parking orbit achieved.".
SWITCH TO 1.

ADD NODE (TIME:SECONDS + ETA:PERIAPSIS + (SHIP:ORBIT:PERIOD * (inputparam-1)), 0, 0, 74.65).

//End
TOGGLE AG10. //Switch on antennas and deploy solar panels

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0. //Pilot throttle - throttle after program ends - only pilot control that is settable.

