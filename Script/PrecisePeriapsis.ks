DECLARE PARAMETER argperi IS nope.

SET peritarget TO (argperi * 1). // crash if input parameter not numeric
PRINT "==| Executing precise periapsis adjustment. |==".
PRINT "Target Periapsis:" + peritarget.

IF SHIP:PERIAPSIS > peritarget
{
	LOCK STEERING TO RETROGRADE.
	WAIT UNTIL VANG(RETROGRADE:VECTOR, SHIP:FACING:VECTOR) < 0.1.

	UNTIL SHIP:PERIAPSIS <= peritarget
	{
		LOCK THROTTLE TO 1 - ((peritarget * 0.9999999999 / SHIP:PERIAPSIS)^2).
		WAIT 1.
	}
}
ELSE
{
	LOCK STEERING TO PROGRADE.
	WAIT UNTIL VANG(PROGRADE:VECTOR, SHIP:FACING:VECTOR) < 0.1.

	UNTIL SHIP:PERIAPSIS >= peritarget
	{
		LOCK THROTTLE TO ((peritarget * 1.0000000001 / SHIP:PERIAPSIS)^2) - 1.
		WAIT 1.
	}
}
LOCK THROTTLE TO 0.

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

IF ADDONS:AVAILABLE("RT")
	WAIT ADDONS:RT:KSCDELAY(ship).
UNLOCK ALL.

PRINT "Target Periapsis reached.".