local landingSightPos is BODY:GEOPOSITIONOF(SHIP:POSITION).

lock shipBearingVec to VECTOREXCLUDE(SHIP:UP:VECTOR,SHIP:FACING:VECTOR):NORMALIZED.
lock HRetrograde to VECTOREXCLUDE(SHIP:UP:VECTOR,SHIP:SRFRETROGRADE:VECTOR):NORMALIZED.
lock killHVelVec to SHIP:UP:VECTOR + (HRetrograde              * min(0.3,SHIP:GROUNDSPEED * 0.1)).
lock flyToLSVec to SHIP:UP:VECTOR  + (landingSightPos:POSITION:NORMALIZED * min(0.3,landingSightPos:POSITION:MAG * 0.1)). //0 normalized?

runpath("0:/slopetools.ks").
runpath("0:/pidHover.ks").


function areaSlopeSearch
{
	parameter tgtSlope is 0.02, pos is SHIP:POSITION, samplewidth is 1, maxSamples is 1000.
	
	local minSlope is 90.
	local rot is 0.
	local bearingDir is LOOKDIRUP(shipBearingVec,SHIP:UP:VECTOR).
	
	local numSamples is 0.
	local samplesPerRot is 8.
	local sampleRadius is sampleWidth * 4.

	until minSlope < tgtSlope OR numSamples > maxSamples
	{
		until rot > 359
		{//check the slope at different points
			set minSlope to min(minSlope, slopeAt(pos + (bearingDir * R(0,rot,0)):VECTOR * sampleRadius)).
			set rot to rot + (360 / samplesPerRot).
			set numSamples to numSamples + 1.
		}

		clearscreen.
		print minSlope.
		if minSlope < tgtSlope
			set landingSightPos to BODY:GEOPOSITIONOF(pos + (bearingDir * R(0,rot,0)):VECTOR * sampleRadius).


		set sampleRadius to sampleRadius + sampleWidth * 4.
		//set samplesPerRot to (sampleRadius / sampleWidth * ?.
		set rot to 0.
	}
	return minSlope.
}

local autoThrottle is 0.
lock throttle to autoThrottle.

local mode is 2.
local debug is true.
local landingSiteReset is TIME:SECONDS.

local desiredVelocityVec is V(0,0,0).
local velocityToKill is V(0,0,0).

sas off.

lock steering to heading(0,90).
until VANG(SHIP:FACING:VECTOR,SHIP:UP:VECTOR) < 1 and SHIP:VERTICALSPEED > 0
	set autoThrottle to verticalSpeedP(0.1).

areaSlopeSearch.
SteeringManager:RESETTODEFAULT().
SET SteeringManager:ROLLTORQUEFACTOR to 0.

until time:seconds > landingSiteReset + 10
	set autoThrottle to hoverPID(BODY:GEOPOSITIONOF(SHIP:POSITION):TERRAINHEIGHT + 100).

local anglePIDlimit is 0.1.
local anglePID is pidLoop(1,0.1,0.1,-anglePIDlimit,anglePIDlimit).
//print "anglePID setpoint: " + anglePID:SETPOINT. //0.

abort off.
until abort
{
	if mode = 1 //loiter
	{
		set autoThrottle to hoverPID(BODY:GEOPOSITIONOF(SHIP:POSITION):TERRAINHEIGHT + 100).
		lock steering to killHVelVec.
	}
	
	if mode = 2 //go to landing site
	{
		set autoThrottle to max(verticalSpeedP(-6), hoverPID(BODY:GEOPOSITIONOF(SHIP:POSITION):TERRAINHEIGHT + 30)).
		
		set desiredVelocityVec to VECTOREXCLUDE(SHIP:UP:VECTOR,landingSightPos:POSITION).
		local distance is desiredVelocityVec:MAG.

		set desiredVelocityVec to desiredVelocityVec:NORMALIZED.// *0.1.// * min(10,(distance * 0.1)^2).
		set desiredVelocityVec to desiredVelocityVec * 0.5.

		clearscreen.
		print "distance to landing site: " + distance.
		print "Target Horizontal Speed: " + desiredVelocityVec:MAG.
		set velocityToKill to desiredVelocityVec - VECTOREXCLUDE(SHIP:UP:VECTOR,SHIP:SRFPROGRADE:VECTOR).
		
		
		local adjustSpeedVec is SHIP:UP:VECTOR + (velocityToKill * -anglePID:update(TIME:SECONDS,velocityToKill:MAG)).
		lock steering to adjustSpeedVec.
	}
	
	
	if debug
	{
		if time:seconds > landingSiteReset + 60
		{
			areaSlopeSearch.
			set landingSiteReset to TIME:SECONDS.
		}
		
		SET HRetrogradeDraw TO VECDRAW(
		  V(0,0,0), //start
		  HRetrograde, //vector
		  RGB(0,0,1), //colour
		  "HRetrograde", //words
		  3.0, //scale
		  FALSE, //show
		  0.1 //width
		).

		SET velocityToKillDraw TO VECDRAW(
		  V(0,0,0), //start
		  velocityToKill, //vector
		  RGB(0,1,0), //colour
		  "velocityToKill", //words
		  3.0, //scale
		  True, //show
		  0.1 //width 
		).
		
		SET retrogradeDraw TO VECDRAW(
		  V(0,0,0), //start
		  SHIP:SRFRETROGRADE:VECTOR, //vector
		  RGB(1,0,0), //colour
		  "RGrade", //words
		  3.0, //scale
		  FALSE, //show
		  0.1 //width 
		).

		SET landingSiteMarker TO VECDRAW(
		  landingSightPos:POSITION, //start
		  SHIP:UP:VECTOR, //vector
		  RGB(0,0,1), //colour
		  "Landing Site", //words
		  3.0, //scale
		  TRUE, //show
		  0.1 //width 
		).

		SET desiredVelocityVecDraw TO VECDRAW(
		  V(0,0,0), //start
		  desiredVelocityVec, //vector
		  RGB(0,0.5,0.5), //colour
		  "desired Velocity", //words
		  3.0, //scale
		  TRUE, //show
		  0.1 //width 
		).

		SET currentVelocityVecDraw TO VECDRAW(
		  V(0,0,0), //start
		  VXCL(SHIP:UP:VECTOR,SHIP:SRFPROGRADE:VECTOR), //vector
		  RGB(0.5,0,0), //colour
		  "current velocity", //words
		  3.0, //scale
		  TRUE, //show
		  0.1 //width 
		).
		
	}
		
	wait 0.01.
	
}
clearvecdraws().
