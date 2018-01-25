wait until ship:maxthrust > 0.
lock gravityHere to CONSTANT:G*BODY:MASS/((SHIP:ALTITUDE+BODY:RADIUS)^2).
lock TWR to SHIP:MAXTHRUST/(gravityHere*SHIP:MASS).

local mP is 0.1. local mI is 0.1. local mD is 0.1.
local lastP is 0. local lastTime is 0. local totalI is 0.

//Suicide burn functions in the event ship needs to drop far.
FUNCTION burnTime
{
	PARAMETER dV.
	return dV / (SHIP:MAXTHRUST / SHIP:MASS).
}
FUNCTION timeToImpact
{
	PARAMETER margin is 100.
	
	if SHIP:VERTICALSPEED > 0
		return 9000.
	
	local d is max(1,ALT:RADAR - margin).
	local v is -SHIP:VERTICALSPEED.
	local g is SHIP:BODY:MU / SHIP:BODY:RADIUS^2.
	
	return (SQRT(v^2 + 2 * g * d) - v) / g.
}

function resetHoverPID
{
	local startTWR is 1/TWR.

	set mP to startTWR.
	set mI to 0.1.
	set mD to startTWR.
	
	set lastP to 0.
	set lastTime to 0.
	set totalI to 0.
}

function verticalSpeedP
{
	PARAMETER tgtSpeed.
	return 1/TWR * (1 + tgtSpeed - SHIP:VERTICALSPEED).
}

function vertSpeedClamp
{
	PARAMETER throttleInput, maxSafeSpeed is 150.

	//Suicide burn
	if SHIP:VERTICALSPEED < -6.5
		if timeToImpact(50) <= burnTime((-SHIP:VERTICALSPEED + SHIP:GROUNDSPEED)*1.1)
			return verticalSpeedP(-6.5).

	//max Q speed limit
	if SHIP:VERTICALSPEED > maxSafeSpeed
		return verticalSpeedP(maxSafeSpeed).

	if SHIP:VERTICALSPEED < -maxSafeSpeed
		return verticalSpeedP(-maxSafeSpeed).
	
	return throttleInput.
}

function hoverPID
{
	PARAMETER target.

	local current is SHIP:APOAPSIS.
	if SHIP:VERTICALSPEED < -1
		set current to SHIP:ALTITUDE.

	local now is TIME:SECONDS.
	until (now - lastTime) <> 0
		set now to TIME:SECONDS.

	local P is (target - current) / 4. //TODO: curve function
	local I is 0.
	local D is 0.

	if lastTime > 0
	{                
		if abs(target - SHIP:ALTITUDE) < (target / 20)
			set I to totalI + ((P + lastP)/2 * (now - lastTime)).
		else set I to 0.

		set D to (P - lastP) / (now - lastTime). // dP / dT
	}

	local output is P * mP + I * mI + D * mD.
	set output to vertSpeedClamp(output).
	
	if 1
	{
		clearscreen.
		print "Target: " + target.
		print "P: " + P * mP.
		print "I: " + I * mI.
		print "D: " + D * mD.
		print "Output: " + output.
	}
	set lastP to P.
	set lastTime to now.
	set totalI to I.

	return output.
}

resetHoverPID.

if 0 //testing
{
	local autoThrottle is 0.
	lock throttle to autoThrottle.
	SAS off.
	lock steering to heading(90,90).
	until 0
	{
		set autoThrottle to hoverPID(BODY:GEOPOSITIONOF(SHIP:POSITION):TERRAINHEIGHT + 100).
		//set autoThrottle to verticalSpeedP(-6).
		wait 0.01.
	}
}