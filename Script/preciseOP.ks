DECLARE PARAMETER argOrbitalPeriod IS 21549.4. //5 h 59 m 9.4 s - one kerbin day

PRINT "==| Executing precise orbital period adjustment. |==".
PRINT "Target Orbital Period: " + argOrbitalPeriod + "Seconds".

IF SHIP:ORBIT:PERIOD > argOrbitalPeriod
{
	LOCK STEERING TO RETROGRADE.
	WAIT UNTIL VANG(RETROGRADE:VECTOR, SHIP:FACING:VECTOR) < 0.1.

	LOCK THROTTLE TO 1 - ((argOrbitalPeriod * 0.9999999999 / SHIP:ORBIT:PERIOD)^2).
	WAIT UNTIL SHIP:ORBIT:PERIOD <= argOrbitalPeriod.
}
ELSE
{
	LOCK STEERING TO PROGRADE.
	WAIT UNTIL VANG(PROGRADE:VECTOR, SHIP:FACING:VECTOR) < 0.1.

	LOCK THROTTLE TO ((argOrbitalPeriod * 1.0000000001 / SHIP:ORBIT:PERIOD)^2) - 1.
	WAIT UNTIL SHIP:ORBIT:PERIOD >= argOrbitalPeriod.
}
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0. //Pilot throttle - throttle after program ends - only pilot control that is settable.

PRINT "Target Orbital period reached with error of " + (argOrbitalPeriod - SHIP:ORBIT:PERIOD) + ".".