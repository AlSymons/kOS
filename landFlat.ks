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

sas off.

areaSlopeSearch.
SteeringManager:RESETTODEFAULT().
SET SteeringManager:ROLLTORQUEFACTOR to 0.

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
		set autoThrottle to hoverPID(BODY:GEOPOSITIONOF(SHIP:POSITION):TERRAINHEIGHT + 100).
		lock steering to flyToLSVec.
	}
	
	
	if debug
	{
		SET HRetrogradeDraw TO VECDRAW(
		  V(0,0,0), //start
		  HRetrograde, //vector
		  RGB(0,0,1), //colour
		  "HRetrograde", //words
		  3.0, //scale
		  FALSE, //show
		  0.1 //width 
		).

		SET killHVelVecDraw TO VECDRAW(
		  V(0,0,0), //start
		  killHVelVec, //vector
		  RGB(0,1,0), //colour
		  "killHVelVec", //words
		  3.0, //scale
		  FALSE, //show
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

		
	}
		
	wait 0.01.
	
}
clearvecdraws().
