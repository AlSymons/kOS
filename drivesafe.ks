DECLARE PARAMETER maxSpeed is 0, vehicleInstability is 1.

SET NAVMODE to "SURFACE".
BRAKES OFF.
SAS OFF. //TODO: add automatic pitch/roll adjustment
RCS OFF.

lock headingVec to VECTOREXCLUDE(SHIP:UP:VECTOR,SHIP:FACING:VECTOR).
lock rightVec to VECTOREXCLUDE(SHIP:UP:VECTOR,SHIP:FACING:STARVECTOR).
lock tgtHeadingVec to VECTOREXCLUDE(SHIP:UP:VECTOR,TARGET:POSITION).
local manualHeadingVec is headingVec.
lock tgtAngle to VANG(headingVec,tgtHeadingVec).
lock tgtAngleR to VANG(rightVec,tgtHeadingVec).

//LOCK tgtAngleL to VECTOREXCLUDE(SHIP:UP:VECTOR,VANG(-ship:facing:starvector,TARGET:POSITION)).
SET steer to 0.
SET tgtSpeed to 0.

until SHIP:CONTROL:PILOTTOP <> 0 OR SHIP:ELECTRICCHARGE < 1//OR TARGET:POSITION:MAG < MAX(50,maxSpeed^2/2)
{
	PRINT "Cruising speed: "+maxSpeed+".".
	PRINT "Target speed: "+tgtSpeed+".".
	PRINT " ".
	PRINT "Wheel steer: "+SHIP:CONTROL:WHEELSTEER+".".
	PRINT "Wheel Throttle: "+WHEELTHROTTLE+".".
	PRINT " ".
	if HASTARGET
		PRINT "Angle to target: "+tgtAngle+".".
	
	// if going backwards
	if VANG(SHIP:FACING:VECTOR, SHIP:SRFRETROGRADE:VECTOR) < 90
	{
		PRINT "GOING BACKWARD? NOPE".
		LOCK WHEELTHROTTLE to 0.
		BRAKES ON.
		WAIT UNTIL SHIP:GROUNDSPEED < 0.1.
	}
	
	if HASTARGET
	{
		if tgtAngleR < 90 //Target is to the right
			SET steer to MAX(-1,-(tgtAngle/60)). //min/max not necessary except it makes other proportional equations easier.
		else //Target is to the left
			SET steer to MIN(1,(tgtAngle/60)).

		SET tgtSpeed to MIN(maxSpeed,(45/(tgtAngle))+1). //speed limit based on target angle curve
	}
	else
	{
		set tgtSpeed to maxSpeed.
	
	}

	SET BRAKES to SHIP:GROUNDSPEED > tgtSpeed.
	LOCK WHEELTHROTTLE to 0.5*(tgtSpeed - SHIP:GROUNDSPEED). //don't accelerate too aggresively.
	
	if (SHIP:GROUNDSPEED < tgtSpeed+0.1)
		SET steer to steer/(SHIP:GROUNDSPEED*vehicleInstability). //steer more carefully at high speed.
	else SET steer to 0. //wait until safe to turn

	if HASTARGET
		set SHIP:CONTROL:WHEELSTEER to steer.
	else
		set SHIP:CONTROL:WHEELSTEER to 0.

	if SHIP:STATUS <> "LANDED"
	{
		PRINT "I'M FLYING I'M NOT SUPPOSED to FLY".
		SET SHIP:CONTROL:WHEELSTEER to 0.
		UNTIL SHIP:STATUS = "LANDED"
		{
			SET maxSpeed to maxSpeed - 0.1.
			WAIT 0.01.
		}
	}

	if SHIP:CONTROL:PILOTPITCH < 0
		set maxSpeed to round(maxSpeed + 0.1,2).
	else if SHIP:CONTROL:PILOTPITCH > 0
		set maxSpeed to round(maxSpeed - 0.1,2).
	
	wait 0.05.
	clearscreen.
}

SET SHIP:CONTROL:WHEELSTEER to 0.
UNLOCK ALL.
BRAKES ON.