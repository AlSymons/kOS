DECLARE PARAMETER maxSpeed is 10, maxTurnVel is 2, maxAngle is 5.

SET NAVMODE TO "SURFACE".
BRAKES OFF.
SAS OFF.
LOCK tgtAngle to VANG(ship:facing:vector,TARGET:POSITION).

UNTIL SHIP:CONTROL:PILOTPITCH <> 0 OR TARGET:POSITION:MAG < 50
{
	PRINT "Wheel Throttle: "+WHEELTHROTTLE+".".
	PRINT " ".
	PRINT "Cruising speed: "+maxSpeed+". Turning velocity: "+maxTurnVel+".".
	PRINT "Angle to target tolerance: "+maxAngle+".".
	PRINT " ".
	
	SET BRAKES TO SHIP:GROUNDSPEED > maxSpeed.
	if tgtAngle > maxAngle
	{
		PRINT "Angle to target > "+maxAngle+" degrees".
		PRINT "Turning. (Max groundspeed "+maxTurnVel+")".
		LOCK WHEELTHROTTLE TO 0.1*(maxTurnVel - SHIP:GROUNDSPEED).
		BRAKES ON.
		WAIT UNTIL SHIP:GROUNDSPEED < maxTurnVel.
		LOCK WHEELSTEERING TO TARGET.
		BRAKES OFF.
	}
	else
	{
		PRINT "Nearly facing target. Speeding up and unlocking steering to prevent wobble.".
		LOCK WHEELTHROTTLE TO 0.1*(maxSpeed - SHIP:GROUNDSPEED).
		UNLOCK WHEELSTEERING.
	}
	wait 0.1.
	clearscreen.
}

SET WHEELTHROTTLE TO 0.
UNLOCK WHEELTHROTTLE.
UNLOCK WHEELSTEERING.
BRAKES ON.