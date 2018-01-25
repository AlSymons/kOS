lock HRetrograde to VECTOREXCLUDE(SHIP:UP:VECTOR,SHIP:SRFRETROGRADE:VECTOR):NORMALIZED.
lock killHVelVec to SHIP:UP:VECTOR + (HRetrograde * min(0.3,SHIP:GROUNDSPEED * 0.1)).

//lock STEERING to (SHIP:SRFRETROGRADE:VECTOR + (UP:VECTOR * MAX(2,MIN(1,(1/SHIP:GROUNDSPEED^2))))).	

runpath("0:/slopetools.ks").
runpath("0:/pidHover.ks").

local landingSightPos is V(0,0,0).

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
		{
			set landingSightPos to pos + (bearingDir * R(0,rot,0)):VECTOR * sampleRadius.
			if 1
			{
				SET landingSiteMarker TO VECDRAW(
				  landingSightPos, //start
				  SHIP:UP:VECTOR, //vector
				  RGB(0,0,1), //colour
				  "Landing Site", //words
				  3.0, //scale
				  TRUE, //show
				  0.1 //width 
				).
			}
		}


		set sampleRadius to sampleRadius + sampleWidth * 4.
		//set samplesPerRot to (sampleRadius / sampleWidth * ?.
		set rot to 0.
	}
	return minSlope.
}

//if areaSlopeSearch(0.02) < 0.02
//{
//	lock throttle to hoverPID(100).
//	abort off.
//	wait until abort.
//
//
//}
//else
	//print "can't find a flat enough landing site.".
local autoThrottle is 0.
lock throttle to autoThrottle.

local mode is 1.
local debug is false.
sas off.
abort off.
until abort
{
	if mode = 1 //loiter
	{
		set autoThrottle to hoverPID(BODY:GEOPOSITIONOF(SHIP:POSITION):TERRAINHEIGHT + 100).
		lock steering to killHVelVec.
	}
	
	if debug
	{
		SET HRetrogradeDraw TO VECDRAW(
		  V(0,0,0), //start
		  HRetrograde, //vector
		  RGB(0,0,1), //colour
		  "HRetrograde", //words
		  3.0, //scale
		  TRUE, //show
		  0.1 //width 
		).

		SET killHVelVecDraw TO VECDRAW(
		  V(0,0,0), //start
		  killHVelVec, //vector
		  RGB(0,1,0), //colour
		  "killHVelVec", //words
		  3.0, //scale
		  TRUE, //show
		  0.1 //width 
		).
		
		SET retrogradeDraw TO VECDRAW(
		  V(0,0,0), //start
		  SHIP:SRFRETROGRADE:VECTOR, //vector
		  RGB(1,0,0), //colour
		  "RGrade", //words
		  3.0, //scale
		  TRUE, //show
		  0.1 //width 
		).

	}
		
	wait 0.01.
	
}
clearvecdraws().
