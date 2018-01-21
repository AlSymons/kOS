DECLARE PARAMETER tgtAltitude is 500.// (SHIP:ALTITUDE + 100).

SAS off.
wait until SHIP:MAXTHRUST > 0.
lock gravityHere to CONSTANT:G*BODY:MASS/((SHIP:ALTITUDE+BODY:RADIUS)^2).
lock TWR to SHIP:MAXTHRUST/(gravityHere*SHIP:MASS).

//functio ThrottleTWR
//{
//	PARAMETER inTWR is 1.0.
//	return 1/TWR * inTWR.
//}

local mP is 0.1.
local mI is 0.1.
local mD is 0.1.
local cI is 1.

local lastP is 0.
local lastTime is 0.
local totalI is 0.

function pid
{
	PARAMETER target.
	PARAMETER current.

	local now is TIME:SECONDS.

	local P is target - current.
	local I is 0.
	local D is 0.

	IF lastTime > 0
	{                   //explicitly alt here, not apo
		if abs(target - SHIP:ALTITUDE) < (target / 20) //accumulate I only when error is small
			set I to totalI + ((P + lastP)/2 * (now - lastTime)).
		else set I to 0.

		//set I to min(1,cI/mI).
		//set I to max(-1,-(cI/mI)).
			
		set D to (P - lastP) / (now - lastTime). // dP / dT
	}

	local output is P * mP + I * mI + D * mD.
	//local output is (P * mP * 1/TWR) + (I * mI * 1/TWR) + (D * mD * 1/TWR).

	clearscreen.
	print "P: " + P * mP.
	print "I: " + I * mI.
	print "D: " + D * mD.
	print "Output: " + output.

	set lastP to P.
	set lastTime to now.
	set totalI to I.

	return output.
}

lock STEERING to heading(90, 90).
lock THROTTLE to autoThrottle.

local startTime is TIME:SECONDS.

abort off.
until abort
{
	if SHIP:VERTICALSPEED > -1
		set autoThrottle to pid(tgtAltitude, SHIP:APOAPSIS).// * 1/TWR.
	else
		set autoThrottle to pid(tgtAltitude, SHIP:ALTITUDE).// * 1/TWR.

	WAIT 0.001.
}
if KUNIVERSE:CANREVERT.
KUNIVERSE:REVERTTOLAUNCH.

LOCK THROTTLE TO 0.