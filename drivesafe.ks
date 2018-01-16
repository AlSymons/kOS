DECLARE PARAMETER maxSpeed is 10, vehicleInstability is 1.

SET NAVMODE TO "SURFACE".
BRAKES OFF.
SAS OFF. //TODO: add automatic pitch/roll adjustment
RCS OFF.

LOCK tgtAngle to VANG(ship:facing:vector,TARGET:POSITION).
LOCK tgtAngleR to VANG(ship:facing:starvector,TARGET:POSITION).
LOCK tgtAngleL to VANG(-ship:facing:starvector,TARGET:POSITION).
SET steer to 0.
SET tgtSpeed to 0.

UNTIL SHIP:CONTROL:PILOTTOP <> 0 OR TARGET:POSITION:MAG < MAX(50,maxSpeed^2/2)
{
	PRINT "Cruising speed: "+maxSpeed+".".
	PRINT "Target speed: "+tgtSpeed+".".
	PRINT " ".
	PRINT "Wheel steer: "+SHIP:CONTROL:WHEELSTEER+".".
	PRINT "Wheel Throttle: "+WHEELTHROTTLE+".".
	PRINT " ".
	PRINT "Angle to target: "+tgtAngle+".".
	
	// if going backwards
	if VANG(SHIP:FACING:VECTOR, SHIP:SRFRETROGRADE:VECTOR) < 90
	{
		PRINT "GOING BACKWARD? NOPE".
		LOCK WHEELTHROTTLE TO 0.
		BRAKES ON.
		WAIT UNTIL SHIP:GROUNDSPEED < 0.1.
	}

	IF tgtAngleR < tgtAngleL //Target is to the right
		SET steer TO MAX(-1,-(tgtAngle/60)). //min/max not necessary except it makes other proportional equations easier.
	else //Target is to the left
		SET steer TO MIN(1,(tgtAngle/60)).

	SET tgtSpeed TO MIN(maxSpeed,(45/(tgtAngle))+1). //speed limit based on target angle curve
	SET BRAKES TO SHIP:GROUNDSPEED > tgtSpeed.
	LOCK WHEELTHROTTLE TO 0.5*(tgtSpeed - SHIP:GROUNDSPEED). //don't accelerate too aggresively.
	
	if (SHIP:GROUNDSPEED < tgtSpeed+0.1)
		SET steer to steer/(SHIP:GROUNDSPEED*vehicleInstability). //steer more carefully at high speed.
	else SET steer to 0. //wait until safe to turn

	SET SHIP:CONTROL:WHEELSTEER TO steer.

	IF SHIP:STATUS <> "LANDED"
	{
		PRINT "I'M FLYING I'M NOT SUPPOSED TO FLY".
		SET SHIP:CONTROL:WHEELSTEER TO 0.
		UNTIL SHIP:STATUS = "LANDED"
		{
			SET maxSpeed TO maxSpeed - 0.1.
			WAIT 0.01.
		}
	}

	wait 0.05.
	clearscreen.
}

SET SHIP:CONTROL:WHEELSTEER TO 0.
UNLOCK ALL.
BRAKES ON.