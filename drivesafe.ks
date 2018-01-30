DECLARE PARAMETER maxSpeed is 0, vehicleInstability is 1.

SET NAVMODE to "SURFACE".
BRAKES OFF.
SAS OFF. //TODO: add automatic pitch/roll adjustment
RCS OFF.

//horizontal fore and starboard
lock headingVec to VECTOREXCLUDE(SHIP:UP:VECTOR,SHIP:FACING:VECTOR).
lock rightVec to VECTOREXCLUDE(SHIP:UP:VECTOR,SHIP:FACING:STARVECTOR).

//steering target
local desiredHeadingVec is headingVec.

//angle to steering target
lock tgtAngle to VANG(headingVec,desiredHeadingVec).
lock tgtAngleR to VANG(rightVec,desiredHeadingVec).

//target vessel
lock tgtHeadingVec to VECTOREXCLUDE(SHIP:UP:VECTOR,TARGET:POSITION).

local steer is 0.
local tgtSpeed is 0.
local lastInput is TIME:SECONDS.
local inputSettled is false.

until SHIP:CONTROL:PILOTTOP <> 0 OR SHIP:ELECTRICCHARGE < 1//OR TARGET:POSITION:MAG < MAX(50,maxSpeed^2/2)
{
	PRINT "Cruising speed: "+maxSpeed+".".
	PRINT "Target speed: "+tgtSpeed+".".
	PRINT " ".
	PRINT "Wheel steer: "+SHIP:CONTROL:WHEELSTEER+".".
	PRINT "Wheel Throttle: "+WHEELTHROTTLE+".".
	PRINT " ".
	PRINT "Angle to target: "+tgtAngle+".".
	//TODO: fix ~0.5 degree persistant error driving certain rover. probably need a PID.
	
	if HASTARGET
		set desiredHeadingVec to tgtHeadingVec.
	//else
	//	set desiredHeadingVec to 
	
	// if going backwards
	if VANG(SHIP:FACING:VECTOR, SHIP:SRFRETROGRADE:VECTOR) < 90 and SHIP:GROUNDSPEED > 0.1
	{
		PRINT "GOING BACKWARD? NOPE".
		LOCK WHEELTHROTTLE to 0.
		BRAKES ON.
		WAIT UNTIL SHIP:GROUNDSPEED < 0.1.
	}
	
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
	
	if tgtAngleR < 90 //Target is to the right
		SET steer to MAX(-1,-(tgtAngle/60)). //min/max not necessary except it makes other proportional equations easier.
	else //Target is to the left
		SET steer to MIN(1,(tgtAngle/60)).
	
	//steer more carefully at high speed.
	if (SHIP:GROUNDSPEED < tgtSpeed+0.1)
		SET steer to steer/(SHIP:GROUNDSPEED*vehicleInstability).
	else SET steer to 0. //wait until safe to turn

	//speed control
	if inputSettled
	{
		set tgtSpeed to MIN(maxSpeed,(45/(tgtAngle))+1).
		lock WHEELTHROTTLE to 0.5*(tgtSpeed - SHIP:GROUNDSPEED).
		set BRAKES to SHIP:GROUNDSPEED > tgtSpeed.
	}
	
	//indirect pilot steering
	if SHIP:CONTROL:PILOTYAW <> 0
	{
		set lastInput to TIME:SECONDS.
		set SHIP:CONTROL:WHEELSTEER to 0.
		set inputSettled to false.
	}

	if TIME:SECONDS - lastInput > 3
	{
		set SHIP:CONTROL:WHEELSTEER to steer.
		
		if not inputSettled
		{
			set desiredHeadingVec to headingVec.
			set inputSettled to true.
		}
	}
	
//		set desiredHeadingVec to (LOOKDIRUP(desiredHeadingVec,SHIP:UP:VECTOR) * R(0,-1,0)):VECTOR.
	//else if SHIP:CONTROL:PILOTYAW > 0
		//set desiredHeadingVec to (LOOKDIRUP(desiredHeadingVec,SHIP:UP:VECTOR) * R(0, 1,0)):VECTOR.
	
	//cruise control
	if SHIP:CONTROL:PILOTPITCH < 0
		set maxSpeed to round(maxSpeed + 0.1,2).
	else if SHIP:CONTROL:PILOTPITCH > 0
		set maxSpeed to round(maxSpeed - 0.1,2).

	if 0
	SET desiredHeadingVecDraw TO VECDRAW(
		  V(0,0,0), //start
		  desiredHeadingVec, //vector
		  RGB(0.5,0.5,0.5), //colour
		  "Desired Heading", //words
		  3.0, //scale
		  TRUE, //show
		  0.1 //width 
		).
	
	wait 0.1.
	clearscreen.
}

SET SHIP:CONTROL:WHEELSTEER to 0.
UNLOCK ALL.
BRAKES ON.