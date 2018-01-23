DECLARE PARAMETER tgtAltitude is 500.// (SHIP:ALTITUDE + 100).

SAS off.
wait until SHIP:MAXTHRUST > 0.
lock gravityHere to CONSTANT:G*BODY:MASS/((SHIP:ALTITUDE+BODY:RADIUS)^2).
lock TWR to SHIP:MAXTHRUST/(gravityHere*SHIP:MASS).

local mP is 0.1. local mI is 0.1. local mD is 0.1.
local lastP is 0. local lastTime is 0. local totalI is 0.

function resetHoverPID
{
	local startTWR is 1/TWR.

	set mP to startTWR.
	set mI to startTWR.
	set mD to startTWR.
	
	set lastP to 0.
	set lastTime to 0.
	set totalI to 0.
}

function hoverPID
{
	PARAMETER target.

	local current is SHIP:APOAPSIS.
	if SHIP:VERTICALSPEED < -1
		set current to SHIP:ALTITUDE.

	local now is TIME:SECONDS.

	local P is target - current. //TODO: curve function
	local I is 0.
	local D is 0.

	IF lastTime > 0
	{                
		if abs(target - SHIP:ALTITUDE) < (target / 20)
			set I to totalI + ((P + lastP)/2 * (now - lastTime)).
		else set I to 0.

		set D to (P - lastP) / (now - lastTime). // dP / dT
	}

	local output is P * mP + I * mI + D * mD.

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

local autoThrottle is 0.

lock STEERING to heading(90, 90).
lock THROTTLE to autoThrottle.

local startTime is TIME:SECONDS.

resetHoverPID.

//abort off.
until 1//abort
{
	set autoThrottle to hoverPID(tgtAltitude).
	WAIT 0.001.
}

//if KUNIVERSE:CANREVERT
//KUNIVERSE:REVERTTOLAUNCH.

//LOCK THROTTLE TO 0.