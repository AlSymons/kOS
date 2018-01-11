DECLARE PARAMETER argapo IS nope.

SET apotarget TO (argapo * 1). // crash if input parameter not numeric
PRINT "==| Executing precise apoapsis adjustment. |==".
PRINT "Target Apoapsis:" + apotarget.

IF SHIP:apoapsis > apotarget
{
	LOCK STEERING TO SHIP:RETROGRADE.
	WAIT UNTIL VANG(RETROGRADE:VECTOR, SHIP:FACING:VECTOR) < 0.1.

	UNTIL SHIP:apoapsis <= apotarget
	{
		LOCK THROTTLE TO 1 - ((apotarget * 0.9999999999 / SHIP:apoapsis)^2).
		WAIT 1.
	}
}
ELSE
{
	LOCK STEERING TO SHIP:PROGRADE.
	WAIT UNTIL VANG(PROGRADE:VECTOR, SHIP:FACING:VECTOR) < 0.1.

	UNTIL SHIP:apoapsis >= apotarget
	{
		LOCK THROTTLE TO ((apotarget * 1.0000000001 / SHIP:apoapsis)^2) - 1.
		WAIT 1.
	}
}
LOCK THROTTLE TO 0.

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

IF ADDONS:AVAILABLE("RT")
	WAIT ADDONS:RT:KSCDELAY(ship).
UNLOCK ALL.

PRINT "Target Apoapsis reached.".